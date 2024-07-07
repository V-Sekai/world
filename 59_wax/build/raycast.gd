#########################################
# raycast                               #
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
# === WAX Standard Library END   ===

# === User Code            BEGIN ===

class ray:
    var o = []
    var d = []
    var tmin = 0.0
    var tmax = 0.0

class mesh:
    var vertices = []
    var faces = []
    var facenorms = []

func v_sub(u, v):
    return 

func v_cross(u, v):
    return 

func v_dot(u, v):
    return (((u[0] * v[0]) + (u[1] * v[1])) + (u[2] * v[2]))

func v_scale(u, x):
    return 

func v_mag(v):
    return sqrt((((v[0] * v[0]) + (v[1] * v[1])) + (v[2] * v[2])))

func normalize(v):
    var l: float = 0.0
    l = v_mag(v)
    v[0] = (v[0] / l)
    v[1] = (v[1] / l)
    v[2] = (v[2] / l)

func det(a, b, c):
    var d: Array = []
    d = v_cross(a, b)
    var e: float = 0.0
    e = v_dot(d, c)
    pass
    return e

func new_ray(ox, oy, oz, dx, dy, dz):
    var r: Object = null
    r.resize(3)
    var o: Array = []
    o.resize(3)
    var d: Array = []
    d.resize(3)
    normalize(d)
    r.o = o
    r.d = d
    r.tmin = 0.0
    r.tmax = INFINITY
    return r

func destroy_ray(r):
    pass
    pass
    pass

func ray_tri(r, p0, p1, p2):
    var e1: Array = []
    e1 = v_sub(p1, p0)
    var e2: Array = []
    e2 = v_sub(p2, p0)
    var s: Array = []
    s = v_sub(r.o, p0)
    var _d: Array = []
    _d = v_scale(r.d, -1)
    var denom: float = 0.0
    denom = det(e1, e2, _d)
    if (denom == 0):
        pass
        pass
        pass
        pass
        return INFINITY

    var u: float = 0.0
    u = (det(s, e2, _d) / denom)
    var v: float = 0.0
    v = (det(e1, s, _d) / denom)
    var t: float = 0.0
    t = (det(e1, e2, s) / denom)
    if (((((u < 0) or (v < 0)) or ((1 - (u + v)) < 0)) or (t < r.tmin)) or (t > r.tmax)):
        pass
        pass
        pass
        pass
        return INFINITY

    r.tmax = t
    pass
    pass
    pass
    pass
    return t

func ray_mesh(r, m, l):
    var dstmin: float = 0.0
    dstmin = INFINITY
    var argmin: int = 0
    argmin = -1
    var tmp_it_0f = 0
    while true:
        var i__s00 = tmp_it_0f
        if (i__s00 < (m.faces).size()):
            var a__s01: Array = []
            a__s01 = m.vertices[m.faces[i__s00][0]]
            var b__s01: Array = []
            b__s01 = m.vertices[m.faces[i__s00][1]]
            var c__s01: Array = []
            c__s01 = m.vertices[m.faces[i__s00][2]]
            var t__s01: float = 0.0
            t__s01 = ray_tri(r, a__s01, b__s01, c__s01)
            if (t__s01 < dstmin):
                dstmin = t__s01
                argmin = i__s00

            tmp_it_0f += 1
        else:
            break

    if ((argmin < -1) or (dstmin == INFINITY)):
        return 0.0

    var n: Array = []
    n = m.facenorms[argmin]
    var ndotl: float = 0.0
    ndotl = v_dot(n, l)
    return (fmax(ndotl, 0) + 0.1)

func add_vert(m, x, y, z):
    (m.vertices).insert((m.vertices).size(), )

func add_face(m, a, b, c):
    (m.faces).insert((m.faces).size(), )

func calc_facenorms(m):
    var tmp_it_10 = 0
    while true:
        var i__s02 = tmp_it_10
        if (i__s02 < (m.faces).size()):
            var a__s03: Array = []
            a__s03 = m.vertices[m.faces[i__s02][0]]
            var b__s03: Array = []
            b__s03 = m.vertices[m.faces[i__s02][1]]
            var c__s03: Array = []
            c__s03 = m.vertices[m.faces[i__s02][2]]
            var e1__s03: Array = []
            e1__s03 = v_sub(a__s03, b__s03)
            var e2__s03: Array = []
            e2__s03 = v_sub(b__s03, c__s03)
            var n__s03: Array = []
            n__s03 = v_cross(e1__s03, e2__s03)
            normalize(n__s03)
            (m.facenorms).insert((m.facenorms).size(), n__s03)
            pass
            pass
            tmp_it_10 += 1
        else:
            break


func move_mesh(m, x, y, z):
    var tmp_it_11 = 0
    while true:
        var i__s04 = tmp_it_11
        if (i__s04 < (m.vertices).size()):
            m.vertices[i__s04][0] = (m.vertices[i__s04][0] + x)
            m.vertices[i__s04][1] = (m.vertices[i__s04][1] + y)
            m.vertices[i__s04][2] = (m.vertices[i__s04][2] + z)
            tmp_it_11 += 1
        else:
            break


func destroy_mesh(m):
    var tmp_it_12 = 0
    while true:
        var i__s05 = tmp_it_12
        if (i__s05 < (m.vertices).size()):
            pass
            tmp_it_12 += 1
        else:
            break

    pass
    var tmp_it_13 = 0
    while true:
        var i__s06 = tmp_it_13
        if (i__s06 < (m.faces).size()):
            pass
            tmp_it_13 += 1
        else:
            break

    pass
    var tmp_it_14 = 0
    while true:
        var i__s07 = tmp_it_14
        if (i__s07 < (m.facenorms).size()):
            pass
            tmp_it_14 += 1
        else:
            break

    pass
    pass

