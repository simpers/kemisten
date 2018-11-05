defmodule Kemisten.Application do
  use Application
  require Logger

  def start(_type, _args) do
    import Supervisor.Spec

    Logger.info "Starting application #{__MODULE__}"
    case Application.get_env(:kemisten, :slack_token) do
      nil ->
        { :error, "No API token found." }
      token ->
        Logger.info "Token present. Starting application."
        IO.inspect token
        slack_args = [Kemisten.Slack.Handler, %{}, token]
        children = [
          supervisor(Kemisten.Slack.Supervisor, [slack_args])
        ]
        opts = [strategy: :one_for_one, name: Kemisten.Supervisor]
        Supervisor.start_link(children, opts)
    end
  end

  def config_change(_changed, _new, _removed), do: :ok
end
