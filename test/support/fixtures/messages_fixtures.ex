defmodule Sandrabbit.MessagesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sandrabbit.Messages` context.
  """

  @doc """
  Generate a message.
  """
  def message_fixture(attrs \\ %{}) do
    {:ok, message} =
      attrs
      |> Enum.into(%{
        body: "some body",
        from: "some from",
        title: "some title"
      })
      |> Sandrabbit.Messages.create_message()

    message
  end
end
