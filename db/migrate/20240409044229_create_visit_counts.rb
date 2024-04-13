class CreateVisitCounts < ActiveRecord::Migration[7.0]
  def change
    create_table :visit_counts do |t|
      t.date :date, null: false
      t.integer :count, null: false, default: 0
    end
  end
end
