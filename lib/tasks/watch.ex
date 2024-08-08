defmodule Mix.Tasks.Watch do
  use Mix.Task

  @shortdoc "Watches project files and restarts `mix run --no-halt` on changes"

  def run(_) do
    Mix.shell().info("Starting file watcher...")

    {:ok, pid} = FileSystem.start_link(dirs: ["lib", "config", "test"])

    FileSystem.subscribe(pid)
    loop(nil)
  end

  defp loop(nil) do
    pid = start_mix_run()
    loop(pid)
  end

  defp loop(pid) do
    receive do
      {:file_event, _watcher_pid, {file, _events}} ->
        Mix.shell().info("File changed: #{file}")
        stop_mix_run(pid)
        new_pid = start_mix_run()
        loop(new_pid)

      {:file_event, _watcher_pid, :stop} ->
        Mix.shell().info("Stopping file watcher...")
        stop_mix_run(pid)
    end
  end

  defp start_mix_run do
    {pid, _ref} =
      spawn_monitor(fn ->
        System.cmd("mix", ["run", "--no-halt"], into: IO.stream(:stdio, :line))
      end)
    Mix.shell().info("Started mix run --no-halt with PID #{inspect(pid)}")
    pid
  end

  defp stop_mix_run(pid) do
    if pid do
      Process.exit(pid, :kill)
      Mix.shell().info("Stopped mix run --no-halt with PID #{inspect(pid)}")
    end
  end
end
