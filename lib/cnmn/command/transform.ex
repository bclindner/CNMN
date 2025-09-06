defmodule CNMN.Command.Transform do
  @command_name "tf"
  @command_desc "Transform an image or video."

  use CNMN.Command
  alias CNMN.Media
  alias CNMN.Util

  def usage(cmdname),
    do: """
      #{cmdname} crunch: Content-aware scale an image.
      #{cmdname} meme [caption...]: Apply a caption to an image.
      #{cmdname} fast: Speed up a GIF/video.
    """

  def handle(["crunch"], msg) do
    url = Util.find_media!(msg)
    Media.transform(msg, url, Media.crunch())
  end

  def handle(["fast"], msg) do
    url = Util.find_media!(msg)
    Media.transform(msg, url, Media.fast())
  end

  def handle(["meme" | text], msg) do
    url = Util.find_media!(msg)
    Media.transform(msg, url, Media.meme(Enum.join(text, " ")))
  end
end
