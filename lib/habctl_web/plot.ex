defmodule HabCtlWeb.Plot do
  def svg(data) do
    dataset = Contex.Dataset.new(data)
    plot_content = Contex.BarChart.new(dataset)
    plot = Contex.Plot.new(200, 100, plot_content)
    Contex.Plot.to_svg(plot)
  end
end
