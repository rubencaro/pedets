defmodule Pedets.MixProject do
  use Mix.Project

  def project do
    [
      app: :pedets,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Pedets.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowboy, "~> 2.0"},
      {:plug, "~> 1.0"},
      {:prometheus_plugs, "~> 1.1.5"},
      {:prometheus_ex, "~> 3.0"},
      {:mix_test_watch, "~> 0.8", only: :dev, runtime: false}
    ]
  end
end
