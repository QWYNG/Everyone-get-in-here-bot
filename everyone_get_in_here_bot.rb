require 'discordrb'
require 'yaml'
CONFIG = YAML.load_file('config/config.yaml')
TEXT_CHANNEL_TYPE_NUMBER = 0
TWO_HOUR_SEC = 7200

bot = Discordrb::Commands::CommandBot.new token: CONFIG['token']
user_before_playing_game_hash = {}

bot.playing do |event|
  user_name = event.user.name
  now_playng_game = event.user.game
  before_playing_game = user_before_playing_game_hash[user_name]

  # ゲームをプレイしはじめてかつ前プレイしてるゲームと違うときのみ反応
  if now_playng_game && now_playng_game != before_playing_game
    # 最初に見つけたテキストチャンネルをfirst_text_channelに代入
    first_text_channel = nil
    event.server.channels.each do |channel|
      first_text_channel ||= channel if channel.type == TEXT_CHANNEL_TYPE_NUMBER
      break if first_text_channel
    end
    # メッセージを送信
    event.bot.send_message(first_text_channel, "#{user_name} playing #{now_playng_game} now!")
    # プレイしてるゲームをuser_played_game_hashに記録
    user_before_playing_game_hash[user_name] = now_playng_game
    # 二時間後に記録はリセット。以前のゲームの記録リセットするスレッドあればkillする
    sleep(30)
    user_before_playing_game_hash.delete(user_name) if user_before_playing_game_hash[user_name] == now_playng_game
  end
end

bot.run
