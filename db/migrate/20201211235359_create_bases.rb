class CreateBases < ActiveRecord::Migration[5.1]
  def change
    create_table :bases do |t|
      t.integer :number
      t.string :name
      t.integer :attendance_type
      t.boolean :error_flag, default: false, null: false

      t.timestamps
    end
  end
end
