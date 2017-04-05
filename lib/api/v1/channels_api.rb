module API
  module V1
    class ChannelsAPI < Grape::API
      
      helpers API::SharedParams
      
      resource :channels, desc: '电视频道接口' do
        desc "获取频道列表"
        params do 
          optional :node_id, type: Integer, desc: '频道节点ID，如果不传该参数，默认会获取所有的频道' 
          use :pagination
        end
        get do
          
          if params[:node_id]
            @node = Node.find_by(nid: params[:node_id])
            if @node.blank?
              return render_error(4004, '不存在的频道类别')
            end
            @channels = @node.channels.opened.sorted
          else
            @channels = Channel.opened.sorted
          end
          
          if params[:page]
            @channels = @channels.paginate page: params[:page], per_page: page_size
          end
          
          render_json(@channels, API::V1::Entities::Channel)
        end # end get list
        
        desc "获取频道详情"
        params do
          requires :id, type: Integer, desc: '频道ID'
          optional :token, type: String, desc: '用户Token'
        end
        get '/:id' do
          @channel = Channel.find_by(chn_id: params[:id])
          
          if @channel.blank?
            return render_error(4004, '该频道不存在')
          end
          
          unless @channel.opened
            return render_error(2001, '该频道已关闭')
          end
          
          render_json(@channel, API::V1::Entities::ChannelDetail, { user: User.find_by(private_token: params[:token]) })
        end # end get
        
        # 获取节目数据
        # http://api.cntv.cn/epg/epginfo?serviceId=cbox&c=cctv5&d=20170106
        desc "获取某个频道的节目列表"
        params do
          requires :channel_id, type: Integer, desc: '频道ID'
          optional :offset, type: Integer, desc: '时间偏移，单位为天，不传该值或传0表示取今天的节目单，否则就相对于今天的进行偏移，如果为正，表示未来时间，否则表示过去时间'
        end
        get '/:channel_id/playlists' do
          @channel = Channel.find_by(chn_id: params[:channel_id])
          
          if @channel.blank?
            return render_error(4004, '该频道不存在')
          end
          
          unless @channel.opened
            return render_error(2001, '该频道已关闭')
          end
          
          offset = (params[:offset] || 0).to_i
          @playlists = @channel.playlists_for_offset(offset)
          
          render_json(@playlists, API::V1::Entities::Playlist)
        end # end get 
        
      end # end resource
      
      resource :channel, desc: '频道收藏相关接口' do
        desc "收藏频道"
        params do
          requires :id, type: Integer, desc: '频道ID'
          requires :token, type: String, desc: '用户Token'
        end
        post :favorite do
          user = authenticate!
          
          channel = Channel.find_by(chn_id: params[:id])
          if channel.blank?
            return render_error(4004, '该频道不存在')
          end
          
          unless channel.opened
            return render_error(3001, '该频道未开放')
          end
          
          if user.favorited?(channel)
            return render_error(5001, '您已经收藏过了')
          end
          
          if user.favorite!(channel)
            render_json_no_data
          else
            render_error(5002, '收藏失败')
          end
        end # end post
        
        desc "取消收藏频道"
        params do
          requires :id, type: Integer, desc: '频道ID'
          requires :token, type: String, desc: '用户Token'
        end
        post :unfavorite do
          user = authenticate!
          
          channel = Channel.find_by(chn_id: params[:id])
          if channel.blank?
            return render_error(4004, '该频道不存在')
          end
          
          unless channel.opened
            return render_error(3001, '该频道未开放')
          end
          
          unless user.favorited?(channel)
            return render_error(5001, '您还未收藏，不能取消')
          end
          
          if user.unfavorite!(channel)
            render_json_no_data
          else
            render_error(5002, '收藏失败')
          end
        end # end post
        
        desc "上传频道直播截图"
        params do
          requires :id, type: Integer, desc: '频道ID'
          requires :image, type: Rack::Multipart::UploadedFile, desc: "截图图片"
        end
        post :upframe do
          channel = Channel.find_by(chn_id: params[:id])
          if channel.blank?
            return render_error(4004, '该频道不存在')
          end
          
          unless channel.opened
            return render_error(3001, '该频道未开放')
          end
          
          temp_ss = channel.temp_screenshot
          if temp_ss.blank?
            temp_ss = TempScreenshot.create!(image: params[:image], upload_at: Time.zone.now, channel_id: channel.id)
          else
            if params[:image].blank?
              return render_error(-1, '图片不正确')
            else
              temp_ss.image = params[:image]
              temp_ss.upload_at = Time.zone.now
              temp_ss.save!
            end
          end
          
          render_json_no_data
          
        end # end post
        
      end # end resource
      
    end
  end
end