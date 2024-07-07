/*****************************************
 * raycast                               *
 *****************************************/
/* Compiled by WAXC (Version Jul  6 2024)*/

/*=== WAX Standard Library BEGIN ===*/
#ifndef WAX_STD
#define WAX_STD
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include <stdint.h>
#include <math.h>
#define W_MIN(a,b) (((a)<(b))?(a):(b))
#define W_MAX(a,b) (((a)>(b))?(a):(b))
void *w_malloc(size_t size){void *mem = malloc(size);if(!mem){exit(-1);}return mem;}
void *w_realloc(void* curr_mem, size_t size){void *mem = realloc(curr_mem, size);if(!mem){exit(-1);}return mem;}
void w_free(void* x){if (x){free(x);}}
typedef struct w_arr_st {void* data;size_t len;size_t cap;size_t elem_size;} w_arr_t;
w_arr_t* w_arr_new_impl(int elem_size){w_arr_t* arr = (w_arr_t*)w_malloc(sizeof(w_arr_t));arr->elem_size = elem_size;arr->len = 0;arr->cap = 16;arr->data = w_malloc((arr->cap)*elem_size);return arr;}
w_arr_t* w_arr_new_ints(int count,...){va_list vals;w_arr_t* arr = (w_arr_t*)w_malloc(sizeof(w_arr_t));arr->elem_size = sizeof(int);arr->len = count;arr->cap = count;arr->data = w_malloc((arr->cap)*arr->elem_size);va_start(vals, count);for (int i = 0; i < count; i++) {((int*)arr->data)[i]=va_arg(vals, int);}va_end(vals);return arr;}
w_arr_t* w_arr_new_flts(int count,...){va_list vals;w_arr_t* arr = (w_arr_t*)w_malloc(sizeof(w_arr_t));arr->elem_size = sizeof(float);arr->len = count;arr->cap = count;arr->data = w_malloc((arr->cap)*arr->elem_size);va_start(vals, count);for (int i = 0; i < count; i++) {((float*)arr->data)[i]=(float)va_arg(vals, double);}va_end(vals);return arr;}
w_arr_t* w_arr_new_strs(int count,...){va_list vals;w_arr_t* arr = (w_arr_t*)w_malloc(sizeof(w_arr_t));arr->elem_size = sizeof(char*);arr->len = count;arr->cap = count;arr->data = w_malloc((arr->cap)*arr->elem_size);va_start(vals, count);for (int i = 0; i < count; i++) {((char**)arr->data)[i]=(char*)va_arg(vals, char*);}va_end(vals);return arr;}
int* w_vec_new_ints(int count,...){va_list vals;int* vec = (int*)w_malloc(sizeof(int)*count);va_start(vals, count);for (int i = 0; i < count; i++) {vec[i]=va_arg(vals, int);}va_end(vals);return vec;}
float* w_vec_new_flts(int count,...){va_list vals;float* vec = (float*)w_malloc(sizeof(float)*count);va_start(vals, count);for (int i = 0; i < count; i++) {vec[i]=(float)va_arg(vals, double);}va_end(vals);return vec;}
char** w_vec_new_strs(int count,...){va_list vals;char** vec = (char**)w_malloc(sizeof(char*)*count);va_start(vals, count);for (int i = 0; i < count; i++) {vec[i]=va_arg(vals, char*);}va_end(vals);return vec;}
#define w_arr_new(type)         (w_arr_new_impl(sizeof(type)))
#define w_arr_get(type,arr,i  ) (((type *)((arr)->data))[(i)])
#define w_arr_set(type,arr,i,x) (((type *)((arr)->data))[(i)]=(x))
void w_arr_insert_impl(w_arr_t* arr,int i) {if ((arr)->len >= (arr)->cap){(arr)->cap = (arr)->cap+W_MAX(4,(arr)->cap/2);(arr)->data = w_realloc((arr)->data, (arr)->elem_size*((arr)->cap));}if ((i) < (arr)->len){memmove((char*)((arr)->data)+((i)+1)*(arr)->elem_size,(char*)((arr)->data)+(i)*(arr)->elem_size,((arr)->len-(i))*(arr)->elem_size );}(arr)->len++;}
#define w_arr_insert(type,arr,i,x) { type tmp__x_ = x; int tmp__i_ = i; w_arr_t* tmp__a_ = arr; w_arr_insert_impl((tmp__a_),(tmp__i_)); (((type *)((tmp__a_)->data))[(tmp__i_)]=(tmp__x_)); }
void w_arr_remove(w_arr_t* arr,int i,int n) {memmove((char*)((arr)->data)+(i)*(arr)->elem_size,(char*)((arr)->data)+((i)+(n))*(arr)->elem_size,((arr->len)-(i)-(n))*(arr)->elem_size );(arr)->len-=(n);}
w_arr_t* w_arr_slice(w_arr_t*arr,int i,int n) {w_arr_t* brr = (w_arr_t*)w_malloc(sizeof(w_arr_t));brr->elem_size = (arr)->elem_size;brr->len = n;brr->cap = n;brr->data = w_malloc((brr->cap)*(brr->elem_size));memcpy((char*)(brr->data), (char*)((arr)->data) + (i), (n)*((arr)->elem_size));return brr;}
#define W_NUM_MAP_SLOTS 64
typedef struct w_slot_st {int keylen;void* key;int64_t data;struct w_slot_st* next;} w_slot_t;
typedef struct w_map_st {int key_is_ptr;size_t len;w_slot_t* slots[W_NUM_MAP_SLOTS];} w_map_t;
w_map_t* w_map_new(char key_is_ptr){w_map_t* map = (w_map_t*)w_malloc(sizeof(w_map_t));map->key_is_ptr = key_is_ptr;for (int i = 0; i < W_NUM_MAP_SLOTS; i++){map->slots[i] = NULL;}map->len = 0;return map;}
int w_map_hash(void* ptr, size_t len){int x = 0;for (size_t i = 0; i < len; i++){unsigned char y = *((unsigned char*)((unsigned char*)ptr+i));x ^= y;}x %= W_NUM_MAP_SLOTS;return x;}
void w_map_set(w_map_t* map, int64_t key, int64_t data){int keylen;void* keyptr;if (map->key_is_ptr){keylen = strlen((char*)key);keyptr = (char*)key;}else{keylen = sizeof(key);keyptr = &key;}int k = w_map_hash(keyptr,keylen);w_slot_t* it = map->slots[k];while (it){if (keylen == it->keylen){if (memcmp(it->key,keyptr,keylen)==0){it->data = data;return;}}it = it -> next;}w_slot_t* nxt = map->slots[k];w_slot_t* slot = (w_slot_t*)w_malloc(sizeof(w_slot_t));slot->key = w_malloc(keylen);memcpy(slot->key,keyptr,keylen);slot->data=data;slot->next = nxt;slot->keylen = keylen;map->slots[k] = slot;map->len++;}
int64_t w_map_get(w_map_t* map, int64_t key){int keylen;void* keyptr;if (map->key_is_ptr){keylen = strlen((char*)key);keyptr = (char*)key;}else{keylen = sizeof(key);keyptr = &key;}int k = w_map_hash(keyptr,keylen);w_slot_t* it = map->slots[k];while (it){if (keylen == it->keylen){if (memcmp(it->key,keyptr,keylen)==0){return it->data;}}it = it -> next;}return 0;}
void w_map_remove(w_map_t* map, int64_t key){size_t keylen;void* keyptr;if (map->key_is_ptr){keylen = strlen((char*)key);keyptr = (char*)key;}else{keylen = sizeof(key);keyptr = &key;}int k = w_map_hash(keyptr,keylen);w_slot_t* it = map->slots[k];w_slot_t* prev = NULL;while (it){if (keylen == it->keylen){if (memcmp(it->key,keyptr,keylen)==0){if (prev){prev->next = it->next;}else{map->slots[k] = it->next;}map->len--;w_free(it->key);w_free(it);return;}}prev = it;it = it -> next;}return;}
int w_reinterp_f2i(float x){return *((int *)&x);}
float w_reinterp_i2f(int x){return *((float *)&x);}
typedef struct {char data[32];} w_shortstr_t;
w_shortstr_t w_int2str(int x){w_shortstr_t str;sprintf(str.data, "%d", x);return str;}
w_shortstr_t w_flt2str(float x){w_shortstr_t str;sprintf(str.data, "%g", x);return str;}
char* w_str_new(char* x){size_t l = strlen(x);char* str = (char*)w_malloc(l);strncpy(str,x,l);str[l] = 0;return str;}
char* w_str_cat(char* x, char* y){size_t l0 = strlen(x);size_t l1 = strlen(y);x = (char*)w_realloc(x,l0+l1+1);memcpy(x+l0,y,l1);x[l0+l1] = 0;return x;}
char* w_str_add(char* x, int y){char c = (char)y;size_t l = strlen(x);x = (char*)w_realloc(x,l+2);x[l] = c;x[l+1]=0;return x;}
char* w_str_cpy(char* x, int i, int l){char* y = (char*)w_malloc(l+1);memcpy(y,x+i,l);y[l] = 0;return y;}
void w_free_arr(w_arr_t* x){if (x){w_free(x->data);w_free(x);}}
void w_free_map(w_map_t* map){if (!map){return;}for (int i = 0; i < W_NUM_MAP_SLOTS; i++){w_slot_t* it = map->slots[i];while (it){w_slot_t* nxt = it->next;w_free(it->key);w_free(it);it = nxt;}}w_free(map);}
#endif
/*=== WAX Standard Library END   ===*/

