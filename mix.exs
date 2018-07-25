defmodule Kemisten.Mixfile do
  use Mix.Project

  def project do
    [ app: :kemisten,
      version: "0.1.0",
      elixir: "~> 1.4",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [ tool: ExCoveralls ],
      preferred_cli_env: [
        "coveralls": :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [ mod: { Kemisten.Application, [] },
      extra_applications: [
        :logger, :slack
      ]
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      # { :websocket_client, git: "https://github.com/simpers/websocket_client.git", tag: "1.1.0", override: true },
      { :slack, "~> 0.14" },
      { :distillery, "~> 1.5.3" },
      { :edeliver, "~> 1.5" },
      { :excoveralls, "~> 0.8", only: :test }
    ]
  end

  defp aliases(), do: [ "test": [ "test --no-start" ] ]
end
