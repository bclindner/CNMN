defmodule CNMN.Application do
  @moduledoc """
  Base application for starting CNMN.
  """
  use Application

  def start(_type, _args) do
    children = [
      # event consumer
      CNMN.Consumer,
      # music queue agent
      CNMN.Command.Music.Manager
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
