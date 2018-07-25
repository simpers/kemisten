defmodule Kemisten.Slack.Supervisor do
  use Supervisor
  require Logger

  def start_link(opts \\ []) do
    Logger.debug "Starting supervisor #{__MODULE__}"
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    children = [
      worker(Slack.Bot, [], restart: :transient)
    ]
    supervise(children, strategy: :simple_one_for_one);
  end
end
