class ChangeQuantityTypeInOrderProducts < ActiveRecord::Migration[7.1]
  def change
    change_column :order_products, :quantity, 'integer USING CAST(quantity AS integer)'
  end
end
