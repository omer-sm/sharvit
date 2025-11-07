class Elixir_Sharvit_Js_Dom {
  static create_element(tagName) {
    return document.createElement(tagName);
  }

  static create_text_node(text) {
    return document.createTextNode(text);
  }

  static append_child(parent, child) {
    return parent.appendChild(child);
  }

  static get_element_by_id(id) {
    return document.getElementById(id);
  }

  static get_children(parent) {
    return [...parent.children];
  }

  static remove_element(element) {
    element.remove();

    return Symbol.for('ok');
  }

  static replace_element(target, replacement) {
    target.replaceWith(replacement);

    return Symbol.for('ok');
  }

  static set_attribute(element, attribute, value) {
    if (value === Symbol.for('remove')) {
      element.removeAttribute(attribute);
    } else {
      element.setAttribute(attribute, value);
      const keys = attribute.split('.');
      const last = keys.pop();
      const target = keys.reduce((acc, key) => acc?.[key], element);

      if (target && last) {
        target[last] = value;
      }
    }

    return element;
  }

  static get_attribute(element, attribute) {
    return element.hasAttribute(attribute)
      ? element.getAttribute(attribute)
      : element[attribute];
  }

  static has_attribute$Q$(element, attribute) {
    return element.hasAttribute(attribute);
  }

  static add_event_listener(element, event, callback) {
    element.addEventListener(event, callback);

    return Symbol.for('ok');
  }
}
