#!/bin/bash
URL=$API_URL
API_KEY=$API_KEY
STACK_NAME=$STACK_NAME
FILE_PATH=$FILE_PATH
imagem=hugollemos/demo:latest
# Faz a solicitação GET e armazena a resposta em uma variável
response=$(curl -s -X GET "$URL" -H "X-API-Key: $API_KEY" --insecure)

# Verifica se a stack com o nome $STACK_NAME está criada
if echo "$response" | jq -e '.[] | select(.Name == "'"$STACK_NAME"'")' > /dev/null; then

  # Extrai o valor do campo "Name" usando jq
  name=$(echo "$response" | jq -r '.[] | select(.Name == "'"$STACK_NAME"'") | .Name')

  # Imprime o nome da stack
  echo "A Stack chamada $name está criada. Noome: $name"

  # Obtém o ID da stack
  id=$(echo "$response" | jq -r '.[] | select(.Name == "'"$STACK_NAME"'") | .Id')
  
  # Imprime o ID da stack
  echo "Obtendo ID da stack: $id"
  
  # Monta a URL para a exclusão
  DELETE_URL="$URL/$id"
  
  # Faz a solicitação DELETE para atualizar a stack
  curl -X DELETE "$DELETE_URL" \
  -H "X-API-Key: $API_KEY" \
  -F "type=2" \
  -F "method=file" \
  -F "file=@$FILE_PATH" \
  -F "endpointId=2" \
  -F "Name=$STACK_NAME" --insecure
  echo "Stack deletada. ID: $id"
  sleep 5

  echo "realizando o pull"
  docker pull $imagem
  sleep 5
  
  echo "CRIANDO A STACK $name"
  response=$(curl -s -X POST "$URL" \
  -H "X-API-Key: $API_KEY" \
  -F "type=2" \
  -F "method=file" \
  -F "file=@$FILE_PATH" \
  -F "endpointId=2" \
  -F "Name=$STACK_NAME" --insecure)

  # Imprimir a resposta da requisição 
  echo "Resposta da solicitação POST: $response"

  # Extrair o valor do campo "Id" da nova stack usando jq
  id=$(echo "$response" | jq -r '.Id')

  # Imprimir o valor do Id
  echo "Nova Stack criada. Id: $id"
else
  echo fazendo o pull da imagem
  docker pull $imagem

  echo "Nenhuma Stack da aplicação encontrada."
  echo "CRIANDO A NOVA STACK"

  response=$(curl -s -X POST "$URL" \
  -H "X-API-Key: $API_KEY" \
  -F "type=2" \
  -F "method=file" \
  -F "file=@$FILE_PATH" \
  -F "endpointId=2" \
  -F "Name=$STACK_NAME" --insecure)

  # Imprimir a resposta da requisição 
  echo "Resposta da solicitação POST: $response"

  # Extrair o valor do campo "Id" da nova stack usando jq
  id=$(echo "$response" | jq -r '.Id')

  # Imprimir o valor do Id
  echo "Nova Stack criada. Id: $id"
fi