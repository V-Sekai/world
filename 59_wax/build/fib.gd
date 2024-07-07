#########################################
# fib                                   #
#########################################
# Compiled by WAXC (Version Jul  6 2024)

# === WAX Standard Library BEGIN ===
extends SceneTree
func w_arr_remove(a, i, n):
    for _j in range(n):
        a.remove_at(i)

func w_slice(a, i, n):
    return a.slice(i, n)

func w_map_get(m, k, d):
    if m.has(k):
        return m[k]
    else:
        return d

func w_map_remove(m, k):
    if m.has(k):
        m.erase(k)
# === WAX Standard Library END   ===

# === User Code            BEGIN ===

func fib(i):
    
    if (i <= 1):
        return i

    return (fib((i - 1)) + fib((i - 2)))

func main():
    
    var x = 0
    x = fib(9)
    print(str(x))
    return 0

# === User Code            END   ===
func _init():
    main()
