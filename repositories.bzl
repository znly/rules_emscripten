load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

_ALL_FILES_CONTENT = """\
package(default_visibility = ['//visibility:public'])
filegroup(
    name = "all",
    srcs = glob(["**/*"]),
)
"""

def _maybe(repo_rule, name, **kwargs):
    if name not in native.existing_rules():
        repo_rule(name=name, **kwargs)

def rules_emscripten_repositories():
    _maybe(http_archive,
        name = 'emscripten_toolchain',
        url = 'https://github.com/kripken/emscripten/archive/1.38.6.tar.gz',
        build_file_content = _ALL_FILES_CONTENT,
        strip_prefix = "emscripten-1.38.6",
    )
    _maybe(http_archive,
        name = 'emscripten_clang',
        url = 'https://s3.amazonaws.com/mozilla-games/emscripten/packages/llvm/tag/osx_64bit/emscripten-llvm-e1.38.6.tar.gz',
        build_file_content = _ALL_FILES_CONTENT,
        strip_prefix = "emscripten-llvm-e1.38.6",
        sha256 = "ebdfe41cd68a32dcc4c2093a811c6dcd3e632906abc5d62243719f88dd6a6b02",
    )
    _maybe(http_archive,
        name = "build_bazel_rules_nodejs",
        url = 'https://github.com/bazelbuild/rules_nodejs/archive/0.15.3.tar.gz',
        strip_prefix = "rules_nodejs-0.15.3",
    )
