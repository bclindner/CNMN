defmodule CNMN.Command.Crunch do
  @command_name "crunch"
  @command_desc "Content-aware scale a provided image."

  use CNMN.Command
  require Mogrify
  alias CNMN.{Util, Image}

  def usage(cmdname),
    do: """
      #{cmdname} searches for a Discord image or URL in the command message and
      the message it replies to (if any), then content-aware scales it down by
      50%.
    """

  def handle(_args, msg) do
    id = to_string(msg.id)
    Temp.track!()
    temppath = Temp.mkdir!(id)
    infile = Path.join(temppath, "input")
    outfile = Path.join(temppath, "output.png")

    case Util.find_image(msg) do
      nil ->
        Util.reply!(msg, "Couldn't find an image!")

      url ->
        Util.download!(url, infile)
        |> Mogrify.open()
        |> Image.crunch(50)
        |> Image.save(outfile)
        |> Util.post_image!(msg)
    end
  end
end
