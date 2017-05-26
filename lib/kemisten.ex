defmodule Kemisten do
  use Application

  @moduledoc """
  Documentation for Kemisten.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Kemisten.hello
      :world

  """
  def hello do
    :world
  end

  def start(_type, _args) do
    Kemisten.Supervisor.start_link
  end
end
