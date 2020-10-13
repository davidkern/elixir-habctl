defmodule HabCtlWeb.PageLive do
  use HabCtlWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    HabCtl.Energy.subscribe()

    {:ok, assign(
      socket,
      board_metrics: HabCtl.Board.get_and_subscribe(),
      energy_metrics: HabCtl.Energy.default_metrics(),
      query: "",
      results: %{})}
  end

  @impl true
  def handle_info({HabCtl.Board, board_metrics}, socket) do
    {:noreply, assign(socket, board_metrics: board_metrics)}
  end

  @impl true
  def handle_info({HabCtl.Energy, energy_metrics}, socket) do
    formatted_metrics = %{
      stored_energy: HabCtl.Number.to_string(energy_metrics.stored_energy),
      power: HabCtl.Number.to_string(energy_metrics.power),
      voltage: HabCtl.Number.to_string(energy_metrics.voltage),
      current: HabCtl.Number.to_string(energy_metrics.current)
    }

    {:noreply, assign(socket, energy_metrics: formatted_metrics)}
  end
end
