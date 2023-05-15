defmodule CNMN.Application do
  @moduledoc """
  Base application for starting CNMN.
  """
  use Application
  alias Nostrum.Api

  def start(_type, _args) do
    children = [
      # event consumer
      CNMN.Consumer,
      # music state manager
      {CNMN.Command.Music.Manager, %{}},
      # music player consumer
      CNMN.Command.Music.Consumer
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
