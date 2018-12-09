defmodule Kemisten.Slack.Handler do
  use Slack
  require Logger

  alias Kemisten.Utils
  
  @module_tag "[Handler]"

  def handle_connect(slack, state) do
    Logger.info "#{@module_tag} Connected as #{slack.me.name}"
    new_state = state
    |> Map.put(:pinging, %{ })
    |> Map.put(:ignoring, %{ })
    |> Map.put(:focus, nil)
    { :ok, new_state }
  end

  def handle_event(message = %{ type: "message", sub_type: "bot_message" }, _slack, state) do
    message_string = Kernel.inspect(message)
    Logger.debug "#{@module_tag} Bot message received:\n#{message_string}"
    { :ok, state }
  end
  def handle_event(message = %{ type: "message", text: text }, slack, state),
    do: Kemisten.Parser.handle_focus_and_ignored(%{ message | text: String.trim(text) }, state, slack)
  def handle_event(%{ type: "hello" }, _, state),
    do: { :ok, state }
  def handle_event(%{ type: "error", error: error }, _slack, state) do
    Logger.error "#{@module_tag} Error: #{Kernel.inspect(error)}"
    { :ok, state }
  end
  def handle_event(event = %{ type: "member_joined_channel", channel: channel, user: user }, slack, state) do
    event_string = Kernel.inspect(event)
    Utils.send_message("Welcome to #{Utils.format_mention_channel(channel, slack)}, #{Utils.format_mention(user)}", channel)
    { :ok, state }
  end
  def handle_event(event = %{ type: "member_left_channel" }, _slack, state) do
    event_string = Kernel.inspect(event)
    Logger.debug "#{@module_tag} Member left channel event:\n#{event_string}"
    { :ok, state }
  end
  def handle_event(%{ type: event_type }, _, state) do
    Logger.info "#{@module_tag} Unhandled event of type #{event_type}"
    { :ok, state }
  end

  # handle_info/3
  def handle_info({ :message, text, channel }, slack, state) do
    Logger.info "#{@module_tag} Sending message (#{channel}): #{text}"
    send_message(text, channel, slack)
    { :ok, state }
  end
  def handle_info(info, _, state) do
    Logger.error "#{@module_tag} handle_info/3 catch all - should not be here!\nGot info: #{Kernel.inspect(info)}"
    { :ok, state }
  end
end
