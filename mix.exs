defmodule Kemisten.Mixfile do
  use Mix.Project

  @kemisten_version "0.2.6"
  @kemisten_iex_version "~> 1.6"
  
  def project do
    [ app: :kemisten,
      version: @kemisten_version,
      elixir: @kemisten_iex_version,
      elixirc_paths: elixirc_paths(Mix.env),
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
        :logger, :timex
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: [ "lib", "test/support", "test/mocks" ]
  defp elixirc_paths(:dev),  do: [ "lib", "test", "priv" ]
  defp elixirc_paths(_),     do: [ "lib" ]
  
  defp deps do
    [
      { :slack, "~> 0.15" },
      { :timex, "~> 3.4" },

      # Tools
      { :distillery, "~> 2.0" },
      { :excoveralls, "~> 0.10", only: :test }
    ]
  end

  defp aliases() do
    [
      test: [ "test --no-start" ]
    ]
  end
end
