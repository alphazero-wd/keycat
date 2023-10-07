defmodule Keycat.Repo.Migrations.AddMoreGamesFields do
  use Ecto.Migration

  def change do
    alter table(:games) do
      add(:time_limit, :integer, null: false)
      add(:paragraph, :text, null: false)
    end

    alter table(:history_games) do
      add(:time_taken, :integer)
    end
  end
end
