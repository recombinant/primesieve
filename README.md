# primesieve

[primesieve](https://github.com/kimwalisch/primesieve) ported to the [Zig](https://ziglang.org/) build system and given a Zig wrapper.

- losing the `primesieve_` from C names - Zig has namespaces
- Zigify names within the `primesieve` namespace.
- There are no releases. Attempts are made to keep this up to date
  with the latest Zig and [primesieve](https://github.com/kimwalisch/primesieve)
- Error checking has to be done by checking the C `err_no` variable or for a return value of `PRIMESIEVE_ERROR` where appropriate. There are currently no Zig errors.

For a reasonable description of the Zig build system can be found [here](https://www.ziglang.in/learn/build-system/zig-build/)

## Installation

The usual dance. Add `primesieve` to your `build.zig.zon` file.

```
$ zig fetch --save git+https://github.com/recombinant/primesieve
```

Then, within your `build.zig`, write something like this:

```
const primesieve_dep = b.dependency("primesieve", .{});
const primesieve_mod = primesieve_dep.module("primesieve");
```
...
```
some_module.addImport("primesieve", primesieve_mod);
```

