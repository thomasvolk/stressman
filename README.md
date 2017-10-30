# StressMan

simple use:

    stressman --duration <DURATION> <URL>

### Distributed

start the port mapper daemon first:

    epmd -daemon

client:

    stressman --cookie <COOKIE> --name <CLIENT_NAME_A@HOST> \
    --nodes <SERVER_NAME_A@HOST>,<SERVER_NAME_B@HOST>,... \
    --duration <DURATION> <URL>

server:

    stressman --cookie <COOKIE> --name <SERVER_NAME_A@HOST>

## Build

build stressman with mix:

    mix escript.build

## Installation

The package can be installed by adding `stressman` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:stressman, git: "https://github.com/thomasvolk/stressman.git", tag: "0.2.0"}
  ]
end
```
