defmodule CNMN.Handler.Music do
  @moduledoc """
  Handles events for music and audio.
  """
  use CNMN.Handler
  alias CNMN.Music.Manager

  # if there is a speaking update and the bot is no longer speaking, then we
  # can re-run the player
  def handle_event(:VOICE_SPEAKING_UPDATE, evt) do
    if !evt.speaking && !evt.timed_out do
      Manager.run_player(evt.guild_id)
    end
  end

  def handle_event(:VOICE_READY, evt) do
    Manager.run_player(evt.guild_id)
  end
end
