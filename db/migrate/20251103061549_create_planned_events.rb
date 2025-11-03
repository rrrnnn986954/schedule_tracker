class CreatePlannedEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :planned_events do |t|
      t.datetime :start_at
      t.datetime :end_at
      t.references :user, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
