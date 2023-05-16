defmodule CNMN.CommandRouter do
  @moduledoc """
  Router for CNMN's plain-text command messages. Uses CNMN.Command modules
  specified in the application config to handle percieved commands when a
  message is received.
  """

  require Logger

  @doc """
  Prefix the CommandRouter is checking each message for.
  """
  def prefix, do: Application.fetch_env!(:cnmn, :prefix)

  @doc """
  Commands the CommandRouter is allowing to handle its commands.
  This is pulled from the Application configuration.
  """
  def commands, do: Application.fetch_env!(:cnmn, :commands)

  defp is_command(msg), do: String.starts_with?(msg.content, prefix())

  defp tokenize(string) do
    prefix_len = byte_size(prefix())

    string
    # cut the prefix
    |> binary_part(prefix_len, byte_size(string) - prefix_len)
    # split into string
    |> String.split(" ", trim: true)
  end

  defp handle_command(msg, [handler | handlers]) do
    [cmdname | args] = tokenize(msg.content)
    handler.handle(cmdname, args, msg)
    handle_command(msg, handlers)
  end

  defp handle_command(_msg, []) do
    :ok
  end

  def handle_message(msg) do
    if is_command(msg) do
      Logger.info("Processing command: #{msg.content}",
        msgid: msg.id,
        userid: msg.author.id,
        command: msg.content
      )
      handle_command(msg, commands())
    end
  end
end
