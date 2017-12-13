require 'faker'
require 'lerolero_generator'

puts "Cadastrando os faqs..."
status_codes = ["read", "unread", "processing"]
50.times do |i|
  Faq.create!(
      question: LeroleroGenerator.sentence([1,2,3].sample),
      gerente_id: Faker::Code.ean,
      status_code: status_codes.sample
  )
end
puts "Faqs cadastrados com sucesso!"