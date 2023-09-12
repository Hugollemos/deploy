#!/bin/bash
URL=$API_URL
URL_PEGANDO_ID="http://89.116.214.202:9000/api/endpoints/2/docker/containers/json"
URL_FOR_PAUSA="http://89.116.214.202:9000/api/endpoints/2/docker/containers"
URL_FOR_DELETE="http://89.116.214.202:9000/api/endpoints/2/docker/containers"
API_KEY=$API_KEY
STACK_NAME=ola
FILE_PATH=$FILE_PATH
imagem=hugollemos/demo:latest
ENDPOINT=2
CONTAINER_NAME=abc
 #Faz a solicitação GET e armazena a resposta em uma variável
response=$(curl -s -X GET "$URL" -H "X-API-Key: $API_KEY" --insecure)

# Obtenha o ID do contêiner com base no nome
CONTAINER_ID=$(curl -X GET "$URL_PEGANDO_ID" -H "X-Api-Key: $API_KEY" | jq -r '.[] | select(.Names[] | contains("'$CONTAINER_NAME'")) | .Id')

# Verifica se a stack com o nome $STACK_NAME está criada
if echo "$response" | jq -e '.[] | select(.Name == "'"$STACK_NAME"'")' > /dev/null; then

  # Extrai o valor do campo "Name" usando jq
  name=$(echo "$response" | jq -r '.[] | select(.Name == "'"$STACK_NAME"'") | .Name')

  # Imprime o nome da stack
  echo "A Stack chamada $name está criada. Nome: $name"

  # Obtém o ID da stack
  id=$(echo "$response" | jq -r '.[] | select(.Name == "'"$STACK_NAME"'") | .Id')

  # Monta a URL para a exclusão
  DELETE_URL="$URL/$id"

  if [ ! -z "$CONTAINER_ID" ]; then
    echo "pausando container"
    curl -X POST "$URL_FOR_PAUSA/$CONTAINER_NAME/stop" -H "X-API-Key: $API_KEY"
    sleep 5
    echo "deletando container"
    curl -X DELETE "$URL_FOR_DELETE/$CONTAINER_NAME" -H "X-API-Key: $API_KEY"
    echo "pull container"
    docker pull hugollemos/demo:latest 
    echo "deletando stack"
    sleep 5
    curl -X DELETE "$DELETE_URL" \
    -H "X-API-Key: $API_KEY" \
    -F "type=2" \
    -F "method=file" \
    -F "file=@$FILE_PATH" \
    -F "endpointId=$ENDPOINT" \
    -F "Name=$STACK_NAME" --insecure
    echo "Stack deletada. ID: $id"
    sleep 5
    echo "Aguarde 2 segundos"
    sleep 2
    echo "CRIANDO A STACK $name"
    sleep 5
    echo "Aguardando 5 segundos..."
    sleep 5
    echo "=========================================="
    echo "CRIANDO A STACK $name"
    echo "=========================================="
    response=$(curl -s -X POST "$URL" \
    -H "X-API-Key: $API_KEY" \
    -F "type=2" \
    -F "method=file" \
    -F "file=@$FILE_PATH" \
    -F "endpointId=$ENDPOINT" \
    -F "Name=$STACK_NAME" --insecure)

    # Imprimir a resposta da requisição 
    echo "Resposta da solicitação POST: $response"

    # Extrair o valor do campo "Id" da nova stack usando jq
    id=$(echo "$response" | jq -r '.Id')

    # Imprimir o valor do Id
    echo "Nova Stack criada. Id: $id"
  else
    echo "container nao encontrado"
    echo "deletando stack"
    curl -X DELETE "$DELETE_URL" \
    -H "X-API-Key: $API_KEY" \
    -F "type=2" \
    -F "method=file" \
    -F "file=@$FILE_PATH" \
    -F "endpointId=$ENDPOINT" \
    -F "Name=$STACK_NAME" --insecure
    echo "Stack deletada. ID: $id"
    echo "CRIANDO A NOVA STACK"

    response=$(curl -s -X POST "$URL" \
    -H "X-API-Key: $API_KEY" \
    -F "type=2" \
    -F "method=file" \
    -F "file=@$FILE_PATH" \
    -F "endpointId=$ENDPOINT" \
    -F "Name=$STACK_NAME" --insecure)

    # Imprimir a resposta da requisição 
    echo "Resposta da solicitação POST: $response"

    # Extrair o valor do campo "Id" da nova stack usando jq
    id=$(echo "$response" | jq -r '.Id')

    # Imprimir o valor do Id
    echo "Nova Stack criada. Id: $id"
  fi

else
  echo "=========================================="
  echo "NENHUMA STACK DA APLICAÇÃO ENCONTRADA."
  echo "CRIANDO A NOVA STACK"
  echo "=========================================="
  echo "realizando o pull"
  docker pull hugollemos/demo:latest
  sleep 5
  response=$(curl -s -X POST "$URL" \
  -H "X-API-Key: $API_KEY" \
  -F "type=2" \
  -F "method=file" \
  -F "file=@$FILE_PATH" \
  -F "endpointId=$ENDPOINT" \
  -F "Name=$STACK_NAME" --insecure)

  # Imprimir a resposta da requisição 
  echo "Resposta da solicitação POST: $response"

  # Extrair o valor do campo "Id" da nova stack usando jq
  id=$(echo "$response" | jq -r '.Id')

  # Imprimir o valor do Id
  echo "Nova Stack criada. Id: $id"
fi