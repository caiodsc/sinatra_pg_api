require 'rufus-scheduler'
require 'sinatra'
require 'rest-client'
require 'facebook/messenger'
require 'json'
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

# Define Time Zone
ENV['TZ'] = 'America/Curacao'

class Scheduler < Sinatra::Base
    scheduler = Rufus::Scheduler.new
    #Chatbot.call
    scheduler.in '30s' do
      messages = RestClient.get 'http://8a7584ea.ngrok.io/faqs/info'
      formated_hash = JSON.parse(messages.body)
      if formated_hash.empty?
        p "Empty faqs"
      else
        formated_hash.each_pair do |k,v|
          Chatbot.send_alert(k, "Olá 😃\nVocê possui #{v} solicitações de aprovação de credito para análise!")
        end
      end
    end
    scheduler.join
end

