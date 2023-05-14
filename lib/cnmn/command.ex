defmodule CNMN.Command do
  @moduledoc """
  Command declaration, usable within CNMN.CommandRouter.
  """

  @doc """
  A longer description of how to use the command.
  """
  @callback usage(String.t()) :: String.t()

  defmacro __using__(_opts) do
    quote location: :keep do
      alias CNMN.Util
      def name, do: @command_name
      def desc, do: @command_desc

      def handle(@command_name, args, msg) do
        handle(args, msg)
      end

      def handle(_othername, args, msg) do
        :noop
      end
    end
  end
end
