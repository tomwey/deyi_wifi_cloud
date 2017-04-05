class SendBiliJob < ActiveJob::Base
  queue_as :messages

  def perform(bili_id)
    @bili = Bilibili.find_by(id: bili_id)
    if @bili
      Yunba.send(@bili.content, @bili.bilibiliable.bili_topic)
    end
  end
  
end
