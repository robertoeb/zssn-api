
require 'rails_helper'

RSpec.describe TradesController, type: :controller do

  let(:survivor1) {
    FactoryBot.create :survivor,
    resources_attributes: [
      FactoryBot.attributes_for(:resource, :water, amount: 6),
      FactoryBot.attributes_for(:resource, :medication, amount: 3),
    ]
  }

  let(:survivor2) {
    FactoryBot.create :survivor,
    resources_attributes: [
      FactoryBot.attributes_for(:resource, :medication, amount: 7),
      FactoryBot.attributes_for(:resource, :ammunition, amount: 10),
    ]
  }

  describe "Trade the resources between two survivors" do
    let(:resources_to_trade_survivor1) {
      [ {item: 'Water', amount: 1}, {item: 'Medication', amount: 1} ]
    }

    let(:resources_to_trade_survivor2) {
      [ {item: 'Ammunition', amount: 6} ]
    }

    let(:trade_params) do
      {
        trade: {
          survivor1: {
            id: survivor1.id,
            resources: resources_to_trade_survivor1
          },
          survivor2: {
            id: survivor2.id,
            resources: resources_to_trade_survivor2
          }
        }
      }
    end

    it 'should raise error when a survivor does not exist' do
      trade_params[:trade][:survivor1][:id] = '999'

      post :trade, params: trade_params

      json = JSON.parse(response.body)
      expect(response).to have_http_status(:not_found)
      expect(json['error']).to eq("Couldn't find Survivor with 'id'=999")
    end

    it 'should not allow trade when a survivor is infected' do
      survivor2.update_attribute(:infection_mark, 4)

      post :trade, params: trade_params

      json = JSON.parse(response.body)
      expect(response).to have_http_status(:conflict)
      expect(json['error']).to eq("Survivor2 It's infected! Run away or kill him!")
    end

    it 'should not allow trade when a survivor has not enough resources' do 
      survivor2.resources.find_by(item: 'Ammunition').update(amount: 2)

      post :trade, params: trade_params, as: :json
      expect(response).to have_http_status(:conflict)

      json = JSON.parse(response.body)
      expect(json['error']).to eq("Invalid resources for Survivor2")

      survivor1.reload

      expect(survivor1.resources.find_by(item: 'Water').amount).to eq 6
      expect(survivor1.resources.find_by(item: 'Medication').amount).to eq 3
    end

    it 'should not allow trade when resources are not balanced' do 
      trade_params[:trade][:survivor1][:resources][0][:amount] = 6

      post :trade, params: trade_params, as: :json

      expect(response).to have_http_status(:conflict)

      json = JSON.parse(response.body)
      expect(json['error']).to eq('Resources points is not balanced both sides')

      survivor1.reload

      expect(survivor1.resources.find_by(item: 'Water').amount).to eq 6
      expect(survivor1.resources.find_by(item: 'Medication').amount).to eq 3
    end

    it 'should successfully trade resources between two survivors' do
      post :trade, params: trade_params, as: :json

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json['message']).to eq('Resources where traded successfully')

      survivor1.reload
      survivor2.reload

      expect(survivor1.resources.find_by(item: 'Water').amount).to eq 5
      expect(survivor1.resources.find_by(item: 'Medication').amount).to eq 2

      expect(survivor2.resources.find_by(item: 'Ammunition').amount).to eq 4
    end
  end

end