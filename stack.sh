#!/bin/bash
URL=$API_URL
API_KEY=$API_KEY
STACK_NAME=$STACK_NAME
FILE_PATH=$FILE_PATH
ENDPOINT=$ENDPOINT
api_docker=$api_docker
MANIPULA_CONTAINER=$api_docker/containers
getsha=$api_docker/images/json
deleteimagem=$api_docker/images
tags=$tags

# Faz a solicitação GET e armazena a resposta em uma variável
response=$(curl -s -X GET "$URL" -H "X-API-Key: $API_KEY" --insecure)


# Obtenha o ID do contêiner com base no nome
CONTAINER_ID=$(curl -X GET "$MANIPULA_CONTAINER/json" -H "X-Api-Key: $API_KEY" | jq -r '.[] | select(.Names[] | contains("'$CONTAINER_NAME'")) | .Id')


# Obtenha o SHA da imagem com base na tag
IMAGE_SHA=$(curl -s -X GET "$getsha" -H "X-API-Key: $API_KEY" | jq -r --arg tags "$tags" '.[] | select(.RepoTags[] | contains($tags)) | .Id')

# Exibe o SHA da imagem
echo $IMAGE_SHA

# Verifica se a stack está criada
if echo "$response" | jq -e '.[] | select(.Name == "'"$STACK_NAME"'")' > /dev/null; then

  # Extrai o valor do campo "Name" usando jq
  name=$(echo "$response" | jq -r '.[] | select(.Name == "'"$STACK_NAME"'") | .Name')

  # Imprime o nome da stack
  echo "A Stack chamada $name está criada. Nome: $name"

  # Obtém o ID da stack
  id=$(echo "$response" | jq -r '.[] | select(.Name == "'"$STACK_NAME"'") | .Id')

  # Monta a URL para a exclusão
  DELETE_URL="$URL/$id"
  
  # verifica se o container existe. 
  if [ ! -z "$CONTAINER_ID" ]; then
    echo "pausando container"
    curl -X POST "$MANIPULA_CONTAINER/$CONTAINER_NAME/stop" -H "X-API-Key: $API_KEY"
    sleep 5

    echo "deletando container"
    curl -X DELETE "$MANIPULA_CONTAINER/$CONTAINER_NAME" -H "X-API-Key: $API_KEY"
    sleep 5

    # VALIDAR PROCESSO DE EXCLUSAO DA IMAGEM
    echo "deletando imagem"
    curl -s -X DELETE "$deleteimagem/$IMAGE_SHA" -H "X-API-Key: $API_KEY" --insecure
    sleep 5

    echo "deletando stack"
    curl -X DELETE "$DELETE_URL" \
    -H "X-API-Key: $API_KEY" \
    -F "type=2" \
    -F "method=file" \
    -F "file=@$FILE_PATH" \
    -F "endpointId=$ENDPOINT" \
    -F "Name=$STACK_NAME" --insecure
    echo "Stack deletada. ID: $id"

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
    echo "stack encontrada, mas container não encontrado"

    echo "deletando imagem"
    curl -s -X DELETE "$deleteimagem/$IMAGE_SHA" -H "X-API-Key: $API_KEY" --insecure
    sleep 5
    
    echo "================"
    echo "DELETANDO STACK"
    echo "================"
    curl -X DELETE "$DELETE_URL" \
    -H "X-API-Key: $API_KEY" \
    -F "type=2" \
    -F "method=file" \
    -F "file=@$FILE_PATH" \
    -F "endpointId=$ENDPOINT" \
    -F "Name=$STACK_NAME" --insecure
    echo "Stack deletada. ID: $id"

    echo "============================"
    echo "CRIANDO A STACK $name"
    echo "============================"
    response=$(curl -s -X POST "$URL" \
    -H "X-API-Key: $API_KEY" \
    -F "type=2" \
    -F "method=file" \
    -F "file=@$FILE_PATH" \
    -F "endpointId=$ENDPOINT" \
    -F "Name=$STACK_NAME" --insecure)
  fi

else
  echo "=========================================="
  echo "NENHUMA STACK DA APLICAÇÃO ENCONTRADA."

  echo "pausando container"
    curl -X POST "$MANIPULA_CONTAINER/$CONTAINER_NAME/stop" -H "X-API-Key: $API_KEY"
    sleep 5

  echo "deletando container"
  curl -X DELETE "$MANIPULA_CONTAINER/$CONTAINER_NAME" -H "X-API-Key: $API_KEY"
  sleep 5

  # VALIDAR PROCESSO DE EXCLUSAO DA IMAGEM
  echo "deletando imagem"
    curl -s -X DELETE "$deleteimagem/$IMAGE_SHA" -H "X-API-Key: $API_KEY" --insecure
    sleep 5

  echo "CRIANDO A NOVA STACK"
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
fi