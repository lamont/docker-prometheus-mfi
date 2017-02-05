require 'sinatra'
require_relative 'mfi_ssh'
 
#Bound to this address so that external hosts can access it, VERY IMPORTANT!
set :bind, '0.0.0.0'
 
set :logging, true
 
get '/' do
  "hello #{ENV['MFI_USER']}"
end

get '/metrics' do
  # I should import a key and use that, not a password
  mfi = Mfi_exporter.new
  mfi.metrics(ENV['MFI_HOST'], ENV['MFI_USER'], ENV['MFI_PASS'])
end