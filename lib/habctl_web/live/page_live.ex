defmodule HabCtlWeb.PageLive do
  use HabCtlWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    HabCtl.Board.subscribe()
    HabCtl.Energy.subscribe()

    {:ok, assign(
      socket,
      board_metrics: HabCtl.Board.default_metrics(),
      energy_metrics: HabCtl.Energy.default_metrics(),
      power_plot: "",
      cpu_temp_plot: "",
      query: "",
      results: %{})}
  end

  def to_hundredths(n) do
    case n do
      nil -> ""
      _ -> :erlang.float_to_binary(n, [decimals: 2])
    end
  end

  @impl true
  def handle_info({HabCtl.Board, board_metrics}, socket) do
    formatted_metrics = %{
      cpu_temp: board_metrics.cpu_temp,
      load_average: board_metrics.load_average
    }

    {:noreply, assign(
      socket,
      board_metrics: formatted_metrics,
      cpu_temp_plot: HabCtlWeb.Plot.svg([{"1", board_metrics.cpu_temp}])
    )}
  end

  @impl true
  def handle_info({HabCtl.Energy, energy_metrics}, socket) do
    formatted_metrics = %{
      stored_energy: to_hundredths(energy_metrics.stored_energy),
      power: to_hundredths(energy_metrics.power),
      voltage: to_hundredths(energy_metrics.voltage),
      current: to_hundredths(energy_metrics.current),
    }

    {:noreply, assign(
      socket,
      energy_metrics: formatted_metrics,
      power_plot: HabCtlWeb.Plot.svg([{1, energy_metrics.power}])
    )}
  end
end
