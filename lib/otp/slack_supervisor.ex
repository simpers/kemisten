defmodule Kemisten.OTP.SlackSupervisor do
  use Supervisor
  require Logger

  def start_link(opts \\ []) do
    Logger.debug "[Kemisten] Starting supervisor #{__MODULE__}"
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(slack_bot_args) do
    children = [
      worker(Slack.Bot, slack_bot_args, restart: :transient)
    ]
    supervise(children, strategy: :one_for_one)
  end
end
