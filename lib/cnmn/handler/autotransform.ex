defmodule CNMN.Handler.Autotransform do
  @moduledoc """
  Handler for automatically transforming images in channels.
  """
  use CNMN.Handler
  alias CNMN.{Media, Util}
  require Logger

  defp channels, do: Application.get_env(:cnmn, :autotransform, %{})

  def handle_event(:MESSAGE_CREATE, msg) do
    case Map.fetch(channels(), msg.channel_id) do
      :error ->
        :noop

      {:ok, value} ->
        if msg.author.bot == nil do
          case Util.find_media!(msg, quiet: true) do
            nil -> :noop
            url -> Media.transform(msg, url, value)
          end
        end
    end
  end
end
