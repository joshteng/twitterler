class CreateTweets < ActiveRecord::Migration
  def change
    create_table :tweets do |t|
      t.string :body
      t.integer :user_id
      t.boolean :tweeted
      t.timestamps
    end
    add_index :tweets, :user_id
    add_index :tweets, :tweeted
  end
end
