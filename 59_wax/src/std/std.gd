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

func fmax(a, b) -> float:
    return max(float(a), float(b))

func fmin(a, b) -> float:
    return min(float(a), float(b))

func fabs(a) -> float:
    return abs(float(a))

func chr(code):
    return code.to_utf8_buffer()[0]

func ord(character):
    return character.unicode_at(0)

const INFINITY = INF