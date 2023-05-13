import Config

config :cnmn,
  prefix: ",",
  commands: [
    CNMN.Command.Ping,
    CNMN.Command.Crunch,
    CNMN.Command.Music,
  ],
  admins: [82984152671985664]

config :nostrum,
  token: System.get_env("BOT_TOKEN"),
  gateway_intents: [
    :guilds,
    :guild_messages,
    :guild_message_reactions,
    :guild_voice_states,
    :message_content
  ]

