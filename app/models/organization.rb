class Organization < ActiveRecord::Base
  has_many :members, :through => :memberships
end
