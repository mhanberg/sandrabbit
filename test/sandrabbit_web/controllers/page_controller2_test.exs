defmodule SandrabbitWeb.PageController2Test do
  use SandrabbitWeb.ConnCase, async: true

  test "POST /messages", %{conn: conn} do
    id = Ecto.UUID.generate()

    conn =
      post(conn, ~p"/messages", %{
        message: %{
          title: id,
          body: """
          It's very hard
          """,
          from: "Mitchell 'The Smartest Man Alive' Hanberg"
        }
      })

    assert text_response(conn, 201) ==
             "Received message from Mitchell 'The Smartest Man Alive' Hanberg"

    assert [%{title: ^id}] = Sandrabbit.Messages.list_messages()
  end
end
