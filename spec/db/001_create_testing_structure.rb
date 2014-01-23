class CreateTestingStructure < ActiveRecord::Migration
  def change
    create_table :issues do |t|
      t.string :name
      t.float :estimated_hours
    end

    create_table :time_entries do |t|
      t.integer :issue_id
      t.float :hours
    end
  end
end
