class CreateWifiAuthConfigs < ActiveRecord::Migration
  def change
    create_table :wifi_auth_configs do |t|
      t.integer :auth_type, default: 1
      t.integer :wifi_length, default: 60 # 单位为分钟
      t.boolean :auto_jump, default: false # 微信认证自动跳转到微信
      t.integer :countdown, default: 5     # 倒计时
      t.string :auth_click_button, default: '点这里免费上网' # 倒计时结束后页面显示的提示消息，1~6个字
      t.boolean :https_auth_support, default: true # 访问https网站是否也能换起认证页面
      t.string :whitelist_websites, array: true, default: []  # 允许直接访问的域名
      t.string :whitelist_macs, array: true, default: []      # 无需认证的设备
      t.string :banned_macs, array: true, default: []         # 禁止上网的设备
      t.integer :user_id

      t.timestamps null: false
    end
    add_index :wifi_auth_configs, :user_id
  end
end
