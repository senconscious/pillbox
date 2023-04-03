# Pillbox

## Description

Allows you to track your pill intakes in telegram

## MVP

- [x] User can create pill course
- [ ] User can update pill course
- [ ] User can delete pill course
- [x] User can create timetable for course
- [ ] User can update timetable for course
- [x] User can delete timetable for course
- [ ] User can checkin pill intakes
- [ ] User can view incomming pill intakes
- [ ] User notified about incomming pill intakes

## MVP database structure

You can view database architecture [here](https://dbdiagram.io/d/641eca425758ac5f17240c0d)

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
