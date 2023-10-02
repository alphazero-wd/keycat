defmodule Keycat.RoomsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Keycat.Rooms` context.
  """

  @doc """
  Generate a room.
  """
  def room_fixture(attrs \\ %{}) do
    {:ok, room} =
      attrs
      |> Enum.into(%{
        join_code: "some join_code"
      })
      |> Keycat.Rooms.create_room()

    room
  end
end
