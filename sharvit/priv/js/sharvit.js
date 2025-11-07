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
