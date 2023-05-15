defmodule CNMN.HTTPClient do
  @moduledoc """
  Functions for interfacing with HTTP via the Erlang httpc library.
  """
  require Logger

  @doc "Default headers."
  def headers, do: [
    {'User-Agent', 'CNMN/#{CNMN.Application.version()}'}
  ]

  @spec parse_options(request_options, headers, keyword()) :: {keyword(), keyword()}
  @doc """
  Convert the request options format into a format httpc respects.
  """
  def parse_options(opts, headers \\ headers(), results \\ [])
  def parse_options([{key, value} | opts], headers, results) do
    results = case key do
      :stream_to -> Keyword.put(results, :stream, to_charlist(value))
      _ -> results
    end
    headers = case key do
      :headers -> Keyword.merge(headers, value)
      _ -> headers
    end
    parse_options(opts, headers, results)
  end
  def parse_options([], headers, results), do: {headers, results}

  @type method :: :get | :post | :put | :delete
  @type headers :: [{charlist(), charlist()}]
  @type request_options :: [{:headers, headers} | {:stream_to, binary()}]
  @type response :: {:ok | :error, term}

  @doc """
  Perform an an HTTPS request with some default values.
  """
  @spec request(method, binary(), request_options) :: response
  def request(method, url, opts \\ []) do
    # combine the default headers with the ones provided (if any)
    url = to_charlist(url)
    {headers, options} = parse_options(opts)
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
  @spec download(binary(), binary()) :: response
  def download(url, filepath) do
    request(:get, url, stream_to: filepath)
  end

  @doc """
  See download/2, but fails if an error is encountered.
  """
  @spec download!(binary(), binary()) :: :ok
  def download!(url, filepath) do
    case download(url, filepath) do
      {:ok, :saved_to_file} ->
        :ok
      {:error, errdata} ->
        raise "Failed to download file from URL \"#{url}\" to \"#{filepath}\": #{errdata}"
    end
  end
end
