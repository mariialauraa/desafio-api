json.products do
  json.array! @products, :id, :name, :ballast
end