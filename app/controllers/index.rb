get '/' do
  # Look in app/views/index.erb
  erb :index
end

get '/request' do
  #ask for request token
  redirect request_token.authorize_url
end

get '/auth' do
  get_access_token
  redirect '/'
end


post '/tweet' do
  current_user.tweet(params[:tweet_message])
end


get '/status/:job_id' do
  job_is_complete(params[:job_id]).to_s
end



# post '/tweet' do
#   options = { status: params[:tweet_message] }

#   uri = URI.new('https://api.twitter.com/1/statuses/update.json')

#   uri.query = {

#     }.to_param
#   HTTParty.post("https://api.twitter.com/1/statuses/update.json", options)
# end
