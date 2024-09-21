export RUST_LOG := "log"
export MVSQLITE_DATA_PLANE := "http://192.168.0.39:7000"

set-android-home:
    @if [ "$$OPERATING_SYSTEM" = "windows" ]; then \
        export ANDROID_HOME="C:/Users/ernest.lee/AppData/Local/Android/Sdk"; \
    else \
        export ANDROID_HOME="/usr/local/share/android-sdk"; \
    fi

build-godot:
    @just set-android-home
    cd godot && \
    scons werror=no compiledb=yes dev_build=no generate_bundle=no precision=double target=editor tests=yes debug_symbols=yes

run-editor:
    @just build-godot
    @if [ "$$OPERATING_SYSTEM" = "macos" ]; then \
        ./godot/bin/godot.macos.editor.double.arm64 --path "planner" -e; \
    elif [ "$$OPERATING_SYSTEM" = "linux" ]; then \
        ./godot/bin/godot.linux.editor.double.x86_64 --path "planner" -e; \
    elif [ "$$OPERATING_SYSTEM" = "windows" ]; then \
        ./godot/bin/godot.windows.editor.double.exe --path "planner" -e; \
    fi
