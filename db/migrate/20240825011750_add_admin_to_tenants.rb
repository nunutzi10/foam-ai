class AddAdminToTenants < ActiveRecord::Migration[7.0]
  def change
    add_column :admins, :tenant_id, :bigint
    add_foreign_key :admins, :tenants, index: true
  end
end
