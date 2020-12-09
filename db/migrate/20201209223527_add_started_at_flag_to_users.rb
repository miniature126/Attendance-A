class AddStartedAtFlagToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :started_at_flag, :boolean, default: false, null: false
  end
end
