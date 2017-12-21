require 'rest-client'

1.times do
RestClient.post "https://api:key-8871a08ac243a011de3d516a89878b63"\
"@api.mailgun.net/v3/sandboxbff017266e8e4a6f84e7a1b174d7c576.mailgun.org/messages",
    :from => "Acqua Park <acquapark@gmail.com>",
    :to => "Caio Câmara <caio.dscamara@gmail.com>",
    :subject => "Hello Caio Câmara",
    :text => "Congratulations Caio Câmara, you just sent an email with Mailgun!  You are truly awesome!"
end
#Manager.where("job_title = 'Gerente'").or(Manager.where("job_title = 'GERENTE'"))
