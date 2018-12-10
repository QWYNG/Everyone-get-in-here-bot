require 'discordrb'
require 'yaml'
CONFIG = YAML.load_file('config/config.yaml')
TEXT_CHANNEL_TYPE_NUMBER = 0
TWO_HOUR_SEC = 7200

bot = Discordrb::Commands::CommandBot.new token: CONFIG['token']
user_played_game_hash = {}

bot.playing do |event|
  now_playng_game = event.user.game
  user_name = event.user.name

  if now_playng_game && now_playng_game != user_played_game_hash[user_name]
    # 最初に見つけたテキストチャンネルをfirst_text_channelに代入
    first_text_channel = nil
    event.server.channels.each do |channel|
      first_text_channel ||= channel if channel.type == TEXT_CHANNEL_TYPE_NUMBER
      break if first_text_channel
    end
    # メッセージを送信
    event.bot.send_message(first_text_channel, "#{user_name} playing #{now_playng_game} now!")
    # プレイしてるゲームをuser_played_game_hashに記録
    user_played_game_hash[user_name] = now_playng_game
    # 二時間後に記録はリセット
    sleep(TWO_HOUR_SEC)
    user_played_game_hash.delete(user_name)
  end
end

bot.run
