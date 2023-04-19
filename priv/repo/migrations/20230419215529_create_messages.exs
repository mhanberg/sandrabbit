defmodule Sandrabbit.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :title, :text
      add :body, :text
      add :from, :text

      timestamps()
    end
  end
end
