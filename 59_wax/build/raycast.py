#########################################
# raycast                               #
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

from math import *
from random import random
INFINITY = float('inf')
fabs = abs
fmin = min
fmax = max
class ray:
    o=None
    d=None
    tmin=0.0
    tmax=0.0

class mesh:
    vertices=None
    faces=None
    facenorms=None

def v_sub(u,v):
    global INFINITY
    return [(((((u)[0]))-(((v)[0])))),(((((u)[1]))-(((v)[1])))),(((((u)[2]))-(((v)[2]))))]

def v_cross(u,v):
    global INFINITY
    return [(((((((u)[1]))*(((v)[2]))))-(((((u)[2]))*(((v)[1])))))),(((((((u)[2]))*(((v)[0]))))-(((((u)[0]))*(((v)[2])))))),(((((((u)[0]))*(((v)[1]))))-(((((u)[1]))*(((v)[0]))))))]

def v_dot(u,v):
    global INFINITY
    return ((((((((u)[0]))*(((v)[0]))))+(((((u)[1]))*(((v)[1]))))))+(((((u)[2]))*(((v)[2])))))

def v_scale(u,x):
    global INFINITY
    return [(((((u)[0]))*(x))),(((((u)[1]))*(x))),(((((u)[2]))*(x)))]

def v_mag(v):
    global INFINITY
    return sqrt(((((((((v)[0]))*(((v)[0]))))+(((((v)[1]))*(((v)[1]))))))+(((((v)[2]))*(((v)[2]))))))

def normalize(v):
    global INFINITY
    l=0.0
    l=v_mag(v)
    (v)[0]=((((v)[0]))/(l))
    (v)[1]=((((v)[1]))/(l))
    (v)[2]=((((v)[2]))/(l))

def det(a,b,c):
    global INFINITY
    d=None
    d=v_cross(a,b)
    e=0.0
    e=v_dot(d,c)
    d=None#(GC)
    return e

def new_ray(ox,oy,oz,dx,dy,dz):
    global INFINITY
    r=None
    r=ray()
    o=None
    o=[(ox),(oy),(oz)]
    d=None
    d=[(dx),(dy),(dz)]
    normalize(d)
    (r).o=o
    (r).d=d
    (r).tmin=0.0
    (r).tmax=INFINITY
    return r

def destroy_ray(r):
    global INFINITY
    ((r).o)=None#(GC)
    ((r).d)=None#(GC)
    r=None#(GC)

def ray_tri(r,p0,p1,p2):
    global INFINITY
    e1=None
    e1=v_sub(p1,p0)
    e2=None
    e2=v_sub(p2,p0)
    s=None
    s=v_sub(((r).o),p0)
    _d=None
    _d=v_scale(((r).d),-1)
    denom=0.0
    denom=det(e1,e2,_d)
    if int((denom)==(0)):
        e1=None#(GC)
        e2=None#(GC)
        s=None#(GC)
        _d=None#(GC)
        return INFINITY

    u=0.0
    u=((det(s,e2,_d))/(denom))
    v=0.0
    v=((det(e1,s,_d))/(denom))
    t=0.0
    t=((det(e1,e2,s))/(denom))
    if int(bool((int(bool((int(bool((int(bool((int((u)<(0))) or (int((v)<(0)))))) or (int((((1)-(((u)+(v)))))<(0)))))) or (int((t)<(((r).tmin))))))) or (int((t)>(((r).tmax)))))):
        e1=None#(GC)
        e2=None#(GC)
        s=None#(GC)
        _d=None#(GC)
        return INFINITY

    (r).tmax=t
    e1=None#(GC)
    e2=None#(GC)
    s=None#(GC)
    _d=None#(GC)
    return t

def ray_mesh(r,m,l):
    global INFINITY
    dstmin=0.0
    dstmin=INFINITY
    argmin=0
    argmin=-1
    tmp_it_0f=0
    while True:
        i__s00=tmp_it_0f;
        if int((i__s00)<(len(((m).faces)))):
            a__s01=None
            a__s01=((((m).vertices))[((((((m).faces))[i__s00]))[0])])
            b__s01=None
            b__s01=((((m).vertices))[((((((m).faces))[i__s00]))[1])])
            c__s01=None
            c__s01=((((m).vertices))[((((((m).faces))[i__s00]))[2])])
            t__s01=0.0
            t__s01=ray_tri(r,a__s01,b__s01,c__s01)
            if int((t__s01)<(dstmin)):
                dstmin=t__s01
                argmin=i__s00

            tmp_it_0f+=1
        else:break
    if int(bool((int((argmin)<(-1))) or (int((dstmin)==(INFINITY))))):
        return 0.0

    n=None
    n=((((m).facenorms))[argmin])
    ndotl=0.0
    ndotl=v_dot(n,l)
    return ((fmax(ndotl,0))+(0.1))

