defmodule Inventario do

  defmodule Pieza do
    defstruct [:codigo, :nombre, :valor, :unidad, :stock]
  end

  defmodule Movimiento do
    defstruct [:codigo, :tipo, :cantidad, :fecha]
  end

  def leer_movimientos(path) when is_binary(path) do
    case File.read(path) do
      {:ok, contenido} ->
        lineas = String.split(contenido, "\n", trim: true)
        parsear_movimientos(lineas, [])

      {:error, razon} ->
        {:error, "No se pudo leer el archivo: #{razon}"}
    end
  end

  defp parsear_movimientos([], acc), do: {:ok, Enum.reverse(acc)}

  defp parsear_movimientos([linea | resto], acc) do
    case String.split(linea, ",", trim: true) do
      [codigo, tipo, cantidad_str, fecha] ->
        with true <- tipo in ["ENTRADA", "SALIDA"],
             {cantidad, ""} <- Integer.parse(cantidad_str),
             true <- cantidad > 0 do
          mov = %Movimiento{
            codigo: codigo,
            tipo: tipo,
            cantidad: cantidad,
            fecha: fecha
          }

          parsear_movimientos(resto, [mov | acc])
        else
           -> {:error, "Datos inválidos en la línea: #{linea}"}
        end
      _ ->
        {:error, "Formato incorrecto en la línea: #{linea}"}
    end
  end

  def aplicar_movimientos(piezas, movimientos) when is_list(piezas) and is_list(movimientos) do
    actualizar_piezas(piezas, movimientos)
  end

  defp actualizar_piezas(piezas, []), do: piezas

  defp actualizar_piezas(piezas, [%Movimiento{} = mov | resto]) do
    piezas_actualizadas = aplicar_movimiento(piezas, mov)
    actualizar_piezas(piezas_actualizadas, resto)
  end

  defp aplicar_movimiento([], _mov), do: []

  defp aplicar_movimiento([%Pieza{codigo: c} = pieza | resto], %Movimiento{
         codigo: codigo,
         tipo: tipo,
         cantidad: cantidad
       }) do
    if c == codigo do
      nuevo_stock =
        case tipo do
          "ENTRADA" -> pieza.stock + cantidad
          "SALIDA" -> max(pieza.stock - cantidad, 0)
        end

      [%Pieza{pieza | stock: nuevo_stock} | resto]
    else
      [pieza | aplicar_movimiento(resto, %Movimiento{codigo: codigo, tipo: tipo, cantidad: cantidad, fecha: ""})]
    end
  end

def guardar_inventario(path, piezas) when is_binary(path) and is_list(piezas) do
    contenido =
      Enum.map(piezas, fn %Pieza{codigo: c, nombre: n, valor: v, unidad: u, stock: s} ->
        "#{c},#{n},#{v},#{u},#{s}"
      end)

      |> Enum.join("\n")

    File.write(path, contenido)
  end
end
