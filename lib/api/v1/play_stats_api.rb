module API
  module V1
    class PlayStatsAPI < Grape::API
      
      helpers API::SharedParams
      
      resource :play, desc: '播放统计接口' do
        desc "生成播放统计"
        params do
          requires :playable_type, type: Integer, desc: '媒体类型，1表示电视，2表示直播，3表示短视频点播'
          requires :playable_id,   type: String,  desc: '媒体ID'
          use :device_info
        end
        post :stat do
          PlayStat.create!(playable_type: params[:playable_type],
                           playable_id: params[:playable_id],
                           udid: params[:udid],
                           device_model: params[:m],
                           os_version: params[:osv],
                           app_version: params[:bv],
                           screen_size: params[:sr],
                           platform: params[:pl],
                           lang_country: params[:cl],
                           network_type: params[:nt],
                           is_broken: params[:bb] == 0 ? false : true)
          render_json_no_data
        end # end post
      end # end resource
      
    end
  end
end