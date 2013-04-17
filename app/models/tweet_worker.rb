class TweetWorker
  include Sidekiq::Worker

  def perform(user_id, tweet_status)
    user = User.find(user_id)
    tweet = user.tweets.create(body: tweet_status)
    twitter_client = Twitter::Client.new(
      :oauth_token => user.token,
      :oauth_token_secret => user.secret
    )
    twitter_client.update(tweet_status)
  end

end
