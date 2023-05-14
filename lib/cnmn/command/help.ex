defmodule CNMN.Command.Help do
  @command_name "help"
  @command_desc "List commands and show help information."

  use CNMN.Command
  alias CNMN.CommandRouter, as: Router
  alias CNMN.Util.Reply

  def usage(cmdname),
    do: """
      "#{cmdname}" on its own lists all commands.
      "#{cmdname} <command>" gives usage for a specific command.
    """

  # name of a command including the CommandRouter prefix
  defp cmdname(cmd), do: Router.prefix() <> cmd.name()

  # a map of registered commands to names
  defp cmdmap, do: Map.new(Router.commands(), &{&1.name(), &1})

  # command summary string
  defp command_summary(cmd), do: "**" <> cmd.name() <> ":** " <> cmd.desc()

  # all command summaries (for !help)
  defp command_summaries do
    Enum.map(Router.commands(), &command_summary(&1))
    |> Enum.join("\n")
  end

  # command description string (for !help <command>)
  defp command_desc(cmd) do
    command_summary(cmd) <> "\n\n" <> cmd.usage(cmdname(cmd))
  end

  def handle([cmdname], msg) do
    response =
      case Map.fetch(cmdmap(), cmdname) do
        {:ok, cmd} -> command_desc(cmd)
        :error -> "No command found for \"#{cmdname}\""
      end

    Reply.text!(
      response,
      msg
    )
  end

  def handle(_args, msg) do
    Reply.text!(
      "Commands:\n" <> command_summaries(),
      msg
    )
  end
end
