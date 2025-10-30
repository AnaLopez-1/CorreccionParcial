defmodule Inventario do

  defmodule Pieza do
    defstruct [:codigo, :nombre, :valor, :unidad, :stock]
  end

  def contar_stock([], _t), do: 0

  def contar_stock([%Pieza{stock: stock} | resto], t) when stock < t do
    1 + contar_stock(resto, t)
  end

  def contar_stock([_ | resto], t), do: contar_stock(resto, t)

end
