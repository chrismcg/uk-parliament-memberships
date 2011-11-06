class AddParliamentIdFields < ActiveRecord::Migration
  def up
    add_column :members, :parliament_id, :integer
    add_column :organizations, :parliament_id, :integer
  end

  def down
    remove_column :organizations, :parliament_id
    remove_column :members, :parliament_id
  end
end
