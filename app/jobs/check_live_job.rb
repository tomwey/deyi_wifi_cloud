require 'rest-client'
require 'digest'

class CheckLiveJob < ActiveJob::Base
  queue_as :scheduled_jobs
  
  def perform(*args)
    
    puts 'start ...'
    
    LiveStream.opened.each do |ls|
      room_id = ls.source_room_id
      
      if not room_id.blank?
        time = Time.now.to_i
      
        auth = Digest::MD5.hexdigest("lapi/live/thirdPart/getPlay/#{room_id}?aid=hbtv&time=#{time}rRrJQ10J8cnGmAz2")
      
        url = "http://coapi.douyucdn.cn/lapi/live/thirdPart/getPlay/#{room_id}?aid=hbtv&time=#{time}&auth=#{auth}"
        # puts url
      
        RestClient.get url, { aid: 'hbtv', time: time, auth: auth, accept: :json } do |resp|
          result = JSON.parse(resp)
          # puts result
          if result["error"] == 0
            # puts '直播中'
            # 直播中
            ls.live_url = result["data"]["live_url"]
            ls.online = true
            ls.save!
          elsif result["error"] == 1010
            # puts '未直播'
            # 未直播
            ls.online = false
            ls.save!
          end
          # puts JSON.parse(resp)["error"]
          # puts '---------------------------------------------'
        end
      end
     
    end
  end
  
end