load("@bazel_tools//tools/build_defs/repo:utils.bzl", "patch", "workspace_and_buildfile")

def os_name(repository_ctx):
    os_name = repository_ctx.os.name.lower()
    if os_name.startswith("mac os"):
        return "darwin"
    elif os_name.find("windows") != -1:
        return "windows"
    elif os_name.startswith("linux"):
        return "linux"
    else:
        fail("Unsupported operating system: " + os_name)

_http_archive_by_os_attrs = {
    "url": attr.string_dict(),
    "urls": attr.string_list_dict(),
    "sha256": attr.string_dict(),
    "strip_prefix": attr.string_dict(),
    "type": attr.string(),
    "build_file": attr.label(allow_single_file = True),
    "build_file_content": attr.string(),
    "patches": attr.label_list(default = []),
    "patch_tool": attr.string(default = "patch"),
    "patch_args": attr.string_list(default = ["-p0"]),
    "patch_cmds": attr.string_list(default = []),
    "workspace_file": attr.label(allow_single_file = True),
    "workspace_file_content": attr.string(),
}

def _http_archive_by_os_impl(ctx):
    """Implementation of the http_archive rule."""
    if not ctx.attr.url and not ctx.attr.urls:
        fail("At least one of url and urls must be provided")
    if ctx.attr.build_file and ctx.attr.build_file_content:
        fail("Only one of build_file and build_file_content can be provided.")

    host = os_name(ctx)
    url = ctx.attr.url.get(host)
    urls = ctx.attr.urls.get(host)
    sha256 = ctx.attr.sha256.get(host) or ""
    strip_prefix = ctx.attr.strip_prefix.get(host) or ""

    all_urls = []
    if url:
        all_urls = url
    if urls:
        all_urls = [urls] + all_urls

    ctx.download_and_extract(
        all_urls,
        "",
        sha256,
        ctx.attr.type,
        strip_prefix,
    )
    patch(ctx)
    workspace_and_buildfile(ctx)

http_archive_by_os = repository_rule(
    implementation = _http_archive_by_os_impl,
    attrs = _http_archive_by_os_attrs,
)
