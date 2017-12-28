require 'faker'
require 'lerolero_generator'


Manager.create!(:name => "Caio Câmara", :user_id => "100022992257363", :last_activity => Time.now)
Manager.create!(:name => "Sonny Miranda", :user_id => "100019196164902", :last_activity => Time.now)
Manager.create!(:name => "Adriano Cunha", :user_id => "100022828969944", :last_activity => Time.now)

gerentes = Manager.all

puts "Cadastrando os faqs..."
status_codes = ["read", "unread"]
gerentes_id = %w( 1 ) #%w(100019196164902 100022992257363 100022828969944)
cliente_kind = %w(Azul Prata Ouro Diamante)
yes_no = %w(SIM NÃO)
conceito_oo = ["Em PCI", "Registro no SPC", "Parcela em atraso", "Em dia"]
conceito_p = %w(Pendente Repactuação CANCELADO Liquidado)

10.times do |i|
sal = Faker::Number.between(1, 19)
n_parcelas = Faker::Number.between(2, 12)
val = Faker::Number.between(1, 5)
parcelas = val.to_i * 1000 / n_parcelas.to_i
cred =  Faker::Number.between(3, 9)
saldo = val.to_i * 1000 - cred.to_i * 100
message ="Código: #{Faker::Number.number(7)}
Cliente
Nome: #{Faker::Name.name}

Cliente #{cliente_kind.sample}

Funcionário: #{yes_no.sample}
Salario:
R$ #{sal}001,00 - R$ #{sal.to_i + 1}000,00

Últimos Conceitos::
Conceito OO - #{conceito_oo.sample}
Conceito OO - #{conceito_oo.sample}
Conceito #{conceito_p.sample}

Valor da Compra: R$ #{val}000,00
Pagamento: 0+#{n_parcelas} x R$ #{parcelas},00
Saldo acima do limite do cliente: R$ #{saldo},00

Limites
Crédito Bemol: R$ #{cred}00,00
Limite Disponível: R$ #{cred}00,00
Adicional Neurotech: R$ #{["1","2"].sample}#{Faker::Number.between(1, 9)}00,00

Contratos em Atraso: #{yes_no.sample}
Restrição de Crédito: #{yes_no.sample}"

  Faq.create!(
      question: message,#LeroleroGenerator.sentence([1,2,3].sample),
      #manager_id: gerentes_id.sample.to_i #Faker::Code.ean,
      manager_id: gerentes.sample.id #Faker::Code.ean,
      #status_code: status_codes.sample
  )
end
puts "Faqs cadastrados com sucesso!"