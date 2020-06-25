ExUnit.start()

defmodule EmqCleanspeakPluginTest do
  use ExUnit.Case, async: true
  doctest EmqCleanspeakPlugin

  require HTTPoison

  HTTPoison.start()

  alias EmqCleanspeakPlugin.{Filter}

  test "test no filtered topic" do
    message = Filter.filter("knulla", "some_topic", %{enabled: true, filtered_topics: []})

    assert message == "knulla"
  end

  test "test with filtered topic" do
    message = Filter.filter("knulla", "some_topic", %{enabled: true, filtered_topics: ["some_topic"]})

    assert message == "******"
  end

  test "test not a swear word with filtered topic" do
    message = Filter.filter("potato", "some_topic", %{enabled: true, filtered_topics: ["some_topic"]})

    assert message == "potato"
  end

  test "test filter disabled" do
    message = Filter.filter("knulla", "some_topic", %{enabled: false, filtered_topics: ["some_topic"]})

    assert message == "knulla"
  end

  test "test filter utf-8 string" do
    message = Filter.filter("他妈的", "some_topic", %{enabled: true, filtered_topics: ["some_topic"]})

    assert message == "***"
  end
end
