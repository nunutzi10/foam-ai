class CreateBot < ActiveRecord::Migration[7.0]
  def change
    create_table :bots do |t|
      t.string :name
      t.datetime :deleted_at
      t.text :custom_instructions
      t.string :whatsapp_phone

      t.timestamps
    end

    add_reference :bots, :tenant, foreign_key: true
  end
end
