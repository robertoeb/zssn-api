class ReportsController < ApplicationController
  before_action :check_survivors

    # GET /reports/infected_survivors
  def infected_survivors
    render json: {
      percentage: percentage(infected_survivor_count / all_survivors_count)
    }
  end

  # GET /reports/uninfected_survivors
  def uninfected_survivors
    render json: {
      percentage: percentage(survivor_count / all_survivors_count)
    }
  end

  # GET /reports/resources_by_survivor
  def resources_by_survivor
    averages = {}

    Resource::RESOURCES_TYPES.each do |resource|
      resource_amount = Resource.public_send(resource).sum(:amount).to_f
      averages[resource] = resource_amount / survivor_count
    end

    render json: { averages: averages }, status: :ok
  end



  # GET /reports/lost_infected_points
  def lost_infected_points
    @lost_points = 0
    infecteds = Survivor.infected.pluck(:id)
    resources = Resource.where(survivor_id: infecteds)
    resources.each do |resource|
      @lost_points = Resource.points_sum(resource) + @lost_points
    end

    render json: { lost_points: @lost_points }, status: :ok
  end

  private

  def check_survivors
    unless Survivor.exists?
      render json: { error: 'There are no survivors' }, status: :conflict
    end
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
