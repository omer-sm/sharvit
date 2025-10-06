// === Pattern Matching ===

const sharvitPatterns = {
  any: Symbol('__any__'),
  any_or_missing: Symbol('__any_or_missing__'),
  cons_tail: Symbol('__cons_tail__'),
};

// TODO: implement any or missing
function doesMatchPattern(pattern, value) {
  if (
    pattern === sharvitPatterns.any ||
    value === sharvitPatterns.any ||
    pattern === sharvitPatterns.any_or_missing ||
    value === sharvitPatterns.any_or_missing
  ) {
    return true;
  }

  if (pattern === null && value === null) {
    return true;
  }

  if (
    typeof pattern === typeof value &&
    ['string', 'boolean', 'number', 'symbol'].includes(typeof pattern)
  ) {
    return pattern === value;
  }

  if (Array.isArray(value) && Array.isArray(pattern)) {
    if (pattern[pattern.length - 1] === sharvitPatterns.cons_tail) {
      return (
        value.length >= pattern.length - 1 &&
        pattern
          .slice(0, -1)
          .every((subPattern, index) => doesMatchPattern(subPattern, value[index]))
      );
    }

    return (
      pattern.length === value.length &&
      pattern.every((subPattern, index) => doesMatchPattern(subPattern, value[index]))
    );
  }

  if (
    typeof pattern === 'object' &&
    typeof value === 'object' &&
    pattern instanceof Object &&
    value instanceof Object
  ) {
    return Object.entries(pattern).every(
      ([key, subPattern]) =>
        value[key] !== undefined && doesMatchPattern(subPattern, value[key])
    );
  }

  return false;
}

function verifyPatternMatch(pattern, value) {
  if (pattern !== null && !doesMatchPattern(pattern, value)) {
    throw new Error(`No match for value ${value} in pattern ${pattern}`);
  }

  return value;
}

// === comparison ===

/*
 * Returns:
 * 0 if equal
 * negative if left < right
 * positive if left > right
 */
function compare(left, right) {
  if (typeof left !== typeof right) {
    throw new Error(
      `Comparison between different types is forbidden. (got ${left}, ${right})`
    );
  }

  switch (typeof left) {
    case 'number':
      return left - right;

    case 'symbol':
    case 'boolean':
      return left.toString().localeCompare(right);

    case 'string':
      return left.localeCompare(right);

    case 'function':
      return left.name.localeCompare(right.name);

    case 'object':
      if (Array.isArray(left) && Array.isArray(right)) {
        return compareLists(left, right);
      }

      if (typeof left === 'object' && left instanceof Object && right instanceof Object) {
        return compareMaps(left, right);
      }

      // For nulls and undefineds
      if (left === right) {
        return 0;
      }

      throw new Error(`Couln't compare values: ${left}, ${right}`);

    case 'undefined':
      return 0;

    default:
      throw new Error(`Comparison of values of type ${typeof left} is not implemented.`);
  }
}

function compareLists(left, right) {
  if (left.length !== right.length) {
    return left.length - right.length;
  }

  for (let index = 0; index < left.length; index++) {
    const diff = compare(left[index], right[index]);

    if (diff !== 0) {
      return diff;
    }
  }

  return 0;
}

function compareMaps(left, right) {
  const leftEntries = Object.entries(left);
  const rightEntriesCount = Object.keys(right).length;

  if (leftEntries.length !== rightEntriesCount) {
    return leftEntries.length - rightEntriesCount;
  }

  for (const [key, value] in leftEntries) {
    if (right.hasOwnProperty(key)) {
      const diff = compare(value, right[key]);

      if (diff !== 0) {
        return diff;
      }
    }
  }

  return 0;
}

// === Erlang ===

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
    return tuple.toSpliced(index, 1)
  }

  static display = console.log;

  static element(n, tuple) {
    return tuple[n - 1];
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
    return typeof term === 'symbol';
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
} 
