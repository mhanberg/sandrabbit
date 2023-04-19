defmodule SandrabbitWeb.PageControllerTest do
  use SandrabbitWeb.ConnCase, async: true

  test "POST /messages", %{conn: conn} do
    conn =
      post(conn, ~p"/messages", %{
        message: %{
          title: "How to do transactional testing",
          body: """
          It's very hard
          """,
          from: "Mitchell 'The Smartest Man Alive' Hanberg"
        }
      })

    assert text_response(conn, 201) ==
             "Received message from mitchell 'The Smarted Man Alive' Hanberg"
  end
end
