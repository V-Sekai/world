# Godot SQLite

This is a [MVSQLite](https://github.com/V-Sekai/mvsqlite) wrapper for the Godot Engine.

## Installation

1. Clone the repository using git:

   ```
   git clone https://github.com/V-Sekai/V-Sekai.godot-mvsqlite.git mvsqlite
   ```

2. Move the `mvsqlite` folder to the `modules` folder inside the Godot Engine source:

   ```
   mv sqlite godot/modules/
   ```

## Example Usage

- [SQL Queries](https://github.com/V-Sekai/godot-sqlite/blob/master/demo/SQLite/sql_queries.gd)
- [Game Highscore](https://github.com/V-Sekai/godot-sqlite/blob/master/demo/SQLite/game_highscore.gd)
- [Item Libraries](https://github.com/V-Sekai/godot-sqlite/blob/master/demo/SQLite/item_database.gd)

## Start `mvstore` on Macos

```
cd thirdparty/mvsqlite
export RUST_LOG=error 
export MVSQLITE_DATA_PLANE="http://localhost:7000"
export LD_LIBRARY_PATH=/usr/local/lib
export DYLD_LIBRARY_PATH=/usr/local/lib
cargo build --release -p mvsqlite
cargo build --release -p mvstore
./target/release/mvstore --data-plane 127.0.0.1:7000 --admin-api 127.0.0.1:7001 --metadata-prefix mvstore --raw-data-prefix m --cluster /usr/local/etc/foundationdb/fdb.cluster 
```

## Credits

This engine module for Godot is based on `gdsqlite-native` by Khairul Hidayat in 2017.
