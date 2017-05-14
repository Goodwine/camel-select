camel-select
============

A smarter selection for camelCase and snake_case.  

> **Disclaimer:** This is not an official Google product.

This Atom plugin changes the behavior of cursor movement when pressing the
Ctrl/Cmd keys to a way that is friendlier on souce code that contains snake_case
and camelCase by mimicking Eclipse's *Smart Caret* instead of Atom's
"subword-boundary" behavior.

This simple and seemingly small difference makes a big impact while coding,
especially for someone who works a lot with Eclipse due to muscle memory.
Now switching between both editors feels like working on the same one.  
An analogy: Vim users want Vim bindings on Atom.

![Comparison of Atom's native behavior vs this plugin.](https://cloud.githubusercontent.com/assets/2022649/26031913/6bf87350-3839-11e7-9a9f-e92d9c36d810.png)

Movement is determined by categorizing characters in 5 groups, and instead of
stopping at non-word characters, the cursor stops when there is a transition:

*   Lower case characters.
*   Upper case characters.
*   Boundary characters. From your config in `Settings -> Editor -> Non Word
    Characters`, plus `_`.
*   Space characters. (Those that match `\s`)
*   Neutral characters, the rest of them.

## License

Apache 2.0; see [LICENSE.md](LICENSE.md) for details.
