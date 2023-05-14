defmodule CNMN.Command.Ping do
  @command_name "ping"
  @command_desc "Send a message immediately when received."

  use CNMN.Command
  alias CNMN.Util.Reply

  def usage(cmdname), do: "#{cmdname} replies with a simple \"pong\" response."

  def handle(_args, msg) do
    Reply.text!(CNMN.CommandRouter.prefix() <> "pong", msg)
  end
end