func render(m, light):
    var pix: Array = []
    pix.resize(3840)
    normalize(light)
    var palette: String = ""
    palette = "`.-,_:^!~;r+|()=>l?icv[]tzj7*f{}sYTJ1unyIFowe2h3Za4X%5P$mGAUbpK960#H&DRQ80WMB@N"
    var lo: float = 0.0
    lo = INFINITY
    var hi: float = 0.0
    hi = 0
    var tmp_it_15 = 0
    while true:
        var y__s08 = tmp_it_15
        if (y__s08 < 40):
            var tmp_it_16 = 0
            while true:
                var x__s09 = tmp_it_16
                if (x__s09 < 80):
                    var fx__s0a: float = 0.0
                    fx__s0a = ((x__s09 - (80 / 2.0)) / 2.0)
                    var fy__s0a: float = 0.0
                    fy__s0a = (y__s08 - (40 / 2.0))
                    var r__s0a: Object = null
                    r__s0a = new_ray(0, 0, 0, fx__s0a, fy__s0a, 100)
                    var gray__s0a: float = 0.0
                    gray__s0a = ray_mesh(r__s0a, m, light)
                    hi = fmax(gray__s0a, hi)
                    if (gray__s0a > 0):
                        lo = fmin(gray__s0a, lo)

                    pix[((y__s08 * 80) + x__s09)] = gray__s0a
                    destroy_ray(r__s0a)
                    tmp_it_16 += 1
                else:
                    break

            tmp_it_15 += 1
        else:
            break

    var s: String = ""
    var tmp_it_17 = 0
    while true:
        var y__s0b = tmp_it_17
        if (y__s0b < 40):
            var tmp_it_18 = 0
            while true:
                var x__s0c = tmp_it_18
                if (x__s0c < 80):
                    var gray__s0d: float = 0.0
                    gray__s0d = pix[((y__s0b * 80) + x__s0c)]
                    if (gray__s0d != 0):
                        gray__s0d = ((gray__s0d - lo) / (hi - lo))
                        var ch__s0e: int = 0
                        ch__s0e = palette.unicode_at(int((gray__s0d * 78)))
                        (s) += chr(ch__s0e)
                    else:
                        (s) += chr(ord(' '))

                    tmp_it_18 += 1
                else:
                    break

            (s) += ("\n")
            tmp_it_17 += 1
        else:
            break

    print(s)
    pass
    pass

func dodecahedron():
    var m: Object = null
    m.vertices = []
    m.faces = []
    m.facenorms = []
    add_vert(m, -0.436466, -0.668835, 0.601794)
    add_vert(m, 0.918378, 0.351401, -0.181931)
    add_vert(m, 0.886304, -0.351401, -0.301632)
    add_vert(m, -0.886304, 0.351401, 0.301632)
    add_vert(m, -0.918378, -0.351401, 0.181931)
    add_vert(m, 0.132934, 0.858018, 0.496117)
    add_vert(m, -0.048964, 0.981941, -0.182738)
    add_vert(m, 0.106555, 0.162217, -0.980985)
    add_vert(m, -0.582772, 0.162217, -0.796280)
    add_vert(m, -0.132934, -0.858018, -0.496117)
    add_vert(m, 0.048964, -0.981941, 0.182738)
    add_vert(m, 0.582772, -0.162217, 0.796280)
    add_vert(m, -0.106555, -0.162217, 0.980985)
    add_vert(m, 0.436466, 0.668835, -0.601794)
    add_vert(m, 0.730785, 0.468323, 0.496615)
    add_vert(m, -0.678888, 0.668835, -0.302936)
    add_vert(m, -0.384570, 0.468323, 0.795474)
    add_vert(m, 0.384570, -0.468323, -0.795474)
    add_vert(m, 0.678888, -0.668835, 0.302936)
    add_vert(m, -0.730785, -0.468323, -0.496615)
    add_face(m, 19, 3, 2)
    add_face(m, 12, 19, 2)
    add_face(m, 15, 12, 2)
    add_face(m, 8, 14, 2)
    add_face(m, 18, 8, 2)
    add_face(m, 3, 18, 2)
    add_face(m, 20, 5, 4)
    add_face(m, 9, 20, 4)
    add_face(m, 16, 9, 4)
    add_face(m, 13, 17, 4)
    add_face(m, 1, 13, 4)
    add_face(m, 5, 1, 4)
    add_face(m, 7, 16, 4)
    add_face(m, 6, 7, 4)
    add_face(m, 17, 6, 4)
    add_face(m, 6, 15, 2)
    add_face(m, 7, 6, 2)
    add_face(m, 14, 7, 2)
    add_face(m, 10, 18, 3)
    add_face(m, 11, 10, 3)
    add_face(m, 19, 11, 3)
    add_face(m, 11, 1, 5)
    add_face(m, 10, 11, 5)
    add_face(m, 20, 10, 5)
    add_face(m, 20, 9, 8)
    add_face(m, 10, 20, 8)
    add_face(m, 18, 10, 8)
    add_face(m, 9, 16, 7)
    add_face(m, 8, 9, 7)
    add_face(m, 14, 8, 7)
    add_face(m, 12, 15, 6)
    add_face(m, 13, 12, 6)
    add_face(m, 17, 13, 6)
    add_face(m, 13, 1, 11)
    add_face(m, 12, 13, 11)
    add_face(m, 19, 12, 11)
    calc_facenorms(m)
    return m

func main():
    var m: Object = null
    m = dodecahedron()
    move_mesh(m, 0, 0, 5)
    var light: Array = []
    light.resize(3)
    render(m, light)
    destroy_mesh(m)
    pass
    return 0

# === User Code            END   ===
func _init():
    main()
