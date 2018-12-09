require 'discordrb'
require 'yaml'
CONFIG = YAML.load_file('config/config.yaml')
TEXT_CHANNEL_TYPE_NUMBER = 0

bot = Discordrb::Commands::CommandBot.new token: CONFIG['token']

bot.playing do |event|
  if event.user.game
    first_text_channel = nil
    event.server.channels.each do |channel|
      first_text_channel ||= channel if channel.type == TEXT_CHANNEL_TYPE_NUMBER
      break if first_text_channel
    end
    event.bot.send_message(first_text_channel, "#{event.user.name} playing #{event.user.game} now!")
  end
end

bot.run
