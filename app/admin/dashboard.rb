ActiveAdmin.register_page "Dashboard" do

  menu priority: 0, label: proc{ I18n.t("active_admin.dashboard") }

  content title: '最新数据统计' do
    
    # 最新用户
    columns do
      column do
        panel "最新用户" do
          table_for User.order('id desc').limit(20) do
            column :id
            column :avatar, sortable: false do |u|
              u.avatar.blank? ? "" : image_tag(u.avatar.url(:normal))
            end
            column :uid, sortable: false
            column :nickname, sortable: false
            column :mobile, sortable: false
            column 'Token', sortable: false do |u|
              u.private_token
            end
            column :verified, sortable: false
            column :created_at
          end
        end
      end # end 
    end
    
  end # content
end
