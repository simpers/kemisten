defmodule Kemisten.Pinger do
  alias Slack.Sends

  alias Kemisten.Utils

  def ping_response(channel, slack), do: Sends.send_message("pong", channel, slack)

  def setup_pinger(channel, state, slack) do
    { :ok, timer_ref } = :timer.apply_interval(5000, __MODULE__, :ping_channel, [user_id, slack])
    { :ok, Kernel.put_in(state, [:pinging, user_id], timer_ref) }
  end

  def stop_pinger(channel, state) do
    case Kernel.pop_in(state[:pinging][user_id]) do
      { nil, state } ->
        Logger.debug "User #{user_id} not found in active pings."
        { :ok, state }
      { timer_ref, new_state } ->
        Logger.info "Stopped pinging user #{user_id}"
        { :ok, :cancel } = :timer.cancel(timer_ref)
        { :ok, new_state }
    end
  end

  def pong_response(user_id, state, slack) do
    case Kernel.pop_in(state[:pinging][user_id]) do
      { nil, state } ->
        Logger.debug "Was not pinging user #{user_id}."
        { :ok, state }
      { timer_ref, new_state } ->
        { :ok, :cancel } = :timer.cancel(timer_ref)
        Sends.send_message(":)", user_id, slack)
        { :ok, new_state }
    end
  end

  def ping_channel(channel, slack) do
    Sends.send_message("ping", channel, slack)
  end
end
