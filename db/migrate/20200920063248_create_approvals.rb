class CreateApprovals < ActiveRecord::Migration[5.1]
  def change
    create_table :approvals do |t|
      t.integer :applied_approval_superior
      t.integer :approval_superior_confirmation
      t.boolean :approval_superior_reflection
      t.datetime :applied_on
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
