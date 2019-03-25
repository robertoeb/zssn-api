class TradeError < StandardError
  attr_reader :status

  def initialize(status)
    @status = status
  end
end
