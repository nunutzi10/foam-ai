# frozen_string_literal: true

class RemoveApiIdAndApiKeyFromAdmins < ActiveRecord::Migration[7.0]
  def change
    remove_column :admins, :api_id
    remove_column :admins, :api_key
  end
end
