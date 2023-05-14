defmodule CNMN.Command.Music.Consumer do
  @moduledoc """
  Consumer for CNMN voice events.
  """
  use Nostrum.Consumer
  alias Nostrum.Voice
  alias CNMN.Command.Music.Agent
  require Logger

  def run_player(guild_id) do
    Logger.info("player running for #{guild_id}")
    # get the first item from the queue and start playing it
    case Agent.pop(guild_id) do
      nil ->
        nil

      {url, type} ->
        Voice.play(guild_id, url, type)
    end
  end

  # if there is a speaking update and the bot is no longer speaking, then we
  # can re-run the player
  def handle_event({:VOICE_SPEAKING_UPDATE, evt, _ws_state}) do
    Logger.info("speaking update")

    if !evt.speaking && !evt.timed_out do
      run_player(evt.guild_id)
    end
  end

  def handle_event({:VOICE_READY, evt, _ws_state}) do
    run_player(evt.guild_id)
  end

  def handle_event(_other) do
    :noop
  end
end
