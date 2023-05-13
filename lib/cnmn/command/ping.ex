defmodule CNMN.Command.Ping do
  use CNMN.Command
  alias CNMN.Util

  def name, do: "ping"

  def desc, do: "Send a message immediately when received."

  def handle(_args, msg) do
    Util.reply!(
      msg,
      CNMN.CommandRouter.prefix() <> "pong"
    )
  end
end
