json.array!(@bookmarks) do |bookmark|
  json.extract! bookmark, :id, :title, :description, :url, :tag_list, :created_at, :updated_at
  json.url bookmark_url(bookmark, format: :json)
end
