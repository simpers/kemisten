defmodule Kemisten.Ignorer do

  require Logger
  
  alias Kemisten.Utils

  @module_tag "[Ignorer]"
  
  def ignore_user(user, state) do
    Kernel.put_in(state, [ :ignoring, user ], Timex.now())
  end

  def unignore_user(user, state) do
    case Kernel.pop_in(state[:ignoring][user]) do
      { nil, state } ->
        Utils.send_message("I was not ignoring #{Utils.format_mention(user)}..? :O", user)
        Logger.info "#{@module_tag} I was not ignoring #{user}, but still ended up in a case where I tried to handle ignoring said user."
        state
      { ignored_at, new_state } ->
        duration = Timex.Interval.duration(Timex.Interval.new(from: ignored_at, until: Timex.now()), :duration)
        dur_formatted = Timex.Format.Duration.Formatter.format(duration, :humanized)
        Utils.send_message("Your sentence has been lifted, #{Utils.format_mention(user)}. I ignored you for:\n#{dur_formatted}", user)
        new_state
    end
  end

  def is_ignoring_user?(user, ignored_users),
    do: Map.has_key?(ignored_users, user)

end
