defmodule Pillbox.Bots.Structs.Message do
  @moduledoc """
    Wraps message params from telegram API

    ## Fields

    - `chat_id` — integer, same as in API
    - `message_id` — integer, same as in API
    - `message_text` - string, same as in API
    - `telegram_id` — integer, same as in API
    - `token` — string, token of your bot
  """

  @enforce_keys [:chat_id, :message_id, :message_text, :telegram_id, :token]
  @type t :: %__MODULE__{
          chat_id: integer(),
          message_id: integer(),
          message_text: String.t(),
          telegram_id: integer(),
          token: String.t()
        }

  defstruct [:chat_id, :message_id, :message_text, :telegram_id, :token]
end
