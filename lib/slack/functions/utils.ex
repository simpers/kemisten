defmodule Kemisten.Utils do

  def extract_user_id(binary) when is_binary(binary) do
    regex = ~r/<@(?<id>[A-Z0-9]{9})>/u
    Regex.named_captures(regex, binary)["id"]
  end
end
