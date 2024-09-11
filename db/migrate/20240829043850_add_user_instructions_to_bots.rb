class AddUserInstructionsToBots < ActiveRecord::Migration[7.0]
  def change
    add_column :bots, :user_instructions, :text
  end
end
