defmodule CNMN.Command.Crunch do
  use CNMN.Command
  require Mogrify
  alias CNMN.{Util,Image}

  def name, do: "crunch"

  def desc, do: "Content-aware scale a provided image."

  def handle(_args, msg) do
    id = to_string(msg.id)
    Temp.track!
    temppath = Temp.mkdir!(id)
    infile = Path.join(temppath, "input")
    outfile = Path.join(temppath, "output.png")
    case Util.find_image(msg) do
      nil -> Util.reply!(msg, "Couldn't find an image!")
      url ->
        Util.download!(url, infile)
        |> Mogrify.open()
        |> Image.crunch(50)
        |> Image.save(outfile)
        |> Util.post_image!(msg)
    end
  end
end
