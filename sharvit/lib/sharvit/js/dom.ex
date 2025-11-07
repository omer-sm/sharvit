defmodule Sharvit.Js.Dom do
  @moduledoc """
  Functions for DOM manipulation. The elixir functions have no real functionality
  when ran, only when transpiled.
  """

  def create_element(tag_name) do
    %{tag: tag_name}
  end

  def create_text_node(text) do
    %{text: text}
  end

  def append_child(_parent, _child) do
    :ok
  end

  @spec get_element_by_id(id :: String.t()) :: map() | nil
  def get_element_by_id(_id) do
    %{}
  end

  def get_children(_parent) do
    []
  end

  def remove_element(_element) do
    :ok
  end

  def replace_element(_target, _replacement) do
    :ok
  end

  def set_attribute(element, attribute, value) do
    %{element | attribute => value}
  end

  @spec get_attribute(element :: map(), attribute :: String.t()) :: String.t() | nil
  def get_attribute(_element, _attribute) do
    "attribute_value"
  end

  def has_attribute?(element, attribute) do
    attribute in element
  end

  def add_event_listener(_element, _event, _callback) do
    :ok
  end
end
