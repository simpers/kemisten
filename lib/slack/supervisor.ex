defmodule Kemisten.Slack.Supervisor do
  use Supervisor
  alias Slack.Bot
  @name Kemisten.Slack.Supervisor
  
  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def init(:ok) do
    children = [
      # botArgs = [SlackKemisten, [], "xoxb-188440640803-4BY20SzzVG0JBNjxKXIgZHdI"]
      worker(Slack.Bot, [], restart: :permanent)
    ]
    supervise(children, strategy: :simple_one_for_one);
  end
end
