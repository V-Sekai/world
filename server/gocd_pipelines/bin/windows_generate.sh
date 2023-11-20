rm -rf build
mkdir -p build
bin/jsonnet -m build src/godot_4_x.jsonnet
dos2unix build/*
