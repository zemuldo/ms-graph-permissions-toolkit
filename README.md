# Graph API Permissions Toolset

- This repo cotains the code that scrapes permissions from the [Microsoft Graph Docs](https://github.com/microsoftgraph/microsoft-graph-docs).
- Written in Elixir using [earmark](https://hex.pm/packages/earmark) for markdown parsing and React with Postgres for search and view.

## How it works

Setup postgres anywhere and provide the following variables through your shell.

- PG_DB_HOST=localhost
- PG_DB_USER=postgres
- PG_DB_NAME=msg-graph-toolkit
- PG_DB_PORT=5432
- PG_DB_PASSWORD=postgres

Now proceede to setup as detailed below.

- Download docs

  ```shell
  curl <https://codeload.github.com/microsoftgraph/microsoft-graph-docs/zip/refs/heads/main> -L -o docs.zip
  ```

- Unzip the Download

  ```shell
  unzip -d docs/ docs.zip
  ```

- Install mix deps

  ```shell
  mix deps.get
  ```

- Install npm packages

  ```shell
  cd assets/
  npm i
  cd ..
  ```

- Run the application

  ```shell
  iex -S mix phx.server
  ```

- In the resulting shell, run one of the following

  ```shell
  Scrapper.get_endpoint("v1.0", "user-list.md") # Get for a doc in v1.0
  Scrapper.get_endpoint("beta", "user-list.md") # Get for a doc in beta
  Scrapper.run("v.10") |> Scrapper.run |> Scrapper.to_json # Dump to json file
  Scrapper.run("v.10") |> Scrapper.run |> Scrapper.to_db # Dump to postgres

## Deployment

- az login
- az acr login -n registry
- docker build . -t registry.azurecr.io/app
- docker push registry.azurecr.io/app

Azure App service will take care of things from here.
