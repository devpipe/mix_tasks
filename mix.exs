defmodule Tasks.MixProject do
  use Mix.Project

  @version "0.0.1"
  @description "Mix tasks"

  def project do
    [
      app: :tasks,
      version: @version,
      description: @description,
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
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
      {:file_system, "~> 1.0"},
    ]
  end
end
