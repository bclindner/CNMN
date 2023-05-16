defmodule CNMN.Image do
  @moduledoc """
  Image transformation functions.
  """

  alias Mogrify, as: Mog
  alias CNMN.{HTTPClient, Util}
  alias CNMN.Util.Reply
  require Logger

  defp pctstring(percentage) do
    to_string(percentage) <> "%"
  end

  def factorstring(percentage) do
    pctstring(percentage) <> "x" <> pctstring(percentage)
  end

  def crunch(image, factor \\ 50) do
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

  If the function cannot find a URL, it replies to the user.
  """
  def transform(msg, transformer, opts \\ []) do
    unless msg.author.bot do
      id = to_string(msg.id)
      Temp.track!()
      temppath = Temp.mkdir!(id)
      infile = Path.join(temppath, "input")
      outfile = Path.join(temppath, "output.png")

      case Util.find_image(msg) do
        nil ->
          unless Keyword.get(opts, :quiet) == true do
            Reply.text!(
              "Couldn't find an image - did you upload an image, or reply to an uploaded image?",
              msg
            )
          end
        url ->
          Logger.info("Running image transformer",
            url: url,
            msgid: msg.id,
            dir: temppath,
            transformer: inspect(transformer)
          )
          HTTPClient.download!(url, infile)
          Mogrify.open(infile)
          |> transformer.()
          |> save(outfile)
          |> Reply.file!(msg)
      end
    end
  end
end
