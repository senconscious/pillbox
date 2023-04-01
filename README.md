# Pillbox

## Description

Allows you to track your pill intakes

## Up and running

- Install corresponding erlang/elixir versions fron `.tool-versions` file in a root as well as postgresql
- Copy sample configuration file:

```sh
  cp .env.sample .env
```

- Set `BOT_TOKEN` in `.env` file
- Retreive deps: 

```sh
mix deps.get
```

- Start your app: 

```sh
source .env && iex -S mix
```
