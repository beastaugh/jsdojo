require 'digest/sha1'
require 'json'

require 'sinatra'

START_TIME = Time.now
$ticker    = START_TIME
$counter   = 0

news_items = []

File.read('data/lipsum.txt').lines.to_a.each_with_index do |line, i|
  t        = Time.now.to_i - rand(7200) - 3600 * i
  hashfunc = Digest::SHA1.new
  
  line.rstrip!
  
  hashfunc.update(line + t.to_s)
  
  item = {
    :text => line,
    :timestamp => t,
    :id => hashfunc.hexdigest
  }
  
  # item[:update] = true if update?
  
  news_items << item
end

partion_length = 0

NEWS_ITEMS = news_items.reverse.inject([[]]) {|memo, item|
  if partion_length < 1
    partion_length = rand(3)
    memo << [] if partion_length == 0
    memo << []
  else
    partion_length -= 1
  end
  
  memo.last << item
  memo
}

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
  
  content_type 'application/javascript', :charset => "utf-8"
  
  callback ? callback + "(" + content + ");" : content
end
