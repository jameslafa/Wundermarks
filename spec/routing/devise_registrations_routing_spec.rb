RSpec.describe Devise::RegistrationsController, type: :routing do
  describe 'registrations' do
    it 'routes to the new registration page' do
      expect(:get => '/users/sign_up').to route_to('devise/registrations#new')
    end
  end
end
