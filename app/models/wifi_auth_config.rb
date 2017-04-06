class WifiAuthConfig < ActiveRecord::Base
  belongs_to :user
  
  validates :wifi_length, :user_id, :auth_click_button, presence: true
  validates :countdown, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 99, only_integer: true }
  
  def self.wifi_lengths
    [['0.5小时', 30], ['1小时', 60],['2小时', 120],['4小时', 240],['6小时', 360],['12小时', 720],['1天', 1440]]
  end
  
  def allow_websites
    self[:whitelist_websites].join('\n')
  end
  
  def allow_websites=(val)
    if val.blank?
      self[:whitelist_websites] = []
    else
      self[:whitelist_websites] = val.split('\n')
    end
  end
  
  def allow_macs
    self[:whitelist_macs].join('\n')
  end
  
  def allow_macs=(val)
    if val.blank?
      self[:whitelist_macs] = []
    else
      self[:whitelist_macs] = val.split('\n')
    end
  end
  
  def not_allow_macs
    self[:banned_macs].join('\n')
  end
  
  def not_allow_macs=(val)
    if val.blank?
      self[:banned_macs] = []
    else
      self[:banned_macs] = val.split('\n')
    end
  end
  
end
