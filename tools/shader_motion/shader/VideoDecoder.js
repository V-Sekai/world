export default {
  vs: `#version 300 es

vec2 ImmCB_0_0_0[6];
out highp vec2 vs_TEXCOORD0;
uint u_xlatu0;
void main()
{
    ImmCB_0_0_0[0] = vec2(1.0, 1.0);
    ImmCB_0_0_0[1] = vec2(0.0, 0.0);
    ImmCB_0_0_0[2] = vec2(0.0, 1.0);
    ImmCB_0_0_0[3] = vec2(0.0, 0.0);
    ImmCB_0_0_0[4] = vec2(1.0, 1.0);
    ImmCB_0_0_0[5] = vec2(1.0, 0.0);
    //null = uintBitsToFloat(uint(gl_VertexID) / 6u);
    u_xlatu0 = uint(gl_VertexID) % 6u;
    vs_TEXCOORD0.xy = ImmCB_0_0_0[int(u_xlatu0)].xy;
    gl_Position.xy = ImmCB_0_0_0[int(u_xlatu0)].xy * vec2(2.0, 2.0) + vec2(-1.0, -1.0);
    gl_Position.zw = vec2(-1.0, 1.0);
    return;
}`,
  fs: `#version 300 es
#ifdef GL_EXT_shader_texture_lod
#extension GL_EXT_shader_texture_lod : enable
#endif

precision highp float;
precision highp int;
uniform     vec4 _MainTex_ST;
uniform mediump sampler2D _MainTex;
in highp vec2 vs_TEXCOORD0;
layout(location = 0) out highp vec4 SV_Target0;
vec4 u_xlat0;
mediump vec3 u_xlat10_0;
int u_xlati0;
vec4 u_xlat1;
mediump vec3 u_xlat10_1;
int u_xlati1;
bool u_xlatb1;
mediump vec3 u_xlat16_2;
float u_xlat3;
int u_xlati3;
bvec2 u_xlatb3;
float u_xlat4;
vec3 u_xlat5;
bvec2 u_xlatb5;
bvec2 u_xlatb7;
float u_xlat8;
float u_xlat9;
int u_xlati9;
bvec2 u_xlatb9;
float u_xlat12;
float u_xlat13;
int u_xlati13;
void main()
{
    u_xlat0 = vs_TEXCOORD0.xyxy * vec4(40.0, 45.0, 40.0, 45.0);
    u_xlat0 = floor(u_xlat0);
    u_xlat0 = u_xlat0 + vec4(0.0, 0.0, 1.0, 1.0);
    u_xlat1.x = float(0.0250000004);
    u_xlat1.z = float(0.0250000004);
    u_xlat1.yw = _MainTex_ST.yy;
    u_xlat0 = u_xlat0 * u_xlat1;
    u_xlatb1 = 0.5<vs_TEXCOORD0.x;
    u_xlat0.xz = (bool(u_xlatb1)) ? u_xlat0.zx : u_xlat0.xz;
    u_xlat1.xz = _MainTex_ST.xx;
    u_xlat1.y = float(0.0222222228);
    u_xlat1.w = float(0.0222222228);
    u_xlat0 = u_xlat0 * u_xlat1 + _MainTex_ST.zwzw;
    u_xlat1 = (-u_xlat0.xyxy) + u_xlat0.zwzw;
    u_xlat0 = u_xlat1 * vec4(0.25, 0.5, 0.75, 0.5) + u_xlat0.xyxy;
    u_xlat10_1.xyz = textureLod(_MainTex, u_xlat0.xy, 0.0).xyz;
    u_xlat10_0.xyz = textureLod(_MainTex, u_xlat0.zw, 0.0).xyz;
    u_xlat16_2.xyz = u_xlat10_1.xyz + u_xlat10_1.xyz;
    u_xlat12 = roundEven(u_xlat16_2.y);
    u_xlat5.x = u_xlat10_1.y * 2.0 + (-u_xlat12);
    u_xlat1.xz = (-u_xlat10_1.xz) * vec2(2.0, 2.0) + vec2(2.0, 2.0);
    u_xlatb3.xy = equal(vec4(u_xlat12), vec4(2.0, 0.0, 0.0, 0.0)).xy;
    {
        vec3 hlslcc_movcTemp = u_xlat5;
        hlslcc_movcTemp.x = (u_xlatb3.x) ? float(0.0) : u_xlat5.x;
        hlslcc_movcTemp.z = (u_xlatb3.y) ? float(0.0) : u_xlat5.x;
        u_xlat5 = hlslcc_movcTemp;
    }
    u_xlati3 = int(u_xlat12);
    u_xlati3 = int(uint(uint(u_xlati3) & 1u));
    u_xlat1.x = (u_xlati3 != 0) ? u_xlat1.x : u_xlat16_2.x;
    u_xlat3 = roundEven(u_xlat1.x);
    u_xlat1.x = u_xlat1.x + (-u_xlat3);
    u_xlatb7.xy = equal(vec4(u_xlat3), vec4(2.0, 0.0, 0.0, 0.0)).xy;
    u_xlat12 = u_xlat12 * 3.0 + u_xlat3;
    {
        vec4 hlslcc_movcTemp = u_xlat1;
        hlslcc_movcTemp.x = (u_xlatb7.x) ? u_xlat5.x : u_xlat1.x;
        hlslcc_movcTemp.y = (u_xlatb7.y) ? u_xlat5.z : u_xlat1.x;
        u_xlat1 = hlslcc_movcTemp;
    }
    u_xlati13 = int(u_xlat12);
    u_xlati13 = int(uint(uint(u_xlati13) & 1u));
    u_xlat9 = (u_xlati13 != 0) ? u_xlat1.z : u_xlat16_2.z;
    u_xlat13 = roundEven(u_xlat9);
    u_xlat9 = (-u_xlat13) + u_xlat9;
    u_xlatb3.xy = equal(vec4(u_xlat13), vec4(2.0, 0.0, 0.0, 0.0)).xy;
    u_xlat12 = u_xlat12 * 3.0 + u_xlat13;
    {
        vec4 hlslcc_movcTemp = u_xlat1;
        hlslcc_movcTemp.x = (u_xlatb3.x) ? u_xlat1.x : float(u_xlat9);
        hlslcc_movcTemp.y = (u_xlatb3.y) ? u_xlat1.y : float(u_xlat9);
        u_xlat1 = hlslcc_movcTemp;
    }
    u_xlati9 = int(u_xlat12);
    u_xlati9 = int(uint(uint(u_xlati9) & 1u));
    u_xlat16_2.xyz = u_xlat10_0.yxz + u_xlat10_0.yxz;
    u_xlat0.xyz = (-u_xlat10_0.yxz) * vec3(2.0, 2.0, 2.0) + vec3(2.0, 2.0, 2.0);
    u_xlat0.x = (u_xlati9 != 0) ? u_xlat0.x : u_xlat16_2.x;
    u_xlat9 = roundEven(u_xlat0.x);
    u_xlat0.x = u_xlat0.x + (-u_xlat9);
    u_xlatb3.xy = equal(vec4(u_xlat9), vec4(2.0, 0.0, 0.0, 0.0)).xy;
    u_xlat12 = u_xlat12 * 3.0 + u_xlat9;
    {
        vec4 hlslcc_movcTemp = u_xlat1;
        hlslcc_movcTemp.x = (u_xlatb3.x) ? u_xlat1.x : u_xlat0.x;
        hlslcc_movcTemp.y = (u_xlatb3.y) ? u_xlat1.y : u_xlat0.x;
        u_xlat1 = hlslcc_movcTemp;
    }
    u_xlati0 = int(u_xlat12);
    u_xlati0 = int(uint(uint(u_xlati0) & 1u));
    u_xlat0.x = (u_xlati0 != 0) ? u_xlat0.y : u_xlat16_2.y;
    u_xlat4 = roundEven(u_xlat0.x);
    u_xlat0.x = (-u_xlat4) + u_xlat0.x;
    u_xlatb9.xy = equal(vec4(u_xlat4), vec4(2.0, 0.0, 2.0, 0.0)).xy;
    u_xlat4 = u_xlat12 * 3.0 + u_xlat4;
    {
        vec4 hlslcc_movcTemp = u_xlat0;
        hlslcc_movcTemp.x = (u_xlatb9.x) ? u_xlat1.x : u_xlat0.x;
        hlslcc_movcTemp.w = (u_xlatb9.y) ? u_xlat1.y : u_xlat0.x;
        u_xlat0 = hlslcc_movcTemp;
    }
    u_xlati1 = int(u_xlat4);
    u_xlati1 = int(uint(uint(u_xlati1) & 1u));
    u_xlat8 = (u_xlati1 != 0) ? u_xlat0.z : u_xlat16_2.z;
    u_xlat1.x = roundEven(u_xlat8);
    u_xlat8 = u_xlat8 + (-u_xlat1.x);
    u_xlatb5.xy = equal(u_xlat1.xxxx, vec4(2.0, 0.0, 0.0, 0.0)).xy;
    u_xlat4 = u_xlat4 * 3.0 + u_xlat1.x;
    u_xlat4 = u_xlat4 + -364.0;
    {
        vec4 hlslcc_movcTemp = u_xlat0;
        hlslcc_movcTemp.x = (u_xlatb5.x) ? u_xlat0.x : float(u_xlat8);
        hlslcc_movcTemp.z = (u_xlatb5.y) ? u_xlat0.w : float(u_xlat8);
        u_xlat0 = hlslcc_movcTemp;
    }
    u_xlat0.xz = u_xlat0.xz * vec2(2.0, -2.0);
    u_xlat0.xz = max(u_xlat0.xz, vec2(0.0, 0.0));
    u_xlat12 = max(u_xlat0.z, u_xlat0.x);
    u_xlat12 = (-u_xlat0.x) * u_xlat0.z + u_xlat12;
    u_xlat12 = max(u_xlat12, 9.99999975e-06);
    u_xlat1.x = min(u_xlat0.z, u_xlat0.x);
    u_xlat0.x = (-u_xlat0.z) + u_xlat0.x;
    u_xlat8 = u_xlat1.x / u_xlat12;
    u_xlat0.x = u_xlat8 * u_xlat0.x + u_xlat0.x;
    u_xlat0.x = u_xlat0.x * 0.5 + u_xlat4;
    u_xlat0 = u_xlat0.xxxx * vec4(0.000686813204, 0.17582418, 45.0109901, 11522.8135) + vec4(0.25, 64.0, 16384.0, 4194304.0);
    u_xlat0 = fract(u_xlat0);
    u_xlat0.xyz = (-u_xlat0.yzw) * vec3(0.00390625, 0.00390625, 0.00390625) + u_xlat0.xyz;
    SV_Target0 = u_xlat0 * vec4(1.00392163, 1.00392163, 1.00392163, 1.00392163);
    return;
}`,
};
