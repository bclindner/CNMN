defmodule CNMN.Consumer do
  @moduledoc """
  Root consumer for CNMN event handling.
  Sends events to all important parts of the bot platform.
  """
  use Nostrum.Consumer
  alias Nostrum.Api
  require CNMN.Application
  require Logger

  def handlers, do: Application.fetch_env!(:cnmn, :handlers)

  def status_string do
    extra =
      if Enum.member?(handlers(), CNMN.Handler.Router) do
        prefix = CNMN.Handler.Router.prefix()
        "(#{prefix}help)"
      end

    "Hi-Fi Rush #{extra}"
  end

  def handle_event({:READY, evt, _ws_state}) do
    # set status and log that we are ready
    version = CNMN.Application.version()
    Api.update_status(:online, status_string())
    username = evt.user.username <> "#" <> evt.user.discriminator

    Logger.info("CNMN v#{version} connected as #{username}",
      version: version,
      username: username
    )
  end

  def handle_event(evt) do
    run_handlers(evt)
  end

  @doc """
  Run all handlers associated with the Consumer.
  """
  def run_handlers(evt, handlers \\ handlers())

  def run_handlers(evt, [handler | handlers]) do
    handler.handle_event(evt)
    run_handlers(evt, handlers)
  end

  def run_handlers(_evt, []) do
    :noop
  end
end
