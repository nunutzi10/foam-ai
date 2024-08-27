class AddUserToTenants < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :tenant_id, :bigint
    add_foreign_key :users, :tenants, index: true
  end
end
