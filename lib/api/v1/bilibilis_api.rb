module API
  module V1
    class BilibilisAPI < Grape::API
      
      helpers API::SharedParams
      
      resource :bilibilis, desc: '弹幕相关接口' do
        desc "获取一部分最新的弹幕"
        params do
          requires :media_type, type: Integer, desc: "值为1或2，1表示电视，2表示直播"
          requires :media_id,   type: Integer, desc: "频道id或直播id"
          optional :size, type: Integer, desc: "获取记录的条数，默认为30条"
        end
        get :latest do
          total = params[:size] || 30
          # type = params[:media_type] == 1 ? 'Channel' : 'LiveStream'
          
          if params[:media_type] == 1
            ownerable = Channel.find_by(chn_id: params[:media_id])
          elsif params[:media_type] == 2
            ownerable = LiveStream.find_by(sid: params[:media_id])
          elsif params[:media_type] == 3
            ownerable = Video.find_by(vid: params[:media_id])
          else
            ownerable = nil
          end
          
          if ownerable.blank?
            return render_error(4004, '未找到数据')
          end
          
          @bibis = Bilibili.where(bilibiliable_type: ownerable.class, bilibiliable_id: ownerable.id).order('id desc').limit(total.to_i)
          render_json(@bibis, API::V1::Entities::Bilibili)
        end # end get
        
        desc "分页获取某个弹幕消息"
        params do
          requires :media_type, type: Integer, desc: "值为1或2，1表示电视，2表示直播"
          requires :media_id,   type: Integer, desc: "频道id或直播id"
          use :pagination
        end
        get do
          # type = params[:media_type] == 1 ? 'Channel' : 'LiveStream'
          
          # if params[:media_type] == 1
          #   ownerable = Channel.find_by(chn_id: params[:media_id])
          # else
          #   ownerable = LiveStream.find_by(sid: params[:media_id])
          # end
          if params[:media_type] == 1
            ownerable = Channel.find_by(chn_id: params[:media_id])
          elsif params[:media_type] == 2
            ownerable = LiveStream.find_by(sid: params[:media_id])
          elsif params[:media_type] == 3
            ownerable = Video.find_by(vid: params[:media_id])
          else
            ownerable = nil
          end
          
          if ownerable.blank?
            return render_error(4004, '未找到数据')
          end
          
          @bibis = Bilibili.where(bilibiliable_type: ownerable.class, bilibiliable_id: ownerable.id).order('id desc')
          @bibis = @bibis.paginate(page: params[:page], per_page: page_size) if params[:page]
          render_json(@bibis, API::V1::Entities::Bilibili)
        end # end get

        desc "发弹幕消息"
        params do
          requires :content,   type: String, desc: "弹幕内容，255个字符长度"
          requires :media_type, type: Integer, desc: "值为1或2，1表示电视，2表示直播"
          requires :media_id,   type: Integer, desc: "频道id或直播id"
          requires :token,     type: String, desc: "用户认证Token"
        end
        post :send do
          user = authenticate!
          
          # if params[:media_type] == 1
          #   ownerable = Channel.find_by(chn_id: params[:media_id])
          # else
          #   ownerable = LiveStream.find_by(sid: params[:media_id])
          # end
          if params[:media_type] == 1
            ownerable = Channel.find_by(chn_id: params[:media_id])
          elsif params[:media_type] == 2
            ownerable = LiveStream.find_by(sid: params[:media_id])
          elsif params[:media_type] == 3
            ownerable = Video.find_by(vid: params[:media_id])
          else
            ownerable = nil
          end
          
          if ownerable.blank?
            return render_error(4004, '未找到该频道或直播')
          end
          
          @bili = Bilibili.new(content: params[:content], user_id: user.id, bilibiliable: ownerable)
  
          if @bili.save
            render_json(@bili, API::V1::Entities::Bilibili)
          else
            render_error(7001, @bili.errors.full_messages.join(','))
          end
  
        end # end post
      end # end resource
      
    end
  end
end