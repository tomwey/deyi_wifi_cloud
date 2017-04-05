class Merchant < ActiveRecord::Base
  validates :name, :address, presence: true
  
  belongs_to :owner, class_name: 'User', foreign_key: :owner_id
  
  before_create :generate_unique_id
  def generate_unique_id
    begin
      n = rand(10)
      if n == 0
        n = 8
      end
      self.merch_id = (n.to_s + SecureRandom.random_number.to_s[2..6]).to_i
    end while self.class.exists?(:merch_id => merch_id)
  end
end
