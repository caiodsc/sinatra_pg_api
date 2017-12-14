require 'json'
require 'sinatra'
require 'sinatra/activerecord'
require './config/database'
require './chatbot'

# Avoid Certificate Verification (OpenSSL::SSL::SSLError)
require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

# Secrets
APP_SECRET = '7295f5ec14f1490ff94d00a2ea4cfcfe'
ACCESS_TOKEN = 'DQVJ0U3hRczU0VElnQXdIYXlNbExIblBWZAXM3d2pHcEx3RHBUa3VlLWpNdjR6ejFBdElpa0dOSWhaLWx5T2ZAZAT2J6eFkzOFJBbjR1eW53WWFrd1NabmRaTVVUOGRGQURQTk9PeWRmc1E4VkJKTXdjanRpOWlwWkxoUVkydmxtRkxxVDY0bTJVMl81R0pSX2R1STNJckNPbExqODVsTVYzU3ppSnlqbHR3emlzX1VCQUtueDdhOFE3M0xQcUpzNEZAzV3ZAsQ2pB'
VERIFY_TOKEN = 'bemol99'
USER_AUTH = 'admin'
PASSWORD_AUTH = 'bemol99'

# Include Facebook Messenger
include Facebook::Messenger

# Subscribe Messenger Access Token for Bot
Facebook::Messenger::Subscriptions.subscribe(access_token: ACCESS_TOKEN)

Dir["./models/*.rb"].each {|file| require file }


class App < Sinatra::Base

  get '/schedule/new' do
    erb :schedule_new
  end

  get '/login' do
    erb :login
  end

  post '/login' do
    redirect request.base_url + '/home'
  end

  get '/home' do
    erb :home
  end

  post '/webhook' do
    result = JSON.parse(request.body.read)['result']
    action = result['action']
    parameters = result['contexts'][0]['parameters']
    messenger_id = parameters['facebook_sender_id']
    if result['contexts'].present?
      #response = InterpretService.call(result['action'], result['contexts'][0]['parameters'])
      response = result
    else
      #response = InterpretService.call(result['action'], result['parameters'])
      response = result
    end
    case result['action']
      when 'get_next_approval'
        faq = Faq.where(:gerente_id => messenger_id, :status_code => "unread").take(1)
        Chatbot.send_next_approval(messenger_id, faq[0][:question].to_s, "test")
        #content_type :json
        #{
        #    "speech": faq[0][:question].to_s,
        #    "displayText": faq[0][:question].to_s,
        #    "source": 'ChatBot'
        #}.to_json
      else
        # type code here
    end

  end

  get '/aprovacoes' do
    content_type :json
    [{
        "gerente_messenger_id": "100022992257363",
        "message": "Uma venda necessita da sua aprovação:",
    }].to_json
  end

  get '/faqs' do
    return Faq.all.to_json
  end

  get '/faqs/read' do
    return Faq.where(:status_code => "read").to_json
  end

  get '/faqs/info' do
    faqs = Faq.where(:status_code => "unread")
    if faqs.empty?
      return {}.to_json
    else
      return (faqs.each_with_object(Hash.new(0)) { |faq ,counts| counts[faq[:gerente_id]] += 1 }).to_json
    end
  end

  get '/faqs/unread' do
    faqs = Faq.where(:status_code => "unread")
    if faqs.empty?
      return [].to_json
    else
      faqs.each do |f|
        f.update(:status_code => "read")
      end
    end
    return faqs.to_json
  end

  get '/faqs/:id' do
    begin
      return Faq.find(params[:id]).to_json
    rescue ActiveRecord::RecordNotFound
      return {}.to_json
    end
  end

  post '/faqs' do
    faq_params = JSON.parse(request.body.read)
    faq_params[:status_code] = "unread"
    faq = Faq.new(faq_params)
    if faq.save
      return faq.to_json
    else
      return faq.errors
    end
  end

  delete '/faqs/:id' do
    if Faq.delete(params[:id]) == 1
      return {:message => "Deletado com sucesso!"}.to_json
    else
      return {:message => "Não foi possível deletar este recurso!"}.to_json
    end
  end

  patch '/faqs/:id' do
    faq_params = JSON.parse(request.body.read)
    Faq.find(params[:id]).update(faq_params)
    return { :message => "Updated!"}.to_json
  end

  get '/faqs/gerente/:id' do
    faqs = Faq.where(:gerente_id => params[:id], :status_code => "unread")
    faqs.to_json
  end

  get '/faqs/gerente/:id/first' do
    faq = Faq.where(:gerente_id => params[:id], :status_code => "unread").take(1)
    faq.to_json
  end


end