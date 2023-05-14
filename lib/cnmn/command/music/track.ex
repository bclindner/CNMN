defmodule CNMN.Command.Music.Track do
  defstruct(
    title: "Unknown",
    uploader: "Unknown",
    thumb_url: nil,
    uploader_url: nil,
    url: "",
    type: nil
  )

  defp ytdl_path, do: Application.get_env(:nostrum, :youtubedl, "youtube-dl")

  @doc """
  Parse a YoutubeDL-compatible audio format into a `CNMN.Command.Music.Track`.
  """
  def from_youtube_dl!(url) do
    # call youtube-dl directly to get what we want
    {output, status} = System.cmd(ytdl_path(), ["-s", "-j", url])

    case status do
      0 ->
        rawdata = Jason.decode!(output)

        %CNMN.Command.Music.Track{
          title: rawdata |> Map.get("title", "Unknown"),
          uploader: rawdata |> Map.get("uploader", "Unknown"),
          uploader_url: rawdata |> Map.get("uploader_url"),
          thumb_url: rawdata |> Map.get("thumbnail"),
          url: url,
          type: :ytdl
        }

      _ ->
        raise "youtube-dl failed to parse"
    end
  end
end
