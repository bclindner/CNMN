defmodule CNMN.Command.Music do
  @command_name "music"
  @command_desc "Play music."

  use CNMN.Command
  alias CNMN.Util.Reply
  alias Nostrum.Struct.Embed
  alias Nostrum.Voice
  alias Nostrum.Cache.GuildCache
  alias CNMN.Music.Manager

  def usage(cmdname),
    do: """
    #{cmdname}: Print queue.
    #{cmdname} join: Join your channel. (Note that this clears the queue if disconnected or moving channels.)
    #{cmdname} play <url>: Play a YTDL-compatible URL (YouTube, Bandcamp, etc.)
    #{cmdname} stop: Stop playing music.
    """

  # checks for user connectivity
  @spec get_user_channel(Nostrum.Snowflake.t(), Nostrum.Snowflake.t()) ::
          Nostrum.Snowflake.t() | nil
  defp get_user_channel(guild_id, user_id) do
    guild_id
    |> GuildCache.get!()
    |> Map.get(:voice_states)
    |> Enum.find(%{}, fn v -> v.user_id == user_id end)
    |> Map.get(:channel_id)
  end

  defp ensure_user_in_voice(msg) do
    case get_user_channel(msg.guild_id, msg.author.id) do
      nil ->
        Reply.text!("You are not currently in a voice channel.", msg)

        nil

      channel_id ->
        channel_id
    end
  end

  def ensure_user_in_same_channel(msg) do
    channel_id = ensure_user_in_voice(msg)

    case channel_id do
      nil ->
        nil

      channel_id ->
        if channel_id != Voice.get_channel_id(msg.guild_id) do
          Reply.text!(
            "You have to be in the same voice channel as the bot to do that.",
            msg
          )

          nil
        end

        channel_id
    end
  end

  # player queue string builder
  defp queue_string(tracks, strings \\ [], count \\ 1)

  defp queue_string([track | queue], strings, count) do
    queue_string(queue, strings ++ ["**#{count}.** #{track.title}"], count + 1)
  end

  defp queue_string([], [], _count) do
    "No items in queue"
  end

  defp queue_string([], strings, _count) do
    Enum.join(strings, "\n")
  end

  # with no args, simply print the guild queue
  def handle([], msg) do
    voice_channel_id = ensure_user_in_voice(msg)

    unless voice_channel_id == nil do
      state = Manager.get_state(msg.guild_id)

      unless state.current == nil do
        Reply.embed!(
          %Embed{
            fields: [
              %Embed.Field{
                name: "Now Playing",
                value: state.current.title
              },
              %Embed.Field{
                name: "Queue",
                value: queue_string(state.queue)
              }
            ]
          },
          msg
        )
      else
        Reply.text!("Not currently playing anything.", msg)
      end
    end
  end

  # with the play arg and a ytdl-compatible url, play the url in the user's
  # joined channel
  def handle(["play", url], msg) do
    channel_id = ensure_user_in_voice(msg)

    unless channel_id == nil do
      # if we are not currently playing, clear the queue
      unless Voice.playing?(msg.guild_id) do
        Manager.clear(msg.guild_id)
      end

      # queue it up (before we join, so the manager sees it)
      data = Manager.push(msg.guild_id, url)
      # if we are not in the user's channel, join their channel
      if Voice.get_channel_id(msg.guild_id) != channel_id do
        Voice.join_channel(msg.guild_id, channel_id)
      end

      # finally, if we are ready and not playing, then let's run the player
      if Voice.ready?(msg.guild_id) && !Voice.playing?(msg.guild_id) do
        Manager.run_player(msg.guild_id)
      end

      Reply.track!(data, msg, content: "Queued:")
    end
  end

  # with the play arg and no url, resume playing
  def handle(["play"], msg) do
    unless ensure_user_in_same_channel(msg) do
      Manager.play(msg.guild_id)
      Reply.text!("Playing.", msg)
    end
  end

  # with the skip arg, skip the current song
  def handle(["skip"], msg) do
    if ensure_user_in_same_channel(msg) do
      next = Manager.skip(msg.guild_id)

      if next do
        Reply.track!(next, msg, content: "Skipped. Now playing:")
      else
        Reply.text!("Skipped.", msg)
      end
    end
  end

  # with the stop arg, stop the playing song
  def handle(["pause"], msg) do
    if ensure_user_in_same_channel(msg) != nil do
      Manager.pause(msg.guild_id)
      Reply.text!("Paused.", msg)
    end
  end

  # with the stop arg, stop the playing song
  def handle(["stop"], msg) do
    if ensure_user_in_same_channel(msg) != nil do
      Manager.stop(msg.guild_id)
      Reply.text!("Stopped.", msg)
    end
  end

end
