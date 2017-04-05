class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :authentication_keys => [:mobile]
         
  mount_uploader :avatar, AvatarUploader
  
  attr_accessor :code
  
  validates :mobile, presence: true
  validates :mobile, format: { with: /\A1[3|4|5|8|7][0-9]\d{8}\z/, message: "请输入11位正确手机号" }, length: { is: 11 },:uniqueness => true
  
  before_create :generate_o_id_and_private_token
  def generate_uid_and_private_token
    begin
      n = rand(10)
      if n == 0
        n = 8
      end
      self.uid = (n.to_s + SecureRandom.random_number.to_s[2..8]).to_i
    end while self.class.exists?(:uid => uid)
    self.private_token = SecureRandom.uuid.gsub('-', '')
  end
  
  ### 重写devise方法
  def email_required?
    false
  end
  
  def email_changed?
    false
  end
end
