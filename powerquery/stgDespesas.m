// Staging: lê todos os CSVs da pasta, unifica os 2 layouts (2020-2024 e 2025+),
// define tipos, corrige a localidade dos valores e anonimiza pessoas físicas (LGPD).
// Carga desabilitada: alimenta a fato e as dimensões.
let
  Origem = Folder.Files(CaminhoPasta),

  // só CSV (proteção contra arquivos estranhos na pasta)
  #"Arquivos ocultos filtrados" = Table.SelectRows(Origem, each [Attributes]?[Hidden]? <> true and [Extension] = ".csv"),
  #"Personalização adicionada" = let
    rootPath = Text.TrimEnd(Value.Metadata(Value.Type(#"Arquivos ocultos filtrados"))[FileSystemTable.RootPath]?, "\"),
    combinePaths = (path1, path2) => Text.Combine({Text.TrimEnd(path1, "\"), path2}, "\"),
    getRelativePath = (path, relativeTo) => Text.Middle(path, Text.Length(relativeTo) + 1)
in
    Table.AddColumn(#"Arquivos ocultos filtrados", "Relative Path", each getRelativePath(combinePaths([Folder Path], [Name]), rootPath), type text),

  // layout 2025+ usa outros nomes de coluna: renomeia ANTES de empilhar,
  // senão o Combinar descarta essas colunas em silêncio
  #"Invocar a função personalizada" = Table.AddColumn(#"Personalização adicionada", "Transformar o arquivo", each Table.RenameColumns(#"Transformar o arquivo"([Content]), {{"nomeld", "elementodespesa"}, {"itemclassificacaodespesaitemclassificacaodespesa", "itemclassificacaodespesa"}}, MissingField.Ignore)),
  #"Colunas renomeadas" = Table.RenameColumns(#"Invocar a função personalizada", {{"Relative Path", "Nome da Origem"}}),
  #"As outras colunas foram removidas" = Table.SelectColumns(#"Colunas renomeadas", {"Nome da Origem", "Transformar o arquivo"}),
  #"Coluna de tabela expandida" = Table.ExpandTableColumn(#"As outras colunas foram removidas", "Transformar o arquivo", Table.ColumnNames(#"Transformar o arquivo"(#"Arquivo de exemplo"))),

  // tira a coluna com o nome do arquivo (o ano já existe)
  #"Remove origem" = Table.RemoveColumns(#"Coluna de tabela expandida", {"Nome da Origem"}),

  // tipos: ano número, data, resto texto (sem detecção automática)
  #"Tipos" = Table.TransformColumnTypes(#"Remove origem", {{"ano", Int64.Type}, {"orgao", type text}, {"dataempenho", type date}, {"uge", type text}, {"nomeunidadegestora", type text}, {"fonte", type text}, {"coditemclassificacaodespesa", type text}, {"itemclassificacaodespesa", type text}, {"nomefornecedor", type text}, {"cnpjfornecedor", type text}, {"num", type text}, {"elementodespesa", type text}}, "pt-BR"),

  // valores em formato americano (ponto decimal): sem o "en-US", 570.06 vira 57006
  #"Valores en-US" = Table.TransformColumnTypes(#"Tipos", {{"total_empenhado", Currency.Type}, {"total_liquidado", Currency.Type}, {"total_pago", Currency.Type}}, "en-US"),

  // padroniza textos: maiúscula + tira espaços
  #"Maiúscula e aparar" = Table.TransformColumns(#"Valores en-US", {{"orgao", each Text.Trim(Text.Upper(_)), type text}, {"fonte", each Text.Trim(Text.Upper(_)), type text}, {"nomeunidadegestora", each Text.Trim(Text.Upper(_)), type text}}),

  #"Colunas renomeadas 1" = Table.RenameColumns(#"Maiúscula e aparar", {{"itemclassificacaodespesa", "item_despesa"}, {"coditemclassificacaodespesa", "cod_item_despesa"}, {"elementodespesa", "elemento_despesa"}, {"nomeunidadegestora", "unidade_gestora"}, {"nomefornecedor", "nome_fornecedor"}, {"num", "num_empenho"}, {"cnpjfornecedor", "cpf_cnpj_fornecedor"}}),

  // LGPD: identifica PF (CPF com 000 na frente OU CPF formatado com hífen)
  #"Tipo fornecedor" = Table.AddColumn(#"Colunas renomeadas 1", "tipo_fornecedor", each if Text.StartsWith([cpf_cnpj_fornecedor], "000") or Text.Contains([cpf_cnpj_fornecedor], "-") then "PF" else "PJ", type text),
  #"LGPD fornecedor" = Table.AddColumn(#"Tipo fornecedor", "fornecedor", each if [tipo_fornecedor] = "PF" then "PESSOA FÍSICA" else [nome_fornecedor], type text),
  #"LGPD cnpj" = Table.AddColumn(#"LGPD fornecedor", "cnpj_fornecedor", each if [tipo_fornecedor] = "PF" then "PF" else [cpf_cnpj_fornecedor], type text),
  #"LGPD remove originais" = Table.RemoveColumns(#"LGPD cnpj", {"nome_fornecedor", "cpf_cnpj_fornecedor"})
in
  #"LGPD remove originais"
