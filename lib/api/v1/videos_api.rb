module API
  module V1
    class VideosAPI < Grape::API
      
      helpers API::SharedParams
      
      resource :videos, desc: '点播相关接口' do
        desc "获取点播列表"
        params do
          optional :filter, type: String, desc: '数据过滤用，保留参数，做数据过滤用' 
          use :pagination
        end
        get :list do
          @streams = Video.opened.sorted
          
          if params[:page]
            @streams = @streams.paginate page: params[:page], per_page: page_size
          end
          
          render_json(@streams, API::V1::Entities::Video)
        end # end get list
        
        desc "获取点播详情"
        params do
          requires :id,   type: Integer, desc: '点播ID'
          optional :token, type: String, desc: '用户Token'
        end
        get '/:id' do
          live = Video.find_by(vid: params[:id])
          if live.blank?
            return render_error(4004, '该视频不存在')
          end
          
          unless live.opened
            return render_error(3001, '该视频未开放')
          end
          
          render_json(live, API::V1::Entities::VideoDetail, { user: User.find_by(private_token: params[:token]) })
        end # end get
        
        desc "收藏视频"
        params do
          requires :id, type: Integer, desc: '视频ID'
          requires :token, type: String, desc: '用户Token'
        end
        post :favorite do
          user = authenticate!
          
          live = Video.find_by(vid: params[:id])
          if live.blank?
            return render_error(4004, '该视频不存在')
          end
          
          unless live.opened
            return render_error(3001, '该视频未开放')
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
        
        desc "取消收藏视频"
        params do
          requires :id, type: Integer, desc: '视频ID'
          requires :token, type: String, desc: '用户Token'
        end
        post :unfavorite do
          user = authenticate!
          
          live = Video.find_by(vid: params[:id])
          if live.blank?
            return render_error(4004, '该视频不存在')
          end
          
          unless live.opened
            return render_error(3001, '该视频未开放')
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