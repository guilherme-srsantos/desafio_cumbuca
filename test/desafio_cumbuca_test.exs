defmodule KvsServerTest do
  use ExUnit.Case
  alias KvsServer

  setup do
    {:ok, _pid} = KvsServer.start_link()
    File.rm("./desafio_cli.dat")
    :ok
  end

  test "set and get a value" do
    assert KvsServer.set("foo", "bar") == {true, "bar"}
    assert KvsServer.get("foo") == "bar"
  end

  test "overwrite an existing key" do
    assert KvsServer.set("key", "value1") == {true, "value1"}
    assert KvsServer.set("key", "value2") == {true, "value2"}
    assert KvsServer.get("key") == "value2"
  end

  test "begin a transaction" do
    assert KvsServer.begin_transaction() == 1
  end

  test "rollback a transaction" do
    KvsServer.set("key", "value1")
    KvsServer.begin_transaction()
    KvsServer.set("key", "value2")
    assert KvsServer.get("key") == "value2"

    assert KvsServer.rollback_transaction() == 0
    assert KvsServer.get("key") == "value1"
  end

  test "commit a transaction" do
    KvsServer.set("key", "value1")
    KvsServer.begin_transaction()
    KvsServer.set("key", "value2")
    assert KvsServer.get("key") == "value2"

    assert KvsServer.commit_transaction() == 0
    assert KvsServer.get("key") == "value2"
  end

  test "nested transactions with rollback" do
    KvsServer.set("key", "value1")
    KvsServer.begin_transaction()
    KvsServer.set("key", "value2")
    KvsServer.begin_transaction()
    KvsServer.set("key", "value3")

    assert KvsServer.get("key") == "value3"

    assert KvsServer.rollback_transaction() == 1
    assert KvsServer.get("key") == "value2"

    assert KvsServer.rollback_transaction() == 0
    assert KvsServer.get("key") == "value1"
  end

  test "nested transactions with commit" do
    KvsServer.set("key", "value1")
    KvsServer.begin_transaction()
    KvsServer.set("key", "value2")
    KvsServer.begin_transaction()
    KvsServer.set("key", "value3")

    assert KvsServer.get("key") == "value3"

    assert KvsServer.commit_transaction() == 1
    assert KvsServer.get("key") == "value3"

    assert KvsServer.commit_transaction() == 0
    assert KvsServer.get("key") == "value3"
  end

  test "persist state to file" do
    KvsServer.set("foo", "bar")
    KvsServer.set("baz", "qux")
    :ok = GenServer.stop(KvsServer)
    {:ok, _pid} = KvsServer.start_link()

    assert KvsServer.get("foo") == "bar"
    assert KvsServer.get("baz") == "qux"
  end
end
