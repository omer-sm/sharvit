defmodule SharvitTests.TestModules.WebTest do
  alias Sharvit.Js.Dom

  def title_el, do: Dom.get_element_by_id("title")
  def desc_el, do: Dom.get_element_by_id("desc")
  def btn_toggle_attr, do: Dom.get_element_by_id("btnToggleAttr")
  def btn_read_attr, do: Dom.get_element_by_id("btnReadAttr")
  def btn_set_attr, do: Dom.get_element_by_id("btnSetAttr")
  def btn_remove_desc, do: Dom.get_element_by_id("btnRemoveDesc")
  def log_el, do: Dom.get_element_by_id("log")

  def log(args) when is_list(args) do
    # append message to the tiny console
    msg = Enum.map_join(args, " ", &String.Chars.to_string/1)
    log_element = log_el()
    curr_log = String.Chars.to_string(Dom.get_attribute(log_element, "textContent"))

    Dom.set_attribute(log_element, "textContent", curr_log <> "\n" <> msg)
    Dom.set_attribute(log_element, "scrollTop", Dom.get_attribute(log_element, "scrollHeight"))

    IO.inspect(args, label: "logged")
  end

  def log(arg), do: log([arg])

  def add_event_listeners() do
    desc = desc_el()

    Dom.add_event_listener(
      btn_toggle_attr(),
      "click",
      fn _event ->
        # if desc has attribute `data-highlight`, remove it; otherwise set it
        if Dom.has_attribute?(desc, "data-highlight") == true do
          IO.puts("removing")
          Dom.set_attribute(desc, "data-highlight", :remove)
          Dom.set_attribute(desc, "style.background", "")

          log("Removed attribute: data-highlight")
        else
          Dom.set_attribute(desc, "data-highlight", "true")
          Dom.set_attribute(desc, "style.background", "#fff8c644")

          log("Set attribute: data-highlight=true")
        end

        log(["hasAttribute?", Dom.has_attribute?(desc, "data-highlight")])
      end
    )

    Dom.add_event_listener(btn_read_attr(), "click", fn _event ->
      #  show whether attribute exists and its value
      has_highlight = Dom.has_attribute?(desc, "data-highlight")

      highlight_val =
        if has_highlight === true, do: Dom.get_attribute(desc, "data-highlight"), else: nil

      log(["hasAttribute(data-highlight):", has_highlight, "value:", highlight_val])

      #  also show an example of reading an attribute from the title
      id = Dom.get_attribute(title_el(), "id")
      log(["title id is", id])
    end)

    Dom.add_event_listener(
      btn_set_attr(),
      "click",
      fn _event ->
        #  demonstrate setAttribute overwriting previous values
        current = Dom.get_attribute(desc, "data-author")

        # String.Chars.to_string/1 invoked to remove warning about binary construction
        next = if current !== nil, do: current <> ", +You", else: "You"
        Dom.set_attribute(desc, "data-author", next)

        log(["setAttribute data-author ->", next])
      end
    )

    Dom.add_event_listener(btn_remove_desc(), "click", fn _event ->
      # demonstrate element.remove() - removes the element from DOM
      if is_nil(desc) do
        log("desc el already gone")
      else
        Dom.remove_element(desc)
        log("desc element removed from DOM")

        # disable this button (accessed via ID) so user can't click twice
        Dom.set_attribute(btn_remove_desc(), "disabled", "true")
      end
    end)

    # small interactive nicety: clicking the title toggles a CSS attribute
    Dom.add_event_listener(title_el(), "click", fn _event ->
      # toggle an attribute on the card container
      card = Dom.get_element_by_id("card")

      if Dom.has_attribute?(card, "data-active") do
        Dom.set_attribute(card, "data-active", :remove)
        Dom.set_attribute(card, "style.borderColor", "#ddd")
        log("card data-active removed")
      else
        Dom.set_attribute(card, "data-active", true)
        Dom.set_attribute(card, "style.borderColor", "#7aa")
        log("card data-active set")
      end
    end)
  end

  def start() do
    add_event_listeners()

    log("Demo ready - try the buttons.")
    title = title_el()
    desc = desc_el()

    log([
      "Elements available:",
      %{"title" => title["id"], "desc" => if(!is_nil(desc), do: desc["id"], else: nil)}
    ])
  end
end
