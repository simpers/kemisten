defmodule Kemisten.Slack.Supervisor do
  use Supervisor

  def start_bot(token, opts \\ []) do
    options = Keyword.merge([name: __MODULE__], opts)
    name = String.to_atom("bot_" <> token)

    case Process.whereis(name) do
      pid when is_pid(pid) -> pid
      nil ->
        bot_params = [ Kemisten.Slack.Handler, %{}, token, %{ name: name } ]
        case Supervisor.start_child(options[:name], bot_params) do
          { :ok, pid } -> pid
          { :error, { :EXIT, { {:badkey, _, err}, _} } } ->
            IO.puts "Failed to start child:"
            IO.inspect err
            err # complex error structure from the Slack.Bot failures
        end
    end
  end
  
  def start_link(opts \\ []) do
    options = Keyword.merge([ name: __MODULE__ ], opts)
    Supervisor.start_link(__MODULE__, [], name: options[:name])
  end

  def init([]) do
    children = [
      worker(Slack.Bot, [], restart: :transient)
    ]
    supervise(children, strategy: :simple_one_for_one);
  end
end
