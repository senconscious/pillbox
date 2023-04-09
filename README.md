# Pillbox

## Description

Allows you to checkin your pill intakes in telegram by creating pill course and timetable for it

## MVP

- [x] User can create pill course
- [ ] User can update pill course
- [x] User can delete pill course
- [x] User can create timetable for course
- [ ] User can update timetable for course
- [x] User can delete timetable for course
- [x] User can checkin pill intakes
- [ ] User can view checked pill intakes
- [ ] User can view incomming pill intakes
- [ ] User notified about incomming pill intakes
- [ ] Support custom timezone

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

## Architecture

### Pillbox

- `Accounts` — domain with users logic
- `Bots` — domain with telegram bot command logic. Invokes API from `Courses` and `Accounts` domains
- `Courses` — domain with logic for courses/timetables/checkins
- `Jobs` — domain with all periodic jobs 

### PillboxWeb

-  `PillboxWeb.Bot` — bot request router. Invokes commands from `Pillbox.Bots` domain
