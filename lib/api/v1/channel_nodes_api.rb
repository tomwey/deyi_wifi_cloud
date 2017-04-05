module API
  module V1
    class ChannelNodesAPI < Grape::API
      
      helpers API::SharedParams
      
      resource :channel_nodes, desc: '电视频道节点接口' do
        desc "获取所有的电视频道目录类别"
        get do
          @nodes = Node.opened.sorted
          
          render_json(@nodes, API::V1::Entities::Node)
        end # end get list
      end # end resource
      
    end
  end
end