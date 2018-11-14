# rules_emscripten
Bazel rules to use emscripten.

## Using rules_emscripten
In the `WORKSPACE`, add the following:
```python
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
git_repository(
    name = "rules_emscripten",
    remote = "https://github.com/znly/rules_emscripten",
    commit = "<HEAD COMMIT>",
)

load("@rules_emscripten//:repositories.bzl", "rules_emscripten_repositories")
rules_emscripten_repositories()

load("@build_bazel_rules_nodejs//:package.bzl", "rules_nodejs_dependencies")
rules_nodejs_dependencies()

load("@build_bazel_rules_nodejs//:defs.bzl", "node_repositories")
node_repositories()
```

You can use the `emcc_binary` rule:
```python
load("@rules_emscripten//toolchain:defs.bzl","emcc_binary")

emcc_binary(
    name = "helloworld",
    srcs = ["helloworld.cc"],
)
```

You'll need to add the following options to your `.bazelrc` file:
```
build:emscripten    --crosstool_top=//toolchain:emscripten
build:emscripten    --cpu=emscripten
build:emscripten    --host_crosstool_top=@bazel_tools//tools/cpp:toolchain
```

Then you can build with:
```
$ bazel build --config emscripten //:helloworld
```

## Notes
`emcc_binary` is a macro that wraps `cc_binary`. As such, it accepts all
`emcc_binary` accepts all `cc_binary` attributes. The reason the macro exists is
because emscripten outputs multiple artifacts (`.js` and `.wasm` file for
instance).

Look at the definition in `toolchain/defs.bzl` to check out the possible
arguments. By default, it will generate a `.js` and `.wasm`, since it's the
default for emscripten.

## Updating emscripten
This git repository embeds a pre-built cache of emscripten libraries (in
`toolchain/emscripten_cache`), which is dependant on the emscripten version.
When updating the emscripten version, it is mandatory to re-generate the cache
as well. This can be done by issuing the following command, when inside the
repository:
```
$ bazel run //toolchain:embuilder build ALL
```
