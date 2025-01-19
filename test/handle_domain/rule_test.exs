defmodule HandleDomain.RuleTest do
  use ExUnit.Case
  alias HandleDomain.Rule

  describe "parse/1" do
    test "returns nil for lines starting with '//'" do
      assert Rule.parse("//some comment", :public) == nil
    end

    test "returns nil for empty string" do
      assert Rule.parse("", :public) == nil
    end

    test "recognizes begin private domains marker" do
      assert Rule.parse("// ===BEGIN PRIVATE DOMAINS===", :public) == :begin_private_domains
    end

    test "parses exception rule" do
      line = "!example.com"
      result = Rule.parse(line, :public)
      assert result.rule_type == :exception
      assert result.length == 2
      assert result.parts == ["com", "example"]
    end

    test "parses wildcard rule" do
      line = "*.example.com"
      result = Rule.parse(line, :public)
      assert result.rule_type == :wildcard
      assert result.length == 3
      assert result.parts == ["com", "example"]
    end

    test "parses standard rule" do
      line = "example.com"
      result = Rule.parse(line, :public)
      assert result.rule_type == :standard
      assert result.length == 2
      assert result.parts == ["com", "example"]
    end
  end

  describe "match/2" do
    test "returns true for wildcard rule" do
      rule = %Rule{rule_type: :wildcard, parts: ["com", "example"], length: 3}
      assert Rule.match?(rule, ["com", "example", "sub"])
      assert Rule.match?(rule, ["com", "example", "sub", "my"])
    end

    test "returns false for non-matching wildcard rule" do
      rule = %Rule{rule_type: :wildcard, parts: ["com", "example"], length: 3}
      refute Rule.match?(rule, ["org", "example", "sub"])
    end

    test "returns true for matching standard rule" do
      rule = %Rule{rule_type: :standard, parts: ["com", "example"], length: 2}
      assert Rule.match?(rule, ["com", "example"])
      assert Rule.match?(rule, ["com", "example", "sub"])
      refute Rule.match?(rule, ["org", "example", "sub"])
    end

    test "returns true for matching exception rule" do
      rule = %Rule{rule_type: :exception, parts: ["com", "example"], length: 2}
      assert Rule.match?(rule, ["com", "example"])
      assert Rule.match?(rule, ["com", "example", "sub"])
      refute Rule.match?(rule, ["org", "example", "sub"])
    end
  end
end
