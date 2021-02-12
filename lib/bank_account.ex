defmodule BankAccount do
  use GenServer

  @moduledoc """
  A bank account that supports access from multiple processes.
  """

  @typedoc """
  An account handle.
  """
  @opaque account :: pid

  @impl true
  def init(:ok) do
    {:ok, %{balance: 0, status: :account_open}}
  end

  def start_link do
    GenServer.start_link(__MODULE__, :ok)
  end

  @impl true
  # balance inquiry when status: :account_closed
  def handle_call(:balance, _from, %{status: :account_closed} = state) do
    {:reply, {:error, :account_closed}, state}
  end

  @impl true
  # balance inquiry
  def handle_call(:balance, _from, state) do
    {:reply, Map.get(state, :balance), state}
  end

  @impl true
  # close bank/update status
  def handle_call({:status, :account_closed}, _from, state) do
    {:reply, :ok, Map.put(state, :status, :account_closed)}
  end

  @impl true
  # balance update when status: account_closed
  def handle_call({:balance, _amount}, _from, %{status: :account_closed} = state) do
    {:reply, {:error, :account_closed}, state}
  end

  @impl true
  # balance update
  def handle_call({:balance, amount}, _from, state) do
    balance = Map.get(state, :balance)
    {:reply, :ok, Map.put(state, :balance, balance + amount)}
  end

  @doc """
  Open the bank. Makes the account available.
  """
  @spec open_bank() :: account
  # TODO: handle errors?
  # @spec open_bank() :: {:ok, account} | {:error, term()}
  def open_bank() do
    {:ok, account} = BankAccount.start_link()
    account
  end

  @doc """
  Close the bank. Makes the account unavailable.
  """
  # @spec close_bank(account) :: none
  def close_bank(account) do
    GenServer.call(account, {:status, :account_closed})
  end

  @doc """
  Get the account's balance.
  """
  @spec balance(account) :: integer
  def balance(account) do
    GenServer.call(account, :balance)
  end

  @doc """
  Update the account's balance by adding the given amount which may be negative.
  """
  @spec update(account, integer) :: any
  def update(account, amount) do
    GenServer.call(account, {:balance, amount})
  end
end
