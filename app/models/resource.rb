class Resource < ApplicationRecord
  belongs_to :survivor, optional: true

  scope :water, -> { where(item: 'Water') }
  scope :food, -> { where(item: 'Food') }
  scope :medication, -> { where(item: 'Medication') }
  scope :ammunition, -> { where(item: 'Ammunition') }

  RESOURCES_TYPES = ['water', 'food', 'medication', 'ammunition']

  RESOURCES_POINTS = {
    water: 4,
    food: 3,
    medication: 2,
    ammunition: 1
  }.with_indifferent_access

  def self.points_sum(resource)
    resource[:amount].to_i * RESOURCES_POINTS[resource[:item].downcase]
  end
end