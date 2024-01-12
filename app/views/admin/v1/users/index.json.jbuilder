json.users do
  json.array! @users, :id, :name, :login
end