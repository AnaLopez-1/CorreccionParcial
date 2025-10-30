defmodule InventarioUtil do

  def eliminar_duplicados(piezas) when is_list(piezas) do

    limpiar_lista(piezas, [])
  end

  defp limpiar_lista([], resultado), do: resultado

  defp limpiar_lista([%Inventario.Pieza{codigo: cod} = pieza | resto], resultado) do
    nuevo_resultado = actualizar_o_agregar(resultado, pieza)
    limpiar_lista(resto, nuevo_resultado)
  end

  defp actualizar_o_agregar([], pieza), do: [pieza]

  defp actualizar_o_agregar([%Inventario.Pieza{codigo: cod} | t], %Inventario.Pieza{codigo: cod_nueva} = nueva)
       when cod == cod_nueva do
    [nueva | t]
  end

  defp actualizar_o_agregar([h | t], nueva) do
    [h | actualizar_o_agregar(t, nueva)]
  end
end
