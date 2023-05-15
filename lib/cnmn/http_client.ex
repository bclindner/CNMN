defmodule CNMN.HTTPClient do
  @moduledoc """
  Functions for interfacing with HTTP via the Erlang httpc library.
  """

  defp headers, do: [
    'User-Agent': 'CNMN/#{CNMN.Application.version()}'
  ]

  defp parse_options(opts), do: [
    stream: Keyword.get(opts, :stream_to, nil)
  ]

  @doc """
  Perform an an HTTPS request with some default values.
  """
  def request(method, url, opts \\ []) do
    # combine the default headers with the ones provided (if any)
    headers = headers()
    url = to_charlist(url)
      |> Keyword.merge(Keyword.get(opts, :headers, []))
    options = parse_options(opts)
    :httpc.request(
      method,
      {url, headers},
      [ssl: [{:verify, :verify_peer}, {:cacerts, :public_key.cacerts_get()}]],
      options
    )
  end

  @doc """
  Download a file from an HTTP server to the provided filepath.
  """
  @spec download(charlist(), charlist()) :: {:ok, :saved_to_file} | {:error, term()}
  def download(url, filepath) do
    request(:get, url, stream_to: filepath)
  end

  @spec download(binary(), binary()) :: :ok
  def download!(url, filepath) do
    case download(url, filepath) do
      {:ok, :saved_to_file} ->
        :ok
      {:error, errdata} ->
        raise "Failed to download file from URL \"#{url}\" to \"#{filepath}\": #{errdata}"
    end
  end
end
