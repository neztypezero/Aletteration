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

const float c_zero = 0.0;
const float c_one = 1.0;


const vec4 c_z = vec4(c_zero, c_zero, c_zero, c_one);
const float gravity = -2.0;

attribute vec4 a_position;
attribute vec3 a_normal;
attribute vec2 a_uv;
attribute vec4 a_indexArray;

uniform float u_time;
uniform mat4 u_modelViewProjectionMatrix;

//Attribute Palette
uniform vec4 u_matrixPalette[NUM_PALETTES*c_3]; // NUM_PALETTES matrices row major order (4x3 no last row)

varying vec2 v_uv;
varying float v_alpha;

float easeInCubic(float t, float b, float c, float d) {
	return c*(t/=d)*t*t + b;
}

void main(void) {
	int idx = int(a_indexArray[c_0]);
	int mIdx = idx*c_3;
	vec4 pos = vec4(dot(c_z, u_matrixPalette[mIdx]), dot(c_z, u_matrixPalette[mIdx+c_1]), dot(c_z, u_matrixPalette[mIdx+c_2]), c_z.w);
	
	pos += a_position*vec4(u_time, u_time, u_time, c_zero) + vec4(c_zero, gravity*u_time*u_time, c_zero, c_zero);
	
	if (u_time > 2.0) {
  		v_alpha = clamp(3.0-u_time, c_zero, c_one);
	} else {
		v_alpha = c_one;
	}

	v_uv = a_uv;
	gl_Position = u_modelViewProjectionMatrix * pos;
	gl_PointSize = 16.0;
}
