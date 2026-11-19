let
  Origem = stgDespesas,
  #"Escolher colunas" = Table.SelectColumns(Origem, {"dataempenho", "tipo_fornecedor", "fornecedor", "cnpj_fornecedor"}),
  #"Linhas classificadas" = Table.Buffer(Table.Sort(#"Escolher colunas", {{"dataempenho", Order.Descending}})),
  #"Colunas removidas" = Table.RemoveColumns(#"Linhas classificadas", {"dataempenho"}),
  #"Duplicatas removidas" = Table.Distinct(#"Colunas removidas", {"cnpj_fornecedor"}),
  #"Consultas mescladas" = Table.NestedJoin(#"Duplicatas removidas", {"cnpj_fornecedor"}, apoioCategoriaFornecedor, {"cnpj_fornecedor"}, "apoioCategoriaFornecedor", JoinKind.LeftOuter),
  #"Expandido apoioCategoriaFornecedor" = Table.ExpandTableColumn(#"Consultas mescladas", "apoioCategoriaFornecedor", {"categoria"}, {"categoria"}),
  #"Coluna condicional inserida" = Table.AddColumn(#"Expandido apoioCategoriaFornecedor", "categoria_fornecedor", each if [tipo_fornecedor] = "PF" then "Pessoa Física" else if [categoria] = null then "Empresa / Entidade" else [categoria]),
  #"Colunas removidas 1" = Table.RemoveColumns(#"Coluna condicional inserida", {"categoria"}),
  #"Tipo de coluna alterado" = Table.TransformColumnTypes(#"Colunas removidas 1", {{"categoria_fornecedor", type text}})
in
  #"Tipo de coluna alterado"
