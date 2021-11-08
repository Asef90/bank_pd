class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.decimal :amount, precision: 15, scale: 2, null: false
      t.bigint :account_id, null: false

      t.timestamps
    end
  end
end
