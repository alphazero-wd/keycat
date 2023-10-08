defmodule KeycatWeb.GameController do
  use KeycatWeb, :controller
  alias Keycat.Games

  def action(conn, _options) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.current_user])
  end

  def index(conn, _params, _user) do
    render(conn, "index.html", page_title: "Home")
  end

  def join_game(conn, _params, user) do
    game = Games.join_game(user)
    redirect(conn, to: Routes.game_path(conn, :show, game))
  end

  def show(conn, %{"id" => id}, user) do
    game = Games.get_game_by_id(id, user)

    if !game do
      redirect(conn, to: "/not-found")
    else
      render(conn, "show.html", game: game, page_title: "Lobby")
    end
  end

  def leave_game(conn, %{"id" => id}, user) do
    game = Games.get_game_by_id(id, user)

    Games.leave_game(user, game)
    conn |> put_flash(:info, "Successfully left game") |> redirect(to: "/")
  end
end
