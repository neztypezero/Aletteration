//
//  GameBoard.vsh
//  GmoLoader
//
//  Created by David Nesbitt on 8/21/10.
//  Copyright David Nesbitt 2010. All rights reserved.
//
const int NUM_PALETTES = 36; // 36 palettes

const int c_0 = 0;
const int c_1 = 1;
const int c_2 = 2;
const int c_3 = 3;

attribute vec4 a_position;
attribute vec3 a_normal;
attribute vec2 a_uv;
attribute vec4 a_indexArray;

uniform float u_time;
uniform mat4 u_modelViewProjectionMatrix;

//Attribute Palette
uniform vec4 u_matrixPalette[NUM_PALETTES*c_3]; // NUM_PALETTES matrices row major order (4x3 no last row)
uniform vec3 u_colorPalette[NUM_PALETTES]; // NUM_PALETTES colorFrom

uniform vec3 u_lightPosition;
uniform vec3 u_ambientMaterial;
uniform vec3 u_specularMaterial;
uniform float u_shininess;

varying vec2 v_uv;
varying vec3 v_diffuse;
varying vec3 v_ambientPlusSpecular;

void main(void) {
	int idx = int(a_indexArray[c_0]);
	int mIdx = idx*c_3;
	vec4 pos    = vec4(dot(a_position, u_matrixPalette[mIdx]),     dot(a_position, u_matrixPalette[mIdx+c_1]),     dot(a_position, u_matrixPalette[mIdx+c_2]), a_position.w);
	vec3 normal = vec3(dot(a_normal,   u_matrixPalette[mIdx].xyz), dot(a_normal,   u_matrixPalette[mIdx+c_1].xyz), dot(a_normal,   u_matrixPalette[mIdx+c_2].xyz));

	vec3 N = normalize(normal);
	vec3 L = normalize(u_lightPosition);
	vec3 E = vec3(0, 0, 1);
	vec3 H = normalize(L + E); //half plane (half vector)
	
	float df = max(0.0, dot(N, L));
	float sf = max(0.0, dot(N, H));
	sf = pow(sf, u_shininess);

	v_ambientPlusSpecular = u_ambientMaterial + sf * u_specularMaterial;

v_uv = a_uv;
v_diffuse = u_colorPalette[idx] * df;
gl_Position = u_modelViewProjectionMatrix * pos;
}
