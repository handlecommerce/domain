defmodule Handle.Domain.RuleDownloader do
  @moduledoc """
  Downloads and parses public suffix list rules.
  """

  @suffix_url "https://publicsuffix.org/list/public_suffix_list.dat"
  @public_suffix_file Path.expand("../../../priv/public_suffix_list.dat", __DIR__)

  def download() do
    case :httpc.request(:get, {@suffix_url, []}, [], []) do
      {:ok, {_, _, body}} -> File.write!(@public_suffix_file, body)
      _ -> :error
    end
  end
end
