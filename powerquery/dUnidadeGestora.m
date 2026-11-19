let
  Origem = stgDespesas,
  #"Escolher colunas" = Table.SelectColumns(Origem, {"orgao", "dataempenho", "uge", "unidade_gestora"}),
  #"Linhas classificadas" = Table.Buffer(Table.Sort(#"Escolher colunas", {{"dataempenho", Order.Descending}})),
  #"Duplicatas removidas" = Table.Distinct(#"Linhas classificadas", {"uge"}),
  #"Colunas removidas" = Table.RemoveColumns(#"Duplicatas removidas", {"dataempenho"})
in
  #"Colunas removidas"