def add_vert(m,x,y,z):
    global INFINITY
    (((m).vertices)).insert((len(((m).vertices))),([(x),(y),(z)]))

def add_face(m,a,b,c):
    global INFINITY
    (((m).faces)).insert((len(((m).faces))),([(((a)-(1))),(((c)-(1))),(((b)-(1)))]))

def calc_facenorms(m):
    global INFINITY
    tmp_it_10=0
    while True:
        i__s02=tmp_it_10;
        if int((i__s02)<(len(((m).faces)))):
            a__s03=None
            a__s03=((((m).vertices))[((((((m).faces))[i__s02]))[0])])
            b__s03=None
            b__s03=((((m).vertices))[((((((m).faces))[i__s02]))[1])])
            c__s03=None
            c__s03=((((m).vertices))[((((((m).faces))[i__s02]))[2])])
            e1__s03=None
            e1__s03=v_sub(a__s03,b__s03)
            e2__s03=None
            e2__s03=v_sub(b__s03,c__s03)
            n__s03=None
            n__s03=v_cross(e1__s03,e2__s03)
            normalize(n__s03)
            (((m).facenorms)).insert((len(((m).facenorms))),(n__s03))
            e1__s03=None#(GC)
            e2__s03=None#(GC)
            tmp_it_10+=1
        else:break

def move_mesh(m,x,y,z):
    global INFINITY
    tmp_it_11=0
    while True:
        i__s04=tmp_it_11;
        if int((i__s04)<(len(((m).vertices)))):
            (((((m).vertices))[i__s04]))[0]=((((((((m).vertices))[i__s04]))[0]))+(x))
            (((((m).vertices))[i__s04]))[1]=((((((((m).vertices))[i__s04]))[1]))+(y))
            (((((m).vertices))[i__s04]))[2]=((((((((m).vertices))[i__s04]))[2]))+(z))
            tmp_it_11+=1
        else:break

def destroy_mesh(m):
    global INFINITY
    tmp_it_12=0
    while True:
        i__s05=tmp_it_12;
        if int((i__s05)<(len(((m).vertices)))):
            ((((m).vertices))[i__s05])=None#(GC)
            tmp_it_12+=1
        else:break
    ((m).vertices)=None#(GC)
    tmp_it_13=0
    while True:
        i__s06=tmp_it_13;
        if int((i__s06)<(len(((m).faces)))):
            ((((m).faces))[i__s06])=None#(GC)
            tmp_it_13+=1
        else:break
    ((m).faces)=None#(GC)
    tmp_it_14=0
    while True:
        i__s07=tmp_it_14;
        if int((i__s07)<(len(((m).facenorms)))):
            ((((m).facenorms))[i__s07])=None#(GC)
            tmp_it_14+=1
        else:break
    ((m).facenorms)=None#(GC)
    m=None#(GC)

