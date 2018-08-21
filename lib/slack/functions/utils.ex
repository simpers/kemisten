defmodule Kemisten.Utils do

  def send_message(text, channel) do
    # send_message(text, channel, slack)
    send(self(), { :message, text, channel })
  end

  def print_state(slack, nil), do: IO.inspect slack
  def print_state(slack, key) when is_binary(key), do: IO.inspect slack[String.to_existing_atom(key)]
  
  def extract_user_id(binary) when is_binary(binary) do
    regex = ~r/<@(?<id>[A-Z0-9]{9})>/u
    Regex.named_captures(regex, binary)["id"]
  end

  def format_mention(binary) when is_binary(binary), do: "<@#{binary}>"
  def format_mention(_user = %{ id: id, alias: mention_alias }), do: "<@#{id}|#{mention_alias}>"

  def check_if_im_channel_with_user(slack, channel, user_id) do
    slack[:ims][channel][:user] == user_id
  end
end
