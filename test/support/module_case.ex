defmodule Kemisten.ModuleCase do
  @moduledoc """
  This module defines the setup for tests that are meant to test a module with 
  no related data structs, e.g. Kemisten.Utils, Kemisten.Pinger.
  """

  use ExUnit.CaseTemplate

  using _module do
    quote do
    end
  end

  setup _tags do
    :ok
  end
  
end
