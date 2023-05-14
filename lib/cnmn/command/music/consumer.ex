defmodule CNMN.Command.Music.Consumer do
  @moduledoc """
  Consumer for CNMN voice events. Passes to the Music.Manager.
  """
  use Nostrum.Consumer
  alias CNMN.Command.Music.Manager

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

  def handle_event(_other) do
    :noop
  end
end
