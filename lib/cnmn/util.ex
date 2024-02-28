defmodule CNMN.Util do
  require Temp
  alias Nostrum.Struct, as: Discord
  alias Nostrum.Api
  require Logger

  # regex for discord images (specifically ones we can process)
  defp discord_media_regex(content, options) do
    extensions = Keyword.get(options, :extensions, ["png", "jpg", "webp", "mp4", "gif"])
    regex = ~r/^https:\/\/(?:media|cdn).discordapp.(?:com|net)\/attachments\/[0-9]+\/[0-9]+\/\S+.(#{Enum.join(extensions,"|")})$/
    case Regex.scan(regex,content) do
      [url | _] -> url
      _ -> []
    end
  end

  @spec find_media(Discord.Message.t(), Integer.t(), Keyword.t()) :: String.t() | nil
  def find_media(msg, loops \\ 1, options \\ []) do
    cond do
      # first, check if there is an attachment
      length(msg.attachments) > 0 ->
        [attachment | _] = msg.attachments
        attachment.proxy_url

      # second, check if the message content has a discord image URL
      length(discord_media_regex(msg.content, options)) > 0 ->
        [url | _] = discord_media_regex(msg.content, options)
        url

      # third, if this message is a reply (type 19), get the reply and check
      # that, recursively, up to `loops` times
      msg.type == 19 && loops > 0 ->
        ref = msg.message_reference

        Api.get_channel_message!(ref.channel_id, ref.message_id)
        |> find_media(loops - 1, options)

      # finally, if there are no more loops, just return nil - nothing more we
      # can do
      true ->
        nil
    end
  end
end
