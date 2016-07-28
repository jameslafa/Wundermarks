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
end
