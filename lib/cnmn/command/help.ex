defmodule CNMN.Command.Help do
  @command_name "help"
  @command_desc "List commands and show help information."

  use CNMN.Command
  alias CNMN.CommandRouter, as: Router

  def usage(cmdname),
    do: """
    "#{cmdname}" on its own lists all commands.
    "#{cmdname} <command>" gives usage for a specific command.
    """

  @doc """
  Returns a map of registered commands to names.
  """
  def cmdmap, do: Map.new(Router.commands(), &{&1.name(), &1})

  def command_summary(cmd), do: cmd.name() <> ": " <> cmd.desc()

  def command_summaries do
    Enum.map(Router.commands(), &command_summary(&1))
    |> Enum.join("\n")
  end

  def command_desc(cmd) do
    command_summary(cmd) <> "\n\n" <> cmd.usage(Router.prefix() <> cmd.name())
  end

  def handle([cmdname], msg) do
    response =
      case Map.fetch(cmdmap(), cmdname) do
        {:ok, cmd} -> command_desc(cmd)
        :error -> "No command found for \"#{cmdname}\""
      end

    Util.reply!(
      msg,
      response
    )
  end

  def handle(_args, msg) do
    Util.reply!(
      msg,
      "Commands:\n" <> command_summaries()
    )
  end
end
