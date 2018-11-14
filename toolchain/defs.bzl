def emcc_binary(name,
                memory_init_file = 0,
                wasm = True,
                worker = False,
                linkopts = [],
                visibility = [],
                **kwargs):
    linkopts = list(linkopts)
    outputs = [
        name + ".js",
    ]
    if wasm:
        linkopts.append("-s WASM=1")
        outputs.append(name + ".wasm")
    else:
        linkopts.append("-s WASM=0")
        linkopts.append("--memory-init-file %d" % memory_init_file)
    if memory_init_file:
        outputs.append(name + ".mem")
    if worker:
        outputs.append(name + ".worker.js")
        linkopts.append("--proxy-to-worker")

    zipfile = name + ".zip"
    native.cc_binary(
        name = zipfile,
        linkopts = linkopts,
        **kwargs
    )
    native.genrule(
        name = name,
        srcs = [zipfile],
        outs = outputs,
        output_to_bindir = 1,
        testonly = kwargs.get('testonly'),
        tools = [
            "@bazel_tools//tools/zip:zipper",
        ],
        cmd = """$(location @bazel_tools//tools/zip:zipper) xf $(SRCS) -d $(@D)""",
        visibility = visibility,
    )

def emcc_test(name, **kwargs):
    binary_args = {}
    test_args = {}
    data = ["@nodejs//:bin/node"]
    for key, val in kwargs.items():
        if key == 'tags':
            binary_args[key] = val
            test_args[key] = val
        elif key == 'data':
            data.extend(val)
        elif key in [
                'args', 'size', 'timeout', 'flaky', 'local', 'shard_count'
        ]:
            test_args[key] = val
        else:
            binary_args[key] = val
    jsfile = name + ".js"
    data.append(jsfile)
    if kwargs.get('wasm', True):
        data.append(name+'.wasm')
    emcc_binary(jsfile, testonly=True, **binary_args)
    shfile = name + "_test.sh"
    native.genrule(
        name="gen_" + shfile,
        cmd="cp $< $@",
        srcs=["@rules_emscripten//toolchain:test.sh"],
        testonly=True,
        outs=[shfile])
    native.sh_test(
        name=name,
        srcs=[shfile],
        data=data,
        deps=[
            "@bazel_tools//tools/bash/runfiles",
        ],
        **test_args)
