require 'rails_helper'

RSpec.describe ReportsController, type: :controller do
  let!(:water) { create :water }

  let!(:food) { create :food }
  let!(:medication) { create :medication }
  let!(:ammunition) { create :ammunition }

  before(:each) do
    create_list(:survivor,  5, :infected, 
      resources: [
        create(:water),
        create(:food),
        create(:medication),
        create(:ammunition)
      ]
    )

    create_list(:survivor, 10, :not_infected)
  end

  describe 'GET #infected_survivors' do
    context 'with valid survivors' do
      it 'should return the infected survivors percentage' do
        get :infected_survivors

        json = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(json['percentage']).to eq '33.33%'
      end
    end

    context 'with invalid survivors' do
      it 'should return erro if there is no survivors' do
        Survivor.delete_all

        get :infected_survivors

        json = JSON.parse(response.body)
        expect(response).to have_http_status(:conflict)
        expect(json['error']).to eq 'There are no survivors'
      end
    end
  end

  describe 'GET #not_infected_survivors' do
    context 'with valid survivors' do
      it 'should return the not infected survivors percentage' do
        get :uninfected_survivors

        json = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(json['percentage']).to eq '66.67%'
      end
    end

    context 'with invalid survivors' do
      it 'should return erro if there is no survivors' do
        Survivor.delete_all

        get :uninfected_survivors

        json = JSON.parse(response.body)
        expect(response).to have_http_status(:conflict)
        expect(json['error']).to eq 'There are no survivors'
      end
    end
  end

  describe 'GET #resources_by_survivor' do
    it 'should return the not infected survivors percentage' do
      get :resources_by_survivor

      json = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(json['water']).to eq 2.5
      expect(json['food']).to eq 0.1
      expect(json['medication']).to eq 0.1
      expect(json['ammunition']).to eq 0.1
    end
  end

  describe 'GET #lost_infected_points' do
    it 'should return the lost point because of infected survivors' do
      get :lost_infected_points

      json = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(json['lostPoints']).to eq 205
    end
  end
end
