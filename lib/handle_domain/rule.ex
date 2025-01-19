defmodule HandleDomain.Rule do
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
