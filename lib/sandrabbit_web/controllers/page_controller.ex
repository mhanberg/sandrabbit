defmodule SandrabbitWeb.PageController do
  use SandrabbitWeb, :controller

  def create(conn, %{"message" => params}) do
    {:ok, chan} = AMQP.Application.get_channel(:messages)

    with :ok <-
           AMQP.Basic.publish(chan, "chat", "", Jason.encode!(params),
             headers: [{"sandrabbit-request", :binary, :erlang.term_to_binary(self())}]
           ) do
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
end
