import Config

config :cnmn,
  handlers: [
    CNMN.Handler.Router,
    CNMN.Handler.Autotransform,
    CNMN.Handler.Music
  ]

config :cnmn, :router,
  commands: [
    CNMN.Command.Help,
    CNMN.Command.Ping,
    CNMN.Command.Music,
    CNMN.Command.Transform
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

config :logger, :console,
  format: "$date $time [$level] $message $metadata\n",
  metadata: [
    :msgid,
    :userid
  ]

case config_env() do
  :prod ->
    import_config "prod.exs"

  _ ->
    :noop
end
