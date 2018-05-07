# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :git_hooks,
  verbose: true,
  hooks: [
    pre_commit: [
      mix_tasks: [
        "format --check-formatted --dry-run",
        "credo"
      ]
    ],
    pre_push: [
      mix_tasks: [
        "dialyzer",
        "coveralls"
      ]
    ]
  ]

import_config "#{Mix.env()}.exs"
