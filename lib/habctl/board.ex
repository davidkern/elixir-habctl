defmodule HabCtl.Board do
  alias __MODULE__
  use GenServer

  @tick_period 1_000
  @topic inspect(__MODULE__)
  @path_load_average "/proc/loadavg"

  defstruct [
    cpu_temp_stream: nil,
    metrics: %{
      cpu_temp: nil,
      load_average: "",
    }
  ]

  ### Client API

  @doc """
  Starts the Board monitoring server.
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
    %Board{}.metrics
  end

  ### Server

  @impl true
  def init(:ok) do
    board = %Board{
      cpu_temp_stream: board_temperature(),
    }

    Process.send_after(self(), :tick, @tick_period)
    {:ok, board}
  end

  @impl true
  def handle_call(:get_metrics, _from, state) do
    {:reply, state.metrics, state}
  end

  @impl true
  def handle_info(:tick, state) do
    metrics = update_metrics(state)
    broadcast(metrics)
    Process.send_after(self(), :tick, @tick_period)
    {:noreply, %Board{ state | metrics: metrics }}
  end

  defp update_metrics(state) do
    %{
      cpu_temp: HabCtl.Enum.take_one(state.cpu_temp_stream),

      load_average:
        with {:ok, content} <- File.read(@path_load_average) do
          content |> String.trim()
        end
    }
  end

  defp broadcast(board_metrics) do
    Phoenix.PubSub.broadcast(HabCtl.PubSub, @topic, {__MODULE__, board_metrics})
  end

  ### Streams

  defp board_temperature_path(
    name,
    search_path
  ) do
    search_paths = Path.wildcard(search_path)
    finder = fn(p) -> {:ok, "#{name}\n"} == File.read(Path.join(p, "type")) end
    case Enum.find(search_paths, finder) do
      nil -> {:error, :not_found}
      found -> {:ok, Path.join(found, "temp")}
    end
  end

  defp read_board_temperature(path) do
    with {:ok, raw} <- File.read(path) do
      raw
      |> String.trim()
      |> String.to_integer()
      |> Kernel./(1000)
    end
  end

  @doc """
  Returns a stream of temperature data from /sys/class/thermal matching
  the provided name.
  """
  def board_temperature(
    name \\ "x86_pkg_temp",
    search_path \\ "/sys/class/thermal/thermal_zone*"
  ) do
    with {:ok, path} <- board_temperature_path(name, search_path) do
      Stream.resource(
        fn -> path end,
        fn path -> {[read_board_temperature(path)], path} end,
        fn value -> value end
      )
    end
  end
end
