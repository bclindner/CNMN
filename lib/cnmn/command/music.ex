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

  @doc ~S"""
  Parse a list of CNMN.Music.Track structs into a list.

  ## Examples

      iex> CNMN.Command.Music.queue_string([%CNMN.Music.Track{title: "Test 1"}])
      "**1.** Test 1"

      iex> CNMN.Command.Music.queue_string([
      ...>  %CNMN.Music.Track{title: "Test 1"},
      ...>  %CNMN.Music.Track{title: "Test 2"}])
      "**1.** Test 1\n**2.** Test 2"

  Setting `max` will limit the max results.

      iex> CNMN.Command.Music.queue_string([
      ...>  %CNMN.Music.Track{title: "Test 1"},
      ...>  %CNMN.Music.Track{title: "Test 2"},
      ...>  %CNMN.Music.Track{title: "Test 3"},
      ...>  %CNMN.Music.Track{title: "Test 4"},
      ...>  %CNMN.Music.Track{title: "Test 5"}], [], 4)
      "**1.** Test 1\n**2.** Test 2\n**3.** Test 3\n**4.** Test 4"

  """
  def queue_string(tracks, strings \\ [], max \\ 10, count \\ 1)

  def queue_string([track | queue], strings, max, count) when count <= max do
    queue_string(queue, strings ++ ["**#{count}.** #{track.title}"], max, count + 1)
  end

  def queue_string([], [], _max, _count) do
    "No items in queue"
  end

  def queue_string(_tracks, strings, _max, _count) do
    Enum.join(strings, "\n")
  end

  # with no args, simply print the guild queue
  def handle([], msg) do
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
              name: "Queue (#{length(state.queue)} track(s))",
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
    if ensure_user_in_same_channel(msg) do
      Manager.play(msg.guild_id)
      Reply.text!("Playing.", msg)
    end
  end

  # with the skip arg and an index, skip a song at a given index (if it exists)
  def handle(["skip", idx], msg) do
    if ensure_user_in_same_channel(msg) do
      # the behavior of `Integer.parse/1` allows weird typos to potentially
      # make it through.
      # while it's probably harmless, some logic is done here to avoid
      # potentially malformatted integers from being used
      result = case Integer.parse(idx) do
        # if we failed, we just return nil
        # (we only aren't using :error because i'd rather not do another check
        # on the Manager.pop call below)
        :error -> nil
        # if the index is 0, let's assume the user is trying to skip the
        # current track, and return nothing from this function
        {0, ""} ->
          handle(["skip"], msg)
          :ok
        # if we're here, then we got a valid integer, let's send it to the
        # Manager
        {idx, ""} ->
          # subtracting 1 since the queue we expect the users to pick from is
          # 1-indexed
          Manager.pop(msg.guild_id, idx - 1)
      end
      case result do
        :nil -> Reply.text!("Invalid track number", msg)
        :ok -> :noop
        track -> Reply.text!("Skipped track #{idx} (#{track.title})", msg)
      end
    end
  end

  # with the skip arg, skip the current song
  def handle(["skip"], msg) do
    if ensure_user_in_same_channel(msg) do
      {:ok, next} = Manager.skip(msg.guild_id)

      if next do
        Reply.track!(next, msg, content: "Skipped. Now playing: #{next.title}")
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
