defmodule Kemisten.Slack.Handler do
  use Slack
  require Logger

  alias Kemisten.Pinger
  alias Kemisten.Utils

  #
  # Callbacks:
  #

  @me "U5JCYJUPM"
  @ping_me "ping <@#{@me}>"

  def handle_connect(slack, state) do
    Logger.info "Connected as #{slack.me.name}"
    { :ok, Map.put(state, :pinging, %{ }) }
  end

  def handle_event(_message = %{ type: "message", user: "U5JCYJUPM" }, _slack, state) do
    Logger.debug "Received my own message."
    { :ok, state }
  end

  # def handle_event(%{ type: "message", text: "ping " <> user }, slack, state) do
  #   Logger.info "Setting up a ping at user #{user}"
  #   { :ok, state } # setup_pinging(user, state, slack) }
  # end
  def handle_event(%{ type: "message", text: "IO.state" }, slack, state), do: print_state(slack, state)
  def handle_event(message = %{ type: "message", text: text, user: from }, slack, state) do
    text = String.trim_trailing(text)
    message = Map.put(message, :text, text)
    Logger.debug "Received message: \"#{text}\" from #{from}"
    handle_message(message, slack, state)
  end
  def handle_event(%{ type: "error", error: %{ code: code, msg: msg } }, _slack, state) do
    Logger.error "Error #{code}: #{msg}"
    { :ok, state }
  end
  def handle_event(%{ type: type }, _, state) do
    Logger.debug "Received event of type #{type}"
    { :ok, state }
  end

  def handle_info({ :message, text, channel }, slack, state) do
    IO.puts "Sending your message, Captain!"
    send_message(text, channel, slack)
    { :ok, state }
  end
  def handle_info(_, _, state), do: { :noreply, state }

  #
  # Internal functions
  #

  defp handle_message(_message = %{ text: "pong", user: user_id }, slack, state) do
    Logger.info "Got pong from user #{user_id}"
    # handle_pong(user_id, state, slack)
    Pinger.pong_response(user_id, state, slack)
  end
  defp handle_message(_message = %{ text: @ping_me }, _slack, state) do
    Logger.info "Some cheeky bastard tried to make me ping myself!"
    { :ok, state }
  end
  defp handle_message(_message = %{ text: "ping " <> user }, slack, state) do
    Logger.info "Start pinging user #{user}"
    Pinger.setup_pinger(Utils.extract_user_id(user), state, slack)
  end
  defp handle_message(_message = %{ text: "ping", channel: channel }, slack, state) do
    Logger.info "Got a ping, will respond with a pong"
    Pinger.ping_response(channel, slack)
    { :ok, state }
  end
  defp handle_message(_message = %{ text: "stop pinging " <> user}, _slack, state) do
    Logger.info "Stop pinging user #{user}"
    Pinger.stop_pinger(Utils.extract_user_id(user), state)
  end
  defp handle_message(message = %{ text: "Greetings" }, slack, state), do: greeting(message, slack, state)
  defp handle_message(message = %{ text: "name" }, slack, state), do: generate_name_for_slack(message, slack, state)
  defp handle_message(message = %{ text: text, user: from }, slack, state) do
    regex = ~r/\?/iu
    case Regex.match?(regex, text) do
      true ->
        let_me_google_it_for_you_slack(message, slack, state)
      false ->
        Logger.error "Unhandled message \"#{text}\" from #{from}"
        { :ok, state }
    end
  end

  defp let_me_google_it_for_you_slack(message, slack, state) do
    user = slack.users[message.user]
    Logger.debug "User #{user.name} needs help to find The Google Search.. (:"
    link = "http://lmgtfy.com/?q=#{URI.encode(message.text)}"
    msg = "Hey, since I am so nice, here you go: #{link}"
    send_message(msg, message.channel, slack)
    { :ok, state }
  end

  defp generate_name_for_slack(message, slack, state) do
    user = slack.users[message.user]
    Logger.debug "User #{user.name} requested a new name!"
    name = generate_name()
    format_args = %{ id: user.id, alias: user.name }
    msg = "Hello, #{format_mention(format_args)}, your new name is #{name}"
    send_message(msg, message.channel, slack)
    { :ok, state }
  end

  defp generate_name(), do: Enum.random([ "Kekler", "Keckler", "Keckan", "Kecka", "Kucka" ])

  defp greeting(message, slack, state) do
    user = slack.users[message.user]
    Logger.debug "User #{} sent message: Greetings"
    args = %{ id: user.id, alias: user.name }
    msg = "Hello, #{format_mention( args )}! How can I be of service?"
    send_message(msg, message.channel, slack)
    { :ok, state }
  end

  defp print_state(slack, state) do
    Logger.debug "Slack state variable:"
    IO.inspect slack
    { :ok, state }
  end

  defp format_mention(_user = %{ id: id, alias: mention_alias }) do
    formatted = "<@#{id}|#{mention_alias}>"
    Logger.debug "format_mention: #{formatted}"
    formatted
  end
end
