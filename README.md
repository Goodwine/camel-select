camel-select
============

A smarter selection for camelCase and snake_case.  
![Example of my solution](http://i.imgur.com/e62Goue.gif)

> **Disclaimer:** This is not an official Google product.

Currently Atom already provides a similar functionality under these methods:

* `editor:move-to-previous-subword-boundary`
* `editor:move-to-next-subword-boundary`
* `editor:select-to-previous-subword-boundary`
* `editor:select-to-next-subword-boundary`
* `editor:delete-to-end-of-subword`
* `editor:delete-to-beginning-of-subword`

While these are good enough, they are not perfect for me, take for example the picture below.
As you can see, the **2nd and 3rd** lines behave differently.  
I use a lot of Eclipse for Java, so I'm not completely happy with the current solution
(mostly the uppercase snake_case).

![Example of Atom's built-in solution](http://i.imgur.com/6qKVQmR.gif)

This package is inspired on [ajile/word-jumper](https://github.com/ajile/word-jumper)'s package,
I didn't try sending PRs because the repo looks inactive, and instead I decided to create my own.
Kudos to `ajile` for creating the first package.

The specific rules of how this works is by having 4 categories:

* Lower case characters.
* Upper case characters.
* Boundary characters. From your config in `Settings -> Editor -> Non Word Characters`,
  plus `_`.
* Space characters. (Those that match `\s`)
* Neutral characters, the rest of them.

| Transition (in order)    | Action                                               |
| ------------------------ | ---------------------------------------------------- |
| boundary -> non-boundary | Continue, new mode mode                              |
| non-boundary -> boundary | Stop, not inclusive                                  |
| space -> non-space       | Continue, new mode mode                              |
| non-space -> space       | Stop, not inclusive                                  |
| neutral -> non-neutral   | Continue, update mode                                |
| non-neutral -> neutral   | Continue, same mode                                  |
| lower -> upper           | Stop, **Left**: inclusive, **Right**: not inclusive  |
| upper -> lower           | Stop, **Left**: not inclusive, **Right**: lower mode |

## License

Apache 2.0; see [LICENSE.md](LICENSE.md) for details.
