require 'rest-client'
class Yunba
  def self.send(content, topic)
    # 5845716ab09557a45c142271
    # sec-YgxrKpSheYH7wyEvDwwzSbnnzhu9U31SdCAZGb5VRti2wUjq
    params = {
        "method" => 'publish', 
        "appkey" => '5845716ab09557a45c142271', 
        "seckey" => 'sec-YgxrKpSheYH7wyEvDwwzSbnnzhu9U31SdCAZGb5VRti2wUjq', 
        "topic"  => topic, 
        "msg" => content
    }
    RestClient.post('http://rest.yunba.io:8080', params.to_json, content_type: :json) { |resp, req, result|
      # puts resp
    }
  end
end