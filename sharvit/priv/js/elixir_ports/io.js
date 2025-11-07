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
