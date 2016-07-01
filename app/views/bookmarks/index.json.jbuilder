json.array!(@bookmarks) do |bookmark|
  json.extract! bookmark, :id, :title, :description, :url, :created_at, :updated_at
  json.url bookmark_url(bookmark, format: :json)
end
