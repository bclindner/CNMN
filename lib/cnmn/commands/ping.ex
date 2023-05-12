defmodule CNMN.Commands.Ping do
  use CNMN.Command
  alias CNMN.Util

  def name, do: "ping"

  def handle([content, name], msg) do
    Util.reply(
      msg,
      content <> ", " <> name <> "!"
    )
  end

  def handle([content], msg) do
    Util.reply(
      msg,
      content
    )

    :ok
  end

  def handle(_args, msg) do
    Util.reply(
      msg,
      "pong!"
    )

    :ok
  end
end
