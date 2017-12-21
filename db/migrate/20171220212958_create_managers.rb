class CreateManagers < ActiveRecord::Migration[5.1]
  def change
    create_table :managers do |t|
      t.string :name
      t.string :mail
      t.string :user_id
      t.string :job_title
      t.string :department
      t.string :phone_number
      t.string :admin
      t.string :source
      t.string :manager_email
      t.string :last_activity
    end
  end
end