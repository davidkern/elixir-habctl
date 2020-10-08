defmodule HabCtl.Board do
  alias __MODULE__
  use GenServer

  @tick_period 1_000
  @topic inspect(__MODULE__)
  @path_load_average "/proc/loadavg"

  defstruct [
    configuration: %{
      cpu_temp_path: nil
    },
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
      configuration: %{
        cpu_temp_path: find_cpu_temp_file()
      }
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
      cpu_temp:
        if state.configuration.cpu_temp_path do
          with {:ok, content} <- File.read(state.configuration.cpu_temp_path) do
            content |> String.trim() |> String.to_integer() |> Kernel./(1000)
          end
        end,

      load_average:
        with {:ok, content} <- File.read(@path_load_average) do
          content |> String.trim()
        end
    }
  end

  defp broadcast(board_metrics) do
    Phoenix.PubSub.broadcast(HabCtl.PubSub, @topic, {__MODULE__, board_metrics})
  end

  defp find_cpu_temp_file() do
    Path.wildcard("/sys/class/thermal/thermal_zone*") |>
    Enum.find(fn(p) -> {:ok, "x86_pkg_temp\n"} == File.read(Path.join(p, "type")) end) |>
    Path.join("temp")
  end
end
