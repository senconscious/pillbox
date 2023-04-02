defmodule Pillbox.Accounts do
  @moduledoc """
    Accounts API
  """

  alias Pillbox.Accounts.UserQueries
  alias Pillbox.Accounts.UserCommands

  def get_or_create_user(telegram_id) do
    with nil <- UserQueries.get_user_by(telegram_id: telegram_id) do
      UserCommands.insert_user!(%{telegram_id: telegram_id})
    end
  end
end
