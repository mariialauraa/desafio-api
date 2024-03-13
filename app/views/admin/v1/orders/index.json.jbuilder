json.orders do
  json.array! @loading_service.records, :id, :code, :bay, :load_id
end
  
json.meta do
  json.partial! 'shared/pagination', pagination: @loading_service.pagination
end