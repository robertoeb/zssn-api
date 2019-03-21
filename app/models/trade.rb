class Trade
  attr_reader :survivor_1, :survivor_2, :resources_hash_1, :resources_hash_2
  attr_accessor :valid, :status, :message

  def initialize(survivor_1, survivor_2, survivor_1_resources_params, survivor_2_resources_params)
    @survivor_1 = survivor_1
    @survivor_2 = survivor_2
    @survivor_1_resources_params = survivor_1_resources_params
    @survivor_2_resources_params = survivor_2_resources_params
    @survivor_1_resources = []
    @survivor_2_resources = []
    @survivor_1_points = 0
    @survivor_2_points = 0
    @valid = false
    @status = nil
    @message = ''
  end

  def process
    check_infection
    check_inconsistent_resources
    check_trade_points
    trade_resources
  rescue TradeError => e
    return_error(e.status, e.message)
  end

  private

  def check_infection
    survivors.each do |survivor|
      if instance_variable_get("@#{survivor}").infected?
        raise TradeError.new(:conflict),
              "#{survivor.to_s.humanize} It's a walker! Run or kill him!"
      end
    end
  end

  def check_inconsistent_resources
    survivors.each do |survivor|
      instance_variable_get("@#{survivor}_resources_params").each do |resource|
        unless valid_resources?(survivor, resource)
          raise TradeError.new(:unprocessable_entity),
                "Invalid resources for #{survivor.to_s.humanize}"
        end
        instance_variable_set "@#{survivor}_resources",
                              instance_variable_get("@#{survivor}_resources") +
                              instance_variable_get("@#{survivor}")
                              .resources.where(type: resource[:type])
                              .first(resource[:amount].to_i)
      end
    end
  end

  def check_trade_points
    survivors.each do |survivor|
      instance_variable_set "@#{survivor}_points",
                            instance_variable_get("@#{survivor}_resources").map(&:points).inject(:+)
    end

    unless @survivor_1_points == @survivor_2_points
      raise TradeError.new(:unprocessable_entity),
            'Invalid amount of points between both sides'
    end
  end

  def trade_resources
    Resource.where(id: @survivor_1_resources).update_all(survivor_id: @survivor_2.id)
    Resource.where(id: @survivor_2_resources).update_all(survivor_id: @survivor_1.id)

    self.valid = true
    self.message = 'Resources were traded successfully'
  end

  def survivors
    [:survivor_1, :survivor_2]
  end

  def valid_resources?(survivor, resource)
    instance_variable_get("@#{survivor}").resources.where(type: resource[:type])
                                         .count >= resource[:amount].to_i
  end

  def return_error(status, message)
    self.status = status
    self.message = message
  end
end
