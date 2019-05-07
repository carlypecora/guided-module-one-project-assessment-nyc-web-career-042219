class CreateTrains < ActiveRecord::Migration[5.2]
  def change
  	create_table :trains do |t|
  		t.string :line
  		t.string :station_near_flatiron
  	end
  end
end
