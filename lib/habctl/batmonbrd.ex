defmodule HabCtl.BatMonBrd do
  alias __MODULE__
  use GenServer

  @topic inspect(__MODULE__)

  ### Client API

  @doc """
  Starts the Battery Monitor Board server.
  """
  def start_link(_opts) do
    {:ok, uart} = Circuits.UART.start_link(name: HabCtl.BatMonBrd.UART)
    GenServer.start_link(__MODULE__, uart, name: HabCtl.BatMonBrd)
  end

  @doc """
  Subscribe to updates from this server.
  """
  def subscribe do
    Phoenix.PubSub.subscribe(HabCtl.PubSub, @topic, link: true)
  end

  @impl true
  def init(uart) do
    Circuits.UART.open(
      uart,
      find_batmonbrd_device(),
      framing: Circuits.UART.Framing.Line,
      active: true)

    {:ok, uart}
  end

  @impl true
  def handle_info({:circuits_uart, _, data}, uart) do
    IO.inspect(data)
    broadcast(data)
    {:noreply, uart}
  end

  defp broadcast(data) do
    Phoenix.PubSub.broadcast(HabCtl.PubSub, @topic, {__MODULE__, data})
  end

  defp find_batmonbrd_device() do
    case Circuits.UART.enumerate |> Enum.find(fn(e) -> match?({_, %{manufacturer: "arturo182"}}, e) end) do
      {name, _} -> name
      _ -> nil
    end
  end
end
