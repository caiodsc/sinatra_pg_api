class CreateFaqs < ActiveRecord::Migration[5.1]
  def change
    create_table :faqs do |t|
      t.string :question
      t.string :gerente_id
      t.string :status_code
    end
  end
end