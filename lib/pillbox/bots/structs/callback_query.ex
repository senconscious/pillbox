defmodule Pillbox.Bots.Structs.CallbackQuery do
  @moduledoc """
    Wraps callback query params from telegram API

    ## Fields

    - `action` — string, representing parsed `action` from `callback_data`
    - `chat_id` — integer, same as in API
    - `message_id` — integer, same as in API
    - `callback_query_id` — integer, same as in API
    - `telegram_id` — integer, same as in API
    - `token` — string, token of your bot
  """

  @enforce_keys [:action, :chat_id, :message_id, :callback_query_id, :telegram_id, :token]
  @type t :: %__MODULE__{
          action: String.t(),
          chat_id: integer(),
          message_id: integer(),
          callback_query_id: integer(),
          telegram_id: integer(),
          token: integer()
        }

  defstruct [:action, :chat_id, :message_id, :callback_query_id, :telegram_id, :token]
end
