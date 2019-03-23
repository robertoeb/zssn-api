require 'rails_helper'

RSpec.describe SurvivorsController, type: :controller do

  let(:survivor_params) {
    FactoryBot.attributes_for :survivor, resources: [water, food]
  }

  let(:invalid_attributes) {
    FactoryBot.attributes_for :survivor
  }

  let(:water){ create :water }

  let(:food){ create :food }

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'returns a new Survivor' do
        expect {
          post :create, params: { survivor: survivor_params }
        }.to change(Survivor, :count).by(1)
      end
    end

    context 'with invalid parameters' do
      it 'returns with errors for the new survivor' do
        post :create, params: {survivor: survivor_params.except(:name)}

        json = JSON.parse(response.body)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq 'application/json'
        expect(json['name']).to eq(["can't be blank"])
      end

      it 'returns survivor need declare resources' do 
        post :create, params: {survivor: invalid_attributes}

        json = JSON.parse(response.body)
        expect(response).to have_http_status(:conflict)
        expect(json['message']).to eq 'Survivors need to declare their resources'
      end
    end
  end

  describe 'GET #index' do
    it 'returns all survivors' do
      survivor = FactoryBot.create(:survivor)

      get :index

      json = JSON.parse(response.body)

      expect(response).to be_success
      expect(response.status).to eq(200)
      expect(json.count).to eq 1
    end
  end

  describe '#show' do
    context 'with a valid id' do
      let(:survivor) { create :survivor }

      it 'returns the survivor model' do
        get :show, params: { id: survivor.id }

        expect(response.status).to eq(200)

        json = JSON.parse(response.body)
        expect(json).to be_a(Hash)
        expect(json.keys)
          .to eq(%w(id name age gender latitude longitude infection_mark))
      end
    end

    context 'with an invalid id' do
      it 'returns an error' do
        get :show, params: { id: 999 }

        expect(response.status).to eq(404)
        json = JSON.parse(response.body)
        expect(json['error']).to eq("Couldn't find Survivor with 'id'=999")
      end
    end
  end

  describe '#update' do
    let(:survivor) { create :survivor }

    context 'with valid parameters' do
      let(:values) do
        {
          latitude: 40.730610,
          longitude: -73.935242
        }
      end

      it 'updates the survivor values' do
        put :update, params: { id: survivor.id, survivor: values }

        expect(response.status).to eq(200)

        expect(assigns(:survivor).latitude).to eq(values[:latitude])
        expect(assigns(:survivor).longitude).to eq(values[:longitude])

        json = JSON.parse(response.body)
        expect(json['latitude']).to eq(values[:latitude])
        expect(json['longitude']).to eq(values[:longitude])
      end
    end

    context 'with invalid parameters' do
      let(:values) do
        {
          latitude: 40.730610,
          longitude: nil
        }
      end

      it 'returns the request errors' do
        put :update, params: { id: survivor.id, survivor: values }

        expect(response.status).to eq(422)

        json = JSON.parse(response.body)
        expect(json).to be_a(Hash)
        expect(json.keys).to eq(%w(longitude))

        expect(json['longitude']).to eq(["can't be blank"])
      end
    end
  end

  describe '#report_infection' do
    context 'with a valid id' do
      let(:survivor) { create :survivor, infection_mark: 0 }

      context 'for a not infected survivor' do
        it 'increment the infection counter and returns the regular message' do
          post :report_infection, params: { id: survivor.id }

          expect(response.status).to eq(200)
          expect(assigns(:survivor).infection_mark).to eq(1)

          json = JSON.parse(response.body)
          expect(json['message']).to eq('Survivor reported as infected 1 times')
        end
      end

      context 'for a infected survivor' do
        it 'increment the infection counter and returns the infected message' do
          survivor.update_column(:infection_mark, Survivor::INFECTED_BITES - 1)

          post :report_infection, params: { id: survivor.id }

          expect(response.status).to eq(200)
          expect(assigns(:survivor).infection_mark).to eq(Survivor::INFECTED_BITES)

          json = JSON.parse(response.body)
          expect(json['message']).to eq('He\'s a walker, do him a favor, shoot his head.')
        end
      end
    end

    context 'with an invalid id' do
      it 'returns an error' do
        post :report_infection, params: { id: 999 }

        expect(response.status).to eq(404)
        json = JSON.parse(response.body)
        expect(json['error']).to eq("Couldn't find Survivor with 'id'=999")
      end
    end
  end
end
