defmodule Kemisten.Parser do
  require Logger

  alias Kemisten.{Pinger,Utils}

  @module_tag "[Parser]"
  @unhandled_msg_string "Unhandled message received:\n"

  def parse_message(_message = %{ text: "ping", channel: channel }, slack, state) do
    Logger.info "#{@module_tag} Got a ping, responding with pong."
    Pinger.ping_response(channel, slack)
    { :ok, state }
  end
  def parse_message(_message = %{ text: "ping " <> user, user: from, channel: channel }, slack, state) do
    target = Utils.extract_user_id(user)
    if_target_me(Utils.get_my_id(slack) == target, { target, from, channel, slack }, state)
  end
  def parse_message(_message = %{ text: "pong", user: user_id }, slack, state) do
    Pinger.pong_response(user_id, state, slack)
  end
  def parse_message(_message = %{ text: "IO.state" }, slack, state) do
    Utils.print_state(slack, nil)
    { :ok, state }
  end
  def parse_message(_message = %{ text: "IO.state " <> key }, slack, state) do
    Utils.print_state(slack, key)
    { :ok, state }
  end
  def parse_message(_message = %{ text: "version", channel: channel }, slack, state) do
    version = Kemisten.version
    Utils.send_message("I'm at version '#{version}', thanks for asking :)", channel)
    { :ok, state }
  end
  def parse_message(_message = %{ text: text, channel: channel }, _slack, state) do
    Logger.debug @unhandled_msg_string <> text
    Utils.send_message(@unhandled_msg_string <> text, channel)
    { :ok, state }
  end

  defp if_target_me(true, { _target, from, channel, _slack }, state) do
    Logger.info "#{@module_tag} The cheeky #{from} tried to make me ping myself!"
    Utils.send_message("No can do, Sir", channel)
    { :ok, state }
  end
  defp if_target_me(false, { target, _from, channel, slack }, state) do
    Logger.info "#{@module_tag} Starting pinger with #{target}"
    Pinger.setup_pinger(target, state, channel, slack)
  end
end
