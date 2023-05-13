import Config

config :cnmn,
  prefix: ",",
  commands: [
    CNMN.Command.Ping,
    CNMN.Command.Crunch
  ],
  admins: [82_984_152_671_985_664]

config :nostrum,
  token: System.get_env("BOT_TOKEN"),
  gateway_intents: [
    :guilds,
    :guild_messages,
    :guild_message_reactions,
    :message_content
  ]
