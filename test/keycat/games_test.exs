defmodule Keycat.GamesTest do
  use Keycat.DataCase

  alias Keycat.Games
  import Keycat.{AccountsFixtures, GamesFixtures}

  setup do
    user = user_fixture()
    %{user: user}
  end

  describe "find_afk_game/1" do
    test "should return the game the user is afk", %{user: user} do
      game = game_fixture()
      add_user_to_game(user, game)
      assert Games.find_afk_game(user).id == game.id
    end

    test "should return nil if the game the user has finished", %{user: user} do
      game = game_fixture()
      add_user_to_game(user, game, %{time_taken: 100})
      afk_game = Games.find_afk_game(user)
      assert is_nil(afk_game)
    end
  end

  describe "join_game/1" do
    test "should reconnect an afk game if previously joined", %{user: user} do
      afk_game = game_fixture()
      not_afk_game = game_fixture()
      another_not_afk_game = game_fixture()
      add_user_to_game(user, afk_game)
      prev_game = Games.join_game(user)
      assert prev_game.id == afk_game.id
      refute prev_game.id == not_afk_game.id
      refute prev_game.id == another_not_afk_game.id
    end

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
    test "should remove the user from the game if it hasn't started", %{user: user} do
      game = game_fixture()
      add_user_to_game(user, game)
      assert Games.find_afk_game(user)
      result = Games.leave_game(user, game)
      assert :ok = result
      refute Games.find_afk_game(user)
    end

    test "should penalize the user if they quit the game halfway", %{user: user} do
      game = game_fixture(%{status: "playing"})
      add_user_to_game(user, game)
      assert Games.find_afk_game(user)
      result = Games.leave_game(user, game)
      assert {:warn, _message} = result
      assert Games.find_afk_game(user)
    end
  end
end
