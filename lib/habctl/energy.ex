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
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: HabCtl.Energy)
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
  @impl true
  def init(:ok) do
    HabCtl.BatMonBrd.subscribe()
    state = %Energy{}

    {:ok, state}
  end

  @impl true
  def handle_info({HabCtl.BatMonBrd, data}, state) do
    acc = Enum.reduce(data, fn(x, acc) ->
      %{
        voltage: acc.voltage + x.voltage,
        current: acc.current + x.current,
        stored_energy: acc.stored_energy + x.stored_energy
      }
    end)

    count = Enum.count(data)

    metrics = %{
      stored_energy: acc.stored_energy,
      power: acc.voltage * acc.current / count,
      voltage: acc.voltage / count,
      current: acc.current
    }

    {:noreply, %Energy{state | metrics: metrics}}
  end
end
