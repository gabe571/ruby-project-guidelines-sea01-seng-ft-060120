class CreatePhases < ActiveRecord::Migration[5.2]
  def change
    create_table :phases do |t|
      t.string :phase_name
      t.string :phase_description
    end
  end
end