defmodule EmqCleanspeakPlugin.Mixfile do
  use Mix.Project

  def project do
    [
      app: :emq_cleanspeak_plugin,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      aliases: aliases(),
    ]
  end

  defp aliases do
    [
      test: "test --no-start",
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {EmqCleanspeakPlugin, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ssl_verify_fun, "1.1.6", override: true},
      {:httpoison, "~> 1.5.1"},
      {:jason, "~> 1.2"},

      {:emqttd,
       github: "emqtt/emqttd",
       only: [:test],
       ref: "v2.3-beta.1",
       manager: :make,
       optional: true,
      },
    ]
  end
end
