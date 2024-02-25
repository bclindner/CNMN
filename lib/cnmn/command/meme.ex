defmodule CNMN.Command.Meme do
  @command_name "meme"
  @command_desc "Caption a provided image."

  use CNMN.Command
  alias CNMN.Image

  def usage(cmdname),
    do: """
      #{cmdname} searches for a Discord image or URL in the command message and
      the message it replies to (if any), then captions it with the provided text.
    """

  def handle(text, msg) do
    Image.transform(msg, Image.meme(Enum.join(text, " ")))
  end
end
