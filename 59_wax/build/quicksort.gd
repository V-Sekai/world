#########################################
# quicksort                             #
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

func qksort_inplace(A, lo, hi):
    
    if (lo >= hi):
        return

    var pivot = 0.0
    pivot = (A)[lo]
    var left = 0
    left = lo
    var right = 0
    right = hi
    while (left <= right):
        while ((A)[left] < pivot):
            left = (left + 1)

        while ((A)[right] > pivot):
            right = (right - 1)

        if (left <= right):
            var tmp__s00 = 0.0
            tmp__s00 = (A)[left]
            (A)[left] = (A)[right]
            (A)[right] = tmp__s00
            left = (left + 1)
            right = (right - 1)


    qksort_inplace(A, lo, right)
    qksort_inplace(A, left, hi)

func qksort(A):
    
    if !(A).size():
        return

    qksort_inplace(A, 0, ((A).size() - 1))

func qksort_func(A):
    
    if ((A).size() <= 1):
        return (A).slice(0, (A).size())

    var pivot = 0.0
    pivot = (A)[0]
    var less = []
    less = []
    var more = []
    more = []
    var tmp_it_04 = 1
    while true:
        var i__s01 = tmp_it_04
        if (i__s01 < (A).size()):
            if ((A)[i__s01] < pivot):
                (less).insert((less).size(), (A)[i__s01])
            else:
                (more).insert((more).size(), (A)[i__s01])

            tmp_it_04 += 1
        else: break

    var sorted = []
    sorted = qksort_func(less)
    var right = []
    right = qksort_func(more)
    (sorted).insert((sorted).size(), pivot)
    var tmp_it_05 = 0
    while true:
        var i__s02 = tmp_it_05
        if (i__s02 < (right).size()):
            (sorted).insert((sorted).size(), (right)[i__s02])
            tmp_it_05 += 1
        else: break

    less = null # (GC)
    more = null # (GC)
    right = null # (GC)
    return sorted

func print_arr(A):
    
    var s = ""
    s = ""
    var tmp_it_06 = 0
    while true:
        var i__s03 = tmp_it_06
        if (i__s03 < (A).size()):
            if i__s03:
                (s) += (", ")

            (s) += (str((A)[i__s03]))
            tmp_it_06 += 1
        else: break

    print(s)
    s = null # (GC)

func main():
    
    var A = []
    A = [0.9, 0.2, 88, 10, 3, 4, 5.5, 0.1]
    print("original array:")
    print_arr(A)
    var B = []
    B = qksort_func(A)
    print("sorted with functional quicksort:")
    print_arr(B)
    print("original array is unchanged:")
    print_arr(A)
    qksort(A)
    print("sorted with in-place quicksort:")
    print_arr(A)
    A = null # (GC)
    B = null # (GC)
    return 0

# === User Code            END   ===
func _init():
    main()
