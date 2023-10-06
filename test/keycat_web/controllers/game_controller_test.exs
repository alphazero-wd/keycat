defmodule KeycatWeb.GameControllerTest do
  use KeycatWeb.ConnCase
  import Keycat.{GamesFixtures}

  setup :register_and_log_in_user

  describe "index/3" do
    test "should show Find Match button if no AFK game is found", %{conn: conn} do
      conn = get(conn, Routes.game_path(conn, :index))
      assert html_response(conn, 200) =~ "Find game"
    end

    test "should show Reconnect button if no AFK game is found", %{conn: conn, user: user} do
      game = game_fixture()
      add_user_to_game(user, game)
      conn = get(conn, Routes.game_path(conn, :index))
      assert html_response(conn, 200) =~ "Reconnect"
    end
  end
end
