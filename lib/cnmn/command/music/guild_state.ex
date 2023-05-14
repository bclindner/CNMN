defmodule CNMN.Command.Music.GuildState do
  @moduledoc """
  State struct for the CNMN.Command.Music.Manager.
  """
  defstruct(
    playing: true,
    current: nil,
    queue: []
  )
end
