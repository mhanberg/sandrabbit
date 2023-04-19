defmodule Sandrabbit.Messages.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :body, :string
    field :from, :string
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:title, :body, :from])
    |> validate_required([:title, :body, :from])
  end
end
