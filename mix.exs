defmodule Kemisten.Mixfile do
  use Mix.Project

  @kemisten_version "0.1.12"
  @kemisten_iex_version "~> 1.6"
  
  def project do
    [ app: :kemisten,
      version: @kemisten_version,
      elixir: @kemisten_iex_version,
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [ tool: ExCoveralls ],
      preferred_cli_env: [
        coveralls: :test,
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
        :logger
      ]
    ]
  end

  defp deps do
    [
      { :slack, "~> 0.15" },

      # Tools
      { :distillery, "~> 2.0" },
      { :excoveralls, "~> 0.8", only: :test }
    ]
  end

  defp aliases() do
    [
      test: [ "test --no-start" ]
    ]
  end
end
