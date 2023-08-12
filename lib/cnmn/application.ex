defmodule CNMN.Application do
  @moduledoc """
  Base application for starting CNMN.
  """
  use Application

  def version, do: Application.spec(:cnmn, :vsn)

  def start(_type, _args) do
    children =
      [
        # music state manager
        {CNMN.Music.Manager, %{}}
      ] ++
        # add the consumer only if test mode is disabled
        # (this prevents the system from launching nostrum and logging in)
        case Application.fetch_env(:cnmn, :test_mode) do
          {:ok, :true} -> []
          _ -> [CNMN.Consumer]
        end

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
