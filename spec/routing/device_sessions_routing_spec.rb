RSpec.describe Devise::SessionsController, type: :routing do
  describe 'sessions' do
    it 'routes to sign in page' do
      expect(:get => '/users/sign_in').to route_to('devise/sessions#new')
    end

    it 'routes to the session creation' do
      expect(:post => '/users/sign_in').to route_to('devise/sessions#create')
    end

    it 'routes to the session deletion' do
      expect(:delete => '/users/sign_out').to route_to('devise/sessions#destroy')
    end
  end
end
