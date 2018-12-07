defmodule Kemisten.Slack.Handler do
  use Slack
  require Logger

  @module_tag "[Handler]"

  def handle_connect(slack, state) do
    Logger.info "#{@module_tag} Connected as #{slack.me.name}"
    { :ok, Map.put(state, :pinging, %{ }) }
  end

  def handle_event(message = %{ type: "message", text: text, channel: channel }, slack, state),
    do: Kemisten.Parser.parse_message(message, slack, state)
  def handle_event(%{ type: "hello" }, _, state),
    do: { :ok, state }
  def handle_event(%{ type: "error", error: %{ code: code, msg: msg } }, _, state) do
    Logger.error "#{@module_tag} Error #{code}: #{msg}"
    { :ok, state }
  end
  def handle_event(%{ type: event_type }, _, state) do
    Logger.info "#{@module_tag} Unhandled event of type #{event_type}"
    { :ok, state }
  end

  def handle_info({ :message, text, channel }, slack, state) do
    Logger.info "#{@module_tag} Sending message (#{channel}): #{text}"
    send_message(text, channel, slack)
    { :ok, state }
  end
  def handle_info(_, _, state),
    do: { :ok, state }
end
