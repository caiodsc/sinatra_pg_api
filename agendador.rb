require 'rufus-scheduler'
require 'sinatra'
ENV['TZ'] = 'America/Curacao'
class Scheduler < Sinatra::Base

scheduler = Rufus::Scheduler.new

scheduler.every '3s' do
  p "Hello world"
end

scheduler.join
end