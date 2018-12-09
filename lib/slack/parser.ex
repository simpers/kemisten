defmodule Kemisten.Parser do
  require Logger

  alias Kemisten.{Ignorer, Pinger,Utils}

  @module_tag "[Parser]"
  @unhandled_msg_string "Unhandled message received:\n"

  def handle_focus_and_ignored(message = %{ user: user }, state, slack) do
    cond do
      Utils.is_focusing?(state.focus) ->
        handle_focus(Utils.is_focusing_user?(user, state.focus), message, slack, state)
      true ->
        handle_ignored(Ignorer.is_ignoring_user?(user, state.ignoring), message, slack, state)
    end
  end

  defp handle_focus(false, _message = %{ user: user }, slack, state) do
    Logger.debug "#{@module_tag} Not focused on user #{Utils.get_users_name(user, slack)}"
    { :ok, state }
  end
  defp handle_focus(true, message, slack, state),
    do: parse_message(message, slack, state)

  defp handle_ignored(false, message, slack, state),
    do: parse_message(message, slack, state)
  defp handle_ignored(true, _message = %{ text: "ignore", user: user }, _slack, state) do
    { :ok, Ignorer.unignore_user(user, state) }
  end
  defp handle_ignored(true, _message = %{ user: user }, _slack, state) do
    Logger.info "#{@module_tag} Ignoring user #{user}"
    { :ok, state }
  end
  
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
  def parse_message(_message = %{ text: "io.state" }, slack, state) do
    Utils.print_state(slack, nil)
    { :ok, state }
  end
  def parse_message(_message = %{ text: "io.state " <> key }, slack, state) do
    Utils.print_state(slack, key)
    { :ok, state }
  end
  def parse_message(_message = %{ text: "version", channel: channel }, _slack, state) do
    version = Kemisten.version
    Utils.send_message("I'm at version '#{version}', thanks for asking :)", channel)
    { :ok, state }
  end
  def parse_message(_message = %{ text: "focus", user: user }, _slack, state = %{ focus: user }) do
    Utils.send_message("It has been a pleasure serving you, #{Utils.format_mention(user)}", user)
    { :ok, Map.put(state, :focus, nil)}
  end
  def parse_message(_message = %{ text: "focus", user: user }, _slack, state) do
    Utils.send_message("You have my full attention from this moment onward, #{Utils.format_mention(user)}", user)
    { :ok, Map.put(state, :focus, user) }
  end
  def parse_message(message = %{ text: "ignore", user: user }, slack, state) do
    parse_message(%{ message | text: "ignore <@#{user}>" }, slack, state)
  end
  def parse_message(message = %{ text: "ignore " <> target, user: user, channel: channel }, _slack, state) do
    target_id = Utils.extract_user_id(target)
    if Ignorer.is_ignoring_user?(target_id, state.ignoring) do
      Logger.debug "#{@module_tag} message as string:\n#{Kernel.inspect(message)}"
      Utils.send_message("I will stop ignoring #{target}, #{Utils.format_mention(user)}", channel)
      { :ok, Ignorer.unignore_user(target_id, state) }
    else
      Utils.send_message("Your wish is my command, #{Utils.format_mention(user)}", channel)
      Utils.send_message("I am now going to ignore you. Let me know when I shouldn't anymore...", target_id)
      { :ok, Ignorer.ignore_user(target_id, state) }
    end
  end
  def parse_message(message = %{ text: text, user: user, channel: channel }, slack, state) do
    cond do
      Utils.is_user_joined_or_left_message?(text) ->
        Logger.debug "#{@module_tag} Ignoring joined/left message"
        { :ok, state }
      Utils.get_my_id(slack) == user ->
        Logger.debug "#{@module_tag} Ignoring a message from myself/other deployment of kemisten"
        { :ok, state }
      true ->
        Logger.debug "#{@module_tag} #{@unhandled_msg_string}:\n#{Kernel.inspect(message)}"
        Utils.send_message(@unhandled_msg_string <> text, channel)
        { :ok, state }
    end
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
