class CreateSurvivors < ActiveRecord::Migration[5.2]
  def change
    create_table :survivors do |t|
      t.string :name
      t.integer :age
      t.string :gender, limit: 1
      t.float :latitude
      t.float :longitude
      t.integer :infection_mark, default: 0
    end
  end
end
