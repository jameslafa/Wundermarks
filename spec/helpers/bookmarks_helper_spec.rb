require 'rails_helper'
include BookmarksHelper

RSpec.describe 'BookmarksHelper', :type => :helper do
  let(:bookmark) { create(:bookmark, created_at: DateTime.new(2001,2,3,4,5,6), title: 'Here is my title') }

  describe 'bookmark_permalink' do
    it 'generates a permalink containing the creation date and title' do
      expect(bookmark_permalink(bookmark)).to eq "/bookmarks/#{bookmark.id}/2001-02-03_here-is-my-title"
    end
  end
end
