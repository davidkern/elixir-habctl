defmodule HabCtl.Board do
  alias __MODULE__
  use Task

  @poll_period 1_000
  @topic inspect(__MODULE__)
  @path_cpu_temp "/sys/class/thermal/thermal_zone2/temp"

  defstruct [
    cpu_temp: nil
  ]

  def start_link(_arg) do
    Task.start_link(&poll/0)
  end

  def poll() do
    receive do
    after
      @poll_period ->
        broadcast(get_metrics())
        poll()
    end
  end

  def get_metrics() do
    board = %Board{}

    board = with {:ok, content} <- File.read(@path_cpu_temp) do
      %{board | cpu_temp: content |> String.trim() |> String.to_integer() |> Kernel./(1000)}
    end

    board
  end

  def subscribe do
    Phoenix.PubSub.subscribe(HabCtl.PubSub, @topic, link: true)
  end

  defp broadcast(board_metrics) do
    Phoenix.PubSub.broadcast(HabCtl.PubSub, @topic, {__MODULE__, board_metrics})
  end
end
