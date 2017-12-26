class Manager < ActiveRecord::Base
  #validates_presence_of :question, :gerente_id#, :status_code
  has_many :faqs
  accepts_nested_attributes_for :faqs, allow_destroy:  true
end