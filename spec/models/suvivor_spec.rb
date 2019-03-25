require 'rails_helper'

RSpec.describe Survivor, type: :model do
  context 'validation tests' do
    it 'ensures name presense' do
      suvivor = Survivor.new(age: 41, gender: 'F', latitude: 31.2000924, longitude: 29.9187387).save
      expect(suvivor).to eq false
    end

    it 'ensures age presense' do
      suvivor = Survivor.new(name: 'Michonne',  gender: 'F', latitude: 24.582349, longitude: -88.242342).save
      expect(suvivor).to eq false
    end

    it 'ensures gender presense' do
      suvivor = Survivor.new(name: 'Michonne', age: 41, latitude: 24.582349, longitude: -88.242342).save
      expect(suvivor).to eq false
    end

    it 'ensures latitude presense' do
      suvivor = Survivor.new(name: 'Michonne', age: 41, gender: 'F', longitude: -88.242342).save
      expect(suvivor).to eq false
    end

    it 'ensures longitude presense' do
      suvivor = Survivor.new(name: 'Michonne', age: 41, gender: 'F', latitude: 24.582349).save
      expect(suvivor).to eq false
    end

    it 'should save successfuly' do
      suvivor = Survivor.new(name: 'Michonne', age: 41, gender: 'F', latitude: 24.582349, longitude: -88.242342).save
      expect(suvivor).to eq true
    end
  end

  context 'scope tests' do
    before(:each) do
      suvivor = Survivor.new(name: 'Shane Walsh', age: 35, gender: 'M', latitude: 33.7489954, longitude: -84.3879824, infection_mark: 3).save
      suvivor = Survivor.new(name: 'Eugene Porter', age: 42, gender: 'F', latitude: 24.582349, longitude: -88.242342, infection_mark: 3, infection_mark: 2).save
    end

    it 'should return infected survivors' do
      expect(Survivor.infected.size).to eq(1)
    end

    it 'should return uninfected survivors' do
      expect(Survivor.not_infected.size).to eq(1)
    end
  end
end
