defmodule Kemisten.Supervisor do
  use Supervisor
  alias Slack.Bot
  @name Kemisten.Supervisor
  
  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def init(:ok) do
    children = [
      worker(Bot, [SlackKemisten, [], "xoxb-188440640803-4BY20SzzVG0JBNjxKXIgZHdI"], restart: :permanent)
    ]
    supervise(children, strategy: :one_for_one);
  end
end
