class Member < ActiveRecord::Base
  has_many :memberships
  has_many :organizations, :through => :memberships

  def committees
    organizations.select { |o| o.section == "Committee" }
  end

  def groups
    organizations.select { |o| o.section == "Group" }
  end
end
