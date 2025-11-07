class Elixir_Enum {
  static all$Q$(enumerable) {
    return this.all$Q$(enumerable, (value) => !!value);
  }

  static all$Q$(enumerable, fun) {
    return enumerable.every((element) => fun(element));
  }

  static any$Q$(enumerable) {
    return this.any$Q$(enumerable, (value) => !!value);
  }

  static any$Q$(enumerable, fun) {
    return enumerable.some((element) => fun(element));
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

  static drop(enumerable, amount) {
    return amount > 0
      ? enumerable.slice(amount)
      : enumerable.slice(0, enumerable.length + amount);
  }

  static drop_every(enumerable, nth) {
    return enumerable.filter((_element, index) => index % nth !== 0);
  }

  static drop_while(enumerable, fun) {
    const startIndex = enumerable.findIndex((element) => !fun(element));

    return startIndex === -1 ? [...enumerable] : enumerable.slice(startIndex);
  }

  static each(enumerable, fun) {
    enumerable.forEach((element) => fun(element));

    return Symbol.for('ok');
  }

  static empty$Q$(enumerable) {
    return enumerable.length === 0;
  }

  static fetch(enumerable, index) {
    if (index < 0) {
      index += enumerable.length;
    }

    return index >= 0 && index < enumerable.length
      ? [Symbol.for('ok'), enumerable[index]]
      : Symbol.for('error');
  }

  static fetch$B$(enumerable, index) {
    if (index < 0) {
      index += enumerable.length;
    }

    if (index < 0 || index >= enumerable.length) {
      throw new Error(`Out of bounds: ${index} not found in ${enumerable}`);
    }

    return enumerable[index];
  }

  static filter(enumerable, fun) {
    return enumerable.filter((element) => fun(element));
  }

  static find(enumerable, defaultValue = null, fun) {
    const result = enumerable.find((element) => fun(element));

    return result === undefined ? defaultValue : result;
  }

  static find_index(enumerable, fun) {
    const result = enumerable.findIndex((element) => fun(element));

    return result === -1 ? null : result;
  }

  static find_value(enumerable, defaultValue = null, fun) {
    for (let index = 0; index < enumerable.length; index++) {
      const funResult = fun(enumerable[index]);

      if (!!funResult) {
        return funResult;
      }
    }

    return defaultValue;
  }

  static flat_map(enumerable, fun) {
    return enumerable.flatMap((element) => fun(element));
  }

  static flat_map_reduce(enumerable, acc, fun) {
    const mappedEnumerable = [];

    for (let index = 0; index < enumerable.length; index++) {
      const funResult = fun(enumerable[index], acc);

      if (funResult[0] === Symbol.for('halt')) {
        return [mappedEnumerable, funResult[1]];
      }

      mappedEnumerable.push(...funResult[0]);
      acc = funResult[1];
    }

    return [mappedEnumerable, acc];
  }

  static frequencies(enumerable) {
    const freqs = {};

    enumerable.forEach((element) => {
      if (freqs.hasOwnProperty(element)) {
        freqs[element]++;
      } else {
        freqs[element] = 1;
      }
    });

    return freqs;
  }

  static frequencies_by(enumerable, keyFun) {
    const freqs = {};

    enumerable.forEach((unmappedElement) => {
      const element = keyFun(unmappedElement);

      if (freqs.hasOwnProperty(element)) {
        freqs[element]++;
      } else {
        freqs[element] = 1;
      }
    });

    return freqs;
  }

  static group_by(enumerable, keyFun, valueFun = (x) => x) {
    const groups = {};

    enumerable.forEach((unmappedElement) => {
      const element = keyFun(unmappedElement);

      if (groups.hasOwnProperty(element)) {
        groups[element].push(valueFun(unmappedElement));
      } else {
        groups[element] = [valueFun(unmappedElement)];
      }
    });

    return groups;
  }

  static intersperse(enumerable, separator) {
    return enumerable.flatMap((element, index) =>
      index === enumerable.length - 1 ? [element] : [element, separator]
    );
  }

  static into(enumerable, collectable) {
    if (Array.isArray(collectable)) {
      if (Array.isArray(enumerable)) {
        return collectable.concat(enumerable);
      }

      if (enumerable instanceof Object) {
        return collectable.concat(Object.entries(enumerable));
      }

      throw new Error(`Bad enumerable in Enum.into: ${enumerable}`);
    }

    if (collectable instanceof Object) {
      if (Array.isArray(enumerable)) {
        return Object.assign({}, collectable, Object.fromEntries(enumerable));
      }

      if (enumerable instanceof Object) {
        return Object.assign({}, collectable, enumerable);
      }

      throw new Error(`Bad enumerable in Enum.into: ${enumerable}`);
    }

    throw new Error(`Bad collectable in Enum.into: ${collectable}`);
  }

  static into(enumerable, collectable, transform) {
    if (!Array.isArray(enumerable)) {
      enumerable = Object.entries(enumerable);
    }

    return this.into(
      enumerable.map((element) => transform(element)),
      collectable
    );
  }

  static join(enumerable, joiner = '') {
    return enumerable.join(joiner);
  }

  static map(enumerable, fun) {
    if (!Array.isArray(enumerable)) {
      enumerable = Object.entries(enumerable);
    }

    return enumerable.map((element) => fun(element));
  }

  static map_every(enumerable, nth, fun) {
    if (!Array.isArray(enumerable)) {
      enumerable = Object.entries(enumerable);
    }

    return enumerable.map((element, index) =>
      index % nth === 0 ? fun(element) : element
    );
  }

  static map_intersperse(enumerable, separator, mapper) {
    if (!Array.isArray(enumerable)) {
      enumerable = Object.entries(enumerable);
    }

    return enumerable.flatMap((element, index) =>
      index === enumerable.length - 1 ? [mapper(element)] : [mapper(element), separator]
    );
  }

  static map_join(enumerable, joiner = '', mapper) {
    if (!Array.isArray(enumerable)) {
      enumerable = Object.entries(enumerable);
    }

    return enumerable.reduce((acc, element) => acc.concat(joiner, mapper(element)), '');
  }

  static map_reduce(enumerable, acc, fun) {
    if (!Array.isArray(enumerable)) {
      enumerable = Object.entries(enumerable);
    }

    const mapped_enumerable = [];

    enumerable.forEach((element) => {
      const funResult = fun(element, acc);
      mapped_enumerable.push(funResult[0]);
      acc = funResult[1];
    });

    return mapped_enumerable;
  }

  static max(
    enumerable,
    sorter = (a, b) => a >= b,
    emptyFallback = () => {
      throw new Error(`Empty enum: ${enumerable}`);
    }
  ) {
    if (enumerable.length === 0) {
      return emptyFallback();
    }

    return enumerable.reduce((currMax, element) =>
      sorter(currMax, element) ? currMax : element
    );
  }

  static max_by(
    enumerable,
    fun,
    sorter = (a, b) => a >= b,
    emptyFallback = () => {
      throw new Error(`Empty enum: ${enumerable}`);
    }
  ) {
    if (enumerable.length === 0) {
      return emptyFallback();
    }

    return enumerable.reduce(
      ([currMax, currMaxIndex], element, index) => {
        const funResult = fun(element);

        return sorter(currMax, funResult) ? [currMax, currMaxIndex] : [funResult, index];
      },
      [fun(enumerable[0]), 0]
    );
  }

  static member$Q$(enumerable, element) {
    return enumerable.some((currElement) => currElement === element);
  }
}
