defmodule Kemisten.Pinger do
  require Logger

  alias Slack.Sends

  alias Kemisten.Sassy
  alias Kemisten.Utils

  def ping_response(channel, slack), do: Sends.send_message("pong", channel, slack)

  def setup_pinger(channel, state, slack) do
    { :ok, timer_ref } = :timer.apply_interval(5000, __MODULE__, :ping_channel, [channel, slack])
    { :ok, Kernel.put_in(state, [:pinging, channel], timer_ref) }
  end

  def stop_pinger(channel, state) do
    case Kernel.pop_in(state[:pinging][channel]) do
      { nil, state } ->
        Logger.debug "User #{channel} not found in active pings."
        { :ok, state }
      { timer_ref, new_state } ->
        Logger.info "Stopped pinging user #{channel}"
        { :ok, :cancel } = :timer.cancel(timer_ref)
        { :ok, new_state }
    end
  end

  def pong_response(channel, state, slack) do
    case Kernel.pop_in(state[:pinging][channel]) do
      { nil, state } ->
        Logger.debug "Was not pinging user #{channel}."
        { :ok, state }
      { timer_ref, new_state } ->
        { :ok, :cancel } = :timer.cancel(timer_ref)
        Sends.send_message(":)", channel, slack)
        { :ok, new_state }
    end
  end

  def ping_channel(channel, slack) do
    Sends.send_message("ping", channel, slack)
  end

  def handle_cheeky(channel, true, user), do: send(self(), { :message, Sassy.get_sass(nil), channel })
  def handle_cheeky(channel, false, user), do: send(self(), { :message, Sassy.get_sass(user), channel })
end
