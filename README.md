# wcwidth-compat

[![Cross-Compiling](https://github.com/dokutoku/wcwidth-compat/actions/workflows/cross-compiling.yml/badge.svg)](https://github.com/dokutoku/wcwidth-compat/actions/workflows/cross-compiling.yml)

This library is a port of [wcwidth](https://github.com/termux/wcwidth) to the D language.

## Usage

### D

It is very simple to use.

```d
import wcwidth_compat;

assert(wcwidth(cast(uint)('Ａ') == 2);
```

### wasm

The generated WASM is not optimized, so you need to optimize it with a tool such as [Binaryen](https://github.com/WebAssembly/binaryen).

```shell
wasm-opt -O -o wcwidth-compat.wasm wcwidth-compat.wasm
```

When run in Node.js, the code is as follows.

```javascript
const fs = require('fs');

let bytes = new Uint8Array(fs.readFileSync('./wcwidth-compat.wasm'));
let instance = new WebAssembly.Instance(new WebAssembly.Module(bytes), {});

let input = 'Ａ';
console.log(instance.exports.wcwidth(input.codePointAt(0)));
```

## Related project

- [wcwidth-cjk-compat](https://gitlab.com/dokutoku/wcwidth-cjk-compat)
