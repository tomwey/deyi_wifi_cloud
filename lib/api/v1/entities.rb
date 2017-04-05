module API
  module V1
    module Entities
      class Base < Grape::Entity
        format_with(:null) { |v| v.blank? ? "" : v }
        format_with(:chinese_date) { |v| v.blank? ? "" : v.strftime('%Y-%m-%d') }
        format_with(:chinese_datetime) { |v| v.blank? ? "" : v.strftime('%Y-%m-%d %H:%M:%S') }
        format_with(:chinese_time) { |v| v.blank? ? "" : v.strftime('%H:%M') }
        format_with(:money_format) { |v| v.blank? ? 0 : ('%.2f' % v).to_f }
        expose :id
        # expose :created_at, format_with: :chinese_datetime
      end # end Base
      
      # 版本信息
      class AppVersion < Base
        expose :version
        expose :app_download_url do |model, opts|
          if model.file
            model.file.url
          else
            ''
          end
        end
        expose :must_upgrade
        expose :link do |model, opts|
          model.version_summary_url
        end
      end
      
      # 收货地址
      class Shipment < Base
        expose :name
        expose :hack_mobile, as: :mobile
        expose :address
        expose :is_current do |model, opts|
          model.id == model.user.try(:current_shipment_id)
        end
      end
      
      # 用户基本信息
      class UserProfile < Base
        expose :uid, format_with: :null
        expose :mobile, format_with: :null
        expose :nickname do |model, opts|
          model.nickname || model.hack_mobile
        end
        expose :avatar do |model, opts|
          model.avatar.blank? ? "" : model.avatar_url(:large)
        end
        # expose :nb_code, as: :invite_code
        # expose :bean
        # expose :balance
        # expose :current_shipment, as: :shipment, using: API::V1::Entities::Shipment, if: proc { |u| u.current_shipment_id.present? }
        # # expose :wifi_length
        # expose :qrcode_url
      end
      
      # 用户详情
      class User < UserProfile
        expose :private_token, as: :token, format_with: :null
      end
      
      # 电视频道节点
      class Node < Base
        unexpose :id
        expose :nid, as: :id, format_with: :null
        expose :name, format_with: :null
      end
      
      # 电视频道
      class Channel < Base
        expose :chn_id, as: :id
        expose :name, :live_url
        expose :view_count
        # expose :intro, format_with: :null
        expose :title do |model, opts|
          model.current_playlist.try(:name) || '该频道正在播放的节目名称'
        end
        expose :image do |model, opts|
          # model.image.blank? ? '' : model.image.url(:thumb)
          model.real_image
        end
        # expose :real_image, as: :image
        expose :online, as: :living
        expose :bili_topic, as: :topic
      end
      
      # 我的收藏
      class Favorite < Base
        expose :media_id do |model, opts|
          model.favoriteable.media_id
        end
        expose :media_type do |model, opts|
          model.favoriteable_type == 'Channel' ? 1 : 2
        end
        expose :name do |model, opts|
          model.favoriteable.try(:name) || ''
        end
        expose :view_count do |model, opts|
          model.favoriteable.try(:view_count)
        end
        expose :live_url do |model, opts|
          model.favoriteable.live_url
        end
        expose :image do |model, opts|
          # model.favoriteable.image.blank? ? '' : model.favoriteable.image.url(:thumb)
          model.favoriteable.real_image
        end
        expose :topic do |model, opts|
          model.favoriteable.bili_topic
        end
        expose :living do |model, opts|
          model.favoriteable.online
        end
        expose :created_at, as: :time, format_with: :chinese_datetime
      end
      
      # 预约
      class Appointment < Base
        expose :playlist_name do |model, opts|
          model.playlist.try(:name) || ''
        end
        expose :channel_name do |model, opts|
          if model.playlist.channel
            model.playlist.channel.try(:name) || ''
          else
            ''
          end
        end
        expose :start_time do |model, opts|
          model.playlist.started_at.strftime('%Y-%m-%d %H:%M')
        end
        expose :end_time do |model, opts|
          if model.playlist.ended_at
            model.playlist.ended_at.strftime('%Y-%m-%d %H:%M')
          else
            ''
          end
        end
      end
      
      # 频道节目
      class Playlist < Base
        expose :pl_id, as: :id
        expose :name
        expose :started_at, as: :start_time, format_with: :chinese_time
        expose :ended_at, as: :end_time, format_with: :chinese_time
        expose :vod_url, as: :playback_url, format_with: :null
        expose :appointed do |model, opts|
          if opts
            if opts[:user]
              user = opts[:user]
              user.appointed?(model)
            else
              false
            end
          else
            false
          end
        end
        expose :state do |model,opts|
          model.state
        end
        
      end
      
      class ChannelDetail < Channel
        unexpose :title
        expose :favorited do |model, opts|
          opts = opts[:opts]
          if opts
            user = opts[:user]
            if user
              user.favorited?(model)
            else
              false
            end
          else
            false
          end
        end
        # Destinations::DestinationResponseEntity.represent trip.destinations, options.merge(custom_field_name: custom_field_value)
        # expose :today_playlists, using: API::V1::Entities::Playlist do |model, opts|
        #   model.playlists_for_offset(0)
        # end
        expose :today_playlists do |model, opts|
          time = Time.zone.now
          user = if opts
            if opts[:opts]
              opts[:opts][:user]
            else
              nil
            end
          else
            nil
          end
          API::V1::Entities::Playlist.represent model.playlists_for_offset(0), options.merge(time: time, user: user)
        end
      end
      
      # 弹幕
      class Bilibili < Base
        expose :content
        expose :author_id do |model, opts|
          model.user.uid
        end
        expose :author_name do |model, opts|
          model.user.nickname || model.user.hack_mobile
        end
        expose :author_avatar do |model, opts|
          model.user.avatar.blank? ? "" : model.user.avatar_url(:large)
        end
        expose :created_at, as: :time, format_with: :chinese_datetime
      end
      
      # 直播
      class LiveStream < Base
        expose :sid, as: :id
        expose :name, :live_url
        expose :view_count
        # expose :intro, format_with: :null
        expose :image do |model, opts|
          # model.image.blank? ? '' : model.image.url(:thumb)
          model.real_image
        end
        expose :online, as: :living
        expose :bili_topic, as: :topic
      end
      
      class LiveStreamDetail < LiveStream
        expose :favorited do |model, opts|
          opts = opts[:opts]
          if opts
            user = opts[:user]
            if user
              user.favorited?(model)
            else
              false
            end
          else
            false
          end
        end
      end
      
      # 视频
      class Video < Base
        expose :vid, as: :id
        expose :name, :live_url
        expose :view_count
        # expose :intro, format_with: :null
        expose :image do |model, opts|
          # model.image.blank? ? '' : model.image.url(:thumb)
          model.real_image
        end
        # expose :online, as: :living
        expose :bili_topic, as: :topic
      end
      
      class VideoDetail < Video
        expose :favorited do |model, opts|
          opts = opts[:opts]
          if opts
            user = opts[:user]
            if user
              user.favorited?(model)
            else
              false
            end
          else
            false
          end
        end
      end
      
      # 订单
      class Order < Base
        expose :order_no
        expose :product_title, as: :title
        expose :product_small_image, as: :image
        expose :quantity
        expose :product_price, as: :price
        expose :total_fee
        expose :state_info, as: :state
        expose :created_at, as: :time, format_with: :chinese_datetime
      end
      
      # 消息
      class Message < Base
        expose :title do |model, opts|
          model.title || '系统公告'
        end#, format_with: :null
        expose :content, as: :body
        expose :created_at, format_with: :chinese_datetime
      end
    
    end
  end
end
