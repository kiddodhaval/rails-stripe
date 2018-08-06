class CreateUsers < ActiveRecord::Migration
  def change
    add_column :users, :stripe_id, :string, default: :null
  end
end
