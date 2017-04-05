module API
  module V1
    class FavoritesAPI < Grape::API
      
      helpers API::SharedParams
      
      resource :favorites, desc: '收藏相关接口' do
        desc "我的收藏"
        params do
          requires :token, type: String,  desc: '用户Token'
          optional :type,  type: Integer, desc: '收藏的类型，值为1或者2，1表示电视，2表示直播，如果不传该参数默认为1'
          use :pagination
        end
        get do
          user = authenticate!
          
          type = (params[:type] || 1).to_i
          
          unless %w(1 2).include?(type.to_s)
            return render_error(-1, '不正确的type参数值')
          end
          
          if type == 1
            klass = 'Channel'
          elsif type == 2
            klass = 'LiveStream'
          else
            return render_error(-2, '非法操作')
          end
          
          @favorites = Favorite.where(user_id: user.id, favoriteable_type: klass).order('id desc')
          
          if params[:page]
            @favorites = @favorites.paginate page: params[:page], per_page: page_size
          end
          
          render_json(@favorites, API::V1::Entities::Favorite)
        end # end get
        
        desc "删除收藏"
        params do
          requires :token, type: String, desc: '用户Token'
          requires :ids,   type: String, desc: '需要删除的收藏id，支持多个删除，多个id之间用英文逗号分隔(,)'
        end
        post :delete do
          user = authenticate!
          
          ids = params[:ids].split(',')
          
          Favorite.where(user_id: user.id, id: ids).delete_all
          render_json_no_data
        end # end post delete
      end # end resource
      
    end
  end
end