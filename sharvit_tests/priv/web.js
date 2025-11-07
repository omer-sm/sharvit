class Elixir_Access {
  static get(map, key) {
    return map[key];
  }
}

class Elixir_Enum {
  static all$Q$(enumerable) {
    return this.all$Q$(enumerable, (value) => !!value);
  }

  static all$Q$(enumerable, fun) {
    return enumerable.every(fun);
  }

  static any$Q$(enumerable) {
    return this.any$Q$(enumerable, (value) => !!value);
  }

  static any$Q$(enumerable, fun) {
    return enumerable.some(fun);
  }

  static at(enumerable, index, defaultValue = null) {
    if (index < 0) {
      index += enumerable.length;
    }

    return index >= 0 && enumerable.length > index ? enumerable[index] : defaultValue;
  }

  static chunk_by(enumerable, fun) {
    const chunks = {};

    enumerable.forEach((element) => {
      const funResult = fun(element);

      if (!chunks.hasOwnProperty(funResult)) {
        chunks[funResult] = [];
      }

      chunks[funResult].push(element);
    });

    return Object.values(chunks);
  }

  static chunk_every(enumerable, count) {
    return this.chunk_every(enumerable, count, count);
  }

  static chunk_every(enumerable, count, step, leftover = []) {
    const chunks = [];

    for (let index = 0; index < enumerable.length; index += step) {
      chunks.push(enumerable.slice(index, index + count));
    }

    if (chunks[chunks.length - 1].length !== count) {
      if (leftover === Symbol.for('discard')) {
        chunks.pop();
      } else {
        chunks[chunks.length - 1].push(
          ...leftover.slice(0, count - chunks[chunks.length - 1].length)
        );
      }
    }

    return chunks;
  }

  static concat(enumerables) {
    return enumerables.length === 0 ? [] : enumerables[0].concat(enumerables.slice(1));
  }

  static concat(left, right) {
    return left.concat(right);
  }

  static count(enumerable, fun) {
    return enumerable.reduce((acc, element) => (fun(element) ? acc + 1 : acc), 0);
  }

  static count_until(enumerable, limit) {
    return Math.min(enumerable.length, limit);
  }

  static count_until(enumerable, fun, limit) {
    let count = 0;

    for (const element of enumerable) {
      if (count >= limit) {
        return limit;
      }

      if (fun(element)) {
        count++;
      }
    }

    return count;
  }

  static dedup(enumerable) {
    const deduped = [];
    let previous;

    for (const element of enumerable) {
      if (element !== previous) {
        deduped.push(element);
      }
    }

    return deduped;
  }

  static dedup_by(enumerable, fun) {
    const deduped = [];
    let previous;

    for (const element of enumerable) {
      const funResult = fun(element);

      if (funResult !== previous) {
        deduped.push(element);
      }
    }

    return deduped;
  }

  // TODO: transpile more

  static map_join(enumerable, joiner = '', mapper) {
    return enumerable.reduce((acc, element) => acc.concat(joiner, mapper(element)), '');
  }
}


class Elixir_IO {
  static inspect(item, opts = []) {
    const optsObject = Object.fromEntries(opts);

    if (optsObject.hasOwnProperty(Symbol.for('label'))) {
      console.log(`${optsObject[Symbol.for('label')]}: `);
    }

    console.dir(item);

    return item;
  }

  static puts(item) {
    console.log(item);

    return Symbol.for('ok');
  }

  static warn(message) {
    console.warn(message);

    return Symbol.for('ok');
  }
}


class Elixir_Map {
  static delete(map, key) {
    return ({ [key]: _, ...rest } = map), rest;
  }

  static drop(map, keys) {
    const mapCopy = { ...map };

    keys.forEach((key) => delete mapCopy[key]);

    return mapCopy;
  }

  static equal$Q$(map1, map2) {
    return compareMaps(map1, map2) === 0;
  }

