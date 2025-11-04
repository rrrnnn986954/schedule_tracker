class CreateTrackedSessions < ActiveRecord::Migration[7.1]
  def change
    create_table :tracked_sessions do |t|
      t.datetime :started_at
      t.datetime :ended_at
      t.references :user, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
