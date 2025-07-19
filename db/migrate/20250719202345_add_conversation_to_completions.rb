class AddConversationToCompletions < ActiveRecord::Migration[7.0]
  def change
    add_reference :completions, :conversation, null: true, foreign_key: true
  end
end
