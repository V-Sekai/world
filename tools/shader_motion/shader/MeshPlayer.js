export default {
  vs: `#version 300 es
#ifdef GL_ARB_texture_query_levels
#extension GL_ARB_texture_query_levels : enable
#endif
#ifdef GL_ARB_shader_image_size
#extension GL_ARB_shader_image_size : enable
#endif

vec4 ImmCB_0_0_0[4];
uniform     mat4 unity_ObjectToWorld;
uniform     mat4 unity_MatrixVP;
uniform     float _ApplyScale;
uniform     float _RotationTolerance;
uniform     float _Layer;
uniform highp sampler2D _MotionDec;
uniform highp sampler2D _Bone;
uniform highp sampler2D _Shape;
in highp vec3 in_POSITION0;
in highp vec3 in_NORMAL0;
in highp vec4 in_TEXCOORD0;
in highp vec4 in_TEXCOORD1;
out mediump vec2 vs_TEXCOORD0;
out highp vec3 vs_TEXCOORD1;
out mediump vec3 vs_TEXCOORD2;
vec3 u_xlat0;
int u_xlati0;
uint u_xlatu0;
vec3 u_xlat1;
uvec2 u_xlatu1;
bool u_xlatb1;
vec4 u_xlat2;
uvec4 u_xlatu2;
vec4 u_xlat3;
uint u_xlatu3;
vec4 u_xlat4;
uvec2 u_xlatu4;
vec4 u_xlat5;
uvec4 u_xlatu5;
vec3 u_xlat6;
vec3 u_xlat7;
vec3 u_xlat8;
vec3 u_xlat9;
vec3 u_xlat10;
vec4 u_xlat11;
uvec3 u_xlatu11;
vec4 u_xlat12;
uvec3 u_xlatu12;
vec4 u_xlat13;
vec4 u_xlat14;
uvec3 u_xlatu14;
vec4 u_xlat15;
uvec3 u_xlatu15;
vec4 u_xlat16;
vec4 u_xlat17;
vec2 u_xlat18;
uint u_xlatu18;
vec3 u_xlat19;
float u_xlat20;
uint u_xlatu20;
bool u_xlatb20;
float u_xlat21;
int u_xlati21;
uint u_xlatu21;
bool u_xlatb21;
float u_xlat22;
vec3 u_xlat32;
vec2 u_xlat36;
uvec2 u_xlatu36;
vec2 u_xlat39;
uvec2 u_xlatu39;
bool u_xlatb39;
float u_xlat54;
uint u_xlatu58;
float u_xlat59;
uint u_xlatu59;
bool u_xlatb59;
float u_xlat60;
bool u_xlatb61;
float u_xlat62;
vec4 TempArray0[1];
vec4 TempArray1[4];
void main()
{
    ImmCB_0_0_0[0] = vec4(1.0, 0.0, 0.0, 0.0);
    ImmCB_0_0_0[1] = vec4(0.0, 1.0, 0.0, 0.0);
    ImmCB_0_0_0[2] = vec4(0.0, 0.0, 1.0, 0.0);
    ImmCB_0_0_0[3] = vec4(0.0, 0.0, 0.0, 1.0);
    u_xlatu0 = uint(_Layer);
    u_xlatu18 = uint(u_xlatu0 >> 1u);
    u_xlat18.x = float(u_xlatu18);
    u_xlat1.y = u_xlat18.x * 0.075000003;
    u_xlati0 = int(uint(u_xlatu0 & 1u));
    u_xlat1.x = 1.0;
    u_xlat18.xy = (-u_xlat1.xy) + vec2(0.0, 1.0);
    u_xlat0.xy = (int(u_xlati0) != 0) ? u_xlat18.xy : u_xlat1.xy;
    u_xlatu36.x = (uvec2(textureSize(_Shape, 0)).x);
    u_xlatu36.y = (uvec2(textureSize(_Shape, 0)).y);
    u_xlat1.xy = roundEven(in_TEXCOORD0.zw);
    u_xlatu1.xy = uvec2(u_xlat1.xy);
    u_xlatu2.x = u_xlatu1.y / u_xlatu36.x;
    u_xlatu3 = u_xlatu1.y % u_xlatu36.x;
    u_xlat36.xy = vec2(u_xlatu36.xy);
    u_xlatu2.y = u_xlatu2.x;
    u_xlatu2.z = uint(uint(0u));
    u_xlatu2.w = uint(uint(0u));
    u_xlat19.xyz = in_POSITION0.xyz;
    for(uint u_xlatu_loop_1 = uint(0u) ; u_xlatu_loop_1<16u ; u_xlatu_loop_1++)
    {
        u_xlatb39 = u_xlatu_loop_1>=u_xlatu1.x;
        if(u_xlatb39){
            break;
        //ENDIF
        }
        u_xlatu2.x = u_xlatu_loop_1 * 3u + u_xlatu3;
        u_xlat39.x = texelFetch(_Shape, ivec2(u_xlatu2.xy), int(u_xlatu2.w)).w;
        u_xlatu39.x = uint(u_xlat39.x);
        u_xlatu39.xy = u_xlatu39.xx + uvec2(uint(0u), 1u);
        u_xlatu4.xy = u_xlatu39.xy / uvec2(45u, 45u);
        u_xlatu5.xy = u_xlatu39.xy % uvec2(45u, 45u);
        u_xlat39.xy = vec2(u_xlatu4.xy);
        u_xlat39.xy = u_xlat39.xy * vec2(0.0250000004, 0.0250000004) + vec2(0.0125000002, 0.0125000002);
        u_xlat4.xy = u_xlat39.xy * u_xlat0.xx + u_xlat0.yy;
        u_xlat39.xy = vec2(u_xlatu5.xy);
        u_xlat4.zw = u_xlat39.xy * vec2(-0.0222222228, -0.0222222228) + vec2(0.98888886, 0.98888886);
        u_xlat5 = textureLod(_MotionDec, u_xlat4.xz, 0.0);
        u_xlat39.x = dot(u_xlat5, vec4(3.984375, 0.0155639648, 6.07967377e-05, 2.37487257e-07));
        u_xlat5.x = u_xlat39.x + -1.0;
        u_xlat4 = textureLod(_MotionDec, u_xlat4.yw, 0.0);
        u_xlat39.x = dot(u_xlat4, vec4(3.984375, 0.0155639648, 6.07967377e-05, 2.37487257e-07));
        u_xlat5.y = u_xlat39.x + -1.0;
        u_xlat39.xy = vec2(u_xlatu2.xy);
        u_xlat39.xy = u_xlat5.xy + u_xlat39.xy;
        u_xlat39.xy = u_xlat39.xy + vec2(0.5, 0.5);
        u_xlat39.xy = u_xlat39.xy / u_xlat36.xy;
        u_xlat4.xyz = textureLod(_Shape, u_xlat39.xy, 0.0).xyz;
        u_xlat19.xyz = u_xlat19.xyz + u_xlat4.xyz;
    }
    u_xlat36.x = _RotationTolerance * _RotationTolerance;
    u_xlat54 = sqrt((-unity_ObjectToWorld[3].w));
    u_xlatb1 = vec4(0.0, 0.0, 0.0, 0.0)!=vec4(_ApplyScale);
    u_xlatu2.z = uint(uint(0u));
    u_xlatu2.w = uint(uint(0u));
    u_xlat3.w = 0.0;
    u_xlat4.z = 0.0;
    u_xlat5.y = 0.0;
    u_xlat6.z = 0.0;
    u_xlat7.x = float(0.0);
    u_xlat7.y = float(0.0);
    u_xlat7.z = float(0.0);
    u_xlat8.x = float(0.0);
    u_xlat8.y = float(0.0);
    u_xlat8.z = float(0.0);
    for(uint u_xlatu_loop_2 = uint(0u) ; u_xlatu_loop_2<4u ; u_xlatu_loop_2++)
    {
        u_xlat59 = dot(in_TEXCOORD1, ImmCB_0_0_0[int(u_xlatu_loop_2)]);
        u_xlat59 = u_xlat59 + 0.25;
        u_xlat60 = fract(u_xlat59);
        u_xlat60 = u_xlat60 * 2.0 + -0.5;
        u_xlatb61 = u_xlat60<9.99999975e-05;
        if(u_xlatb61){
            break;
        //ENDIF
        }
        u_xlat59 = floor(u_xlat59);
        u_xlatu2.y = uint(u_xlat59);
        u_xlat9.xyz = u_xlat19.xyz;
        u_xlat10.xyz = in_NORMAL0.xyz;
        u_xlatu2.x = uint(0u);
        for( ; u_xlatu2.x<64u ; u_xlatu2.x = u_xlatu2.x + 4u)
        {
            u_xlat11 = texelFetch(_Bone, ivec2(u_xlatu2.xy), int(u_xlatu2.w));
            u_xlat12 = texelFetchOffset(_Bone, ivec2(u_xlatu2.xy), int(u_xlatu2.w), ivec2(1, 0));
            u_xlat13 = texelFetchOffset(_Bone, ivec2(u_xlatu2.xy), int(u_xlatu2.w), ivec2(2, 0)).xywz;
            u_xlat14 = texelFetchOffset(_Bone, ivec2(u_xlatu2.xy), int(u_xlatu2.w), ivec2(3, 0)).xwyz;
            u_xlat15.xyz = u_xlat9.yyy * u_xlat12.xyz;
            u_xlat15.xyz = u_xlat11.xyz * u_xlat9.xxx + u_xlat15.xyz;
            u_xlat15.xyz = u_xlat13.xyw * u_xlat9.zzz + u_xlat15.xyz;
            u_xlat12.xyz = u_xlat10.yyy * u_xlat12.xyz;
            u_xlat11.xyz = u_xlat11.xyz * u_xlat10.xxx + u_xlat12.xyz;
            u_xlat11.xyz = u_xlat13.xyw * u_xlat10.zzz + u_xlat11.xyz;
            u_xlat12.xyz = u_xlat14.xzw + u_xlat15.xyz;
            u_xlatb59 = u_xlat14.y<0.0;
            if(u_xlatb59){
                u_xlat14.x = u_xlat13.z;
                TempArray0[0].zw = u_xlat14.xy;
                u_xlat9.xyz = u_xlat12.xyz;
                u_xlat10.xyz = u_xlat11.xyz;
                break;
            //ENDIF
            }
            u_xlat13.x = u_xlat11.w;
            u_xlat13.y = u_xlat12.w;
            u_xlat13.xyz = u_xlat13.xyz * vec3(3.14159274, 3.14159274, 3.14159274);
            u_xlatu59 = uint(u_xlat14.y);
            u_xlatu14.xyz = uvec3(u_xlatu59) + uvec3(uint(0u), 1u, 2u);
            u_xlatu15.xyz = u_xlatu14.xyz % uvec3(45u, 45u, 45u);
            u_xlatu14.xyz = u_xlatu14.xyz / uvec3(45u, 45u, 45u);
            u_xlat14.xyz = vec3(u_xlatu14.xyz);
            u_xlat14.xyz = u_xlat14.xyz * vec3(0.0250000004, 0.0250000004, 0.0250000004) + vec3(0.0125000002, 0.0125000002, 0.0125000002);
            u_xlat14.xyz = u_xlat14.xyz * u_xlat0.xxx + u_xlat0.yyy;
            u_xlat15.xyz = vec3(u_xlatu15.xyz);
            u_xlat15.xyz = u_xlat15.xzy * vec3(-0.0222222228, -0.0222222228, -0.0222222228) + vec3(0.98888886, 0.98888886, 0.98888886);
            u_xlat14.w = u_xlat15.x;
            u_xlat16 = textureLod(_MotionDec, u_xlat14.xw, 0.0);
            u_xlat59 = dot(u_xlat16, vec4(3.984375, 0.0155639648, 6.07967377e-05, 2.37487257e-07));
            u_xlat16.x = u_xlat59 + -1.0;
            u_xlat15.xw = u_xlat14.zy;
            u_xlat17 = textureLod(_MotionDec, u_xlat15.wz, 0.0);
            u_xlat59 = dot(u_xlat17, vec4(3.984375, 0.0155639648, 6.07967377e-05, 2.37487257e-07));
            u_xlat16.y = u_xlat59 + -1.0;
            u_xlat14 = textureLod(_MotionDec, u_xlat15.xy, 0.0);
            u_xlat59 = dot(u_xlat14, vec4(3.984375, 0.0155639648, 6.07967377e-05, 2.37487257e-07));
            u_xlat16.z = u_xlat59 + -1.0;
            u_xlat3.xyz = u_xlat13.xyz * u_xlat16.xyz;
            u_xlat6.x = cos(u_xlat3.x);
            u_xlat3.x = sin(u_xlat3.x);
            u_xlat59 = dot(u_xlat3.yz, u_xlat3.yz);
            u_xlat59 = sqrt(u_xlat59);
            u_xlat13.x = sin(u_xlat59);
            u_xlat14.x = cos(u_xlat59);
            u_xlatb61 = 9.99999975e-06<u_xlat59;
            u_xlat62 = u_xlat13.x / u_xlat59;
            u_xlat62 = (u_xlatb61) ? u_xlat62 : 1.0;
            u_xlat13.xyz = u_xlat3.zwy * vec3(u_xlat62);
            u_xlat62 = (-u_xlat14.x) + 1.0;
            u_xlat62 = sqrt(u_xlat62);
            u_xlat59 = u_xlat62 / u_xlat59;
            u_xlat59 = (u_xlatb61) ? u_xlat59 : 0.707106769;
            u_xlat32.xyz = u_xlat3.wyz * vec3(u_xlat59);
            u_xlat4.xy = u_xlat13.zx * vec2(0.0, 1.0);
            u_xlat5.xz = u_xlat13.xz * vec2(0.0, 1.0);
            u_xlat5.xzw = u_xlat4.xyz + (-u_xlat5.xyz);
            u_xlat5.xzw = u_xlat14.xxx * vec3(1.0, 0.0, 0.0) + u_xlat5.xzw;
            u_xlat6.y = u_xlat3.x;
            u_xlat3.x = dot(u_xlat32.yz, u_xlat6.xy);
            u_xlat15.xyz = u_xlat6.xyz * u_xlat13.xyz;
            u_xlat13.xyz = u_xlat13.zxy * u_xlat6.yzx + (-u_xlat15.xyz);
            u_xlat3.xyz = u_xlat3.xxx * u_xlat32.xyz + u_xlat13.xyz;
            u_xlat3.xyz = u_xlat14.xxx * u_xlat6.zxy + u_xlat3.xyz;
            u_xlat13.xyz = u_xlat3.yzx * u_xlat5.wxz;
            u_xlat13.xyz = u_xlat5.zwx * u_xlat3.zxy + (-u_xlat13.xyz);
            u_xlat14.xyz = u_xlat12.yyy * u_xlat3.xyz;
            u_xlat12.xyw = u_xlat5.xzw * u_xlat12.xxx + u_xlat14.xyz;
            u_xlat9.xyz = u_xlat13.xyz * u_xlat12.zzz + u_xlat12.xyw;
            u_xlat3.xyz = u_xlat11.yyy * u_xlat3.xyz;
            u_xlat3.xyz = u_xlat5.xzw * u_xlat11.xxx + u_xlat3.xyz;
            u_xlat10.xyz = u_xlat13.xyz * u_xlat11.zzz + u_xlat3.xyz;
        }
        u_xlat2.xy = TempArray0[0].zw;
        u_xlat20 = (-u_xlat2.y) + -1.0;
        u_xlatu20 = uint(u_xlat20);
        for(uint u_xlatu_loop_3 = uint(0u) ; u_xlatu_loop_3<4u ; u_xlatu_loop_3++)
        {
            u_xlati21 = 3 * int(u_xlatu_loop_3) + int(u_xlatu20);
            u_xlatu5.xzw = uvec3(u_xlati21) + uvec3(uint(0u), 1u, 2u);
            u_xlatu11.xyz = u_xlatu5.xzw / uvec3(45u, 45u, 45u);
            u_xlatu12.xyz = u_xlatu5.xzw % uvec3(45u, 45u, 45u);
            u_xlat5.xzw = vec3(u_xlatu11.xyz);
            u_xlat5.xzw = u_xlat5.xzw * vec3(0.0250000004, 0.0250000004, 0.0250000004) + vec3(0.0125000002, 0.0125000002, 0.0125000002);
            u_xlat11.xyz = u_xlat5.xzw * u_xlat0.xxx + u_xlat0.yyy;
            u_xlat5.xzw = vec3(u_xlatu12.xyz);
            u_xlat12.xyz = u_xlat5.xwz * vec3(-0.0222222228, -0.0222222228, -0.0222222228) + vec3(0.98888886, 0.98888886, 0.98888886);
            u_xlat11.w = u_xlat12.x;
            u_xlat13 = textureLod(_MotionDec, u_xlat11.xw, 0.0);
            u_xlat21 = dot(u_xlat13, vec4(3.984375, 0.0155639648, 6.07967377e-05, 2.37487257e-07));
            u_xlat13.x = u_xlat21 + -1.0;
            u_xlat12.xw = u_xlat11.zy;
            u_xlat14 = textureLod(_MotionDec, u_xlat12.wz, 0.0);
            u_xlat21 = dot(u_xlat14, vec4(3.984375, 0.0155639648, 6.07967377e-05, 2.37487257e-07));
            u_xlat13.y = u_xlat21 + -1.0;
            u_xlat11 = textureLod(_MotionDec, u_xlat12.xy, 0.0);
            u_xlat21 = dot(u_xlat11, vec4(3.984375, 0.0155639648, 6.07967377e-05, 2.37487257e-07));
            u_xlat13.z = u_xlat21 + -1.0;
            TempArray1[int(u_xlatu_loop_3)].xyz = u_xlat13.xyz;
        }
        u_xlat3.xyz = TempArray1[1].xyz;
        u_xlat3.xyz = u_xlat3.xyz + u_xlat3.xyz;
        u_xlat5.xzw = TempArray1[2].xyz;
        u_xlat11.xyz = TempArray1[3].xyz;
        u_xlat20 = dot(u_xlat5.xzw, u_xlat11.xyz);
        u_xlat20 = u_xlat20 * -2.0;
        u_xlat4.x = dot(u_xlat5.xzw, u_xlat5.xzw);
        u_xlat22 = dot(u_xlat11.xyz, u_xlat11.xyz);
        u_xlat4.x = u_xlat22 + u_xlat4.x;
        u_xlat22 = u_xlat20 * u_xlat20;
        u_xlat22 = u_xlat4.x * u_xlat4.x + (-u_xlat22);
        u_xlat22 = sqrt(abs(u_xlat22));
        u_xlat4.x = u_xlat22 + u_xlat4.x;
        u_xlat12.xyz = u_xlat11.xyz * vec3(u_xlat20);
        u_xlat12.xyz = u_xlat4.xxx * u_xlat5.xzw + u_xlat12.xyz;
        u_xlat22 = dot(u_xlat5.xzw, u_xlat12.xyz);
        u_xlat6.x = dot(u_xlat12.xyz, u_xlat12.xyz);
        u_xlat22 = u_xlat22 / u_xlat6.x;
        u_xlat13.xyz = vec3(u_xlat22) * u_xlat12.xyz;
        u_xlat14.xyz = u_xlat5.xzw * vec3(u_xlat20);
        u_xlat14.xyz = u_xlat4.xxx * u_xlat11.xyz + u_xlat14.xyz;
        u_xlat20 = dot(u_xlat11.xyz, u_xlat14.xyz);
        u_xlat4.x = dot(u_xlat14.xyz, u_xlat14.xyz);
        u_xlat20 = u_xlat20 / u_xlat4.x;
        u_xlat15.xyz = vec3(u_xlat20) * u_xlat14.xyz;
        u_xlat5.xzw = (-u_xlat12.xyz) * vec3(u_xlat22) + u_xlat5.xzw;
        u_xlat4.x = dot(u_xlat5.xzw, u_xlat5.xzw);
        u_xlat5.xzw = (-u_xlat14.xyz) * vec3(u_xlat20) + u_xlat11.xyz;
        u_xlat20 = dot(u_xlat5.xzw, u_xlat5.xzw);
        u_xlat20 = u_xlat20 + u_xlat4.x;
        u_xlat4.x = dot(u_xlat13.xyz, u_xlat13.xyz);
        u_xlat4.x = sqrt(u_xlat4.x);
        u_xlat22 = dot(u_xlat15.xyz, u_xlat15.xyz);
        u_xlat5.x = sqrt(u_xlat22);
        u_xlat4.x = max(u_xlat4.x, u_xlat5.x);
        u_xlat4.x = u_xlat4.x + -1.0;
        u_xlat20 = u_xlat4.x * u_xlat4.x + u_xlat20;
        u_xlatb20 = u_xlat36.x<u_xlat20;
        u_xlat5.xzw = (bool(u_xlatb20)) ? vec3(u_xlat54) : u_xlat9.xyz;
        u_xlat20 = inversesqrt(u_xlat22);
        u_xlat2.x = u_xlat2.x * u_xlat20;
        u_xlat11.xyz = u_xlat2.xxx * u_xlat13.xyz;
        u_xlat2.x = dot(u_xlat11.xyz, u_xlat11.xyz);
        u_xlat2.x = inversesqrt(u_xlat2.x);
        u_xlat12.xyz = u_xlat2.xxx * u_xlat3.xyz;
        u_xlat13.xyz = u_xlat2.xxx * u_xlat11.xyz;
        u_xlat3.xyz = (bool(u_xlatb1)) ? u_xlat3.xyz : u_xlat12.xyz;
        u_xlat11.xyz = (bool(u_xlatb1)) ? u_xlat11.xyz : u_xlat13.xyz;
        u_xlat2.x = dot(u_xlat11.xyz, u_xlat11.xyz);
        u_xlat4.x = sqrt(u_xlat2.x);
        u_xlat20 = u_xlat20 * u_xlat4.x;
        u_xlat12.xyz = vec3(u_xlat20) * u_xlat15.xyz;
        u_xlat2.x = inversesqrt(u_xlat2.x);
        u_xlat13.xyz = u_xlat2.xxx * u_xlat11.zxy;
        u_xlat14.xyz = u_xlat12.yzx * u_xlat13.xyz;
        u_xlat13.xyz = u_xlat13.zxy * u_xlat12.zxy + (-u_xlat14.xyz);
        u_xlat14.xyz = u_xlat5.zzz * u_xlat11.xyz;
        u_xlat14.xyz = u_xlat13.xyz * u_xlat5.xxx + u_xlat14.xyz;
        u_xlat5.xzw = u_xlat12.xyz * u_xlat5.www + u_xlat14.xyz;
        u_xlat11.xyz = u_xlat10.yyy * u_xlat11.xyz;
        u_xlat11.xyz = u_xlat13.xyz * u_xlat10.xxx + u_xlat11.xyz;
        u_xlat11.xyz = u_xlat12.xyz * u_xlat10.zzz + u_xlat11.xyz;
        u_xlat3.xyz = u_xlat3.xyz + u_xlat5.xzw;
        u_xlat7.xyz = u_xlat3.xyz * vec3(u_xlat60) + u_xlat7.xyz;
        u_xlat8.xyz = u_xlat11.xyz * vec3(u_xlat60) + u_xlat8.xyz;
    }
    // u_xlat7.xyz = in_POSITION0.xyz; // todo
    u_xlat0.xyz = u_xlat7.yyy * unity_ObjectToWorld[1].xyz;
    u_xlat0.xyz = unity_ObjectToWorld[0].xyz * u_xlat7.xxx + u_xlat0.xyz;
    u_xlat0.xyz = unity_ObjectToWorld[2].xyz * u_xlat7.zzz + u_xlat0.xyz;
    u_xlat0.xyz = u_xlat0.xyz + unity_ObjectToWorld[3].xyz;
    u_xlat1.xyz = u_xlat8.yyy * unity_ObjectToWorld[1].xyz;
    u_xlat1.xyz = unity_ObjectToWorld[0].xyz * u_xlat8.xxx + u_xlat1.xyz;
    u_xlat1.xyz = unity_ObjectToWorld[2].xyz * u_xlat8.zzz + u_xlat1.xyz;
    u_xlat2 = u_xlat0.yyyy * unity_MatrixVP[1];
    u_xlat2 = unity_MatrixVP[0] * u_xlat0.xxxx + u_xlat2;
    u_xlat2 = unity_MatrixVP[2] * u_xlat0.zzzz + u_xlat2;
    gl_Position = u_xlat2 + unity_MatrixVP[3];
    vs_TEXCOORD0.xy = in_TEXCOORD0.xy;
    vs_TEXCOORD1.xyz = u_xlat0.xyz;
    vs_TEXCOORD2.xyz = u_xlat1.xyz;
    return;
}`,
  fs: `#version 300 es

precision highp float;
precision highp int;
uniform     mediump vec4 _Color;
uniform     mediump float _Cutoff;
uniform mediump sampler2D _MainTex;
in mediump vec2 vs_TEXCOORD0;
in mediump vec3 vs_TEXCOORD2;
layout(location = 0) out mediump vec4 SV_Target0;
mediump vec4 u_xlat16_0;
bvec3 u_xlatb0;
mediump vec4 u_xlat16_1;
bool u_xlatb1;
mediump vec3 u_xlat16_2;
mediump vec3 u_xlat16_3;
mediump vec3 u_xlat16_6;
void main()
{
    u_xlat16_0 = texture(_MainTex, vs_TEXCOORD0.xy);
    u_xlatb1 = u_xlat16_0.w<_Cutoff;
    if(((int(u_xlatb1) * int(0xffffffffu)))!=0){discard;}
    u_xlat16_1 = u_xlat16_0 * _Color;
    u_xlat16_2.x = dot(vs_TEXCOORD2.xyz, vs_TEXCOORD2.xyz);
    u_xlat16_2.x = inversesqrt(u_xlat16_2.x);
    u_xlat16_2.x = vs_TEXCOORD2.y * u_xlat16_2.x + 1.0;
    u_xlat16_2.x = clamp(u_xlat16_2.x, 0.0, 1.0);
    u_xlat16_6.xyz = (-u_xlat16_0.xyz) * _Color.xyz + vec3(1.0, 1.0, 1.0);
    u_xlat16_2.xyz = u_xlat16_2.xxx * u_xlat16_6.xyz + u_xlat16_1.xyz;
    u_xlat16_2.xyz = u_xlat16_1.xyz * u_xlat16_2.xyz;
    u_xlatb0.xyz = greaterThanEqual(vec4(0.00313080009, 0.00313080009, 0.00313080009, 0.0), u_xlat16_2.xyzx).xyz;
    u_xlat16_3.xyz = u_xlat16_2.xyz * vec3(12.9200001, 12.9200001, 12.9200001);
    u_xlat16_2.xyz = log2(u_xlat16_2.xyz);
    u_xlat16_2.xyz = u_xlat16_2.xyz * vec3(0.416666657, 0.416666657, 0.416666657);
    u_xlat16_2.xyz = exp2(u_xlat16_2.xyz);
    u_xlat16_2.xyz = u_xlat16_2.xyz * vec3(1.05499995, 1.05499995, 1.05499995) + vec3(-0.0549999997, -0.0549999997, -0.0549999997);
    SV_Target0.x = (u_xlatb0.x) ? u_xlat16_3.x : u_xlat16_2.x;
    SV_Target0.y = (u_xlatb0.y) ? u_xlat16_3.y : u_xlat16_2.y;
    SV_Target0.z = (u_xlatb0.z) ? u_xlat16_3.z : u_xlat16_2.z;
    SV_Target0.w = u_xlat16_1.w;
    return;
}`,
};
