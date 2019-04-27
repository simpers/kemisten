defmodule Kemisten.Application do
  use Application
  require Logger

  def start(_type, _args) do
    import Supervisor.Spec

    Logger.info "Starting application #{__MODULE__}"
    case Application.get_env(:kemisten, :slack_token_env_name) do
      nil ->
        :error
      { :env, token_name } ->
        token = System.get_env(token_name)
        slack_args = [ Kemisten.Slack.Handler, %{}, token, %{ client: Kemisten.Client } ]
        children = [
          supervisor(Kemisten.OTP.SlackSupervisor, [ slack_args ])
        ]
        opts = [ strategy: :one_for_one, name: Kemisten.Supervisor ]
        Supervisor.start_link(children, opts)
    end
  end

  def config_change(_changed, _new, _removed), do: :ok
end
