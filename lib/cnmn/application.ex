defmodule CNMN.Application do
  @moduledoc """
  Base application for starting CNMN.
  """
  use Application

  def version, do: Application.spec(:cnmn, :vsn)

  def start(_type, _args) do
    children = [
      # event consumer
      CNMN.Consumer,
      # music state manager
      {CNMN.Music.Manager, %{}}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
