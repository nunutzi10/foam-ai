class CreateTenants < ActiveRecord::Migration[7.0]
  def change
    create_table :tenants do |t|
      t.string :name, null: false
      t.json :settings, default: {}
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
