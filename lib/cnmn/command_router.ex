defmodule CNMN.CommandRouter do
  defp prefix, do: Application.get_env(:cnmn, :prefix)
  defp commands, do: Application.get_env(:cnmn, :commands)
  defp is_command(msg), do: String.starts_with?(msg.content, prefix())

  def tokenize(string) do
    prefix_len = byte_size(prefix())

    string
    # cut the prefix off
    |> binary_part(prefix_len, byte_size(string) - prefix_len)
    # split into string
    |> String.split(" ", trim: true)
  end

  defp handle_command(msg, [handler | handlers]) do
    [cmdname | args] = tokenize(msg.content)
    handler.handle(cmdname, args, msg)
    handle_command(msg, handlers)
  end

  defp handle_command(_msg, []) do
    :ok
  end

  def handle_message(msg) do
    if is_command(msg) do
      handle_command(msg, commands())
    end
  end
end
