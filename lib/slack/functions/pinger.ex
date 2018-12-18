defmodule Kemisten.Pinger do
  require Logger

  alias Kemisten.Utils

  @module_tag "[Pinger]"

  def ping_response(channel, _slack),
    do: Utils.send_message("pong", channel)

  # setup_pinger/4
  def setup_pinger(target, state, origin_channel, slack) do
    setup_pinger(target, state, origin_channel, slack, 5000)
  end

  # setup_pinger/5
  def setup_pinger(nil, state, origin_channel, _slack, _interval) do
    msg = "Target is nil"
    Logger.error "#{@module_tag} #{msg}"
    Utils.send_message(msg, origin_channel)
    { :ok, state }
  end  
  def setup_pinger(target, state, origin_channel, slack, interval) do
    case Utils.does_channel_or_user_exist?(target, slack) do
      true ->
        { :ok, timer_ref } = :timer.apply_interval(interval, __MODULE__, :ping_channel, [ target, self() ])
        { :ok, Kernel.put_in(state, [ :pinging, target ], timer_ref) }
      false ->
        msg = "Target #{target} does not exist or is invalid."
        Logger.error "#{@module_tag} #{msg}"
        Utils.send_message(msg, origin_channel)
        { :ok, state }
    end
  end  

  def stop_pinger(channel, state) do
    case Kernel.pop_in(state[:pinging][channel]) do
      { nil, state } ->
        Logger.debug "#{@module_tag} User #{channel} not found in active pings."
        { :ok, state }
      { timer_ref, new_state } ->
        Logger.info "#{@module_tag} Stopped pinging user #{channel}"
        { :ok, :cancel } = :timer.cancel(timer_ref)
        { :ok, new_state }
    end
  end

  def pong_response(channel, state, _slack) do
    case Kernel.pop_in(state[:pinging][channel]) do
      { nil, state } ->
        Logger.debug "#{@module_tag} Was not pinging user #{channel}."
        { :ok, state }
      { timer_ref, new_state } ->
        { :ok, :cancel } = :timer.cancel(timer_ref)
        Utils.send_message(":)", channel)
        { :ok, new_state }
    end
  end

  def ping_channel(channel, process) do
    Utils.send_message("ping", channel, process)
  end
end
