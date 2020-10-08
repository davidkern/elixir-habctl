defmodule HabCtlWeb.PageLive do
  use HabCtlWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    HabCtl.Board.subscribe()

    {:ok, assign(
      socket,
      board_metrics: HabCtl.Board.default_metrics(),
      energy_metrics: HabCtl.Energy.default_metrics(),
      query: "",
      results: %{})}
  end

  @impl true
  def handle_info({HabCtl.Board, board_metrics}, socket) do
    {:noreply, assign(socket, board_metrics: board_metrics)}
  end
end
