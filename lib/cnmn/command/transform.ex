defmodule CNMN.Command.Transform do
  @command_name "tf"
  @command_desc "Transform an image or video."

  use CNMN.Command
  alias CNMN.Media

  def usage(cmdname),
    do: """
      #{cmdname} crunch: Content-aware scale an image.
      #{cmdname} meme [caption...]: Apply a caption to an image.
      #{cmdname} fast: Speed up a GIF/video.
    """

  def handle(["crunch"], msg) do
    Media.transform(msg, Media.crunch())
  end

  def handle(["fast"], msg) do
    Media.transform(msg, Media.fast())
  end

  def handle(["meme" | text], msg) do
    Media.transform(msg, Media.meme(Enum.join(text, " ")))
  end

end
