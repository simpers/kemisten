defmodule Kemisten.HandlerTest do
  use Kemisten.ModuleCase

  alias Kemisten.Slack.Handler

  @mock_slack %{
    me: %{
      id: "mocked_id",
      name: "test-bot"
    },
    channels: %{
    },
    users: %{
      "012345678" => %{ 
        profile: %{
          name: "test-bot",
          real_name: "Test McKormac"
        }
      }
    }
  }
  @init_state %{ pinging: %{}, ignoring: %{}, focus: nil }

  @init_pinging_event_state %{ pinging: %{}, ignoring: %{}, focus: nil }
  @init_pinging_mock_message %{ type: "message", user: "012345678", channel: "test-channel", text: "ping <@012345678>" }

  describe "test handle_connect/2" do
    test "test valid arguments" do
      assert { :ok, @init_state } == Handler.handle_connect(@mock_slack, %{})
    end

    test "test invalid arguments" do
      assert { :error, :invalid_argument, { :invalid_init_state, [] } } == Handler.handle_connect(@mock_slack, [])
    end
  end

  describe "test handle_event/3 for pinging" do
    test "test successful request to start pinging" do
      { :ok, new_state } = Handler.handle_event(@init_pinging_mock_message, @mock_slack, @init_pinging_event_state)
      # assert { :ok, %{ pinging: %{ "012345678" => { :interval, _ } }, focus: nil, ignoring: %{} } } == { :ok, new_state }
      assert Map.has_key?(new_state, :pinging)
      assert Map.has_key?(new_state.pinging, "012345678")
    end
  end
end
