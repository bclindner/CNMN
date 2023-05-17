defmodule CNMN.Handler.Autotransform do
  @moduledoc """
  Handler for automatically transforming images in channels.
  """
  use CNMN.Handler
  alias CNMN.Image
  require Logger

  defp channels, do: Application.get_env(:cnmn, :autotransform, %{})

  def handle_event(:MESSAGE_CREATE, msg) do
    case Map.get(channels(), msg.channel_id) do
      nil -> :noop
      value ->
        Image.transform(msg, value, quiet: true)
    end
  end
end
