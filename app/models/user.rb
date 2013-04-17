class User < ActiveRecord::Base
  has_many :tweets

  def tweet(status)
    TweetWorker.perform_async(self.id, status)
  end
end
