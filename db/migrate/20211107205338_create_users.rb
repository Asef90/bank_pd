class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.decimal :amount
      t.bigint :account_id

      t.timestamps
    end
  end
end
