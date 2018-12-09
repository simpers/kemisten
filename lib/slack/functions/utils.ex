defmodule Kemisten.Utils do

  def get_my_id(nil),
    do: nil
  def get_my_id(slack),
    do: get_my_id_p(slack.me)

  defp get_my_id_p(nil),
    do: nil
  defp get_my_id_p(me),
    do: me.id

  # get_users_name/2
  def get_users_name(_user_id, nil), do: nil
  def get_users_name(user_id, slack) when is_binary(user_id) do
    { result, _ } = Kernel.pop_in(slack, [ :users, user_id, :name ])
    result
  end
    
  # get_users_real_name/2
  def get_users_real_name(_user_id, nil), do: nil
  def get_users_real_name(user_id, slack) when is_binary(user_id) do
    { result, _ } = Kernel.pop_in(slack, [ :users, user_id, :profile, :real_name ])
    result
  end

  # slack.users[user_id].profile.real_name

  def get_channel_name(channel_id, slack) when is_binary(channel_id) do
    slack.channels[channel_id].name
  end

  def format_mention_channel(channel_id, slack) when is_binary(channel_id) do
    "<##{channel_id}|#{get_channel_name(channel_id, slack)}>"
  end
  
  def print_state(slack, nil),
    do: IO.inspect slack
  def print_state(slack, key) when is_binary(key),
    do: IO.inspect slack[String.to_existing_atom(key)]

  def extract_user_id(binary) when is_binary(binary) do
    regex = ~r/<@(?<id>[A-Z0-9]{9})>/u
    Regex.named_captures(regex, binary)["id"]
  end

  # format_mention/1
  def format_mention(binary) when is_binary(binary),
    do: "<@#{binary}>"
  def format_mention(_nonbinary),
    do: nil

  # format_mention/3
  def format_mention(id, :name, slack),
    do: "<@#{id}|#{get_users_name(id, slack)}>"
  def format_mention(id, :real_name, slack),
    do: "<@#{id}|#{get_users_real_name(id, slack)}>"
  def format_mention(_id, _invalid_option, _slack),
    do: nil

  # does_channel_or_user_exists?/2
  def does_channel_or_user_exist?(channel, slack) do
    does_channel_or_user_exist_p([ :channels, channel ], slack) != nil or does_channel_or_user_exist_p([ :users, channel ], slack) != nil
  end

  defp does_channel_or_user_exist_p(list, slack) do
    { result, _ } = Kernel.pop_in(slack, list)
    result
  end

  #
  def is_user_joined_or_left_message?(binary) when is_binary(binary) do
    regex = ~r/<@(?<id>[A-Z0-9]{9})> has (joined|left) the channel/u
    Regex.match?(regex, binary)
  end
  def is_user_joined_or_left_message?(_nonbinary),
    do: false
  
  # send_message/2
  def send_message(_text, nil),
    do: nil
  def send_message(text, channel),
    do: send_message(text, channel, self())

  # send_message/3
  def send_message(text, channel, target),
    do: send(target, { :message, text, channel })

  # is_focusing?/2
  def is_focusing?(focus),
    do: focus != nil

  def is_focusing_user?(user, focus),
    do: user == focus
end
