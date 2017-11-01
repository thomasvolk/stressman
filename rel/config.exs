Path.join(["rel", "plugins", "*.exs"])
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Mix.Releases.Config,
    # This sets the default release built by `mix release`
    default_release: :default,
    # This sets the default environment used by `mix release`
    default_environment: Mix.env()


environment :dev do
  set dev_mode: true
  set include_erts: false
  set cookie: :"tuo6cheiDuu4shaiFahyaeroo1soh4fae7uo1thoh5tae1aic1Aewo1Aphoh9hieDiuquu4wahJeanguichiephu0feeb2ohphae4ooYu0xo3Iegeej4fohx"
end

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: :"tuo6cheiDuu4shaiFahyaeroo1soh4fae7uo1thoh5tae1aic1Aewo1Aphoh9hieDiuquu4wahJeanguichiephu0feeb2ohphae4ooYu0xo3Iegeej4fohx"
end

release :stressman do
  set version: current_version(:stressman)
  set applications: [
    :runtime_tools
  ]
end
