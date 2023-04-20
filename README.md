# Sandrabbit

This repository demonstrates how to wire up multiple asynchronous processes into the Ecto sandbox, as well as demonstrate how always passing in which piece of state you want to use (in our case, a cache), you can avoid concurrent tests clobbering each other.

## Tour

TODO: write me up

## Getting Started

This is a fairly basic Phoenix and Ecto application.

The only unique characteristic is the usage of RabbitMQ and the [amqp](https://hex.pm/packages/amqp) library. So you must have RabbitMQ installed and running (you can install with Hombrew).

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
