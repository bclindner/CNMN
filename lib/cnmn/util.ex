defmodule CNMN.Util do
  def reply(msg, content) do
    Nostrum.Api.create_message!(
      msg.channel_id,
      content: content,
      message_reference: %{message_id: msg.id}
    )
  end
end
