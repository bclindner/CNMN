defmodule CNMN.Image do
  @moduledoc """
  Image transformation functions.
  """

  require Image
  alias Mogrify, as: Mog
  alias CNMN.{HTTPClient, Util}
  alias CNMN.Util.Reply
  require Logger

  def factorstring(pct), do: factorstring(pct, pct)

  def factorstring(pct1, pct2) do
    pct1 = round(pct1 * 100)
    pct2 = round(pct2 * 100)
    "#{pct1}%x#{pct2}%"
  end

  def crunch(factor \\ 0.5) do
    fn infile, outpath ->
      outfile = Path.join(outpath, "crunch.png")

      Mog.open(infile)
      |> Mog.custom("liquid-rescale", factorstring(factor))
      |> Mog.save(path: outfile)

      outfile
    end
  end

  def meme(toptext, bottomtext \\ "") do
    fn infile, outpath ->
      outfile = Path.join(outpath, "meme.png")

      Image.open!(infile)
      |> Image.meme!(toptext, text: bottomtext)
      |> Image.write!(outfile, minimize_file_size: true)

      outfile
    end
  end

  @doc """
  Perform a generic image transformation process on a message.

  This process finds a URL in the mssage or its replies, then saves it to a
  temporary file, transforms it with a function taking the input file path and
  the directory to save the output and outputting the output filepath, then
  returns the saved file as a reply.

  If the function cannot find a URL, it replies to the user.
  """
  def transform(msg, transformer, opts \\ []) do
    unless msg.author.bot do
      id = to_string(msg.id)
      Temp.track!()
      temppath = Temp.mkdir!(id)
      infile = Path.join(temppath, "input")

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

          transformer.(infile, temppath)
          |> Reply.file!(msg)

          Logger.info("Transformation successful",
            msgid: msg.id
          )
      end
    end
  end
end
