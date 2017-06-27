defmodule Kemisten do
  use Application

  @moduledoc """
  Documentation for Kemisten.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Kemisten.hello
      :world

  """
  def hello do
    :world
  end

  def start(_type, _args) do
    import Supervisor.Spec
    children = [
      supervisor(Kemisten.Slack.Supervisor, [])
    ]
    opts = [ strategy: :one_for_one, name: Kemisten.Supervisor ]
    ret = Supervisor.start_link(children, opts)
    
    case System.get_env("SLACK_TOKEN") do
      nil ->
        IO.puts "No token given in SLACK_TOKEN environment variable."
      token when is_bitstring(token) -> Kemisten.Slack.Supervisor.start_bot(token)
    end

    ret
  end
end
