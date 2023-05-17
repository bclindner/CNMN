defmodule CNMN.Handler do
  @moduledoc """
  System that hooks into the CNMN.Consumer to handle events for particular functionalities.
  """
  defmacro __using__(_opts) do
    quote do
      @before_compile CNMN.Handler
      @behaviour CNMN.Handler
    end
  end

  @callback handle_event({atom(), term}) :: any
  @callback handle_event({atom(), term, term}) :: any

  defmacro __before_compile__(_opts) do
    quote do
      def handle_event({name, evt, _ws_state}) do
        handle_event(name, evt)
      end
      def handle_event(_name, _evt) do
        :noop
      end
    end
  end
end
