[![Coverage Status](https://coveralls.io/repos/github/qgadrian/graphito/badge.svg?branch=master)](https://coveralls.io/github/qgadrian/graphito?branch=master)
[![Hex version](https://img.shields.io/hexpm/v/sippet.svg "Hex version")](https://hex.pm/packages/graphito)
[![Hex Docs](https://img.shields.io/badge/hex-docs-9768d1.svg)](https://hexdocs.pm/graphito)
[![Build Status](https://travis-ci.org/qgadrian/graphito.svg?branch=master)](https://travis-ci.org/qgadrian/graphito.svg?branch=master)
[![Deps Status](https://beta.hexfaktor.org/badge/all/github/qgadrian/graphito.svg)](https://beta.hexfaktor.org/github/qgadrian/graphito)

# Graphito

[GraphQL](https://graphql.org/) client for Elixir.

## Table of Contents

- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)

## Installation

Add to dependencies in your `mix.exs` file...

```elixir
def deps do
  [{:graphito, "~> 0.1.1"}]
end
```

...and run:

```bash
mix deps.get
```

## Configuration

You will have to configure a url for the GraphQL server.

```elixir
config :graphito,
  url: "a_graphql_host"
```

Additionally, headers can be configured and they will be sent in all requests.

```elixir
config :graphito,
  headers: [{"this_header", "is_always_to_be_send"}]
```

## Usage

Run any GraphQL operation (a query or mutation):

```elixir
iex> Graphito.run("""
  query {
    jedis {
      name
    }
  }
  """)

%Graphito.Response{data: %{"jedis" => [%{"name" => "luke"}]}, status: 200, errors: nil, headers: [{"content-type", "application/json"}]}
```

If an operation fails the errors are parsed and returned:

```elixir
iex> Graphito.run("""
  query {
    jedis {
      lightzaber
    }
  }
  """)

%Graphito.Response{data: nil, status: 200, errors: [%{"message" => "Cannot query field \"lightzaber\" on type \"Jedi\". Did you mean \"lightsaber\"?"}], headers: [{"content-type", "application/json"}]}

iex> Graphito.run("""
  query {
    jedis {
      lightsaber
    }
  }
  """)

%Graphito.Response{data: nil, status: 200, errors: [%{"message" => "Third party server timeout", "code" => 503}], headers: [{"content-type", "application/json"}]}
```

If something fails an error is returned:

```elixir
iex> Graphito.run("""
  query {
    jedis {
      lightzaber
    }
  }
  """)

%Graphito.Response.Error{reason: :timeout, errors: [%{"message" => "Failed to fetch GraphQL response"}], headers: []}
```
