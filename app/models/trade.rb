# frozen_string_literal: true

class Trade
  attr_reader :survivor1, :survivor2, :resources_hash_1, :resources_hash_2
  attr_accessor :valid, :status, :message

  def initialize(survivor1, survivor2, survivor1_resources_params, survivor2_resources_params)
    @survivor1 = survivor1
    @survivor2 = survivor2
    @survivor1_resources_params = survivor1_resources_params
    @survivor2_resources_params = survivor2_resources_params
    @survivor1_id = @survivor1.id
    @survivor2_id = @survivor2.id
    @survivor1_points = 0
    @survivor2_points = 0
    @valid = false
    @status = nil
    @message = ''
  end

  def process
    check_infection
    check_inconsistent_resources
    trade_resources
  rescue TradeError => e
    return_error(e.status, e.message)
  end

  private

  def check_infection
    survivors.each do |survivor|
      if instance_variable_get("@#{survivor}").infected?
        raise TradeError.new(:conflict),
              "#{survivor.to_s.humanize} It's infected! Run away or kill him!"
      end
    end
  end

  def check_inconsistent_resources
    survivors.each do |survivor|
      instance_variable_get("@#{survivor}_resources_params").each do |resource|
        unless valid_resources?(survivor, resource)
          raise TradeError.new(:conflict),
                "Invalid resources for #{survivor.to_s.humanize}"
        end
      end
    end
    check_points
    if @survivor1_points != @survivor2_points
      raise TradeError.new(:conflict),
            'Resources points is not balanced both sides'
    end
  end

  def trade_resources
    survivors.each do |survivor|
      instance_variable_get("@#{survivor}_resources_params").each do |resource|
        @survivor_id = instance_variable_get("@#{survivor}_id")
        @resource_table = Resource.where(item: resource[:item], survivor_id: @survivor_id).first
        @resource_table.decrement!(:amount, resource[:amount])
        if survivor == :survivor1
          unless Resource.where(item: resource[:item], survivor_id: @survivor2.id).first.present?
            Resource.new(item: resource[:item], amount: 0, survivor_id: @survivor2.id).save
          end
          @resource_table = Resource.where(item: resource[:item], survivor_id: @survivor2.id).first
          @resource_table.increment!(:amount, resource[:amount])
        else
          unless Resource.where(item: resource[:item], survivor_id: @survivor1.id).first.present?
            Resource.new(item: resource[:item], amount: 0, survivor_id: @survivor1.id).save
          end
          @resource_table = Resource.where(item: resource[:item], survivor_id: @survivor1.id).first
          @resource_table.increment!(:amount, resource[:amount])
        end
      end
    end

    self.valid = true
    self.message = 'Resources where traded successfully'
  end

  def valid_resources?(survivor, resource)
    instance_variable_get("@#{survivor}").resources.where(item: resource[:item]).pluck(:amount).first.to_i >= resource[:amount].to_i
  end

  def check_points
    @survivor1_resources_params.each do |resource|
      @survivor1_points = Resource.points_sum(resource) + @survivor1_points
    end
    @survivor2_resources_params.each do |resource|
      @survivor2_points = Resource.points_sum(resource) + @survivor2_points
    end
  end

  def survivors
    %i[survivor1 survivor2]
  end

  def return_error(status, message)
    self.status = status
    self.message = message
  end
end
