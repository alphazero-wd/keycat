defmodule KeycatWeb.GameChannel do
  use Phoenix.Channel
  alias Keycat.Games
  alias KeycatWeb.Presence

  def join("game:" <> game_id, _message, socket) do
    send(self(), :after_join)
    {:ok, assign(socket, :game_id, String.to_integer(game_id))}
  end

  def handle_info(:after_join, socket) do
    player = socket.assigns.current_user

    {:ok, _} =
      Presence.track(
        socket,
        socket.assigns.current_user.id,
        %{username: player.username, progress: 0}
      )

    game_players = Presence.list(socket)

    push(socket, "presence_state", game_players)

    if length(Map.keys(game_players)) > 1 do
      {:ok, tRef} = :timer.send_interval(1_000, :countdown)
      {:noreply, assign(socket, :tRef, tRef)}
    else
      {:noreply, assign(socket, :countdown, nil)}
    end
  end

  def handle_info(:countdown, socket) do
    countdown = if is_nil(socket.assigns[:countdown]), do: 10, else: socket.assigns[:countdown]

    if countdown >= 0 do
      push(socket, "countdown", %{countdown: countdown})
      broadcast(socket, "countdown", %{countdown: countdown})
      {:noreply, assign(socket, :countdown, countdown - 1)}
    else
      :timer.cancel(socket.assigns[:tRef])
      {:ok, game} = Games.update_game_status(socket.assigns.game_id, "playing")
      socket = assign(socket, time_limit: game.time_limit)
      :timer.send_interval(1_000, :game_timer)
      {:noreply, socket}
    end
  end

  def handle_info(:game_timer, socket) do
    time_limit = socket.assigns[:time_limit]

    if time_limit >= 0 do
      push(socket, "game_timer", %{time_limit: time_limit - 1})
      broadcast(socket, "game_timer", %{time_limit: time_limit - 1})
    else
      Games.update_game_status(socket.assigns.game_id, "played")
    end

    {:noreply, assign(socket, :time_limit, time_limit - 1)}
  end
end
