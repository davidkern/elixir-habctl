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
      query: "",
      results: %{})}
  end

  def to_hundredths(n) do
    case n do
      nil -> ""
      _ -> :io.format("~.2f", [n])
    end
  end

  @impl true
  def handle_info({HabCtl.Board, board_metrics}, socket) do
    {:noreply, assign(socket, board_metrics: board_metrics)}
  end

  @impl true
  def handle_info({HabCtl.Energy, energy_metrics}, socket) do
    formatted_metrics = %{
      stored_energy: to_hundredths(energy_metrics.stored_energy),
      power: to_hundredths(energy_metrics.power),
      voltage: to_hundredths(energy_metrics.voltage),
      current: to_hundredths(energy_metrics.current)
    }

    {:noreply, assign(socket, energy_metrics: formatted_metrics)}
  end
end
