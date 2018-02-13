defmodule Fbapi.Mixfile do
  use Mix.Project

  def project do
    [
      app: :fbapi,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :ssl, :inets]
    ]
  end

  defp deps do
    [
      {:poison, "~> 3.1"},
      {:httpoison, "~> 0.13.0"},
      {:uuid, "~> 1.1"},
      {:rsa, "~> 0.0.1"}
    ]
  end
end
