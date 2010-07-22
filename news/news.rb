require 'digest/sha1'
require 'json'

require 'sinatra'

ROOT_DIR = File.expand_path(File.dirname(__FILE__))

def make_news_items(dir)
  items = []
  
  File.readlines(dir + '/data/lipsum.txt').each_with_index do |line, i|
    t        = Time.now.to_i - rand(7200) - 3600 * i
    hashfunc = Digest::SHA1.new
    
    line.rstrip!
    
    hashfunc.update(line + t.to_s)
    
    item = {
      :text => line,
      :timestamp => t,
      :id => hashfunc.hexdigest
    }
    
    items << item
  end
  
  items
end

def partition_news_items(items)
  partition_length = 0
  
  items.inject([[]]) do |memo, item|
    if partition_length < 1
      partition_length = rand(3)
      memo << [] if partition_length == 0
      memo << []
    else
      partition_length -= 1
    end
    
    memo.last << item
    
    memo
  end
end

def make_duplicates(item_groups)
  duplicates = []
  
  item_groups.each do |group|
    group.each do |item|
      next unless rand(10) == 0
      
      dupe = item.clone
      
      if rand(2) == 0
        dupe[:update] = true
        dupe[:text] += " Updated!"
        dupe[:timestamp] += (rand(3600) * 3)
      end
      
      duplicates << {
        :duplicate => dupe,
        :index => group.length + 2 + rand(5)
      }
    end
  end
  
  duplicates
end

def insert_duplicates!(groups, duplicates)
  duplicates.each do |dupe|
    group = groups[dupe[:index]]
    (group ? group : items.last) << dupe[:duplicate]
  end
end

groups = partition_news_items(make_news_items(ROOT_DIR))
dupes  = make_duplicates(groups)
insert_duplicates!(groups, dupes)

NEWS_ITEMS = groups
$ticker    = Time.now
$counter   = groups.length - 1

get '/news.json' do
  t = Time.now
  
  if t - 5 > $ticker
    $ticker = t
    $counter -= 1
  end
  
  callback = params[:callback]
  
  begin
    content = NEWS_ITEMS[$counter].to_json
  rescue
    content = [].to_json
  end
  
  if callback
    content_type 'application/javascript', :charset => "utf-8"
    callback + "(" + content + ");"
  else
    content_type 'application/json', :charset => "utf-8"
    content
  end
end
