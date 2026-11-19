let
  Origem = stgDespesas,
  #"Escolher colunas" = Table.SelectColumns(Origem, {"dataempenho", "cod_item_despesa", "item_despesa", "elemento_despesa"}),
  #"Linhas classificadas" = Table.Buffer(Table.Sort(#"Escolher colunas", {{"dataempenho", Order.Descending}})),
  #"Colunas removidas" = Table.RemoveColumns(#"Linhas classificadas", {"dataempenho"}),
  #"Duplicatas removidas" = Table.Distinct(#"Colunas removidas", {"cod_item_despesa"}),
  #"Intervalo de texto inserido" = Table.AddColumn(#"Duplicatas removidas", "Intervalo de texto", each Text.Middle([cod_item_despesa], 4, 2), type text),
  #"Colunas renomeadas" = Table.RenameColumns(#"Intervalo de texto inserido", {{"Intervalo de texto", "cod_elemento"}})
in
  #"Colunas renomeadas"
