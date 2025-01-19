defmodule Handle.Domain.Rule do
  @moduledoc """
  Provides functionality for parsing and matching domain rules defined by the
  Public Suffix List and as described at
  https://github.com/publicsuffix/list/wiki/Format#format

  This module defines a struct representing a domain rule with its type, length, parts,
  and associated domain type (public, private, or test). It provides functions to parse
  string representations of rules and to match domain parts against these rules.

  ## Parsing Rules

  The `parse/2` function processes a string rule and a domain type to produce a rule struct or special values:
    - Returns `nil` for empty or comment lines.
    - Returns `:begin_private_domains` for the specific marker line.
    - Parses rules starting with `"!"` as exceptions.
    - Parses rules starting with `"*."` as wildcards.
    - All other rules are parsed as standard.

  ## Matching

  The `match?/2` function checks if a given list of domain parts starts with the parts of the rule,
  determining if the rule matches the domain.

  ## Examples

      iex> rule = Handle.Domain.Rule.parse("*.example.com", :public)
      iex> Handle.Domain.Rule.match?(rule, ["com", "example", "subdomain"])
      true

  """
  defstruct [:rule_type, :length, :parts, :domain_type]

  @type domain_type :: :public | :private | :test
  @type t :: %__MODULE__{
          rule_type: :standard | :wildcard | :exception,
          length: integer | nil,
          parts: [String.t()] | nil,
          domain_type: domain_type()
        }

  @spec parse(binary(), domain_type()) :: :begin_private_domains | nil | t()
  def parse("", _domain_type), do: nil
  def parse("// ===BEGIN PRIVATE DOMAINS===", _domain_type), do: :begin_private_domains
  def parse("//" <> _, _domain_type), do: nil

  def parse("!" <> rule, domain_type) do
    parts =
      rule
      |> String.split(".")
      |> Enum.reverse()

    %__MODULE__{
      rule_type: :exception,
      length: length(parts),
      parts: parts,
      domain_type: domain_type
    }
  end

  def parse("*." <> rule, domain_type) do
    parts =
      rule
      |> String.split(".")
      |> Enum.reverse()

    %__MODULE__{
      rule_type: :wildcard,
      length: length(parts) + 1,
      parts: parts,
      domain_type: domain_type
    }
  end

  def parse(rule, domain_type) do
    parts =
      rule
      |> String.split(".")
      |> Enum.reverse()

    %__MODULE__{
      rule_type: :standard,
      length: length(parts),
      parts: parts,
      domain_type: domain_type
    }
  end

  @spec match?(t(), [String.t()]) :: boolean()
  def match?(%__MODULE__{rule_type: _, parts: parts}, domain_parts),
    do: List.starts_with?(domain_parts, parts)
end
