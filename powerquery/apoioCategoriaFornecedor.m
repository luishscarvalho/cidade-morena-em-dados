// De-para CNPJ -> categoria de fornecedor (dados/suporte/categoria_fornecedor.csv).
// Carga desabilitada: usado na mesclagem da dFornecedor.
let
  Origem = Csv.Document(File.Contents(CaminhoSuporte & "\categoria_fornecedor.csv"), [Delimiter = ";", Columns = 3, Encoding = 65001]),
  #"Cabeçalhos promovidos" = Table.PromoteHeaders(Origem, [PromoteAllScalars = true])
in
  #"Cabeçalhos promovidos"
