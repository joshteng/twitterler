helpers do
  def create_consumer
    OAuth::Consumer.new(ENV['CONSUMER_KEY'], ENV['CONSUMER_SECRET'],
    :site => "https://api.twitter.com/")
  end

  def request_token
    host = request.host
    host << ":9393" if request.host == "localhost"
    consumer = create_consumer
    session[:request_token] ||=
      consumer.get_request_token(
      :oauth_callback => "http://#{host}/auth")
  end

  def get_access_token
    access_token = request_token.get_access_token(
      :oauth_verifier => params[:oauth_verifier])
    user = User.find_or_create_by_token_and_secret(access_token.token, access_token.secret)
    login(user)
    session.delete(:request_token)
  end

  def login(user)
    session[:current_user_id] = user.id
  end

  def current_user
    @current_user ||= User.find_by_id(session[:current_user_id])
  end

  def login?
    current_user ? true : false
  end

  def logout
    session.delete(:current_user_id)
  end

  def twitter_client
    Twitter::Client.new(
      :oauth_token => current_user.token,
      :oauth_token_secret => current_user.secret
    )
  end
end