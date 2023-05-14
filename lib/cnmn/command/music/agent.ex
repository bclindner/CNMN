defmodule CNMN.Command.Music.Agent do
  use Agent

  def start_link(_init) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def clear(guild_id) do
    Agent.update(__MODULE__, &Map.put(&1, guild_id, []))
  end

  def get(guild_id) do
    Agent.get(__MODULE__, &Map.get(&1, guild_id, []))
  end

  def push(guild_id, url) do
    queue = get(guild_id)

    Agent.update(__MODULE__, fn queues ->
      Map.put(queues, guild_id, queue ++ [url])
    end)
  end

  def pop(guild_id) do
    case get(guild_id) do
      nil ->
        nil

      [] ->
        nil

      [url | queue] ->
        Agent.update(__MODULE__, fn queues ->
          Map.put(queues, guild_id, queue)
        end)

        url
    end
  end
end
