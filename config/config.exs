import Config

config :cnmn,
  prefix: ",",
  commands: [
    CNMN.Command.Help,
    CNMN.Command.Ping,
    CNMN.Command.Music,
    CNMN.Command.Crunch
  ],
  admins: [82_984_152_671_985_664]

config :nostrum,
  token: System.get_env("BOT_TOKEN"),
  gateway_intents: [
    :guilds,
    :guild_messages,
    :guild_message_reactions,
    :guild_voice_states,
    :message_content
  ],
  youtubedl: "yt-dlp"
