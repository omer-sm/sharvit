class erlang {
  static abs = Math.abs;

  static append_element(list, element) {
    return list.concat([element]);
  }

  static atom_to_binary(atom) {
    return atom.description;
  }

  static atom_to_list(atom) {
    return [...atom.description].map((char) => char.codePointAt(0));
  }

  static binary_part(subject, [start, length]) {
    return this.binary_part(subject, start, length);
  }

  static binary_part(subject, start, length) {
    return subject.slice(
      start,
      start >= 0 ? start + length : subject.length + start + length
    );
  }

  static binary_to_atom = Symbol.for;

  static binary_to_existing_atom = Symbol.for;

  static binary_to_float = parseFloat;

  static binary_to_integer = parseInt;

  static binary_to_list(binary) {
    return [...binary].map((char) => char.codePointAt(0));
  }

  static binary_to_list(binary, start, stop) {
    return this.binary_to_list(binary.slice(start + 1, stop + 1));
  }

  // TODO: implement
  // static binary_to_term(binary, _opts = []) {
  //   return binary;
  // }

  static bit_size(bitstring) {
    return this.byte_size(bitstring) * 8;
  }

  static bitstring_to_list(bitstring) {
    return this.binary_to_list(bitstring);
  }

  static byte_size(bitstring) {
    const encoder = new TextEncoder();
    return encoder.encode(bitstring).length;
  }

  static ceil = Math.ceil;

  // TODO: implement(?)
  // static decode_packet() {
  // }

  static delete_element(index, tuple) {
    return tuple.toSpliced(index, 1);
  }

  static display = console.log;

  static element(n, tuple) {
    return tuple[n - 1];
  }

  static error(args) {
    throw new Error(`erlang.error called with: ${JSON.stringify(args)}`);
  }

  // TODO: implement
  // static external_size(term) {
  //   return 0;
  // }

  static float(number) {
    return number;
  }

  // TODO: implement options
  static float_to_binary(number) {
    return number.toString();
  }

  static float_to_list = this.float_to_binary;

  static floor = Math.floor;

  // TODO: implement
  // static fun_info(fun) {
  //   return fun;
  // }

  // TODO: implement
  // static fun_to_list(fun) {
  //   return fun;
  // }

  static hd(list) {
    return list[0];
  }

  static insert_element(index, tuple, term) {
    return tuple.toSpliced(index, 0, term);
  }

  static integer_to_binary(integer, base = 10) {
    return integer.toString(base);
  }

  static integer_to_list(integer, base = 10) {
    return this.integer_to_binary(integer, base);
  }

  static iolist_size(item) {
    return item.length;
  }

  static iolist_to_binary(ioListOrBinary) {
    return ioListOrBinary;
  }

  // TODO: implement(?)
  // static iolist_to_iovec(ioListOrBinary) {
  //   return ioListOrBinary;
  // }

  static is_atom(term) {
    return typeof term === 'symbol' || typeof term === 'boolean' || term === null;
  }

  static is_binary(term) {
    return typeof term === 'string';
  }

  static is_bitstring(term) {
    return this.is_binary(term);
  }

  static is_boolean(term) {
    return typeof term === 'boolean';
  }

  static is_float(term) {
    return typeof term === 'number';
  }

  static is_function(term) {
    return typeof term === 'function';
  }

  // TODO: implement arity?
  static is_function(term, arity) {
    return this.is_function(term);
  }

  static is_integer = Number.isInteger;

  static is_list = Array.isArray;

  static is_map(term) {
    return typeof term === 'object' && term instanceof Object;
  }

  static is_map_key(key, map) {
    if (!is_map(map)) {
      throw new Error(`Bad map: ${map}`);
    }

    return map.hasOwnProperty(key);
  }

  static is_number(term) {
    return typeof term === 'number';
  }

  // TODO: implement
  // static is_pid(term) {
  //   return false;
  // }

  // TODO: implement
  // static is_port(term) {
  //   return false;
  // }

  static is_record(term, recordTag) {
    return this.is_tuple(term) && this.is_atom(term[0]) && term[0] === recordTag;
  }

  static is_record(term, recordTag, size) {
    return this.is_record(term, recordTag) && term.length === size;
  }

  // TODO: implement
  // static is_reference(term) {
  //   return false;
  // }

  static is_tuple(term) {
    return this.is_list(term);
  }

  static length(term) {
    return term.length;
  }

  // TODO: make it able to parse charlists
  static list_to_atom(string) {
    return Symbol.for(string);
  }

  static list_to_binary(ioList) {
    return [...ioList].map((char) => char.codePointAt(0));
  }

  static list_to_bitstring(ioList) {
    return this.list_to_binary(ioList);
  }

  // TODO: implement error?
  static list_to_existing_atom(string) {
    return this.list_to_atom(string);
  }

  static list_to_float(string) {
    return parseFloat(string);
  }

  static list_to_integer(string, base = 10) {
    return parseInt(string, base);
  }

  // TODO: implement
  // static list_to_pid(string) {
  //   return string;
  // }

  // TODO: implement
  // static list_to_port(string) {
  //   return string;
  // }

  // TODO: implement
  // static list_to_ref(string) {
  //   return string;
  // }

  static list_to_tuple(list) {
    return list;
  }

  // TODO: implement
  // static make_ref() {
  // }

  static make_tuple(arity, initialValue) {
    return Array(arity)
      .fill(null)
      .map(() => initialValue);
  }

  static make_tuple(arity, defaultValue, initList) {
    const tuple = this.make_tuple(arity, defaultValue);
    initList.forEach(([index, element]) => (tuple[index] = element));

    return tuple;
  }

  static map_get(key, map) {
    if (!this.is_map_key(key, map)) {
      throw new Error(`Bad key: ${key} (${map})`);
    }

    return map[key];
  }

  static map_size(map) {
    return Object.keys(map).length;
  }

  // TODO: implement?
  // static match_spec_test(matchAgainst, matchSpec, type) {}

  static max = Math.max;

  static min = Math.min;

  // TODO: implement
  // static node(arg) {}

  // TODO: implement
  // static phash2(term, range) {}

  // TODO: implement
  // static pid_to_list(pid)

  // TODO: implement
  // static port_to_list(pid)

  // TODO: implement
  // static ref_to_list(pid)

  static round = Math.round;

  static setelement(index, tuple, value) {
    return tuple.toSpliced(index - 1, 1, value);
  }

  static size(item) {
    return item.length;
  }

  static split_binary(bin, pos) {
    return [bin.slice(0, pos), bin.slice(pos)];
  }

  // TODO: implement
  // static term_to_binary(term, options)

  // TODO: implement
  // static term_to_iovec(term, options)

  static tl(list) {
    if (list.length === 0) {
      throw new Error(`Bad arg: ${list} (in tl/1)`);
    }

    return list.slice(1);
  }

  static trunc = Math.trunc;

  static tuple_size(tuple) {
    return tuple.length;
  }

  static tuple_to_list(tuple) {
    return tuple;
  }

  // TODO: implement
  // static unique_integer(modifierList) {}
}
