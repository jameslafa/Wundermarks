require 'rinku'

module ApplicationHelper

  # Add query parameters to an existing url
  def url_with_query_parameters(url, new_params)
    uri = URI(url)
    params = URI.decode_www_form(uri.query || "")
    new_params.each do |new_param_elt|
      params << new_param_elt
    end
    uri.query = URI.encode_www_form(params)
    uri.to_s
  end

  def text_to_html(text)
    return "" unless text.present?
    clean_text = sanitize(text, tags: ['strong', 'b', 'em', 'i', 'a'], attributes: ['href'])
    clean_text = simple_format(clean_text, {}, sanitize: false)
    Rinku.auto_link(clean_text, :all, 'target="_blank" rel="nofollow noopener noreferrer"').html_safe
  end

  def notifications_count(user)
    if user
      count = NotificationFetcher.unread_user_notifications_count(user)
      if count == 0
        ''
      elsif count > 10
        '10+'
      else
        count.to_s
      end
    else
      ''
    end
  end
end
