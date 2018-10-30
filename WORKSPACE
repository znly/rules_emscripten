workspace(name="rules_emscripten")

load("@rules_emscripten//:repositories.bzl", "rules_emscripten_repositories")
rules_emscripten_repositories()

load("@build_bazel_rules_nodejs//:package.bzl", "rules_nodejs_dependencies")
rules_nodejs_dependencies()

load("@build_bazel_rules_nodejs//:defs.bzl", "node_repositories")
node_repositories(package_json = ["//:package.json"])
