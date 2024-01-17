json.loads do
  json.array! @loading_service.records, :id, :code, :delivery_date
end

json.meta do
  json.partial! 'shared/pagination', pagination: @loading_service.pagination
end