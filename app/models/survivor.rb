class Survivor < ApplicationRecord
  INFECTED_BITES = 3

  has_many :resources
  accepts_nested_attributes_for :resources

  validates_presence_of :name, :age, :gender, :latitude, :longitude, presence: true
  validates :gender, format: { with: /\A[M|F]\z/, message: 'Invalid gender, enter M for male and F for female.' }
  scope :infected, -> { where('infection_mark >= ?', INFECTED_BITES) }
  scope :not_infected, -> { where('infection_mark < ?', INFECTED_BITES) }

  def infected?
    infection_mark >= INFECTED_BITES
  end
end