defmodule Inventario do

  defmodule Pieza do
    defstruct [:codigo, :nombre, :valor, :unidad, :stock]
  end


  def leer_piezas(archivo) do
    case File.read(archivo) do
      {:ok, contenido} ->
        lineas = String.split(contenido, "\n", trim: true)
        lista_actualizada(lineas, [])

      {:error, razon} ->
        {:error, "No se pudo leer el archivo: #{razon}"}
    end
  end

  defp lista_actualizada([], acumulador), do: {:ok, Enum.reverse(acumulador)}

  defp lista_actualizada([linea | resto], acumulador) do
    [codigo, nombre, valor_str, unidad, stock_str] = String.split(linea, ",", trim: true)

    valor = String.to_integer(valor_str)
    stock = String.to_integer(stock_str)

    pieza = %Pieza{codigo: codigo, nombre: nombre, valor: valor, unidad: unidad, stock: stock}

    lista_actualizada(resto, [pieza | acumulador])
  end
end
