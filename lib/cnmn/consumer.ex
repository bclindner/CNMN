defmodule CNMN.Consumer do
  @moduledoc """
  Root consumer for CNMN event handling.
  Sends events to all important parts of the bot platform.
  """
  use Nostrum.Consumer
  alias Nostrum.Api

  def handle_event({:READY, _evt, _ws_state}) do
    version = Application.spec(:cnmn, :vsn)
    Api.update_status(:online, "Hi-Fi Rush (v#{version})")
  end

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    CNMN.CommandRouter.handle_message(msg)
    CNMN.Autocrunch.handle_message(msg)
  end

  def handle_event(_other) do
    :noop
  end
end
