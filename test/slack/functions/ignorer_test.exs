defmodule Kemisten.IgnorerTest do
  use Kemisten.ModuleCase

  alias Kemisten.Ignorer

  @empty_ignoring_state %{ ignoring: %{ } }
  @user_ignoring_state %{
    ignoring: %{
      "user_id" => Timex.now(),
      "false" => Timex.now()
    }
  }
  
  describe "test Ignorer module" do
    test "test ignore_user/2" do
      %{ ignoring: ignoring } = Ignorer.ignore_user("user_id", @empty_ignoring_state)
      assert Map.has_key?(ignoring, "user_id")
      assert Map.has_key?(ignoring, "false") == false
    end

    test "test unignore_user/2" do
      %{ ignoring: ignoring } = Ignorer.unignore_user("user_id", @user_ignoring_state)
      assert Map.has_key?(ignoring, "user_id") == false
      assert Map.has_key?(ignoring, "false")
    end
  end
end
