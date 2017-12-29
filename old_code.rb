content_type :json
{
    "messages": [
        {
            "speech": "Dados da Pré Venda 👇",
            "type": 0
        },
        {
            "speech": faq[0][:question].to_s,
            "type": 0
        },
        {
            "buttons": [
                {
                    "text": "Mais Informações"
                },
                {
                    "postback": "Aprovar",
                    "text": "Aprovar"
                },
                {
                    "postback": "Reprovar",
                    "text": "Reprovar"
                }
            ],
            "title": "Opções:",
            "type": 1
        }
    ]
}.to_json