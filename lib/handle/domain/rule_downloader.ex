defmodule Handle.Domain.RuleDownloader do
  @moduledoc """
  Downloads and parses public suffix list rules.
  """

  @suffix_url "https://publicsuffix.org/list/public_suffix_list.dat"

  @spec download() :: {:ok, list(Handle.Domain.Rule.t())} | {:error, String.t()}
  def download() do
    :inets.start()
    :ssl.start()

    case :httpc.request(:get, {@suffix_url, []}, [], []) do
      {:ok, {_, _, body}} -> to_string(body)
      _ -> "Could not read"
    end
  end
end
