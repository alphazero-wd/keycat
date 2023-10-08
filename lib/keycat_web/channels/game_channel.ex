defmodule KeycatWeb.GameChannel do
  use Phoenix.Channel
  alias KeycatWeb.Presence

  def join("game:" <> game_id, _message, socket) do
    send(self(), :after_join)
    {:ok, assign(socket, :game_id, String.to_integer(game_id))}
  end

  def handle_info(:after_join, socket) do
    {:ok, _} = Presence.track(socket, socket.assigns.current_user.username, %{})

    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end
end
