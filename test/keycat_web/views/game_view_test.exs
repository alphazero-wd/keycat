defmodule Keycat.GameViewTest do
  import Phoenix.View
  import Keycat.{AccountsFixtures}
  use KeycatWeb.ConnCase, async: true

  test "should display the home page", %{conn: conn} do
    user = user_fixture()

    html =
      render_to_string(KeycatWeb.GameView, "index.html", conn: conn, current_user: user, game: nil)

    assert String.contains?(html, "Find game")
    assert String.contains?(html, "Welcome back, #{user.username}")
  end
end
