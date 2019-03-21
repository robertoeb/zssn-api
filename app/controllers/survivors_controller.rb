class SurvivorsController < ApplicationController
  before_action :set_survivor, only: [:update, :report_infection, :show]

  # GET /survivors
  def index
    @survivors = Survivor.all
    render json: @survivors, status: :ok
  end

  # GET /survivors/:id
  def show
    render json: @survivor
  end

  # POST /survivors
  def create
    if resources_params.has_key?(:resources)
      @survivor = Survivor.new(survivor_params.merge(resources_attributes: parsed_resources))

      if @survivor.save
        render json: @survivor, status: :created
      else
        render json: @survivor.errors, status: :unprocessable_entity
      end
    else
      render json: { message: 'Survivors need to declare their resources' }, status: :conflict
    end
  end

  # PATCH/PUT /survivors/:id
  def update
    if @survivor.update_attributes(update_params)
      render json: @survivor, status: :ok
    else
      render json: @survivor.errors, status: :unprocessable_entity
    end
  end

  # POST /survivors/:id/report_infection
  def report_infection
    @survivor.increment(:infection_mark, 1).save
    if @survivor.infected?
      render json: { message: 'He\'s a walker, do him a favor, shoot his head.' },
             status: :ok
    else
      render json: { message: "Survivor reported as infected #{@survivor.infection_mark} times" },
             status: :ok
    end
  end

  private

  def set_survivor
    @survivor = Survivor.find(params[:id])
    head :not_found if @survivor.blank?
  end

  def survivor_params
    params.require(:survivor).permit(:name, :age, :gender, :latitude, :longitude)
  end

  def resources_params
    params.require(:survivor).permit(resources: [:type, :amount])
  end

  def update_params
    params.require(:survivor).permit(:latitude, :longitude)
  end

  def parsed_resources
    resources = []
    resources_params[:resources].each do |resource|
      resource[:amount].to_i.times { resources << { type: resource[:type] } }
    end
    resources
  end
end