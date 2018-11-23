load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@rules_emscripten//:http_archive_by_os.bzl", "http_archive_by_os")

_EMSCRIPTEN_VERSION = "1.38.20"

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
    http_archive(
        name = "emscripten_toolchain",
        url = "https://github.com/kripken/emscripten/archive/%s.tar.gz" % _EMSCRIPTEN_VERSION,
        build_file_content = """\
package(default_visibility = ['//visibility:public'])
filegroup(
    name = "all",
    srcs = glob(["**"], exclude=["third_party/websockify/Windows/**", "site/**"]),
)""",
        strip_prefix = "emscripten-%s" % _EMSCRIPTEN_VERSION,
        patches = [
            "@rules_emscripten//:third_party/emscripten_toolchain/7558.patch",
            "@rules_emscripten//:third_party/emscripten_toolchain/7563.patch",
        ],
        patch_tool = "git",
        patch_args = ["apply"],
    )
    http_archive_by_os(
        name = "emscripten_clang",
        url = {
            "darwin": "https://s3.amazonaws.com/mozilla-games/emscripten/packages/llvm/tag/osx_64bit/emscripten-llvm-e%s.tar.gz" % _EMSCRIPTEN_VERSION,
            "linux": "https://s3.amazonaws.com/mozilla-games/emscripten/packages/llvm/tag/linux_64bit/emscripten-llvm-e%s.tar.gz" % _EMSCRIPTEN_VERSION,
        },
        build_file_content = _ALL_FILES_CONTENT,
        strip_prefix = {
            "darwin": "emscripten-llvm-e%s" % _EMSCRIPTEN_VERSION,
            "linux": "emscripten-llvm-e%s" % _EMSCRIPTEN_VERSION,
        },
        sha256 = {
            "darwin": "524de09338a476c4621a8a454d3b5399d5aecc99304a52f638e1f84d585935e3",
            "linux": "c3704866391bf2417bd7e0fd246713f6f322ea19ff741ef00a301cea7e604114",
        },
    )
    _maybe(http_archive,
        name = "build_bazel_rules_nodejs",
        url = "https://github.com/bazelbuild/rules_nodejs/archive/0.15.3.tar.gz",
        strip_prefix = "rules_nodejs-0.15.3",
    )
