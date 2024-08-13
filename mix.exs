defmodule Tasks.MixProject do
  use Mix.Project

  @version "0.0.1"
  @description "Some nice additional tasks for Mix"
  @repo "https://github.com/devpipe/mix_tasks"

  def project do
    [
      app: :tasks,
      version: @version,
      description: @description,
      package: package(),
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  defp package do
    %{
      licenses: ["MIT"],
      maintainers: ["Wess Cope"],
      links: %{"Github" => @repo}
    }
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.4"},
      {:httpoison, "~> 2.2"},
      {:file_system, "~> 1.0"},
    ]
  end
end
