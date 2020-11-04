class AddBeforeTimeToHistory < ActiveRecord::Migration[5.1]
  def change
    add_column :histories, :b_started_at, :datetime
    add_column :histories, :b_finished_at, :datetime
  end
end
