require 'json'
require 'sinatra'
require 'sinatra/activerecord'
require 'facebook/messenger'
require './config/database'
require './chatbot'
# Avoid Certificate Verification (OpenSSL::SSL::SSLError)
require 'openssl'
#require 'puma'
require 'rack/ssl'
require_relative './encrypt_decrypt.rb'
require 'mongoid'
require 'roar/json/hal'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

# Secrets
#APP_SECRET = '7295f5ec14f1490ff94d00a2ea4cfcfe'
ACCESS_TOKEN = 'DQVJ0U3hRczU0VElnQXdIYXlNbExIblBWZAXM3d2pHcEx3RHBUa3VlLWpNdjR6ejFBdElpa0dOSWhaLWx5T2ZAZAT2J6eFkzOFJBbjR1eW53WWFrd1NabmRaTVVUOGRGQURQTk9PeWRmc1E4VkJKTXdjanRpOWlwWkxoUVkydmxtRkxxVDY0bTJVMl81R0pSX2R1STNJckNPbExqODVsTVYzU3ppSnlqbHR3emlzX1VCQUtueDdhOFE3M0xQcUpzNEZAzV3ZAsQ2pB'
VERIFY_TOKEN = 'bemol99'
USER_AUTH = 'admin'
PASSWORD_AUTH = 'bemol99'

# Include Facebook Messenger
include Facebook::Messenger
# Subscribe Messenger Access Token for Bot
Facebook::Messenger::Subscriptions.subscribe(access_token: ACCESS_TOKEN)

Dir["./models/*.rb"].each {|file| require file }

#configure { set :server, :puma }

configure do
  Mongoid.load!("config/mongoid.yml", settings.environment)
  #set :server, :puma # default to puma for performance
end

class MongoFaq
  include Mongoid::Document
  include Mongoid::Timestamps

  field :question, type: String
  #field :status_ap, type String
end

module MongoFaqRepresenter
  include Roar::JSON::HAL

  property :question
  #property :status_ap
  property :created_at, :writeable=>false

  link :self do
    "/faq/#{id}"
  end
end

