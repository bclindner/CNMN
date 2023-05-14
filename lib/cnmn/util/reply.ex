defmodule CNMN.Util.Reply do
  @moduledoc """
  Functions for sending consistent replies.
  """

  @cnmn_ok 0x1FEEFA
  alias Nostrum.Api
  alias Nostrum.Struct.Embed
  defp styled_embed(embed) do
    now = DateTime.utc_now() |> DateTime.to_iso8601()
    embed
    |> Embed.put_color(@cnmn_ok)
    |> Embed.put_footer("CNMN", nil)
    |> Embed.put_timestamp(now)
  end

  def track!(track, msg, opts \\ []) do
    embed!(
      %Embed{
        title: track.title,
        url: track.url,
        image: %Embed.Image{url: track.thumb_url},
        author: %Embed.Author{
          name: track.uploader,
          url: track.uploader_url
        }
      }
      |> styled_embed(),
      msg,
      opts
    )
  end

  def embed!(embed, msg, opts \\ []) do
    Api.create_message!(
      msg.channel_id,
      embeds: [embed],
      content: Keyword.get(opts, :content, ""),
      message_reference: %{message_id: msg.id}
    )
  end

  def text!(text, msg) do
    Api.create_message!(
      msg.channel_id,
      content: text,
      message_reference: %{message_id: msg.id}
    )
  end

  def file!(filepath, msg) do
    Api.create_message!(
      msg.channel_id,
      message_reference: %{message_id: msg.id},
      file: filepath
    )
  end
end
