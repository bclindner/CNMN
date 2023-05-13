defmodule CNMN.Util do
  require Temp
  alias Nostrum.Struct, as: Discord
  alias Nostrum.Api

  @doc """
  Save a URL to a tempfile.

  Helpful for certain tasks operating on large files, like video
  or image manipulation.
  """
  @spec download!(String.t(), String.t()) :: String.t()
  def download!(url, filepath) do
    Application.ensure_all_started :inets
    url = to_charlist(url)
    {:ok, :saved_to_file} = :httpc.request(:get, {url, []}, [ssl: [{:verify, :verify_peer},{:cacerts, :public_key.cacerts_get()}]], stream: to_charlist(filepath))
    filepath
  end

  @doc """
  Reply to a post.
  """
  @spec reply!(Discord.Message.t(), binary()) :: Discord.Message.t()
  def reply!(msg, content) do
    Api.create_message!(
      msg.channel_id,
      content: content,
      message_reference: %{message_id: msg.id}
    )
  end

  # regex for discord images (specifically ones we can process)
  defp discord_img_regex(content) do
    case Regex.scan(~r/^https:\/\/(?:media|cdn).discordapp.(?:com|net)\/attachments\/[0-9]+\/[0-9]+\/\S+.(png|jpg|webp)$/, content) do
      [url | _] -> url
      _ -> []
    end
  end

  @doc """
  Find an image URL from a `Nostrum.Struct.Message`.
  This first searches for the first attachment, then the first
  """
  @spec find_image(Discord.Message.t()) :: String.t() | nil
  def find_image(msg), do: find_image(msg, 1)

  @doc """
  Similar to `find_image/1`, but allows for controlling the depth of the reply searches.
  """
  @spec find_image(Discord.Message.t(), Integer.t()) :: String.t() | nil
  def find_image(msg, loops) do
    cond do
      # first, check if there is an attachment
      length(msg.attachments) > 0 ->
        [attachment | _] = msg.attachments
        attachment.proxy_url
      # second, check if the message content has a discord image URL
      length(discord_img_regex(msg.content)) > 0 ->
        [url | _] = discord_img_regex(msg.content)
        url
      # third, if this message is a reply (type 19), get the reply and check
      # that, recursively, up to `loops` times
      msg.type == 19 && loops > 0 ->
        ref = msg.message_reference
        Api.get_channel_message!(ref.channel_id, ref.message_id)
        |> find_image(loops - 1)
      # finally, if there are no more loops, just return nil - nothing more we
      # can do
      true -> nil
    end
  end

  def post_image!(filepath, msg) do
    Api.create_message!(
      msg.channel_id,
      message_reference: %{message_id: msg.id},
      file: filepath
    )
  end
end
