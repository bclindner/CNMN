defmodule CNMN.Handler.Router do
  @moduledoc """
  Router for CNMN's plain-text command messages. Uses CNMN.Command modules
  specified in the application config to handle percieved commands when a
  message is received.
  """
  use CNMN.Handler

  require Logger

  def config, do: Application.fetch_env!(:cnmn, :router)

  @doc """
  Prefix the Router is checking each message for.
  """
  def prefix, do: config() |> Keyword.fetch!(:prefix)

  @doc """
  Commands the Router is allowing to handle its commands.
  This is pulled from the Application configuration.
  """
  def commands, do: config() |> Keyword.fetch!(:commands)

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

  def handle_event(:MESSAGE_CREATE, msg) do
    if is_command(msg) do
      Logger.info("Processing command: \"#{msg.content}\"",
        msgid: msg.id,
        userid: msg.author.id,
        command: msg.content
      )

      handle_command(msg, commands())
    end
  end

  def handle_event(:READY, _evt) do
    Logger.info("Router initialized (prefix \"#{prefix()}\")")
  end
end
