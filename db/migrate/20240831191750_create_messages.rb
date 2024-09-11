class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
      t.references :contact, foreign_key: true
      t.integer :status, default: 0
      t.integer :sender, default: 0
      t.integer :content_type, default: 0
      t.string :body
      t.string :media_url
      t.string :vonage_id
      t.string :custom_destination
      t.json :metadata

      t.timestamps
    end
  end
end