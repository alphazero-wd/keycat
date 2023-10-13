defmodule Keycat.GamesTest do
  use Keycat.DataCase

  alias Keycat.{Games, Games.HistoryGames}
  import Keycat.{AccountsFixtures, GamesFixtures}

  setup do
    user = user_fixture()
    %{user: user}
  end

  describe "join_game/1" do
    test "should join in a game if there's an available one", %{user: user} do
      other_user = user_fixture()
      game = game_fixture()
      add_user_to_game(other_user, game)

      assert Games.join_game(user).id == game.id
    end

    test "should create a game if all games are full", %{user: user} do
      game = game_fixture()

      for _ <- 1..5 do
        another_user = user_fixture()
        add_user_to_game(another_user, game)
      end

      refute Games.join_game(user) == game.id
    end

    test "should create a game if all games are not in lobby mode", %{user: user} do
      game = game_fixture(%{status: "playing"})
      refute Games.join_game(user) == game.id
      game = game_fixture(%{status: "played"})
      refute Games.join_game(user) == game.id
    end
  end

  describe "leave_game/2" do
    test "should remove the history game if it hasn't started", %{user: user} do
      game = game_fixture()
      add_user_to_game(user, game)
      result = Games.leave_game(user.id, game.id)
      assert :ok = result

      refute Repo.exists?(
               from hg in HistoryGames, where: hg.game_id == ^game.id and hg.user_id == ^user.id
             )
    end

    test "should remove the history game if the user quits halfway", %{user: user} do
      game = game_fixture(%{status: "playing"})
      add_user_to_game(user, game)
      result = Games.leave_game(user.id, game.id)
      assert :ok = result

      refute Repo.exists?(
               from hg in HistoryGames, where: hg.game_id == ^game.id and hg.user_id == ^user.id
             )
    end

    test "shouldn't remove the history game if it has finished", %{user: user} do
      game = game_fixture(%{status: "played"})
      add_user_to_game(user, game)
      result = Games.leave_game(user.id, game.id)
      assert :ok = result

      assert Repo.exists?(
               from hg in HistoryGames, where: hg.game_id == ^game.id and hg.user_id == ^user.id
             )
    end
  end

  describe "get_game_by_id/2" do
    test "should return nil if the game is not found", %{user: user} do
      assert is_nil(Games.get_game_by_id(123, user))
    end

    test "should return nil if the game has already finished", %{user: user} do
      game = game_fixture(%{status: "played"})
      add_user_to_game(user, game)
      assert game.id |> Games.get_game_by_id(user) |> is_nil()
    end

    test "should return nil if the user doesn't join in the game", %{user: user} do
      game = game_fixture()
      assert is_nil(Games.get_game_by_id(game.id, user))
    end

    test "should return nil if the game is in playing status", %{user: user} do
      game = game_fixture(%{status: "playing"})
      add_user_to_game(user, game)
      assert is_nil(Games.get_game_by_id(game.id, user))
    end
  end
end
