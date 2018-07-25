defmodule Kemisten.Sassy do
  def get_sass(nil) do
    [
      "You think you're so cheeky, eh?",
      "Oh no, you didn't!",
      "I don't think so..."
    ]
    |> Enum.random
  end
  def get_sass(user) when is_binary(user) do
    [
      "You think you're so cheeky, eh?",
      "Oh no, you didn't!",
      "I don't think so, #{user}"
    ]
    |> Enum.random
  end
end
