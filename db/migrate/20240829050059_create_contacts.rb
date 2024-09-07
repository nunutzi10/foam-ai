class CreateContacts < ActiveRecord::Migration[7.0]
  def change
    create_table :contacts do |t|
      t.references :tenant, foreign_key: true
      t.string :name
      t.string :last_name
      t.string :email
      t.string :phone

      t.timestamps
    end
  end
end
