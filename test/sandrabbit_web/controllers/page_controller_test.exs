defmodule SandrabbitWeb.PageControllerTest do
  use SandrabbitWeb.ConnCase, async: true

  test "POST /messages", %{conn: conn} do
    title = "The Day in the Life of a Coder"
    from = "Mitchell 'The #1 Coder' Hanberg"

    message = """
    Programming is simple and rewarding.
    """

    conn =
      post(conn, ~p"/api/messages", %{
        message: %{
          title: title,
          body: message,
          from: from
        }
      })

    assert text_response(conn, 201) == "Received message from #{from}"

    assert [%{title: ^title, body: ^message}] = Sandrabbit.Messages.list_messages()

    conn =
      conn
      |> recycle()
      |> get(~p"/api/messages/#{title}")

    assert %{"message" => ^message} = json_response(conn, 200)
  end
end
