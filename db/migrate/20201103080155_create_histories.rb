class CreateHistories < ActiveRecord::Migration[5.1]
  def change
    create_table :histories do |t|
      t.datetime :b_finish_overwork
      t.boolean :b_next_day
      t.string :b_work_contents
      t.integer :b_applied_overwork
      t.integer :b_overwork_confirmation
      t.references :attendance, foreign_key: true

      t.timestamps
    end
  end
end
