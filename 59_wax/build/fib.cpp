/*****************************************
 * fib_wax                     *
 *****************************************/
/* Compiled by WAXC (Version Jul  6 2024)*/

#include <iostream>
#include <string>
#include <vector>
#include <array>
#include <map>
#include <math.h>

namespace fib_wax{
/*=== WAX Standard Library BEGIN ===*/
template <typename T>
inline void w_arr_insert (std::vector<T>* arr, int i, T x){arr->insert(arr->begin()+i,x);}
template <typename T>
inline void w_arr_remove (std::vector<T>* arr, int i, int n){arr->erase(arr->begin()+i,arr->begin()+i+n);}
template <typename T>
inline std::vector<T>* w_arr_slice (std::vector<T>* arr, int i, int n){return new std::vector<T>(arr->begin()+i,arr->begin()+i+n);}
template <typename K, typename V>
inline V w_map_get (std::map<K,V>* m, K k, V defau){typename std::map<K,V>::iterator it = m->find(k);if (it != m->end()){return it->second;}return defau;}
template <typename T, std::size_t N>
inline std::array<T,N>* w_vec_init (T v){std::array<T,N>* vec = new std::array<T,N>;vec->fill(v);return vec;}
/*=== WAX Standard Library END   ===*/

/*=== User Code            BEGIN ===*/

  inline int fib(int i){
    if((int)(i<=1)){
      return i;
    };
    return (int)(fib((int)(i-1))+fib((int)(i-2)));
  }
  inline int main(){
    int x=0;
    (x=fib(9));
    std::cout << (std::to_string(x)) << std::endl;
    return 0;
  }
/*=== User Code            END   ===*/
};
int main(){
  return fib_wax::main();
}