class App < Sinatra::Base
  #use Rack::SSL

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
    parameters = result['contexts'][-1]['parameters']
    messenger_id = nil
    result['contexts'].each do |context|
      if !context['parameters']['facebook_sender_id'].nil?
        messenger_id = context['parameters']['facebook_sender_id']
      end
    end
    #if result['contexts'].present?
      #response = InterpretService.call(result['action'], result['contexts'][0]['parameters'])
      #response = result
    #else
      #response = InterpretService.call(result['action'], result['parameters'])
      #response = result
    #end
    case action
      when 'get_next_approval'
        #faq = Faq.where(:gerente_id => messenger_id, :status_code => "unread").take(1)
        #faq = Faq.where(:gerente_id => messenger_id, :status_ap => nil).take(1)
        man = Manager.includes(:faqs).where(:user_id => messenger_id).take(1)
        man[0].update(:last_activity => Time.now)
        faq = man[0].faqs.where(:status_ap => nil).take(1)
        while !faq.empty? && faq[0].updated_at < 10.minutes.ago do
          faq[0].update(:status_ap => "expirado")
          faq = man[0].faqs.where(:status_ap => nil).take(1)
        end
        if faq.empty?
          content_type :json
          {
              "speech": "Não há mais análises pendentes no momento! 🙂",
              "displayText": "Não há mais análises pendentes no momento! 🙂"
          }.to_json
        else
          mongo_faq = MongoFaq.new(:question => faq[0][:question].to_s)
          faq_id = mongo_faq.id.to_s
          #res = faq
          #faq[0][:status_code] = "read"
          if mongo_faq.save
            p mongo_faq
            #Chatbot.send_next_approval(messenger_id, faq[0][:question].to_s, "test")
            Chatbot.send_text(messenger_id, "Dados da Pré Venda 👇")
            Chatbot.send_text(messenger_id, faq[0][:question].to_s)
            Chatbot.send_next_approval(messenger_id, request.base_url.to_s, faq_id)
          else
            Chatbot.send_text(messenger_id, "Houve um erro ao processar a próxima aprovação, por favor tente novamente! 😥")
          end
        end

      when 'allow_first'
        #faq = Faq.where(:gerente_id => messenger_id, :status_ap => nil).take(1).first
        man = Manager.includes(:faqs).where(:user_id => messenger_id).take(1)
        man[0].update(:last_activity => Time.now)
        faq = man[0].faqs.where(:status_ap => nil).take(1)
        #p faq.size
        if faq.empty?
          content_type :json
          return {
              "speech": "Houve um erro ao processar sua análise, por favor tente novamente! 😥",
              "displayText": "Houve um erro ao processar sua análise, por favor tente novamente! 😥"
            }.to_json
        else
          faq = faq[0]
        end
        faq[:status_ap] = "aprovado"
        if faq.save
          content_type :json
          {
              "messages": [{
                "title": "Obrigado.\nSua análise foi enviada com sucesso! 😃",
                "replies": ["Próxima Aprovação"],
                "type": 2
              }]
          }.to_json
        else
          content_type :json
          {
              "speech": "Houve um erro ao processar sua análise, por favor tente novamente! 😥",
              "displayText": "Houve um erro ao processar sua análise, por favor tente novamente! 😥"
          }.to_json
        end

      when 'disallow_first'
        #faq = Faq.where(:gerente_id => messenger_id, :status_ap => nil).take(1).first
        man = Manager.includes(:faqs).where(:user_id => messenger_id).take(1)
        man[0].update(:last_activity => Time.now)
        faq = man[0].faqs.where(:status_ap => nil).take(1)
        if faq.empty?
          content_type :json
          return {
              "speech": "Houve um erro ao processar sua análise, por favor tente novamente! 😥",
              "displayText": "Houve um erro ao processar sua análise, por favor tente novamente! 😥"
            }.to_json
        else
          faq = faq[0]
        end
        faq[:status_ap] = "reprovado"
        if faq.save
          content_type :json
          {
              "messages": [{
                               "title": "Obrigado.\nSua análise foi enviada com sucesso! 😃",
                               "replies": ["Próxima Aprovação"],
                               "type": 2
                           }]
          }.to_json
        else
          content_type :json
          {
              "speech": "Houve um erro ao processar sua análise, por favor tente novamente! 😥",
              "displayText": "Houve um erro ao processar sua análise, por favor tente novamente! 😥"
          }.to_json
        end
      else
        # type code here
    end

  end

  get '/aprovacoes' do
    content_type :json
    [{
        "gerente_messenger_id": "100022992257363",
        "message": "Uma venda necessita da sua aprovação:"
    }].to_json
  end

  get '/faqs' do
    return Faq.all.to_json
  end

  get '/faqs/read' do
    return Faq.where(:status_ap => "read").to_json
  end

  get '/faqs/info' do
    faqs = Faq.where(:status_ap => nil)
    if faqs.empty?
      return {}.to_json
    else
      return (faqs.each_with_object(Hash.new(0)) { |faq ,counts| counts[faq[:manager_id]] += 1 }).to_json
    end
  end

  get '/faqs/unread' do
    faqs = Faq.where(:status_ap => "unread")
    if faqs.empty?
      return [].to_json
    else
      faqs.each do |f|
        f.update(:status_ap => "read")
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
    faq_params[:status_ap] = "unread"
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
    faqs = Faq.where(:gerente_id => params[:id], :status_ap => nil)
    faqs.to_json
  end

  get '/faqs/gerente/:id/last' do
    request_type = (JSON.parse(request.accept[0].to_json))["type"]
    p request_type
    p '100022992257363'.encrypt
    man = Manager.includes(:faqs).where(:user_id => params[:id].decrypt).take(1)
    man[0].update(:last_activity => Time.now)
    @faq = man[0].faqs.where(:status_ap => nil).take(1).first
    #p @faq["question"]
    case request_type
      when 'text/html'
        #halt haml(:index, :locals => data)
        erb :more_info
        #return request.accept[0].to_json
      when 'application/json'
        #faq = Faq.where(:gerente_id => params[:id], :status_ap => nil).take(1)
        return @faq.to_json
    end
  end

  get '/faq/:id' do
    request_type = (JSON.parse(request.accept[0].to_json))["type"]
    @faq_unformated = MongoFaq.where(:id => params[:id], :created_at => (1.minutes.ago..Time.now))
    if @faq_unformated.empty?
      return [410, {:message=>"The target resource is no longer available at the origin server and this condition is likely to be permanent."}.to_json]
    end
    @faq =  JSON.parse(MongoFaqRepresenter.for_collection.prepare(@faq_unformated).to_json)[0]
    #p @faq
    #p @faq["question"]
    case request_type
      when 'text/html'
        #halt haml(:index, :locals => data)
        erb :more_info
      #return request.accept[0].to_json
      when 'application/json'
        #faq = Faq.where(:gerente_id => params[:id], :status_ap => nil).take(1)
        return @faq.to_json
    end
  end


end