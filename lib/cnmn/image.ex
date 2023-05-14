defmodule CNMN.Image do
  @moduledoc """
  Image transformation functions.
  """

  alias Mogrify, as: Mog
  alias CNMN.Util
  alias CNMN.Util.Reply

  defp pctstring(percentage) do
    to_string(percentage) <> "%"
  end

  def factorstring(percentage) do
    pctstring(percentage) <> "x" <> pctstring(percentage)
  end

  def crunch(image, factor) do
    image |> Mog.custom("liquid-rescale", factorstring(factor))
  end

  def save(image, path) do
    Mog.save(image, path: path)
    path
  end

  @doc """
  Perform a generic image transformation process on a message.

  This process finds a URL in the mssage or its replies, then saves it to a
  temporary file, transforms it with the ImageMagick wrapper Mogrify, then
  returns it as a reply.
  """
  def transform(msg, transformer) do
    id = to_string(msg.id)
    Temp.track!()
    temppath = Temp.mkdir!(id)
    infile = Path.join(temppath, "input")
    outfile = Path.join(temppath, "output.png")

    case Util.find_image(msg) do
      nil ->
        Reply.text!(
          "Couldn't find an image - did you upload an image, or reply to an uploaded image?",
          msg
        )

      url ->
        Util.download!(url, infile)
        |> Mogrify.open()
        |> transformer.()
        |> save(outfile)
        |> Reply.file!(msg)
    end
  end
end
