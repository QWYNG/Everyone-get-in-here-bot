require 'discordrb'
require 'yaml'
CONFIG = YAML.load_file('config/config.yaml')
TEXT_CHANNEL_TYPE_NUMBER = 0
TWO_HOUR_SEC = 7200

bot = Discordrb::Commands::CommandBot.new token: CONFIG['token'], client_id: 520551630421360640, prefix: '!'
user_before_playing_game_hash = {}

def get_first_text_channel(channles)
  first_text_channel = nil
  channles.each do |channel|
    first_text_channel ||= channel if channel.type == TEXT_CHANNEL_TYPE_NUMBER
    break if first_text_channel
  end
  first_text_channel
end

bot.playing do |event|
  user_name = event.user.name
  now_playng_game = event.user.game
  before_playing_game = user_before_playing_game_hash[user_name]

  if now_playng_game && now_playng_game != before_playing_game
    first_text_channel = get_first_text_channel(event.server.channels)
    event.bot.send_message(first_text_channel, "#{user_name} playing #{now_playng_game} now!")
    user_before_playing_game_hash[user_name] = now_playng_game
    # 二時間後に記録はリセット
    sleep(TWO_HOUR_SEC)
    user_before_playing_game_hash.delete(user_name) if user_before_playing_game_hash[user_name] == now_playng_game
  end
end

bot.command :help do |event|
  event.respond("This is a bot that notifies the server that the user started the game on the server's first text channel")
end

bot.run
