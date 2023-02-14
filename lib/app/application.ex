defmodule App.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      AppWeb.Telemetry,
      # Start the Ecto repository
      App.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: App.PubSub},
      # Start Finch
      {Finch, name: App.Finch},
      # Start the Endpoint (http/https)
      AppWeb.Endpoint,
      # Start a worker by calling: App.Worker.start_link(arg)
      # {App.Worker, arg}
      {Nx.Serving, serving: serving(), name: App.Serving, batch_timeout: 100}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: App.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AppWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp serving do
    {:ok, model} = Bumblebee.load_model({:hf, "deepset/roberta-base-squad2"})
    {:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, "roberta-base"})

    Bumblebee.Text.question_answering(model, tokenizer)
  end
end
