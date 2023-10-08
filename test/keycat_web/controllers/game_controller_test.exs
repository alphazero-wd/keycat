defmodule KeycatWeb.GameControllerTest do
  use KeycatWeb.ConnCase, async: true
  import Keycat.{GamesFixtures}
  alias Keycat.Games.Game

  setup :register_and_log_in_user

  describe "index/3" do
    test "should show Find game button if no AFK game is found", %{conn: conn, user: user} do
      conn = get(conn, Routes.game_path(conn, :index))
      assert html_response(conn, 200) =~ "Welcome back, #{user.username}"
      assert html_response(conn, 200) =~ "Find game"
    end
  end

  describe "show/3" do
    test "should display the game if the user has joined in", %{conn: conn, user: user} do
      game = game_fixture()
      add_user_to_game(user, game)
      conn = get(conn, Routes.game_path(conn, :show, game))

      assert html_response(conn, 200) =~ "Game Lobby"

      assert html_response(conn, 200) |> String.contains?(game.paragraph)
    end

    test "should redirect to 404 page if the user doesn't join in", %{conn: conn} do
      game = game_fixture()
      conn = get(conn, Routes.game_path(conn, :show, game))
      assert redirected_to(conn) == "/not-found"
    end

    test "should redirect to 404 page if the game with the given id is not found", %{conn: conn} do
      conn = get(conn, Routes.game_path(conn, :show, %Game{id: 123}))
      assert redirected_to(conn) == "/not-found"
    end
  end

  describe "leave_game/3" do
    test "should leave game without penalty during lobby stage", %{conn: conn, user: user} do
      game = game_fixture()
      add_user_to_game(user, game)
      conn = delete(conn, Routes.game_path(conn, :leave_game, game))
      assert redirected_to(conn) == "/"
      conn = get(conn, "/")
      assert html_response(conn, 200) =~ "Successfully left game"
      assert html_response(conn, 200) =~ "Find game"
    end
  end
end
