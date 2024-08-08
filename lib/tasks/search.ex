defmodule Mix.Tasks.Search do
  use Mix.Task

  @shortdoc "Searches Hex.pm for a package"

  @moduledoc """
  A Mix task to search Hex.pm for a package.

  ## Examples

      mix hex_search PACKAGE_NAME
  """

  def run([package_name]) do
    # Ensure :hackney application is started
    Application.ensure_all_started(:hackney)

    case search_hex(package_name) do
      {:ok, results} ->
        IO.puts("Search results for #{package_name}:")
        Enum.each(results, fn result ->
          IO.puts("  - #{IO.ANSI.green()}#{result["name"]}#{IO.ANSI.reset()} #{IO.ANSI.white()}#{IO.ANSI.bright()}#{result["latest_version"]}#{IO.ANSI.reset()} : #{result["meta"]["description"]}")
        end)

      {:error, reason} ->
        IO.puts("Failed to search Hex.pm: #{reason}")
    end
  end

  defp search_hex(package_name) do
    url = "https://hex.pm/api/packages?search=#{package_name}"

    case HTTPoison.get(url, [], timeout: 5000, recv_timeout: 5000) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, "HTTP request failed with status code #{status_code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end
