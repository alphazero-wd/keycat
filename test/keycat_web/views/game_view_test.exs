defmodule Keycat.GameViewTest do
  import Phoenix.View
  import Keycat.{AccountsFixtures, GamesFixtures}
  use KeycatWeb.ConnCase, async: true

  test "should display the Find game button if there's no AFK game", %{conn: conn} do
    user = user_fixture()

    html =
      render_to_string(KeycatWeb.GameView, "index.html", conn: conn, current_user: user, game: nil)

    assert String.contains?(html, "Find game")
    refute String.contains?(html, "Reconnect")
  end

  test "should display the Reconnect button if there's an AFK game", %{conn: conn} do
    user = user_fixture()

    html =
      render_to_string(KeycatWeb.GameView, "index.html",
        conn: conn,
        current_user: user,
        game: game_fixture()
      )

    refute String.contains?(html, "Find game")
    assert String.contains?(html, "Reconnect")
  end
end
