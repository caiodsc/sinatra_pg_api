require 'faker'

namespace :seeds do
  desc "Configura o nosso ambiente de desenvolvimento."
  task setup: :environment do
    puts "Cadastrando os faqs..."
    status_codes = ["read", "unread", "processing"]
    50.times do |i|
      Faq.create!(
          question: Faker::Lorem.sentence,
          gerente_id: Faker::Code.ean,
          status_code: status_codes.sample
      )
    end
    puts "Faqs cadastrados com sucesso!"
  end
end