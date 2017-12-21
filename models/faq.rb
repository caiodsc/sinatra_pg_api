class Faq < ActiveRecord::Base
  validates_presence_of :question, :gerente_id#, :status_code
end