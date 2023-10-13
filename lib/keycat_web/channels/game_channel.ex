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

    if length(Map.keys(game_players)) == 2 do
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
      broadcast(socket, "game_timer", %{time_limit: game.time_limit})
      {:noreply, socket}
    end
  end

  def handle_in("progress", %{"progress" => progress}, socket) do
    current_user = socket.assigns.current_user

    Presence.update(socket, current_user.id, %{
      username: current_user.username,
      progress: progress
    })

    broadcast(socket, "progress", %{player_id: current_user.id, progress: progress})

    {:noreply, socket}
  end

  intercept ["presence_diff"]

  def handle_out(
        "presence_diff",
        payload,
        socket
      ) do
    IO.inspect(%{payload: payload})

    if map_size(payload.leaves) == 1 do
      Games.leave_game(Map.keys(payload.leaves) |> hd(), socket.assigns.game_id)
    end

    game_players = Presence.list(socket)

    push(socket, "presence_state", game_players)

    {:noreply, socket}
  end
end
