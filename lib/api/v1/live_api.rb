module API
  module V1
    class LiveAPI < Grape::API
      
      helpers API::SharedParams
      
      resource :live, desc: '直播相关接口' do
        desc "获取直播列表"
        params do
          optional :filter, type: String, desc: '数据过滤用，保留参数，做数据过滤用' 
          use :pagination
        end
        get :list do
          @streams = LiveStream.opened.sorted
          
          if params[:page]
            @streams = @streams.paginate page: params[:page], per_page: page_size
          end
          
          render_json(@streams, API::V1::Entities::LiveStream)
        end # end get list
        
        desc "获取直播详情"
        params do
          requires :id,   type: Integer, desc: '直播ID'
          optional :token, type: String, desc: '用户Token'
        end
        get '/:id' do
          live = LiveStream.find_by(sid: params[:id])
          if live.blank?
            return render_error(4004, '该直播不存在')
          end
          
          unless live.opened
            return render_error(3001, '该直播未开放')
          end
          
          render_json(live, API::V1::Entities::LiveStreamDetail, { user: User.find_by(private_token: params[:token]) })
        end # end get
        
        desc "收藏直播"
        params do
          requires :id, type: Integer, desc: '直播ID'
          requires :token, type: String, desc: '用户Token'
        end
        post :favorite do
          user = authenticate!
          
          live = LiveStream.find_by(sid: params[:id])
          if live.blank?
            return render_error(4004, '该直播不存在')
          end
          
          unless live.opened
            return render_error(3001, '该直播未开放')
          end
          
          if user.favorited?(live)
            return render_error(5001, '您已经收藏过了')
          end
          
          if user.favorite!(live)
            render_json_no_data
          else
            render_error(5002, '收藏失败')
          end
        end # end post
        
        desc "取消收藏直播"
        params do
          requires :id, type: Integer, desc: '直播ID'
          requires :token, type: String, desc: '用户Token'
        end
        post :unfavorite do
          user = authenticate!
          
          live = LiveStream.find_by(sid: params[:id])
          if live.blank?
            return render_error(4004, '该直播不存在')
          end
          
          unless live.opened
            return render_error(3001, '该直播未开放')
          end
          
          unless user.favorited?(live)
            return render_error(5001, '您还未收藏，不能取消')
          end
          
          if user.unfavorite!(live)
            render_json_no_data
          else
            render_error(5002, '取消收藏失败')
          end
        end # end post
      end # end resource
      
    end
  end
end