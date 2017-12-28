class CreateFaqs < ActiveRecord::Migration[5.1]
  def change
    create_table :faqs do |t|
      t.string :question
      #t.integer :manager_id
      t.references :manager, index: true, foreign_key: true
      #t.string :status_code
      t.string :status_ap
      t.timestamps
    end
  end
end

