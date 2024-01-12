json.loads do
  json.array! @loads, :id, :code, :delivery_date
end