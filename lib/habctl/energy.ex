defmodule HabCtl.Energy do
  alias __MODULE__
  use GenServer

  @topic inspect(__MODULE__)

  defstruct [
    configuration: %{},
    metrics: %{
      stored_energy: nil,
      power: nil,
      voltage: nil,
      current: nil,
    }
  ]

  ## Client API

  @doc """
  Starts the Energy monitoring server.
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Subscribe to updates from this server.
  """
  def subscribe do
    Phoenix.PubSub.subscribe(HabCtl.PubSub, @topic, link: true)
  end

  @doc """
  Gets the default (empty) metrics.
  """
  def default_metrics do
    %Energy{}.metrics
  end

  ### Server
  def init(:ok) do
    state = %Energy{}

    {:ok, state}
  end
end
