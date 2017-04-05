module API
  module V1
    class AppointmentsAPI < Grape::API
      
      helpers API::SharedParams
      
      resource :appointments, desc: '预约相关接口' do
        desc "我的预约"
        params do
          requires :token, type: String, desc: "用户Token"
          use :pagination
        end
        get do
          user = authenticate!
          
          @appointments = Appointment.where(user_id: user.id).order('id desc')
          
          if params[:page]
            @appointments = @appointments.paginate page: params[:page], per_page: page_size
          end
          
          render_json(@appointments, API::V1::Entities::Appointment)
        end # end get
        desc "预约节目"
        params do
          requires :token, type: String, desc: "用户Token"
          requires :id, type: Integer, desc: "节目ID"
        end
        post :create do
          user = authenticate!
          
          @playlist = Playlist.find_by(pl_id: params[:id])
          if @playlist.blank?
            return render_error(4004, '该节目不存在')
          end
          
          if user.appointed?(@playlist)
            return render_error(6001, '您已经预约过了')
          end
          
          if user.appoint!(@playlist)
            render_json_no_data
          else
            render_error(6002, '预约失败')
          end
        end # end post
        
        desc "取消预约节目"
        params do
          requires :token, type: String, desc: "用户Token"
          requires :id, type: Integer, desc: "节目ID"
        end
        post :cancel do
          user = authenticate!
          
          @playlist = Playlist.find_by(pl_id: params[:id])
          if @playlist.blank?
            return render_error(4004, '该节目不存在')
          end
          
          unless user.appointed?(@playlist)
            return render_error(6001, '您还未预约，不能取消')
          end
          
          if user.cancel_appoint!(@playlist)
            render_json_no_data
          else
            render_error(6002, '取消预约失败')
          end
        end # end post
        
        desc "删除预约"
        params do
          requires :token, type: String, desc: "用户Token"
          requires :ids, type: String, desc: "预约ID，如果有多个ID,用英文逗号分隔"
        end
        post :delete do
          user = authenticate!
          
          ids = params[:ids].split(',')
          
          Appointment.where(user_id: user.id, id: ids).delete_all
          
          render_json_no_data
        end # end post
      end # end resource
      
    end
  end
end