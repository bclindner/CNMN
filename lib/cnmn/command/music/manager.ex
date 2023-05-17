defmodule CNMN.Command.Music.Manager do
  use GenServer
  alias CNMN.Command.Music.{Track, GuildState}
  alias Nostrum.Voice

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @doc """
  Run the music player for a guild.

  This should be run on ready or any time the bot stops transmitting, to allow
  the system to pull from the queue. This is primarily used by the Consumer.
  """
  def run_player(guild_id) do
    state = GenServer.call(__MODULE__, {:get, guild_id})

    if state.playing do
      data = GenServer.call(__MODULE__, {:pop, guild_id})

      case data do
        nil -> nil
        data -> Voice.play(guild_id, data.url, data.type)
      end
    end
  end

  def get_state(guild_id) do
    GenServer.call(__MODULE__, {:get, guild_id})
  end

  @doc """
  Stop playing audio (and clear the queue).
  """
  def pause(guild_id) do
    GenServer.call(__MODULE__, {:clear, guild_id})
    Voice.pause(guild_id)
  end

  @doc """
  Resume playing audio, if paused.
  """
  def play(guild_id) do
    GenServer.call(__MODULE__, {:set_playing, guild_id, true})
    Voice.resume(guild_id)
  end

  @doc """
  Stop playing audio and clear the queue.
  """
  def stop(guild_id) do
    clear(guild_id)
    Voice.stop(guild_id)
    Voice.leave_channel(guild_id)
  end

  @doc """
  Clear the GuildState for a bot.
  This effectively clears the queue.
  """
  def clear(guild_id) do
    GenServer.call(__MODULE__, {:clear, guild_id})
  end

  @doc """
  Enqueue a URL.
  """
  def push(guild_id, url) do
    data = Track.from_youtube_dl!(url)
    GenServer.cast(__MODULE__, {:push, guild_id, data})
    data
  end

  @doc """
  Skip the currently playing song.
  """
  def skip(guild_id) do
    Voice.stop(guild_id)
    GenServer.call(__MODULE__, {:peek, guild_id})
  end

  @impl true
  def init(states) do
    {:ok, states}
  end

  defp get_state(states, guild_id), do: Map.get(states, guild_id, %GuildState{})

  @impl true
  def handle_call({:get, guild_id}, _from, states) do
    {:reply, get_state(states, guild_id), states}
  end

  @impl true
  def handle_call({:clear, guild_id}, _from, states) do
    {:reply, :ok, Map.drop(states, [guild_id])}
  end

  @impl true
  def handle_call({:peek, guild_id}, _from, states) do
    track =
      get_state(states, guild_id).queue
      |> Enum.fetch(0)

    {:reply, track, states}
  end

  @impl true
  def handle_call({:pop, guild_id}, _from, states) do
    state = get_state(states, guild_id)

    case state.queue do
      [] ->
        {:reply, nil, states}

      [data] ->
        state =
          state
          |> Map.put(:queue, [])
          |> Map.put(:current, data)

        {:reply, data, Map.put(states, guild_id, state)}

      [data | queue] ->
        state =
          state
          |> Map.put(:queue, queue)
          |> Map.put(:current, data)

        {:reply, data, Map.put(states, guild_id, state)}
    end
  end

  @impl true
  def handle_call({:set_playing, guild_id, value}, _from, states) do
    state =
      get_state(states, guild_id)
      |> Map.put(:playing, value)

    {:reply, :ok, Map.put(states, guild_id, state)}
  end

  @impl true
  def handle_cast({:push, guild_id, data}, states) do
    state = get_state(states, guild_id)
    queue = state.queue ++ [data]
    state = Map.put(state, :queue, queue)
    {:noreply, Map.put(states, guild_id, state)}
  end
end
