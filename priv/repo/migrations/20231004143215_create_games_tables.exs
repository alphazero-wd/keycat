defmodule Keycat.Repo.Migrations.CreateGamesTables do
  use Ecto.Migration

  def change do
    create table(:games) do
      add :min_wpm, :integer
      add :max_wpm, :integer
      add :status, :string, default: "lobby"
      timestamps()
    end

    create table(:users_games, primary_key: false) do
      add :game_id, references(:games, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)
      add :wpm, :integer, default: 0
      add :acc, :float, default: 0
    end

    create index(:users_games, :game_id)
    create index(:users_games, :user_id)
    create unique_index(:users_games, [:game_id, :user_id])
  end
end
