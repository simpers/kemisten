defmodule Kemisten.UtilsTests do
  use Kemisten.ModuleCase

  alias Kemisten.Utils

  describe "test get_my_id/1" do
    test "return id when state is legit" do
      slack_mock_state = %{ me: %{ id: "test" } }
      assert Utils.get_my_id(slack_mock_state) == "test"
    end
    
    test "return nil when state is not legit" do
      slack_mock_state = %{ me: nil }
      assert Utils.get_my_id(slack_mock_state) == nil
    end

    test "return nil state is nil" do
      slack_mock_state = nil 
      assert Utils.get_my_id(slack_mock_state) == nil
    end
  end

  describe "test get_users_name/2" do
    test "return name when user_id and state is legit" do
      slack_mock_state = %{ users: %{ "binary-user-id" => %{ name: "testname" } } }
      assert Utils.get_users_name("binary-user-id", slack_mock_state) == "testname"
    end
    
    test "return nil when user_id doesn't exist" do
      slack_mock_state = %{ users: %{ "binary-user-id-two" => %{ name: "testname" } } }
      assert Utils.get_users_name("binary-user-id", slack_mock_state) == nil
    end

    test "return nil state is nil" do
      slack_mock_state = nil
      assert Utils.get_users_name("binary-user-id", slack_mock_state) == nil
    end
  end

  describe "test get_users_real_name/2" do
    test "return id when state is legit" do
      slack_mock_state = %{ users: %{ "binary-user-id" => %{ profile: %{ real_name: "Real Name McKormac" } } } }
      assert Utils.get_users_real_name("binary-user-id", slack_mock_state) == "Real Name McKormac"
    end
    
    test "return nil when state is not legit" do
      slack_mock_state = %{ users: %{ "some other id" => %{ name: "name" } } }
      assert Utils.get_users_real_name("binary-user-id", slack_mock_state) == nil
    end

    test "return nil state is nil" do
      slack_mock_state = nil 
      assert Utils.get_users_real_name("binary-user-id", slack_mock_state) == nil
    end
  end

  describe "test does_channel_or_user_exists?/2" do
    test "return false when neither exists" do
      slack_mock_state = %{
        users: %{ "binary-user-id" => %{ profile: %{ real_name: "Real Name McKormac" } } },
        channels: %{}
      }
      assert Utils.does_channel_or_user_exist?("fake-channel", slack_mock_state) == false
    end
    
    test "return true when channel OR user exists" do
      slack_mock_state = %{
        users: %{ "some user id" => %{ name: "name" } },
        channels: %{ "some channel id" => %{} }
      }
      assert Utils.does_channel_or_user_exist?("some user id", slack_mock_state)
      assert Utils.does_channel_or_user_exist?("some channel id", slack_mock_state)
    end

    test "return nil state is nil" do
      slack_mock_state = nil 
      assert Utils.get_users_real_name("binary-user-id", slack_mock_state) == nil
    end
  end
end
