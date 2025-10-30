defmodule InventarioAnalisis do

  defmodule Movimiento do
    defstruct [:codigo, :tipo, :cantidad, :fecha]
  end

  def resumen_rango(movimientos, fini, ffin) do
    case {validar_fecha(fini), validar_fecha(ffin)} do
      {{:ok, fecha_ini}, {:ok, fecha_fin}} when fecha_ini <= fecha_fin ->
        {:ok, analizar(movimientos, fecha_ini, fecha_fin, %{}, 0)}

      {{:ok, _}, {:ok, _}} ->

        {:error, "La fecha inicial no puede ser después de la final"}

      {{:error, msg}, _} -> {:error, msg}
      {_, {:error, msg}} -> {:error, msg}
    end
  end

  defp analizar([], _ini, _fin, dias, maximo) do
    dias_con_mov = map_size(dias)
    {dias_con_mov, maximo}
  end

  defp analizar([%Movimiento{fecha: f, cantidad: c} | resto], ini, fin, dias, maximo) do
    case validar_fecha(f) do
      {:ok, fecha_mov} ->
        if fecha_mov >= ini and fecha_mov <= fin do
          nuevo_dia = Map.put(dias, f, true)
          nuevo_max = if c > maximo, do: c, else: maximo
          analizar(resto, ini, fin, nuevo_dia, nuevo_max)
        else
          analizar(resto, ini, fin, dias, maximo)
        end
      {:error, _} ->
        analizar(resto, ini, fin, dias, maximo)
    end
  end
  defp validar_fecha(fecha) do
    partes = String.split(fecha, "-", trim: true)

    case partes do
      [a, m, d] ->
        with {anio, ""} <- Integer.parse(a),
             {mes, ""} <- Integer.parse(m),
             {dia, ""} <- Integer.parse(d),
             true <- mes in 1..12,
             true <- dia in 1..31 do
          {:ok, {anio, mes, dia}}
        else
          _ -> {:error, "La fecha '#{fecha}' no tiene el formato correcto (YYYY-MM-DD)"}
        end

      _ ->
        {:error, "La fecha '#{fecha}' no tiene el formato correcto (YYYY-MM-DD)"}
    end
  end
end
