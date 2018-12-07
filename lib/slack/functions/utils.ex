defmodule Kemisten.Utils do
  def get_my_id(slack), do: slack.me.id

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

  def channel_or_user_exists(slack, channel) do
    slack.channels[channel] != nil or slack.users[channel] != nil
  end

  # send_message/2
  def send_message(text, nil),
    do: nil
  def send_message(text, channel),
    do: send_message(text, channel, self())

  # send_message/3
  def send_message(text, channel, target),
    do: send(target, { :message, text, channel })
end
