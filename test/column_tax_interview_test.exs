defmodule ColumnTaxInterviewTest do
  use ExUnit.Case
  doctest ColumnTaxInterview

  test "greets the world" do
    assert ColumnTaxInterview.search("aaa", :email_body) == []
  end
end
