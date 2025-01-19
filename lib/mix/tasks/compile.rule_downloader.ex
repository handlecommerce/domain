defmodule Mix.Tasks.Compile.RuleDownloader do
  @moduledoc """
  Downloads the latest public suffix list rules.
  """

  @behaviour Mix.Task.Compiler

  @suffix_url "https://publicsuffix.org/list/public_suffix_list.dat"
  @public_suffix_file Path.expand("../../../priv/public_suffix_list.dat", __DIR__)
  @number_of_days_before_refresh 1

  @spec run([binary]) :: Mix.Task.Compiler.status()
  def run(_args) do
    case download_suffix_list() do
      :ok -> :ok
      {:error, _reason} -> :error
    end
  end

  defp download_suffix_list do
    if days_since_modified(@public_suffix_file) >= @number_of_days_before_refresh do
      do_download()
    else
      :ok
    end
  end

  defp do_download do
    case :httpc.request(:get, {@suffix_url, []}, [], []) do
      {:ok, {_, _, body}} ->
        # Ensure the directory exists
        File.mkdir_p!(Path.dirname(@public_suffix_file))
        File.write(@public_suffix_file, body)

        IO.puts("Public suffix list downloaded")

      _ ->
        # Update the last modified time of the file if it exists
        if File.exists?(@public_suffix_file), do: File.touch(@public_suffix_file)

        {:error, "Could not download public suffix list"}
    end
  end

  defp days_since_modified(file_path) do
    case File.stat(file_path) do
      {:ok, stat} ->
        modified = stat.mtime
        now = :calendar.universal_time()

        # Convert both datetimes to seconds since a common epoch
        modified_secs = :calendar.datetime_to_gregorian_seconds(modified)
        now_secs = :calendar.datetime_to_gregorian_seconds(now)

        diff_days = (now_secs - modified_secs) / (60 * 60 * 24)
        diff_days

      _ ->
        # Force the file to download if it doesn't exist
        1_000_000
    end
  end
end
