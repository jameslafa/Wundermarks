require 'nokogiri'
require 'open-uri'

class URLMetadataFinder
  class << self
    DEFAULT_USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.95 Safari/537.36"

    # Get metadata from a website defined by a url
    def get_metadata(url, timeout = 5)
      stripped_url = url.strip

      # If there is an error, we just return nil
      begin
        if doc = Nokogiri::HTML(open(stripped_url, {"User-Agent" => DEFAULT_USER_AGENT, :read_timeout => 10}))
          metadata = {}
          metadata[:url] = stripped_url
          metadata[:title] = title(doc)
          metadata[:description] = description(doc)
          metadata[:canonical_url] = canonical_url(doc)
          metadata[:language] = language(doc)
          metadata
        end
      rescue
        nil
      end
    end

    private

    # Extract webpage title from the DOM
    def title(doc)
      node = doc.at('/html/head/title') and node.text
    end

    # Extract webpage description from the DOM
    def description(doc)
      node = doc.at('/html/head/meta[@name="description"]/@content') and node.text
    end

    # Extract webpage canonical url from the DOM
    def canonical_url(doc)
      node = doc.at('/html/head/link[@rel="canonical"]/@href') and node.value
    end

    # Extract webpage language from the DOM
    def language(doc)
      node = doc.at('/html/@lang')
      if node
        lang = node.text
        if lang.present?
          lang.split(/[^a-zA-Z]/, 2).first.downcase
        end
      end
    end
  end
end
