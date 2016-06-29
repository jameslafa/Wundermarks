json.array!(@bookmarks) do |bookmark|
  json.extract! bookmark, :id, :title, :description, :url, :user_id
  json.url bookmark_url(bookmark, format: :json)
end
