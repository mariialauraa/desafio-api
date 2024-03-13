class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.string :code
      t.string :bay
      t.references :load, foreign_key: true

      t.timestamps
    end
  end
end
