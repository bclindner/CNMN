defmodule CNMN.Music.GuildState do
  @moduledoc """
  State struct for the CNMN.Music.Manager.
  """
  defstruct(
    playing: true,
    current: nil,
    queue: []
  )
end
