import Config

config :cnmn,
  prefix: ",",
  commands: [
    CNMN.Command.Ping,
    CNMN.Command.Crunch,
  ],
  admins: [82984152671985664]

config :nostrum,
  token: System.get_env("BOT_TOKEN"),
  gateway_intents: [
    :guilds,
    :guild_messages,
    :guild_message_reactions,
    :message_content
  ]

