# StressMan

simple use:

    stressman --requests <REQUESTS> <URL>

### Distributed

start the port mapper daemon first:

    epmd -daemon

client:

    stressman --manager --cookie <COOKIE> --name <CLIENT_NAME_A@HOST> --nodes <SERVER_NAME_A@HOST>,<SERVER_NAME_B@HOST>,... --requests <REQUESTS> <URL>

server:

    stressman --server --cookie <COOKIE> --name <SERVER_NAME_A@HOST>

## Build

build stressman with mix:

    mix escript.build

## Installation

The package can be installed by adding `stressman` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:stressman, git: "https://github.com/thomasvolk/stressman.git", tag: "0.1.0"}
  ]
end
```
