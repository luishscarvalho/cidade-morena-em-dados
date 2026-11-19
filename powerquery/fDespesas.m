let
  Origem = stgDespesas,
  #"Escolher colunas" = Table.SelectColumns(Origem, {"dataempenho", "uge", "fonte", "cod_item_despesa", "num_empenho", "total_empenhado", "total_liquidado", "total_pago", "cnpj_fornecedor"})
in
  #"Escolher colunas"
