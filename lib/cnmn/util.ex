defmodule CNMN.Util do
  require Temp
  alias Nostrum.Struct, as: Discord
  alias Nostrum.Api

  # regex for discord images (specifically ones we can process)
  defp discord_img_regex(content) do
    case Regex.scan(
           ~r/^https:\/\/(?:media|cdn).discordapp.(?:com|net)\/attachments\/[0-9]+\/[0-9]+\/\S+.(png|jpg|webp)$/,
           content
         ) do
      [url | _] -> url
      _ -> []
    end
  end

  @spec find_image(Discord.Message.t(), Integer.t()) :: String.t() | nil
  def find_image(msg, loops \\ 1) do
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
      true ->
        nil
    end
  end
end
