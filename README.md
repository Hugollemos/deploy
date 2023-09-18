# deploy


```
-
        name: Deploy
        uses: Hugollemos/deploy@v1
        env:
          API_URL: ${{ secrets.API_URL }}
          API_KEY: ${{ secrets.API_KEY }}
          FILE_PATH: "./docker-compose.yml"
          STACK_NAME: ola
          ENDPOINT: 2
          CONTAINER_NAME: as
          tags: nomedocontainer com tag
          api_docker: ${{ secrets.api_docker }} // http://1.2.4.0:90/api/endpoints/2/docker 
```