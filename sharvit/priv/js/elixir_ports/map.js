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
