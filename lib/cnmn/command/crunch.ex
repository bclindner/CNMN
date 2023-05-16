defmodule CNMN.Command.Crunch do
  @command_name "crunch"
  @command_desc "Content-aware scale a provided image."

  use CNMN.Command
  alias CNMN.Image

  def usage(cmdname),
    do: """
      #{cmdname} searches for a Discord image or URL in the command message and
      the message it replies to (if any), then content-aware scales it down by
      50%.
    """

  def handle(_args, msg) do
    Image.transform(msg, &Image.crunch/2)
  end
end
