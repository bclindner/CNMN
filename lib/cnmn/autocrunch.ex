defmodule CNMN.Autocrunch do
  @moduledoc """
  Handler for automatically crunching images in a set of channels.
  """
  alias CNMN.Image

  defp enabled_channels, do: Application.get_env(:cnmn, :autocrunch_channels, [])

  @spec handle_message(Nostrum.Struct.Message.t()) :: term
  def handle_message(msg) do
    if Enum.member?(enabled_channels(), msg.channel_id) do
      Image.transform(msg, &Image.crunch/2, quiet: true)
    end
  end
end
