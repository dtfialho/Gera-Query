# Gera-Query
Gerador de querys usando a linguagem ADVPL para copiar dados de uma tabela para outra baseado no dicionário de dados do protheus.

Para realizar a rotina primeiro deve ser especificado, a empresa e filial que será estabelecida a conexão com o dicionário de dados durante a execução do programa, após isso basta alterar a lista das tabelas que serão clonadas e o código da empresa de destino que pode ser uma ou mais.
Feito isso é necessário alterar também o código da empresa de origem e adicionar a path onde os arquivos serão salvos.
Execute o programa diretamente pelo DevStudio e os arquivos serão salvos na pasta indicada na path.
O programa cria um job que pode ser executado diretamente no banco de dados para não ser necessário copiar, colar e executar cada query gerada.
Obs.: Caso não seja utilizado uma base de dados Oracle, altere o select na linha 153 de null para algum valor.
