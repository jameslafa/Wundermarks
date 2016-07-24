require 'uri'

module BookmarksHelper
  def bookmark_permalink(bookmark, url=false)
    if url
      bookmark_permalink_url(id: bookmark.id, title: "#{bookmark.created_at.to_date}_#{bookmark.title.parameterize}")
    else
      bookmark_permalink_path(id: bookmark.id, title: "#{bookmark.created_at.to_date}_#{bookmark.title.parameterize}")
    end
  end

  def share_twitter_popup_url(bookmark)
    base_url = base_twitter_url(bookmark)
    new_params = [['via', 'wundermarks']]
    new_params << ['hashtags', bookmark.tag_list.join(',')] if bookmark.tag_list.size > 0
    new_params << ['url', base_url]

    url_with_query_parameters("https://twitter.com/intent/tweet", new_params)
  end

  def share_facebook_popup_url(bookmark)
    base_url = base_facebook_url(bookmark)
    new_params = [
      ['app_id', Settings.facebook.app_id],
      ['display', 'popup'],
      ['href', base_url],
      ['redirect_uri', bookmark_permalink(bookmark, true)],
      ['hashtag', '#wundermarks']
    ]

    url_with_query_parameters("https://www.facebook.com/dialog/share", new_params)
  end

  def base_twitter_url(bookmark)
    url_with_query_parameters(bookmark_permalink(bookmark, true), [['utm_source', 'user_share'], ['utm_medium', 'twitter'], ['redirect', '1']])
  end

  def base_facebook_url(bookmark)
    url_with_query_parameters(bookmark_permalink(bookmark, true), [['utm_source', 'user_share'], ['utm_medium', 'facebook'], ['redirect', '1']])
  end

  def url_with_query_parameters(url, new_params)
    uri = URI(url)
    params = URI.decode_www_form(uri.query || "")
    new_params.each do |new_param_elt|
      params << new_param_elt
    end
    uri.query = URI.encode_www_form(params)
    uri.to_s
  end
end
