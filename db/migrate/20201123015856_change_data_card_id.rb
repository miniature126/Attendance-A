class ChangeDataCardId < ActiveRecord::Migration[5.1]
  def change
    change_column :users, :card_id, :string
  end
end
