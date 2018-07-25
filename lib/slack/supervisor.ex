defmodule Kemisten.Slack.Supervisor do
  use Supervisor
  require Logger

  def start_link(opts \\ []) do
    Logger.debug "Starting supervisor #{__MODULE__}"
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    children = [
      worker(Slack.Bot, opts, restart: :transient)
    ]
    supervise(children, strategy: :one_for_one);
  end
end