def render(m,light):
    global INFINITY
    pix=None
    pix=([0.0]*3840)
    normalize(light)
    palette=None
    palette="`.-,_:^!~;r+|()=>l?icv[]tzj7*f{}sYTJ1unyIFowe2h3Za4X%5P$mGAUbpK960#H&DRQ80WMB@N"
    lo=0.0
    lo=INFINITY
    hi=0.0
    hi=0
    tmp_it_15=0
    while True:
        y__s08=tmp_it_15;
        if int((y__s08)<(40)):
            tmp_it_16=0
            while True:
                x__s09=tmp_it_16;
                if int((x__s09)<(80)):
                    fx__s0a=0.0
                    fx__s0a=((((x__s09)-(((80)/(2.0)))))/(2.0))
                    fy__s0a=0.0
                    fy__s0a=((y__s08)-(((40)/(2.0))))
                    r__s0a=None
                    r__s0a=new_ray(0,0,0,fx__s0a,fy__s0a,100)
                    gray__s0a=0.0
                    gray__s0a=ray_mesh(r__s0a,m,light)
                    hi=fmax(gray__s0a,hi)
                    if int((gray__s0a)>(0)):
                        lo=fmin(gray__s0a,lo)

                    (pix)[((((y__s08)*(80)))+(x__s09))]=gray__s0a
                    destroy_ray(r__s0a)
                    tmp_it_16+=1
                else:break
            tmp_it_15+=1
        else:break
    s=None
    s=""
    tmp_it_17=0
    while True:
        y__s0b=tmp_it_17;
        if int((y__s0b)<(40)):
            tmp_it_18=0
            while True:
                x__s0c=tmp_it_18;
                if int((x__s0c)<(80)):
                    gray__s0d=0.0
                    gray__s0d=((pix)[((((y__s0b)*(80)))+(x__s0c))])
                    if int((gray__s0d)!=(0)):
                        gray__s0d=((((gray__s0d)-(lo)))/(((hi)-(lo))))
                        ch__s0e=0
                        ch__s0e=ord((palette)[int(((gray__s0d)*(78)))])
                        (s)+=chr(ch__s0e)
                    else:
                        (s)+=chr(ord(' '))

                    tmp_it_18+=1
                else:break
            (s)+=("\n")
            tmp_it_17+=1
        else:break
    print(s)
    pix=None#(GC)
    s=None#(GC)

def dodecahedron():
    global INFINITY
    m=None
    m=mesh()
    (m).vertices=[]
    (m).faces=[]
    (m).facenorms=[]
    add_vert(m,-0.436466,-0.668835,0.601794)
    add_vert(m,0.918378,0.351401,-0.181931)
    add_vert(m,0.886304,-0.351401,-0.301632)
    add_vert(m,-0.886304,0.351401,0.301632)
    add_vert(m,-0.918378,-0.351401,0.181931)
    add_vert(m,0.132934,0.858018,0.496117)
    add_vert(m,-0.048964,0.981941,-0.182738)
    add_vert(m,0.106555,0.162217,-0.980985)
    add_vert(m,-0.582772,0.162217,-0.796280)
    add_vert(m,-0.132934,-0.858018,-0.496117)
    add_vert(m,0.048964,-0.981941,0.182738)
    add_vert(m,0.582772,-0.162217,0.796280)
    add_vert(m,-0.106555,-0.162217,0.980985)
    add_vert(m,0.436466,0.668835,-0.601794)
    add_vert(m,0.730785,0.468323,0.496615)
    add_vert(m,-0.678888,0.668835,-0.302936)
    add_vert(m,-0.384570,0.468323,0.795474)
    add_vert(m,0.384570,-0.468323,-0.795474)
    add_vert(m,0.678888,-0.668835,0.302936)
    add_vert(m,-0.730785,-0.468323,-0.496615)
    add_face(m,19,3,2)
    add_face(m,12,19,2)
    add_face(m,15,12,2)
    add_face(m,8,14,2)
    add_face(m,18,8,2)
    add_face(m,3,18,2)
    add_face(m,20,5,4)
    add_face(m,9,20,4)
    add_face(m,16,9,4)
    add_face(m,13,17,4)
    add_face(m,1,13,4)
    add_face(m,5,1,4)
    add_face(m,7,16,4)
    add_face(m,6,7,4)
    add_face(m,17,6,4)
    add_face(m,6,15,2)
    add_face(m,7,6,2)
    add_face(m,14,7,2)
    add_face(m,10,18,3)
    add_face(m,11,10,3)
    add_face(m,19,11,3)
    add_face(m,11,1,5)
    add_face(m,10,11,5)
    add_face(m,20,10,5)
    add_face(m,20,9,8)
    add_face(m,10,20,8)
    add_face(m,18,10,8)
    add_face(m,9,16,7)
    add_face(m,8,9,7)
    add_face(m,14,8,7)
    add_face(m,12,15,6)
    add_face(m,13,12,6)
    add_face(m,17,13,6)
    add_face(m,13,1,11)
    add_face(m,12,13,11)
    add_face(m,19,12,11)
    calc_facenorms(m)
    return m

def main():
    global INFINITY
    m=None
    m=dodecahedron()
    move_mesh(m,0,0,5)
    light=None
    light=[(0.1),(0.2),(0.4)]
    render(m,light)
    destroy_mesh(m)
    light=None#(GC)
    return 0

# === User Code            END   ===
exit(main())
