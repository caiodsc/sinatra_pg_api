require 'faker'
require 'lerolero_generator'

puts "Cadastrando os faqs..."
status_codes = ["read", "unread"]
gerentes_id = %w(100019196164902 100022992257363 100022828969944)
50.times do |i|
  Faq.create!(
      question: LeroleroGenerator.sentence([1,2,3].sample),
      gerente_id: gerentes_id.sample, #Faker::Code.ean,
      status_code: status_codes.sample
  )
end
puts "Faqs cadastrados com sucesso!"