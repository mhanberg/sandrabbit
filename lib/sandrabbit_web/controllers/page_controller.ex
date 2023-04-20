defmodule SandrabbitWeb.PageController do
  use SandrabbitWeb, :controller

  plug :sandbox
  plug :get_caches

  def show(conn, %{"title" => title}) do
    message = Sandrabbit.Messages.get_message!(title, conn.private.message_cache)

    json(conn, %{message: message.body})
  end

  def create(conn, %{"message" => params}) do
    {:ok, chan} = AMQP.Application.get_channel(:messages)

    headers = [
      {"sandrabbit-request", :binary, :erlang.term_to_binary(self())},
      {"sandrabbit-user-agent", :binary, conn.private.useragent},
      {"sandrabbit-message-cache", :binary, :erlang.term_to_binary(conn.private.message_cache)}
    ]

    with :ok <-
           AMQP.Basic.publish(chan, "chat", "", Jason.encode!(params), headers: headers) do
      receive do
        {:consumer, {:ok, message}} ->
          conn
          |> put_status(201)
          |> text(message)

        {:consumer, {:error, changeset}} ->
          conn
          |> put_status(400)
          |> json(SandrabbitWeb.ErrorJSON.render(changeset))
      end
    else
      _ ->
        conn
        |> put_status(500)
        |> text("Internal Server Error")
    end
  end

  defp get_caches(%{private: private} = conn, _) do
    private = Map.put_new(private, :message_cache, :message_cache)

    Map.put(conn, :private, private)
  end

  if Mix.env() == :test do
    defp sandbox(conn, _) do
      metadata =
        Phoenix.Ecto.SQL.Sandbox.metadata_for(
          Application.get_env(:sandrabbit, :ecto_repos),
          self()
        )
        |> Phoenix.Ecto.SQL.Sandbox.encode_metadata()

      put_private(conn, :useragent, metadata)
    end
  else
    defp sandbox(conn, _) do
      put_private(conn, :useragent, "")
    end
  end
end
