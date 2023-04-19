defmodule SandrabbitWeb.PageController do
  use SandrabbitWeb, :controller
  alias Sandrabbit.Messages
  alias Sandrabbit.Messages.Message

  def create(conn, %{"message" => params}) do
    with {:ok, %Message{from: from}} <- Messages.create_message(params) do
      text(conn, "Hi #{from}, I got your message!")
    end
  end
end
