defmodule CNMN.Consumer do
  @moduledoc """
  Root consumer for CNMN event handling.
  Sends events to all important parts of the bot platform.
  """
  use Nostrum.Consumer
  alias Nostrum.Api
  alias CNMN.Command.Music.{Manager}
  require CNMN.Application
  require Logger

  def handle_event({:READY, evt, _ws_state}) do
    # set status and log that we are ready
    version = CNMN.Application.version()
    prefix = CNMN.CommandRouter.prefix()
    Api.update_status(:online, "Hi-Fi Rush (#{prefix}help, v#{version})")
    username = evt.user.username <> "#" <> evt.user.discriminator

    Logger.info("CNMN v#{version} connected as #{username} (prefix \"#{prefix}\")",
      version: version,
      username: username
    )
  end

  # if there is a speaking update and the bot is no longer speaking, then we
  # can re-run the player
  def handle_event({:VOICE_SPEAKING_UPDATE, evt, _ws_state}) do
    if !evt.speaking && !evt.timed_out do
      Manager.run_player(evt.guild_id)
    end
  end

  def handle_event({:VOICE_READY, evt, _ws_state}) do
    Manager.run_player(evt.guild_id)
  end

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    CNMN.CommandRouter.handle_message(msg)
    CNMN.Autocrunch.handle_message(msg)
  end

  def handle_event(_other) do
    :noop
  end
end
