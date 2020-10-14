class CreateCorrections < ActiveRecord::Migration[5.1]
  def change
    create_table :corrections do |t|
      t.date :date
      t.datetime :before_attendance_time
      t.datetime :before_leaving_time
      t.datetime :attendance_time
      t.datetime :leaving_time
      t.integer :instructor
      t.date :approval_date
      t.belongs_to :attendance, index: { unique: true }, foreign_key: true

      t.timestamps
    end
  end
end
