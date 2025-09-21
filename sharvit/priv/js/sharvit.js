const sharvitPatterns = {
  any: Symbol('__any__'),
};

function doesMatchPattern(pattern, value) {
  if (pattern === sharvitPatterns.any) {
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
