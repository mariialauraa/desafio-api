json.order_products @order_products do |order_product|
  json.extract! order_product, :id, :order_id, :product_id, :quantity, :box
  json.product_name order_product.product.name
end