class CreateResources < ActiveRecord::Migration[5.2]
  def change
    create_table :resources do |t|
      t.string :item
      t.integer :amount
      t.references :survivor, foreign_key: true
    end
  end
end
