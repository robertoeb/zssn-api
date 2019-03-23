require 'rails_helper'

RSpec.describe TradesController, type: :controller do
  describe '#trade' do
    let(:survivor1) { create :survivor }
    let(:survivor2) { create :survivor }

    let!(:water_resources) { create :water, survivor: survivor1 }
    let!(:food_resources) { create_list :food, 2, survivor: survivor1 }
    let!(:medication_resources) { create_list :medication, 2, survivor: survivor2 }
    let!(:ammunition_resources) { create_list :ammunition, 6, survivor: survivor2 }

    let(:survivor1_resources_params) do
      [
        {
          type: 'Water',
          amount: 1
        },
        {
          type: 'Food',
          amount: 2
        }
      ]
    end

    let(:survivor2_resources_params) do
      [
        {
          type: 'Medication',
          amount: 2
        },
        {
          type: 'Ammunition',
          amount: 6
        }
      ]
    end

    let(:request_params) do
      {
        trade: {
          survivor1: {
            id: survivor1.id,
            resources: survivor1_resources_params
          },
          survivor2: {
            id: survivor2.id,
            resources: survivor2_resources_params
          }
        }
      }
    end

    it 'trades resources between survivors' do
      post :trade, params: request_params

      expect(response.status).to eq(200)

      json = JSON.parse(response.body)
      expect(json['message']).to eq('Resources were traded successfully')

      expect(water_resources.reload.survivor).to eq(survivor2)
      food_resources.each { |resource| expect(resource.reload.survivor).to eq(survivor2) }
      medication_resources.each { |resource| expect(resource.reload.survivor).to eq(survivor1) }
      ammunition_resources.each { |resource| expect(resource.reload.survivor).to eq(survivor1) }
    end

    context 'when a survivor is not found' do
      let(:request_params) do
        {
          trade: {
            survivor1: {
              id: 999,
              resources: survivor1_resources_params
            },
            survivor2: {
              id: survivor2.id,
              resources: survivor2_resources_params
            }
          }
        }
      end

      it 'returns a survivor not found error' do
        post :trade, params: request_params

        expect(response.status).to eq(404)

        json = JSON.parse(response.body)
        expect(json['error']).to eq("Couldn't find Survivor with 'id'=999")
      end
    end

    context 'when a survivor is infected' do
      it 'returns an infected survivor error for the first survivor' do
        survivor1.update_attribute(:infection_mark, Survivor::INFECTED_BITES)

        post :trade, params: request_params

        expect(response.status).to eq(409)

        json = JSON.parse(response.body)
        expect(json['error']).to eq('Survivor 1 It\'s a walker! Run or kill him!')
      end

      it 'returns an infected survivor error for the second survivor' do
        survivor2.update_attribute(:infection_mark, Survivor::INFECTED_BITES)

        post :trade, params: request_params

        expect(response.status).to eq(409)

        json = JSON.parse(response.body)
        expect(json['error']).to eq('Survivor 2 It\'s a walker! Run or kill him!')
      end
    end

    context 'when a survivor does not have the described resources' do
      context 'for the first survivor' do
        let(:survivor1_resources_params) do
          [
            {
              type: 'Water',
              amount: 2
            },
            {
              type: 'Food',
              amount: 2
            }
          ]
        end

        it 'returns an invalid resources error' do
          post :trade, params: request_params

          expect(response.status).to eq(422)

          json = JSON.parse(response.body)
          expect(json['error']).to eq('Invalid resources for Survivor 1')
        end
      end

      context 'for the second survivor' do
        let(:survivor2_resources_params) do
          [
            {
              type: 'Medication',
              amount: 2
            },
            {
              type: 'Ammunition',
              amount: 10
            }
          ]
        end

        it 'returns an invalid resources error' do
          post :trade, params: request_params

          expect(response.status).to eq(422)

          json = JSON.parse(response.body)
          expect(json['error']).to eq('Invalid resources for Survivor 2')
        end
      end
    end

    context 'when sides offer distinct amount of points' do
      context 'for the first survivor' do
        let(:survivor1_resources_params) do
          [
            {
              type: 'Water',
              amount: 1
            },
            {
              type: 'Food',
              amount: 1
            }
          ]
        end

        it 'returns an invalid amount error' do
          post :trade, params: request_params

          expect(response.status).to eq(422)

          json = JSON.parse(response.body)
          expect(json['error']).to eq('Invalid amount of points between both sides')
        end
      end

      context 'for the second survivor' do
        let(:survivor2_resources_params) do
          [
            {
              type: 'Medication',
              amount: 2
            },
            {
              type: 'Ammunition',
              amount: 1
            }
          ]
        end

        it 'returns an invalid amount error' do
          post :trade, params: request_params

          expect(response.status).to eq(422)

          json = JSON.parse(response.body)
          expect(json['error']).to eq('Invalid amount of points between both sides')
        end
      end
    end
  end
end
