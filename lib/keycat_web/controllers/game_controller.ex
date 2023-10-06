defmodule KeycatWeb.GameController do
  use KeycatWeb, :controller
  alias Keycat.Games

  def action(conn, _options) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.current_user])
  end

  def index(conn, _params, user) do
    game = Games.find_afk_game(user)
    render(conn, "index.html", game: game, page_title: "Home")
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

    case Games.leave_game(user, game) do
      :ok -> conn |> put_flash(:info, "Successfully left game") |> redirect(to: "/")
      {:warn, message} -> conn |> put_flash(:info, message) |> redirect(to: "/")
    end
  end
end
