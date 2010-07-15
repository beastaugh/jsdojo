require 'digest/sha1'
require 'json'

require 'sinatra'

START_TIME = Time.now
$ticker    = START_TIME
$counter   = 0

dir = File.expand_path(File.dirname(__FILE__))

news_items = []
raw_items  = File.read(dir + '/data/lipsum.txt').lines.to_a

raw_items.each_with_index do |line, i|
  t        = Time.now.to_i - rand(7200) - 3600 * i
  hashfunc = Digest::SHA1.new
  
  line.rstrip!
  
  hashfunc.update(line + t.to_s)
  
  item = {
    :text => line,
    :timestamp => t,
    :id => hashfunc.hexdigest
  }
  
  news_items << item
end

partion_length = 0
duplicates = []

news_item_groups = news_items.reverse.inject([[]]) {|memo, item|
  if partion_length < 1
    partion_length = rand(3)
    memo << [] if partion_length == 0
    memo << []
  else
    partion_length -= 1
  end
  
  # Duplicate, 'updated' item
  if rand(10) == 0
    dupe = item.clone
    
    if rand(2) == 0
      dupe[:update] = true
      dupe[:text] += " Updated!"
      dupe[:timestamp] += (rand(3600) * 3)
    end
    
    duplicates << {
      :obj => dupe,
      :index => memo.length + 2 + rand(5)
    }
  end
  
  memo.last << item
  memo
}

duplicates.each do |obj|
  group = news_item_groups[obj[:index]]
  (group ? group : news_item_groups.last) << obj[:obj]
end

NEWS_ITEMS = news_item_groups

$counter = NEWS_ITEMS.length - 1

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
