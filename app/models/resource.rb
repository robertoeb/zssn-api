class Resource < ApplicationRecord
  belongs_to :survivor, optional: true

  scope :water, -> { where(type: 'Water') }
  scope :food, -> { where(type: 'Food') }
  scope :medication, -> { where(type: 'Medication') }
  scope :ammunition, -> { where(type: 'Ammunition') }
end