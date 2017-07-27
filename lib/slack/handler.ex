defmodule Kemisten.Slack.Handler do
  use Slack
  require Logger

  #
  # Callbacks:
  #

  def handle_connect(slack, state) do
    IO.puts "Connected as #{slack.me.name}"
    {:ok, state}
  end

  def handle_event(%{ type: "message", user: "U5JCYJUPM" } = message, slack, state) do
    Logger.debug "Received my own message."
    { :ok, state }
  end
  def handle_event(%{ type: "message", text: "IO.state" } = message, slack, state), do: print_state(slack, state)
  def handle_event(%{ type: "message", text: "Greetings" } = message, slack, state) do
    user = slack.users[message.user]
    Logger.debug "User #{} sent message: Greetings"
    args = %{ id: user.id, alias: user.name }
    msg = "Hello, #{format_mention( args )}! How can I be of service?"
    send_message(msg, message.channel, slack)
    { :ok, state }
  end
  def handle_event(%{ type: "message", text: "ke" } = message, slack, state) do
    IO.inspect message
    user_id = message.user
    real_name = slack.users[user_id].real_name
    msg = "Hello, #{format_mention(%{ id: user_id, real_name: real_name })}! How can I be of service?"
    IO.inspect msg
    send_message(msg, message.channel, slack)
    { :ok, state }
  end
  def handle_event(%{ type: "message", text: text }, _, state) do
    Logger.debug "Unhandled message: #{text}"
    { :ok, state }
  end
  def handle_event(%{ type: "hello" }, _, state) do
    { :ok, state }
  end
  def handle_event(_, _, state), do: { :ok, state }
  
  def handle_info({:message, text, channel}, slack, state) do
    IO.puts "Sending your message, Captain!"
    send_message(text, channel, slack)
    {:ok, state}
  end
  def handle_info(_, _, state), do: {:ok, state}

  #
  # Internal functions
  #
  
  defp print_state(slack, state) do
    Logger.debug "Slack variable:"
    Logger.debug slack
    {:ok, state}
  end

  defp format_mention(%{ id: id, alias: mention_alias } = user) do
    formatted = "<@#{id}|#{mention_alias}>"
    Logger.debug "format_mention: #{formatted}"
    formatted
  end
end
