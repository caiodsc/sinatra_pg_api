require 'json'
require 'sinatra'
require 'sinatra/activerecord'

require './config/database'

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
    if result['contexts'].present?
      #response = InterpretService.call(result['action'], result['contexts'][0]['parameters'])
      response = result
    else
      #response = InterpretService.call(result['action'], result['parameters'])
      response = result
    end

    content_type :json
    {
        "speech": response.to_s,
        "displayText": response.to_s,
        "source": 'ChatBot'
    }.to_json
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

  get '/faqs/:id' do
    return Faq.find(params[:id]).to_json
  end

  post '/faqs' do
    return @params
  end

end