defmodule Mix.Tasks.Add do
  use Mix.Task

  @shortdoc "Adds a package from Hex.pm to mix.exs"

  def run(args) do
    {opts, packages, _} = OptionParser.parse(args, switches: [dev: :boolean, test: :boolean])

    case packages do
      [package_name] ->
        add_package(package_name, opts)

      [package_name, version] ->
        if add_dependency_to_mix_exs(package_name, version, opts) do
          run_mix_deps_get()
        else
          Mix.shell().error("Failed to add #{package_name} #{version} to mix.exs dependencies.")
        end

      _ ->
        Mix.shell().error("Usage: mix add <package_name> [version] [--dev] [--test]")
    end
  end

  defp add_package(package_name, opts) do
    with {:ok, version} <- get_latest_version(package_name),
         :ok <- add_dependency_to_mix_exs(package_name, version, opts) do
      run_mix_deps_get()
    else
      {:error, reason} ->
        Mix.shell().error("Failed to add #{package_name}: #{reason}")
        :error
    end
  end

  defp get_latest_version(package_name) do
    case System.cmd("mix", ["hex.info", package_name]) do
      {output, 0} ->
        parse_version(output)

      {_, _} ->
        {:error, "Package not found on Hex.pm"}
    end
  end

  defp parse_version(output) do
    case Regex.run(~r/Versions\s+:\s+([^\s,]+)/, output) do
      [_, version] -> {:ok, version}
      _ -> {:error, "Unable to parse version"}
    end
  end

  defp add_dependency_to_mix_exs(package_name, version, opts) do
    mix_file = "mix.exs"

    case File.read(mix_file) do
      {:ok, contents} ->
        new_dep = build_dependency_string(package_name, version, opts)

        new_contents =
          contents
          |> String.replace(~r/deps do\s*\[/, "deps do\n    [#{new_dep},")

        case File.write(mix_file, new_contents) do
          :ok ->
            env = env_flag(opts)
            Mix.shell().info("Added #{package_name} #{version} to mix.exs dependencies#{env}.")
            :ok

          _ ->
            Mix.shell().error("Failed to write to mix.exs")
            :error
        end

      {:error, reason} ->
        Mix.shell().error("Failed to read mix.exs: #{reason}")
        :error
    end
  end

  defp build_dependency_string(package_name, version, opts) do
    cond do
      opts[:dev] -> "{:#{package_name}, \"~> #{version}\", only: :dev}"
      opts[:test] -> "{:#{package_name}, \"~> #{version}\", only: :test}"
      true -> "{:#{package_name}, \"~> #{version}\"}"
    end
  end

  defp env_flag(opts) do
    cond do
      opts[:dev] -> " (dev)"
      opts[:test] -> " (test)"
      true -> ""
    end
  end

  defp run_mix_deps_get do
    {_, exit_code} = System.cmd("mix", ["deps.get"])

    if exit_code == 0 do
      Mix.shell().info("Successfully fetched dependencies.")
    else
      Mix.shell().error("Failed to fetch dependencies.")
    end
  end
end
