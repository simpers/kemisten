defmodule Kemisten.Supervisor do
  use Supervisor
  alias Slack.Bot
  @name Kemisten.Supervisor
  
  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def init(:ok) do
    token = Application.get_env(:kemisten, :slack_token)
    IO.inspect token
    children = [
      worker(Bot, [SlackKemisten, [], token], restart: :permanent)
    ]
    supervise(children, strategy: :one_for_one);
  end
end
