defmodule CNMN.Music.Track do
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
    # quick verification - let's make sure this is https. we do this primarily
    # so that people can't abuse ytsearch and other plugins that will break our
    # embeds and other discord functions that require us to input URLS
    unless String.starts_with?(url, "https://") do
      raise "link is invalid"
    end

    # now call youtube-dl directly to get what we want
    {output, status} = System.cmd(ytdl_path(), ["-s", "-j", url])

    case status do
      0 ->
        rawdata = Jason.decode!(output)

        %CNMN.Music.Track{
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
