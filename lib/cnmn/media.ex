defmodule CNMN.Media do
  @moduledoc """
  Media transformation functions.
  """
  import FFmpex
  use FFmpex.Options
  require Image
  alias Mogrify, as: Mog
  alias CNMN.HTTPClient
  alias CNMN.Util.Reply
  require Logger

  def factorstring(pct), do: factorstring(pct, pct)

  def factorstring(pct1, pct2) do
    pct1 = round(pct1 * 100)
    pct2 = round(pct2 * 100)
    "#{pct1}%x#{pct2}%"
  end

  defp is_gif!(file) do
    case FFprobe.format_names(file) do
      {:ok, names} -> Enum.member?(names, "gif")
      {_, error_type} -> raise "Failed to run FFprobe: " ++ to_string(error_type)

    end
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

  def fast() do
    fn infile, outpath ->
      # check if file is a gif
      outfile =
        if is_gif!(infile) do
          Path.join(outpath, "fast.gif")
        else
          Path.join(outpath, "fast.mp4")
        end

      cmd =
        FFmpex.new_command()
        |> add_global_option(option_y())
        |> add_input_file(infile)
        |> add_output_file(outfile)
        |> add_file_option(option_vf("setpts=0.5*PTS"))
        |> add_file_option(option_af("atempo=2.0"))
        |> add_file_option(option_loop(0))

      result =
        case execute(cmd) do
          {:ok, _} -> outfile
          {_, error_type} -> raise "Failed to run FFprobe: " ++ to_string(error_type)
        end

      result
    end
  end

  @doc """
  Perform a generic media transformation process on a message.

  This process finds a URL in the mssage or its replies, then saves it to a
  temporary file, transforms it with a function taking the input file path and
  the directory to save the output and outputting the output filepath, then
  returns the saved file as a reply.

  If the function cannot find a URL, it replies to the user.
  """
  def transform(msg, url, transformer) do
    Temp.track!()
    id = to_string(msg.id)
    temppath = Temp.mkdir!(id)
    infile = Path.join(temppath, "input")

    Logger.info("Running media transformer",
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
