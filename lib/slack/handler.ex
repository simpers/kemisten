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
  def handle_event(%{ type: "message", text: "IO.state" }, slack, state), do: print_state(slack, state)
  def handle_event(message = %{ type: "message", text: text, user: from }, slack, state) do
    text = String.rstrip(text)
    message = Map.put(message, :text, text)
    Logger.debug "Received message: \"#{text}\" from #{from}"
    { :ok, state } = handle_message(message, slack, state)
    { :ok, state }
  end
  def handle_event(%{ type: "hello" }, _, state) do
    { :ok, state }
  end
  def handle_event(_, _, state), do: { :ok, state }
  
  def handle_info({:message, text, channel}, slack, state) do
    IO.puts "Sending your message, Captain!"
    send_message(text, channel, slack)
    { :ok, state }
  end
  def handle_info(_, _, state), do: {:ok, state}

  #
  # Internal functions
  #

  defp handle_message(message = %{ text: "Greetings" }, slack, state), do: greeting(message, slack, state)
  defp handle_message(message = %{ text: text, user: from }, slack, state) do
    Logger.debug "Unhandled message \"#{text}\" from #{from}"
    { :ok, state }
  end
  
  defp greeting(message, slack, state) do
    user = slack.users[message.user]
    Logger.debug "User #{} sent message: Greetings"
    args = %{ id: user.id, alias: user.name }
    msg = "Hello, #{format_mention( args )}! How can I be of service?"
    send_message(msg, message.channel, slack)
    { :ok, state }
  end
  
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
