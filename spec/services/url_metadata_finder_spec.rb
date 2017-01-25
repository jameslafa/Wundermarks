require 'rails_helper'

RSpec.describe URLMetadataFinder, type: :service do
  describe 'get_metadata' do

    context "when the url is reachable" do
      it 'returns metadata from the url [google.com]' do
        stub_request(:get, "https://google.com/").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.95 Safari/537.36'}).
          to_return(:status => 200, :body => File.read(Rails.root.join('spec', 'fixtures', 'html', 'google.com')), :headers => {})

        metadata = URLMetadataFinder.get_metadata("https://google.com")
        expect(metadata[:url]).to eq "https://google.com"
        expect(metadata[:title]).to eq "Google"
        expect(metadata[:description]).to eq "Search the world's information, including webpages, images, videos and more. Google has many special features to help you find exactly what you're looking for."
        expect(metadata[:canonical_url]).to eq nil
        expect(metadata[:language]).to eq "en"
      end

      it 'returns metadata from the url [thatoneprivacysite.net]' do
        stub_request(:get, "https://thatoneprivacysite.net/").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.95 Safari/537.36'}).
          to_return(:status => 200, :body => File.read(Rails.root.join('spec', 'fixtures', 'html', 'thatoneprivacysite.net')), :headers => {})

        metadata = URLMetadataFinder.get_metadata("https://thatoneprivacysite.net")
        expect(metadata[:url]).to eq "https://thatoneprivacysite.net"
        expect(metadata[:title]).to eq "That One Privacy Site | Welcome"
        expect(metadata[:description]).to eq nil
        expect(metadata[:canonical_url]).to eq "https://thatoneprivacysite.net/"
        expect(metadata[:language]).to eq "en"
      end


    end

    context "when the url timeout" do
      it 'returns nil' do
        stub_request(:get, "https://google.com/").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.95 Safari/537.36'}).
          to_timeout

        metadata = URLMetadataFinder.get_metadata("https://google.com")
        expect(metadata).to be_nil
      end
    end

    context "when the url does not exist" do
      it 'returns nil' do
        stub_request(:get, "https://abcder45.com/").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.95 Safari/537.36'}).
          to_raise(SocketError)

        metadata = URLMetadataFinder.get_metadata("https://abcder45.com/")
        expect(metadata).to be_nil
      end
    end
  end
end
