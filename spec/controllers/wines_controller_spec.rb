require 'rails_helper'
require 'rspec/rails'
require 'devise'
# require 'devise' goes after 'rspec/rails'

RSpec.describe WinesController, type: :controller do

    describe 'GET index' do
        
        # it 'assigns @wines' do
        #     wine = Wine.create
        #     wines = Wine.all
        #     get :index
        #     expect(assigns(:wines)).to eq(wine)
        # end

        it "routes to #index" do
            get :index
            expect(get: "/wines").to route_to("wines#index")
        end

        it "routes to #show" do
            expect(get: "/wines/9").to route_to("wines#show", id: "9")
        end
    end

    describe 'GET show' do
        render_views # under describe or context 

        user = User.create(email: "peter@example.com", password: '1234567', admin: true)

        before do
            sign_in user
        end

        it "renders show template" do
            wine = Wine.create
            get :show, params: { id: wine.id }
            expect(response.status).to eq(302)
            # expect(response).to have_http_status(302)
        end

    end  
end

# 200 is a success, 302 is found. Rails scaffold return 302 on get method

# bundle exec rspec spec/controllers/wines_controller_spec.rb