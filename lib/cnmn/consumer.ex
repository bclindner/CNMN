defmodule CNMN.Consumer do
  @moduledoc """
  Root consumer for CNMN event handling.
  Sends events to all important parts of the bot platform.
  """
  use Nostrum.Consumer

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    CNMN.CommandRouter.handle_message(msg)
  end

  def handle_event(_other) do
    :noop
  end
end
