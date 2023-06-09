defmodule Sandrabbit.Consumer do
  use GenServer
  use AMQP

  require Logger

  alias Sandrabbit.Messages
  alias Sandrabbit.Messages.Message

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], [])
  end

  @exchange "chat"
  @queue "messages"
  @queue_error "#{@queue}_error"

  def init(_opts) do
    {:ok, conn} = Connection.open("amqp://guest:guest@localhost")
    {:ok, chan} = Channel.open(conn)
    setup_queue(chan)

    # Limit unacknowledged messages to 10
    :ok = Basic.qos(chan, prefetch_count: 0)
    # Register the GenServer process as a consumer
    {:ok, _consumer_tag} = Basic.consume(chan, @queue)
    {:ok, chan}
  end

  # Confirmation sent by the broker after registering this process as a consumer
  def handle_info({:basic_consume_ok, %{consumer_tag: _consumer_tag}}, chan) do
    {:noreply, chan}
  end

  # Sent by the broker when the consumer is unexpectedly cancelled (such as after a queue deletion)
  def handle_info({:basic_cancel, %{consumer_tag: _consumer_tag}}, chan) do
    {:stop, :normal, chan}
  end

  # Confirmation sent by the broker to the consumer process after a Basic.cancel
  def handle_info({:basic_cancel_ok, %{consumer_tag: _consumer_tag}}, chan) do
    {:noreply, chan}
  end

  def handle_info(
        {:basic_deliver, payload,
         %{
           delivery_tag: tag,
           redelivered: redelivered,
           headers: [
             {"sandrabbit-request", :binary, pid},
             {"sandrabbit-user-agent", :binary, useragent},
             {"sandrabbit-message-cache", :binary, cache}
           ]
         }},
        chan
      ) do
    pid = pid |> Base.decode64!() |> :erlang.binary_to_term()
    cache = cache |> Base.decode64!() |> :erlang.binary_to_term()

    Task.async(
      wrap(useragent, fn ->
        consume(chan, tag, redelivered, payload, pid, cache)
      end)
    )
    |> Task.await()

    {:noreply, chan}
  end

  defp setup_queue(chan) do
    {:ok, _} = Queue.declare(chan, @queue_error, durable: false)

    # Messages that cannot be delivered to any consumer in the main queue will be routed to the error queue
    {:ok, _} =
      Queue.declare(chan, @queue,
        durable: false,
        arguments: [
          {"x-dead-letter-exchange", :longstr, ""},
          {"x-dead-letter-routing-key", :longstr, @queue_error}
        ]
      )

    :ok = Exchange.fanout(chan, @exchange, durable: true)
    :ok = Queue.bind(chan, @queue, @exchange)
  end

  defp consume(channel, tag, redelivered, payload, pid, cache) do
    with {:ok, params} <- Jason.decode(payload),
         {:ok, %Message{from: from}} <- Messages.create_message(params, cache) do
      Logger.debug("Received message from #{from}")
      Basic.ack(channel, tag)
      send(pid, {:consumer, {:ok, "Received message from #{from}"}})
    else
      {:error, changeset} ->
        Logger.error("Failed to send the message. #{inspect(changeset)}")

        send(pid, {:consumer, {:error, changeset}})
    end
  rescue
    exception ->
      :ok = Basic.reject(channel, tag, requeue: not redelivered)
      reraise exception, __STACKTRACE__
  end

  if Mix.env() == :test do
    defp wrap(useragent, func) do
      fn ->
        :ok = Phoenix.Ecto.SQL.Sandbox.allow(useragent, Ecto.Adapters.SQL.Sandbox)
        func.()
      end
    end
  else
    defp wrap(_, func) do
      func
    end
  end
end
