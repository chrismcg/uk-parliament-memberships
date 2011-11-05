class Member < ActiveRecord::Base
  has_many :organizations, :through => :memberships
end