  static fetch(map, key) {
    if (map.hasOwnProperty(key)) {
      return [Symbol.for('ok'), map[key]];
    }

    return Symbol.for('error');
  }

  static fetch$B$(map, key) {
    if (map.hasOwnProperty(key)) {
      return map[key];
    }

    throw new Error(`Key not found in map: ${key}, ${map}`);
  }

  static filter(map, fun) {
    const result = {};

    for (const key in map) {
      if (map.hasOwnProperty(key) && fun([key, map[key]])) {
        result[key] = map[key];
      }
    }

    return result;
  }

  static from_keys(keys, value) {
    const stringifedValue = JSON.stringify(value);

    return Object.fromEntries(keys.map((key) => [key, JSON.parse(stringifedValue)]));
  }

  static from_struct(struct) {
    return this.drop(struct, Symbol.for('__struct__'));
  }

  static get(map, key, defaultValue = null) {
    return map.hasOwnProperty(key) ? map[key] : defaultValue;
  }

  static get_and_update(map, key, fun) {
    const [currentValue, newValue] = fun(this.fetch$B$(map, key));

    return [
      currentValue,
      newValue === Symbol.for('pop')
        ? this.delete(map, key)
        : this.put(map, key, newValue),
    ];
  }

  static get_and_update$B$(map, key, fun) {
    const [currentValue, newValue] = fun(this.get(map, key));

    return [
      currentValue,
      newValue === Symbol.for('pop')
        ? this.delete(map, key)
        : this.put(map, key, newValue),
    ];
  }

  static get_lazy(map, key, fun) {
    return map.hasOwnProperty(key) ? key : fun();
  }

  static has_key$Q$(map, key) {
    return map.hasOwnProperty(key);
  }

  static intersect(map1, map2) {
    return this.filter(map1, ([key]) => map2.hasOwnProperty(key));
  }

  static intersect(map1, map2, fun) {
    const result = {};

    for (const key in map1) {
      if (map1.hasOwnProperty(key) && map2.hasOwnProperty(key)) {
        result[key] = fun(key, map1[key], map2[key]);
      }
    }

    return result;
  }

  static keys = Object.keys;

  static merge(map1, map2) {
    return { ...map1, ...map2 };
  }

  static merge(map1, map2, fun) {
    return { ...map1, ...map2, ...this.intersect(map1, map2, fun) };
  }

  static new() {
    return {};
  }

  static new(enumerable) {
    return Object.fromEntries(enumerable);
  }

  static new(enumerable, transform) {
    return Object.fromEntries(enumerable.map(transform));
  }

  static pop(map, key, defaultValue = null) {
    return map.hasOwnProperty(key)
      ? [map[key], this.delete(map, key)]
      : [defaultValue, { ...map }];
  }

  static pop$B$(map, key) {
    return [this.fetch$B$(map, key), this.delete(map, key)];
  }

  static pop_lazy(map, key, fun) {
    return map.hasOwnProperty(key)
      ? [map[key], this.delete(map, key)]
      : [fun(), { ...map }];
  }

  static put(map, key, value) {
    return { ...map, [key]: value };
  }

  static put_new(map, key, value) {
    return map.hasOwnProperty(key) ? { ...map } : { ...map, [key]: value };
  }

  static put_new_lazy(map, key, fun) {
    return map.hasOwnProperty(key) ? { ...map } : { ...map, [key]: fun() };
  }

  static reject(map, fun) {
    const result = {};

    for (const key in map) {
      if (map.hasOwnProperty(key) && !fun([key, map[key]])) {
        result[key] = map[key];
      }
    }

    return result;
  }

  static replace(map, key, value) {
    return map.hasOwnProperty(key) ? { ...map, [key]: value } : { ...map };
  }

  static replace$B$(map, key, value) {
    this.fetch$B$(map, key);

    return { ...map, [key]: value };
  }

