class CreateSortedOrderProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :sorted_order_products do |t|
      t.references :order, foreign_key: true
      t.references :product, foreign_key: true
      t.integer :layer
      t.integer :quantity
      t.boolean :box

      t.timestamps
    end
  end
end
