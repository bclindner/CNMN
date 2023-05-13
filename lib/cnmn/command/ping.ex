defmodule CNMN.Command.Ping do
  @command_name "ping"
  @command_desc "Send a message immediately when received."
  use CNMN.Command
  alias CNMN.Util

  def usage(cmdname), do: "Just type #{cmdname}"

  def handle(_args, msg) do
    Util.reply!(
      msg,
      CNMN.CommandRouter.prefix() <> "pong"
    )
  end
end
