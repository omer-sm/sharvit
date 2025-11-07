class Elixir_String_Chars {
  static to_string(term) {
    return typeof term === 'object' ? JSON.stringify(term) : term.toString();
  }
}
