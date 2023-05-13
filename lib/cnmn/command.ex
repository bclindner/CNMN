defmodule CNMN.Command do
  @moduledoc """
  Command declaration, usable within CNMN.CommandRouter.
  """
  @doc """
  Name of the command in question, i.e. what the user should be typing after
  the prefix to trigger the command.
  """
  @callback name() :: String.t()

  @doc """
  A short description of the command.
  """
  @callback desc() :: String.t()

  defmacro __using__(_opts) do
    quote location: :keep do
      def handle(cmdname, args, msg) do
        if cmdname == __MODULE__.name() do
          handle(args, msg)
        end
      end
    end
  end
end
