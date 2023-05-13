defmodule CNMN.Command.Music do
  @moduledoc """
  Play music.
  """
  use CNMN.Command
  alias CNMN.Util
  alias Nostrum.Voice
  alias Nostrum.Cache.{GuildCache}
  alias CNMN.Command.Music.QueueManager

  def name, do: "music"

  def desc, do: "Send a message immediately when received."

  @spec get_user_channel(Nostrum.Snowflake.t(), Nostrum.Snowflake.t()) :: Nostrum.Snowflake.t() | nil
  def get_user_channel(guild_id, user_id) do
    guild_id
    |> GuildCache.get!()
    |> Map.get(:voice_states)
    |> Enum.find(%{}, fn v -> v.user_id == user_id end)
    |> Map.get(:channel_id)
  end

  def ensure_user_in_voice(msg) do
    case get_user_channel(msg.guild_id, msg.author.id) do
      nil ->
        Util.reply!(
          msg,
          "You are not currently in a voice channel"
        )
        nil
      channel_id -> channel_id
    end
  end

  #@doc """
  #Play queued audio, if any is available - otherwise, notify the user there is
  #no audio to play.
  #"""
  #def handle(["play"], msg) do
  #end

  #@doc """
  #Play a song directly in the bot, queueing it if a song is already playing.
  #"""
  #def handle(["play", url], msg) do

  #end
  @doc """
  Join the user's channel.
  """
  def handle(["join"], msg) do
    channel_id = ensure_user_in_voice(msg)
    unless channel_id == nil do
      Voice.join_channel(msg.guild_id, channel_id)
    end
  end

  def handle(_args, msg) do
    case get_user_channel(msg.guild_id, msg.author.id) do
      nil ->
        Util.reply!(
          msg,
          "You are not currently in a voice channel!"
        )
      channel_id ->
        Voice.join_channel(msg.guild_id, channel_id)
    end
  end
end

