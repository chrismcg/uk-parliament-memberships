class Organization < ActiveRecord::Base
  has_many :memberships, :dependent => :destroy
  has_many :members, :through => :memberships

  def full_name
    "#{name} #{section}"
  end
end