  static replace_lazy(map, key, fun) {
    return map.hasOwnProperty(key) ? { ...map, [key]: fun() } : { ...map };
  }

  static split(map, keys) {
    const existingKeys = keys.reduce(
      (acc, key) => (map.hasOwnProperty(key) ? ((acc[key] = map[key]), acc) : acc),
      {}
    );

    return [
      existingKeys,
      this.reject(map, ([key, _val]) => existingKeys.hasOwnProperty(key)),
    ];
  }

  static split_with(map, fun) {
    const truthy = {};
    const falsy = {};

    for (const key in map) {
      if (map.hasOwnProperty(key)) {
        if (fun([key, map[key]])) {
          truthy[key] = map[key];
        } else {
          falsy[key] = map[key];
        }
      }
    }

    return [truthy, falsy];
  }

  static take(map, keys) {
    return keys.reduce((acc, key) =>
      map.hasOwnProperty(key) ? ((acc[key] = map[key]), acc) : acc
    );
  }

  static to_list = Object.entries;

  static update(map, key, defaultValue, fun) {
    return { ...map, [key]: map.hasOwnProperty(key) ? fun(map[key]) : defaultValue };
  }

  static update(map, key, fun) {
    return { ...map, [key]: fun(this.fetch$B$(map, key)) };
  }

  static values = Object.values;
}


class Elixir_String_Chars {
  static to_string(term) {
    return typeof term === 'object' ? JSON.stringify(term) : term.toString();
  }
}


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


// === Pattern Matching ===

const sharvitPatterns = {
  any: Symbol('__any__'),
  any_or_missing: Symbol('__any_or_missing__'),
  cons_tail: Symbol('__cons_tail__'),
};

