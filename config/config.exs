import Config

config :cnmn,
  prefix: ",",
  commands: [
    CNMN.Command.Help,
    CNMN.Command.Ping,
    CNMN.Command.Music,
    CNMN.Command.Crunch
  ]

config :nostrum,
  gateway_intents: [
    :guilds,
    :guild_messages,
    :guild_message_reactions,
    :guild_voice_states,
    :message_content
  ],
  youtubedl: "yt-dlp"
