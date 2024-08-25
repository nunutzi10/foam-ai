class CreateApiKeys < ActiveRecord::Migration[7.0]
  def change
    create_table :api_keys do |t|
      t.string :name, null: false
      t.string :api_id, null: false
      t.string :api_key, null: false
      t.bigint :role, default: 0
      t.bigint :tenant_id
      t.index :tenant_id, name: 'index_api_keys_on_tenant_id'
      t.timestamps
    end
  end
end