// TODO: implement any or missing?
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
    if (
      (typeof left === 'object' && left !== null) ||
      (typeof right === 'object' && right !== null)
    ) {
      throw new Error(
        `Comparison between different types is forbidden. (got ${left}, ${right})`
      );
    } else {
      return compare(!!left, !!right);
    }
  }

  if (right === null || left === null) {
    return compare(!!left, !!right);
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


class Elixir_SharvitTests_TestModules_WebTest {
    static start(...args) {
        if (doesMatchPattern([], args)) {
            this.add_event_listeners();

            this.log('Demo ready - try the buttons.');

            const title$V0 = this.title_el();

            title$V0;

            const desc$V1 = this.desc_el();

            desc$V1;

            return this.log(['Elements available:', {
                ['title']: Elixir_Access.get(title$V0, 'id'),
                ['desc']: ((...args) => {
                    if (((...args) => {
                        if (compare(desc$V1, null) === 0) {
                            return false;
                        } else {
                            return true;
                        }
                    })()) {
                        return Elixir_Access.get(desc$V1, 'id');
                    } else {
                        return null;
                    }
                })()
            }]);
        }

        throw new Error('No function clause matching in start(' + (args + ')'));
    };
    static log(...args) {
        if (doesMatchPattern([sharvitPatterns.any], args) && ((args$V0) => erlang.is_list(args$V0))(...args)) {
            let [args$V0] = args;

            const msg$V1 = Elixir_Enum.map_join(args$V0, ' ', (...args) => {
                if (doesMatchPattern([sharvitPatterns.any], args)) {
                    let [$1] = args;

                    return Elixir_String_Chars.to_string($1);
                }

                throw new Error('No function clause matching in anonymous_function(' + (args + ')'));
            });

            msg$V1;

            const log_element$V2 = this.log_el();

            log_element$V2;

            const curr_log$V3 = Elixir_String_Chars.to_string(Elixir_Sharvit_Js_Dom.get_attribute(log_element$V2, 'textContent'));

            curr_log$V3;

            Elixir_Sharvit_Js_Dom.set_attribute(log_element$V2, 'textContent', curr_log$V3.concat('\n', msg$V1));

            Elixir_Sharvit_Js_Dom.set_attribute(log_element$V2, 'scrollTop', Elixir_Sharvit_Js_Dom.get_attribute(log_element$V2, 'scrollHeight'));

            return Elixir_IO.inspect(args$V0, [[Symbol.for('label'), 'logged']]);
        }

        if (doesMatchPattern([sharvitPatterns.any], args)) {
            let [arg$V0] = args;

            return this.log([arg$V0]);
        }

        throw new Error('No function clause matching in log(' + (args + ')'));
    };
    static title_el(...args) {
        if (doesMatchPattern([], args)) {
            return Elixir_Sharvit_Js_Dom.get_element_by_id('title');
        }

        throw new Error('No function clause matching in title_el(' + (args + ')'));
    };
    static desc_el(...args) {
        if (doesMatchPattern([], args)) {
            return Elixir_Sharvit_Js_Dom.get_element_by_id('desc');
        }

        throw new Error('No function clause matching in desc_el(' + (args + ')'));
    };
    static btn_toggle_attr(...args) {
        if (doesMatchPattern([], args)) {
            return Elixir_Sharvit_Js_Dom.get_element_by_id('btnToggleAttr');
        }

        throw new Error('No function clause matching in btn_toggle_attr(' + (args + ')'));
    };
    static btn_read_attr(...args) {
        if (doesMatchPattern([], args)) {
            return Elixir_Sharvit_Js_Dom.get_element_by_id('btnReadAttr');
        }

        throw new Error('No function clause matching in btn_read_attr(' + (args + ')'));
    };
    static btn_set_attr(...args) {
        if (doesMatchPattern([], args)) {
            return Elixir_Sharvit_Js_Dom.get_element_by_id('btnSetAttr');
        }

        throw new Error('No function clause matching in btn_set_attr(' + (args + ')'));
    };
    static btn_remove_desc(...args) {
        if (doesMatchPattern([], args)) {
            return Elixir_Sharvit_Js_Dom.get_element_by_id('btnRemoveDesc');
        }

        throw new Error('No function clause matching in btn_remove_desc(' + (args + ')'));
    };
    static log_el(...args) {
        if (doesMatchPattern([], args)) {
            return Elixir_Sharvit_Js_Dom.get_element_by_id('log');
        }

        throw new Error('No function clause matching in log_el(' + (args + ')'));
    };
    static add_event_listeners(...args) {
        if (doesMatchPattern([], args)) {
            const desc$V0 = this.desc_el();

            desc$V0;

            Elixir_Sharvit_Js_Dom.add_event_listener(this.btn_toggle_attr(), 'click', (...args) => {
                if (doesMatchPattern([sharvitPatterns.any], args)) {
                    ((...args) => {
                        if (compare(Elixir_Sharvit_Js_Dom.has_attribute$Q$(desc$V0, 'data-highlight'), true) === 0) {
                            Elixir_IO.puts('removing');

                            Elixir_Sharvit_Js_Dom.set_attribute(desc$V0, 'data-highlight', Symbol.for('remove'));

                            Elixir_Sharvit_Js_Dom.set_attribute(desc$V0, 'style.background', '');

                            return this.log('Removed attribute: data-highlight');
                        } else {
                            Elixir_Sharvit_Js_Dom.set_attribute(desc$V0, 'data-highlight', 'true');

                            Elixir_Sharvit_Js_Dom.set_attribute(desc$V0, 'style.background', '#fff8c644');

                            return this.log('Set attribute: data-highlight=true');
                        }
                    })();

                    return this.log(['hasAttribute?', Elixir_Sharvit_Js_Dom.has_attribute$Q$(desc$V0, 'data-highlight')]);
                }

                throw new Error('No function clause matching in anonymous_function(' + (args + ')'));
            });

            Elixir_Sharvit_Js_Dom.add_event_listener(this.btn_read_attr(), 'click', (...args) => {
                if (doesMatchPattern([sharvitPatterns.any], args)) {
                    const has_highlight$V3 = Elixir_Sharvit_Js_Dom.has_attribute$Q$(desc$V0, 'data-highlight');

                    has_highlight$V3;

                    const highlight_val$V4 = ((...args) => {
                        if (compare(has_highlight$V3, true) === 0) {
                            return Elixir_Sharvit_Js_Dom.get_attribute(desc$V0, 'data-highlight');
                        } else {
                            return null;
                        }
                    })();

                    highlight_val$V4;

                    this.log(['hasAttribute(data-highlight):', has_highlight$V3, 'value:', highlight_val$V4]);

                    const id$V5 = Elixir_Sharvit_Js_Dom.get_attribute(this.title_el(), 'id');

                    id$V5;

                    return this.log(['title id is', id$V5]);
                }

                throw new Error('No function clause matching in anonymous_function(' + (args + ')'));
            });

            Elixir_Sharvit_Js_Dom.add_event_listener(this.btn_set_attr(), 'click', (...args) => {
                if (doesMatchPattern([sharvitPatterns.any], args)) {
                    const current$V7 = Elixir_Sharvit_Js_Dom.get_attribute(desc$V0, 'data-author');

                    current$V7;

                    const next$V8 = ((...args) => {
                        if (compare(current$V7, null) !== 0) {
                            return current$V7.concat(', +You');
                        } else {
                            return 'You';
                        }
                    })();

                    next$V8;

                    Elixir_Sharvit_Js_Dom.set_attribute(desc$V0, 'data-author', next$V8);

                    return this.log(['setAttribute data-author ->', next$V8]);
                }

                throw new Error('No function clause matching in anonymous_function(' + (args + ')'));
            });

            Elixir_Sharvit_Js_Dom.add_event_listener(this.btn_remove_desc(), 'click', (...args) => {
                if (doesMatchPattern([sharvitPatterns.any], args)) {
                    return ((...args) => {
                        if (compare(desc$V0, null) === 0) {
                            return this.log('desc el already gone');
                        } else {
                            Elixir_Sharvit_Js_Dom.remove_element(desc$V0);

                            this.log('desc element removed from DOM');

                            return Elixir_Sharvit_Js_Dom.set_attribute(this.btn_remove_desc(), 'disabled', 'true');
                        }
                    })();
                }

                throw new Error('No function clause matching in anonymous_function(' + (args + ')'));
            });

            return Elixir_Sharvit_Js_Dom.add_event_listener(this.title_el(), 'click', (...args) => {
                if (doesMatchPattern([sharvitPatterns.any], args)) {
                    const card$V11 = Elixir_Sharvit_Js_Dom.get_element_by_id('card');

                    card$V11;

                    return ((...args) => {
                        if (doesMatchPattern([sharvitPatterns.any], args) && ((x$V12) => compare(x$V12, false) === 0 || compare(x$V12, null) === 0)(...args)) {
                            let [x$V12] = args;

                            Elixir_Sharvit_Js_Dom.set_attribute(card$V11, 'data-active', true);

                            Elixir_Sharvit_Js_Dom.set_attribute(card$V11, 'style.borderColor', '#7aa');

                            return this.log('card data-active set');
                        }

                        if (doesMatchPattern([sharvitPatterns.any], args)) {
                            Elixir_Sharvit_Js_Dom.set_attribute(card$V11, 'data-active', Symbol.for('remove'));

                            Elixir_Sharvit_Js_Dom.set_attribute(card$V11, 'style.borderColor', '#ddd');

                            return this.log('card data-active removed');
                        }
                    })(Elixir_Sharvit_Js_Dom.has_attribute$Q$(card$V11, 'data-active'));
                }

                throw new Error('No function clause matching in anonymous_function(' + (args + ')'));
            });
        }

        throw new Error('No function clause matching in add_event_listeners(' + (args + ')'));
    }
}