require 'rails_helper'

RSpec.describe ReportsController, type: :controller do
  before do
    create_list(:survivor,  10, :infected, 
      resources_attributes: [
        attributes_for(:resource, :water, amount: 6),
        attributes_for(:resource, :food,  amount: 9),
        attributes_for(:resource, :medication, amount: 4),
        attributes_for(:resource, :ammunition, amount: 15)
      ]
      )

    create_list(:survivor, 25, :not_infected,
      resources_attributes: [
        attributes_for(:resource, :water, amount: 12),
        attributes_for(:resource, :food,  amount: 5),
        attributes_for(:resource, :medication, amount: 6),
        attributes_for(:resource, :ammunition, amount: 26)
      ]
      )
  end

  describe 'GET #infected_survivors' do
    context 'with valid survivors' do
      it 'should return the infected survivors percentage' do
        get :infected_survivors

        json = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(json['percentage']).to eq '28.57%'
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
        expect(json['percentage']).to eq '71.43%'
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
      expect(json['averages']['water']).to eq 14.4
      expect(json['averages']['food']).to eq 8.6
      expect(json['averages']['medication']).to eq 7.6
      expect(json['averages']['ammunition']).to eq 32
    end
  end

  describe 'GET #lost_infected_points' do
    it 'should return the lost point because of infected survivors' do
      get :lost_infected_points

      json = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(json['lost_points']).to eq 740
    end
  end
end
