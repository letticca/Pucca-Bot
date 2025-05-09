import Config

config :nostrum,
  token: System.get_env("DISCORD_BOT_TOKEN"),
  ffmpeg: :nil,
  gateway_intents: :all
