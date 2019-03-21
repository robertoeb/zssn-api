class ReportsController < ApplicationController
  def infected_survivors
    render json: {
      percentage: percentage(infected_survivor_count / all_survivors_count)
    }
  end

  def uninfected_survivors
    render json: {
      percentage: percentage(survivor_count / all_survivors_count)
    }
  end

  def resources_by_survivor
    render json: {
      water: Resource.water.count.to_f / survivor_count,
      food: Resource.food.count.to_f / survivor_count,
      medication: Resource.medication.count.to_f / survivor_count,
      ammunition: Resource.ammunition.count.to_f / survivor_count
    }
  end

  def lost_infected_points
    render json: {
      lostPoints: Resource.where(survivor_id: Survivor.infected).map(&:points).inject(:+)
    }
  end

  def percentage(number)
    "#{number.round(4) * 100}%"
  end

  def survivor_count
    Survivor.not_infected.count.to_f
  end

  def infected_survivor_count
    Survivor.infected.count.to_f
  end

  def all_survivors_count
    Survivor.all.count.to_f
  end
end