/*=== User Code            BEGIN ===*/

#define random() ((float)rand()/RAND_MAX)
struct ray{
  float* o;
  float* d;
  float tmin;
  float tmax;
};
struct mesh{
  w_arr_t* vertices;
  w_arr_t* faces;
  w_arr_t* facenorms;
};
float* v_sub(float* u,float* v){
  return w_vec_new_flts(3,((((u)[0])-((v)[0]))),((((u)[1])-((v)[1]))),((((u)[2])-((v)[2]))));
}
float* v_cross(float* u,float* v){
  return w_vec_new_flts(3,(((((u)[1])*((v)[2]))-(((u)[2])*((v)[1])))),(((((u)[2])*((v)[0]))-(((u)[0])*((v)[2])))),(((((u)[0])*((v)[1]))-(((u)[1])*((v)[0])))));
}
float v_dot(float* u,float* v){
  return (((((u)[0])*((v)[0]))+(((u)[1])*((v)[1])))+(((u)[2])*((v)[2])));
}
float* v_scale(float* u,float x){
  return w_vec_new_flts(3,((((u)[0])*x)),((((u)[1])*x)),((((u)[2])*x)));
}
float v_mag(float* v){
  return sqrt((((((v)[0])*((v)[0]))+(((v)[1])*((v)[1])))+(((v)[2])*((v)[2]))));
}
void normalize(float* v){
  float l=0;
  (l=v_mag(v));
  ((v)[0])=(((v)[0])/l);
  ((v)[1])=(((v)[1])/l);
  ((v)[2])=(((v)[2])/l);
}
float det(float* a,float* b,float* c){
  float* d=0;
  (d=v_cross(a,b));
  float e=0;
  (e=v_dot(d,c));
  w_free(d);
  return e;
}
struct ray* new_ray(float ox,float oy,float oz,float dx,float dy,float dz){
  struct ray* r=0;
  (r=(struct ray*)calloc(sizeof(struct ray),1));
  float* o=0;
  (o=w_vec_new_flts(3,(ox),(oy),(oz)));
  float* d=0;
  (d=w_vec_new_flts(3,(dx),(dy),(dz)));
  normalize(d);
  r->o=o;
  r->d=d;
  r->tmin=0.0;
  r->tmax=INFINITY;
  return r;
}
void destroy_ray(struct ray* r){
  w_free(r->o);
  w_free(r->d);
  w_free(r);
}
float ray_tri(struct ray* r,float* p0,float* p1,float* p2){
  float* e1=0;
  (e1=v_sub(p1,p0));
  float* e2=0;
  (e2=v_sub(p2,p0));
  float* s=0;
  (s=v_sub(r->o,p0));
  float* _d=0;
  (_d=v_scale(r->d,((float)-1)));
  float denom=0;
  (denom=det(e1,e2,_d));
  if((!!(denom==((float)0)))){
    w_free(e1);
    w_free(e2);
    w_free(s);
    w_free(_d);
    return INFINITY;
  };
  float u=0;
  (u=(det(s,e2,_d)/denom));
  float v=0;
  (v=(det(e1,s,_d)/denom));
  float t=0;
  (t=(det(e1,e2,s)/denom));
  if((((((u<((float)0))||(v<((float)0)))||((((float)1)-(u+v))<((float)0)))||(t<r->tmin))||(t>r->tmax))){
    w_free(e1);
    w_free(e2);
    w_free(s);
    w_free(_d);
    return INFINITY;
  };
  r->tmax=t;
  w_free(e1);
  w_free(e2);
  w_free(s);
  w_free(_d);
  return t;
}
float ray_mesh(struct ray* r,struct mesh* m,float* l){
  float dstmin=0;
  (dstmin=INFINITY);
  int argmin=0;
  (argmin=-1);
  for(int i=0;(i<(m->faces->len));i+=1){
    float* a=0;
    (a=((float*)w_arr_get(float*,m->vertices,((((int*)w_arr_get(int*,m->faces,i)))[0]))));
    float* b=0;
    (b=((float*)w_arr_get(float*,m->vertices,((((int*)w_arr_get(int*,m->faces,i)))[1]))));
    float* c=0;
    (c=((float*)w_arr_get(float*,m->vertices,((((int*)w_arr_get(int*,m->faces,i)))[2]))));
    float t=0;
    (t=ray_tri(r,a,b,c));
    if((t<dstmin)){
      (dstmin=t);
      (argmin=i);
    };
  };
  if(((argmin<-1)||(!!(dstmin==INFINITY)))){
    return 0.0;
  };
  float* n=0;
  (n=((float*)w_arr_get(float*,m->facenorms,argmin)));
  float ndotl=0;
  (ndotl=v_dot(n,l));
  return (fmax(ndotl,((float)0))+0.1);
}
void add_vert(struct mesh* m,float x,float y,float z){
  w_arr_insert(float*,m->vertices,(m->vertices->len),w_vec_new_flts(3,(x),(y),(z)));
}
void add_face(struct mesh* m,int a,int b,int c){
  w_arr_insert(int*,m->faces,(m->faces->len),w_vec_new_ints(3,((a-1)),((c-1)),((b-1))));
}
void calc_facenorms(struct mesh* m){
  for(int i=0;(i<(m->faces->len));i+=1){
    float* a=0;
    (a=((float*)w_arr_get(float*,m->vertices,((((int*)w_arr_get(int*,m->faces,i)))[0]))));
    float* b=0;
    (b=((float*)w_arr_get(float*,m->vertices,((((int*)w_arr_get(int*,m->faces,i)))[1]))));
    float* c=0;
    (c=((float*)w_arr_get(float*,m->vertices,((((int*)w_arr_get(int*,m->faces,i)))[2]))));
    float* e1=0;
    (e1=v_sub(a,b));
    float* e2=0;
    (e2=v_sub(b,c));
    float* n=0;
    (n=v_cross(e1,e2));
    normalize(n);
    w_arr_insert(float*,m->facenorms,(m->facenorms->len),n);
    w_free(e1);
    w_free(e2);
  };
}
void move_mesh(struct mesh* m,float x,float y,float z){
  for(int i=0;(i<(m->vertices->len));i+=1){
    ((((float*)w_arr_get(float*,m->vertices,i)))[0])=(((((float*)w_arr_get(float*,m->vertices,i)))[0])+x);
    ((((float*)w_arr_get(float*,m->vertices,i)))[1])=(((((float*)w_arr_get(float*,m->vertices,i)))[1])+y);
    ((((float*)w_arr_get(float*,m->vertices,i)))[2])=(((((float*)w_arr_get(float*,m->vertices,i)))[2])+z);
  };
}
void destroy_mesh(struct mesh* m){
  for(int i=0;(i<(m->vertices->len));i+=1){
    w_free(((float*)w_arr_get(float*,m->vertices,i)));
  };
  w_free_arr(m->vertices);
  for(int i=0;(i<(m->faces->len));i+=1){
    w_free(((int*)w_arr_get(int*,m->faces,i)));
  };
  w_free_arr(m->faces);
  for(int i=0;(i<(m->facenorms->len));i+=1){
    w_free(((float*)w_arr_get(float*,m->facenorms,i)));
  };
  w_free_arr(m->facenorms);
  w_free(m);
}
void render(struct mesh* m,float* light){
  float* pix=0;
  (pix=(float*)calloc(sizeof(float),3840));
  normalize(light);
  char* palette=0;
  (palette="`.-,_:^!~;r+|()=>l?icv[]tzj7*f{}sYTJ1unyIFowe2h3Za4X%5P$mGAUbpK960#H&DRQ80WMB@N");
  float lo=0;
  (lo=INFINITY);
  float hi=0;
  (hi=((float)0));
  for(int y=0;(y<40);y+=1){
    for(int x=0;(x<80);x+=1){
      float fx=0;
      (fx=((((float)x)-(((float)80)/2.0))/2.0));
      float fy=0;
      (fy=(((float)y)-(((float)40)/2.0)));
      struct ray* r=0;
      (r=new_ray(((float)0),((float)0),((float)0),fx,fy,((float)100)));
      float gray=0;
      (gray=ray_mesh(r,m,light));
      (hi=fmax(gray,hi));
      if((gray>((float)0))){
        (lo=fmin(gray,lo));
      };
      ((pix)[((y*80)+x)])=gray;
      destroy_ray(r);
    };
  };
  char* s=0;
  (s=w_str_new(""));
  for(int y=0;(y<40);y+=1){
    for(int x=0;(x<80);x+=1){
      float gray=0;
      (gray=((pix)[((y*80)+x)]));
      if((gray!=((float)0))){
        (gray=((gray-lo)/(hi-lo)));
        int ch=0;
        (ch=(palette)[((int)(gray*((float)78)))]);
        (s=w_str_add(s,ch));
      }else{
        (s=w_str_add(s,' '));
      };
    };
    (s=w_str_cat(s,"\n"));
  };
  puts(s);
  w_free(pix);
  w_free(s);
}
struct mesh* dodecahedron(){
  struct mesh* m=0;
  (m=(struct mesh*)calloc(sizeof(struct mesh),1));
  m->vertices=w_arr_new(float*);
  m->faces=w_arr_new(int*);
  m->facenorms=w_arr_new(float*);
  add_vert(m,-0.436466,-0.668835,0.601794);
  add_vert(m,0.918378,0.351401,-0.181931);
  add_vert(m,0.886304,-0.351401,-0.301632);
  add_vert(m,-0.886304,0.351401,0.301632);
  add_vert(m,-0.918378,-0.351401,0.181931);
  add_vert(m,0.132934,0.858018,0.496117);
  add_vert(m,-0.048964,0.981941,-0.182738);
  add_vert(m,0.106555,0.162217,-0.980985);
  add_vert(m,-0.582772,0.162217,-0.796280);
  add_vert(m,-0.132934,-0.858018,-0.496117);
  add_vert(m,0.048964,-0.981941,0.182738);
  add_vert(m,0.582772,-0.162217,0.796280);
  add_vert(m,-0.106555,-0.162217,0.980985);
  add_vert(m,0.436466,0.668835,-0.601794);
  add_vert(m,0.730785,0.468323,0.496615);
  add_vert(m,-0.678888,0.668835,-0.302936);
  add_vert(m,-0.384570,0.468323,0.795474);
  add_vert(m,0.384570,-0.468323,-0.795474);
  add_vert(m,0.678888,-0.668835,0.302936);
  add_vert(m,-0.730785,-0.468323,-0.496615);
  add_face(m,19,3,2);
  add_face(m,12,19,2);
  add_face(m,15,12,2);
  add_face(m,8,14,2);
  add_face(m,18,8,2);
  add_face(m,3,18,2);
  add_face(m,20,5,4);
  add_face(m,9,20,4);
  add_face(m,16,9,4);
  add_face(m,13,17,4);
  add_face(m,1,13,4);
  add_face(m,5,1,4);
  add_face(m,7,16,4);
  add_face(m,6,7,4);
  add_face(m,17,6,4);
  add_face(m,6,15,2);
  add_face(m,7,6,2);
  add_face(m,14,7,2);
  add_face(m,10,18,3);
  add_face(m,11,10,3);
  add_face(m,19,11,3);
  add_face(m,11,1,5);
  add_face(m,10,11,5);
  add_face(m,20,10,5);
  add_face(m,20,9,8);
  add_face(m,10,20,8);
  add_face(m,18,10,8);
  add_face(m,9,16,7);
  add_face(m,8,9,7);
  add_face(m,14,8,7);
  add_face(m,12,15,6);
  add_face(m,13,12,6);
  add_face(m,17,13,6);
  add_face(m,13,1,11);
  add_face(m,12,13,11);
  add_face(m,19,12,11);
  calc_facenorms(m);
  return m;
}
int main(){
  struct mesh* m=0;
  (m=dodecahedron());
  move_mesh(m,((float)0),((float)0),((float)5));
  float* light=0;
  (light=w_vec_new_flts(3,(0.1),(0.2),(0.4)));
  render(m,light);
  destroy_mesh(m);
  w_free(light);
  return 0;
}
/*=== User Code            END   ===*/
