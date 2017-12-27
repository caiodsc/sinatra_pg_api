class Faq < ActiveRecord::Base
  validates_presence_of :question#, :manager_id#, :status_code
  belongs_to :manager, optional: true
end
