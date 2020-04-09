class CreateDeviseUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :devise_users do |t|

      t.timestamps
    end
  end
end
