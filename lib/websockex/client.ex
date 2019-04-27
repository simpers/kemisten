defmodule Kemisten.Client do
  use WebSockex

  def start_link(url, module, state) when is_list(url),
    do: start_link(to_string(url), module, state)
  def start_link(url, module, state) when is_binary(url) do
    WebSockex.start_link(url, module, state)
  end
end
