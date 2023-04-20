defmodule SandrabbitWeb.PageControllerTest do
  use SandrabbitWeb.ConnCase, async: true

  setup %{conn: conn, module: module} do
    cache = :"message-#{module}"
    start_supervised!(Supervisor.child_spec({Cachex, name: cache}, id: cache))

    conn = put_private(conn, :message_cache, cache)

    [conn: conn]
  end

  for i <- 1..1000 do
    test "POST /messages #{i}", %{conn: conn} do
      title = "The Day in the Life of a Coder"
      from = "Mitchell 'The #1 Coder' Hanberg"

      message = """
      Programming is simple and rewarding.
      """

      response_conn =
        post(conn, ~p"/api/messages", %{
          message: %{
            title: title,
            body: message,
            from: from
          }
        })

      assert text_response(response_conn, 201) == "Received message from #{from}"

      assert [%{title: ^title, body: ^message}] = Sandrabbit.Messages.list_messages()

      response_conn = get(conn, ~p"/api/messages/#{title}")

      assert %{"message" => ^message} = json_response(response_conn, 200)
    end
  end
end
