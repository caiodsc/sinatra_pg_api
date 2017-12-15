class Chatbot
  def self.call
  end

  def self.send_alert(id, text)
    Bot.deliver({
                    recipient: {
                        id: id
                    },
                    message: {
                        text: text,
                        quick_replies: [
                            {
                                content_type: 'text',
                                title: 'Próxima',
                                payload: 'Próxima Aprovação'
                            },
                            {
                                content_type: 'text',
                                title: 'Ocupado',
                                payload: 'HARMLESS'
                            }
                        ]
                    }
                }, access_token: ACCESS_TOKEN)
  end

  def self.send_next_approval(id, text, payload)
    Bot.deliver({
                    recipient: {
                        id: id
                    },
                    message: {
                        attachment: {
                            type: 'template',
                            payload: {
                                template_type: 'button',
                                text: "Opções:",
                                buttons: [
                                    { type: 'postback', title: 'Mais Informações', payload: 'HARMLESS' },
                                    { type: 'postback', title: 'Aprovar', payload: 'HARMLESS' },
                                    { type: 'postback', title: 'Reprovar', payload: 'EXTERMINATE' }
                                ]
                            }
                        }
                    }
                }, access_token: ACCESS_TOKEN)
  end
  def self.send_example(id, text, payload)
    Bot.deliver({
                    recipient: {
                        id: id
                    },
                    message: {
                        attachment: {
                            type: 'template',
                            payload: {
                                template_type: 'generic',
                                elements: [
                                    {
                                        title: 'Opções:',
                                        buttons: [
                                            { type: 'postback', title: 'Mais Informações', payload: 'HARMLESS' },
                                            { type: 'postback', title: 'Aprovar', payload: 'HARMLESS' },
                                            { type: 'postback', title: 'Reprovar', payload: 'EXTERMINATE' }
                                        ]
                                    }
                                ]
                            }
                        }
                    }
                }, access_token: ACCESS_TOKEN)
  end
end
