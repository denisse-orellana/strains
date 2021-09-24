class AddOenologistToWines < ActiveRecord::Migration[5.2]
  def change
    add_reference :wines, :oenologist, foreign_key: true
  end
end
