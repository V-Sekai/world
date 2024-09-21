export RUST_LOG := "log"
export MVSQLITE_DATA_PLANE := "http://192.168.0.39:7000"
export OPERATING_SYSTEM := os()
export ANDROID_HOME_COMMAND := "set-android-home-$OPERATING_SYSTEM"
export EDITOR_TYPE_COMMAND := "run-editor-$OPERATING_SYSTEM"

set-android-home:
    @just {{ ANDROID_HOME_COMMAND }}

set-android-home-linux:
    export ANDROID_HOME="/usr/local/share/android-sdk"

set-android-home-windows:
    export ANDROID_HOME="C:/Users/ernest.lee/AppData/Local/Android/Sdk"

build-godot:
    @just {{ EDITOR_TYPE_COMMAND }}
    cd godot && scons werror=no compiledb=yes dev_build=no generate_bundle=no precision=double target=editor tests=yes debug_symbols=yes
    cd -

run-editor:
    @just build-godot
    @just {{ EDITOR_TYPE_COMMAND }}

run-editor-macos:
    samply record ./godot/bin/godot.macos.editor.double.arm64 --path ./planner -e --display-driver macos --rendering-driver vulkan

run-editor-linux:
    ./godot/bin/godot.linux.editor.double.x86_64 --path ./planner -e

run-editor-windows:
    ./godot/bin/godot.windows.editor.double.exe --path ./planner -e
