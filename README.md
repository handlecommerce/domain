# Handle.Domain

**Handle.Domain** is an Elixir library for parsing hostnames and extracting
their domain components—such as domain, subdomain, TLD, and type—based on
public and test suffix rules. It leverages the Public Suffix List to accurately
identify domain parts for various domain types.

The Public Suffix List is automatically updated daily to ensure that the
library's parsing rules are up-to-date. This allows for accurate domain
parsing and classification, even for new TLDs and domain types.

## Features

- Parse hostnames to determine domain, subdomain, and TLD.
- Distinguish between public, private, and test domains.
- Use the Public Suffix List for up-to-date rule parsing.
- Handle wildcard and exception rules effectively.

## Installation

Add `handle_domain` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:handle_domain, "~> 0.1.0"}
  ]
end
```

## Usage

To parse a hostname and obtain its components:

```elixir
case Handle.Domain.parse("sub.example.co.uk") do
  {:ok, domain_info} ->
    # domain_info is a %Handle.Domain.Components{} struct containing:
    # - domain: "example"
    # - subdomain: "sub"
    # - tld: "co.uk"
    # - type: :public

    IO.inspect(domain_info)

  {:error, reason} ->
    IO.puts("Error: #{reason}")
end
```

## Contributing

Contributions are welcome! Please open issues or submit pull requests for
improvements or bug fixes.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file
for details.