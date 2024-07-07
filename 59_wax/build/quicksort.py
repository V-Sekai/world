#########################################
# quicksort                             #
#########################################
# Compiled by WAXC (Version Jul  6 2024)

# === WAX Standard Library BEGIN ===
def w_arr_remove(a,i,n):del a[i:i+n]
def w_slice(a,i,n):return a[i:i+n]
def w_map_get(m,k,d):
    try:return m[k]
    except:return d
def w_map_remove(m,k):
    try:del m[k]
    except:pass
# === WAX Standard Library END   ===

# === User Code            BEGIN ===

def qksort_inplace(A,lo,hi):
    
    if int((lo)>=(hi)):
        return

    pivot=0.0
    pivot=((A)[lo])
    left=0
    left=lo
    right=0
    right=hi
    while int((left)<=(right)):
        while int((((A)[left]))<(pivot)):
            left=((left)+(1))

        while int((((A)[right]))>(pivot)):
            right=((right)-(1))

        if int((left)<=(right)):
            tmp__s00=0.0
            tmp__s00=((A)[left])
            (A)[left]=((A)[right])
            (A)[right]=tmp__s00
            left=((left)+(1))
            right=((right)-(1))


    qksort_inplace(A,lo,right)
    qksort_inplace(A,left,hi)

def qksort(A):
    
    if int(not(len(A))):
        return

    qksort_inplace(A,0,((len(A))-(1)))

def qksort_func(A):
    
    if int((len(A))<=(1)):
        return w_slice(A,0,len(A))

    pivot=0.0
    pivot=((A)[0])
    less=None
    less=[]
    more=None
    more=[]
    tmp_it_04=1
    while True:
        i__s01=tmp_it_04;
        if int((i__s01)<(len(A))):
            if int((((A)[i__s01]))<(pivot)):
                (less).insert((len(less)),(((A)[i__s01])))
            else:
                (more).insert((len(more)),(((A)[i__s01])))

            tmp_it_04+=1
        else:break
    sorted=None
    sorted=qksort_func(less)
    right=None
    right=qksort_func(more)
    (sorted).insert((len(sorted)),(pivot))
    tmp_it_05=0
    while True:
        i__s02=tmp_it_05;
        if int((i__s02)<(len(right))):
            (sorted).insert((len(sorted)),(((right)[i__s02])))
            tmp_it_05+=1
        else:break
    less=None#(GC)
    more=None#(GC)
    right=None#(GC)
    return sorted

def print_arr(A):
    
    s=None
    s=""
    tmp_it_06=0
    while True:
        i__s03=tmp_it_06;
        if int((i__s03)<(len(A))):
            if i__s03:
                (s)+=(", ")

            (s)+=(str(((A)[i__s03])))
            tmp_it_06+=1
        else:break
    print(s)
    s=None#(GC)

def main():
    
    A=None
    A=[(0.9),(0.2),(88),(10),(3),(4),(5.5),(0.1)]
    print("original array:")
    print_arr(A)
    B=None
    B=qksort_func(A)
    print("sorted with functional quicksort:")
    print_arr(B)
    print("original array is unchanged:")
    print_arr(A)
    qksort(A)
    print("sorted with in-place quicksort:")
    print_arr(A)
    A=None#(GC)
    B=None#(GC)
    return 0

# === User Code            END   ===
exit(main())
