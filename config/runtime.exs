import Config

config :nostrum,
  token: System.get_env("BOT_TOKEN")

config :cnmn, :router, prefix: System.get_env("BOT_PREFIX", "c-")

config :cnmn,
  autotransform: %{
    1_107_403_690_630_987_846 => CNMN.Media.crunch(),
    994_748_788_520_521_778 => CNMN.Media.crunch()
  }
