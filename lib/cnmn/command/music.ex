defmodule CNMN.Command.Music do
  @command_name "music"
  @command_desc "Play music."

  use CNMN.Command
  alias CNMN.Util
  alias Nostrum.Voice
  alias Nostrum.Cache.{GuildCache}
  alias CNMN.Command.Music.{Agent, Consumer}

  def usage(cmdname),
    do: """
    #{cmdname}: Print queue.
    #{cmdname} join: Join your channel. (Note that this clears the queue if disconnected or moving channels.)
    #{cmdname} play <url>: Play a YTDL-compatible URL (YouTube, Bandcamp, etc.)
    #{cmdname} stop: Stop playing music.
    """

  @spec get_user_channel(Nostrum.Snowflake.t(), Nostrum.Snowflake.t()) ::
          Nostrum.Snowflake.t() | nil
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

      channel_id ->
        channel_id
    end
  end

  defp play(guild_id, channel_id, url) do
    # if we are not currently playing, clear the queue
    unless Voice.playing?(guild_id) do
      Agent.clear(guild_id)
    end

    # queue it up (early, so the voice consumer can get to it)
    Agent.push(guild_id, url)
    # if we are not in the user's channel, join their channel
    if Voice.get_channel_id(guild_id) != channel_id do
      Voice.join_channel(guild_id, channel_id)
    end

    # finally, if we are ready and not playing, then let's run the player
    if Voice.ready?(guild_id) && !Voice.playing?(guild_id) do
      Consumer.run_player(guild_id)
    end
  end

  # with join arg, join the user's channel
  def handle(["join"], msg) do
    voice_channel_id = ensure_user_in_voice(msg)

    unless voice_channel_id == nil do
      Voice.join_channel(msg.guild_id, voice_channel_id)
    end
  end

  # with the play arg and a ytdl-compatible url, play the url in the user's
  # joined channel
  def handle(["play", url], msg) do
    channel_id = ensure_user_in_voice(msg)

    unless channel_id == nil do
      play(msg.guild_id, channel_id, {url, :ytdl})
      # Notify the user that we have added the URL to the queue
      Util.reply!(msg, "Added to queue: #{url}")
    end
  end

  # with the stop arg, leave the channel
  def handle(["stop"], msg) do
    channel_id = ensure_user_in_voice(msg)

    unless channel_id == nil do
      if channel_id == Voice.get_channel_id(msg.guild_id) do
        Voice.leave_channel(msg.guild_id)
        Util.reply!(msg, "Stopped.")
      else
        Util.reply!(msg, "You aren't in the correct channel to do that.")
      end
    end
  end

  # with no args, simply print the guild queue
  def handle(_args, msg) do
    voice_channel_id = ensure_user_in_voice(msg)

    unless voice_channel_id == nil do
      reply_text =
        case Agent.get(msg.guild_id) do
          [] -> "No songs queued right now."
          urls -> Enum.each(urls, &("Queue:\n- " <> Enum.join(&1, "\n- ")))
        end

      Util.reply!(msg, reply_text)
    end
  end
end
