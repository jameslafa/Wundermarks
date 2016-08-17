require 'uri'

module BookmarksHelper

  # Returns a nice bookmark's permalink include title for better SEO
  def bookmark_permalink(bookmark, url=false)
    if url
      bookmark_permalink_url(id: bookmark.id, title: "#{bookmark.created_at.to_date}_#{bookmark.title.parameterize}")
    else
      bookmark_permalink_path(id: bookmark.id, title: "#{bookmark.created_at.to_date}_#{bookmark.title.parameterize}")
    end
  end

  # URL to open a Twitter popup to share the url
  def share_twitter_popup_url(bookmark)
    base_url = base_twitter_url(bookmark)
    new_params = [['via', 'wundermarks']]
    new_params << ['text', bookmark.title]
    new_params << ['hashtags', bookmark.tag_list.join(',')] if bookmark.tag_list.size > 0
    new_params << ['url', base_url]

    url_with_query_parameters("https://twitter.com/intent/tweet", new_params)
  end

  # URL to open a Facebook popup to share the url
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

  # Build the URL that will be share on Twitter including necessary analytics parameters
  def base_twitter_url(bookmark)
    url_with_query_parameters(bookmark_shortlink_url(bookmark), [['utm_medium', 'twitter'], ['redirect', '1']])
  end

  # Build the URL that will be share on Facebook including necessary analytics parameters
  def base_facebook_url(bookmark)
    url_with_query_parameters(bookmark_shortlink_url(bookmark), [['utm_medium', 'facebook'], ['redirect', '1']])
  end

  # Return the privacy icon's class of the bookmark
  def privacy_icon_class(bookmark)
    case bookmark.privacy
    when 'everyone'
      'octicon octicon-globe'
    when 'only_me'
      'octicon octicon-lock'
    end
  end

  def bookmark_list_date(date)
    nb_day_difference = (Time.now.to_date - date.to_date).to_i
    case nb_day_difference
    when 0
      return t("date.today")
    when 1
      return t("date.yesterday")
    when 2..6
      return t("date.last_week_day", day_name: t(:"date.day_names")[date.cwday])
    else
      return l(date, format: :long)
    end
  end
end
