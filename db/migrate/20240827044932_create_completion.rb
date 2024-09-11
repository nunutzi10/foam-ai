class CreateCompletion < ActiveRecord::Migration[7.0]
  def change
    create_table :completions do |t|
      t.references :bot, null: false, foreign_key: true
      t.integer :status, default: 0
      t.string :prompt
      t.text :full_prompt
      t.json :context
      t.string :response
      t.json :metadata

      t.timestamps
    end
  end
end
