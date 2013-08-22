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

uniform mat4 u_modelViewProjectionMatrix;

//Attribute Palette
uniform vec4 u_matrixPalette[NUM_PALETTES*c_3]; // NUM_PALETTES matrices row major order (4x3 no last row)

varying vec2 v_uv;

void main(void) {
	int idx = int(a_indexArray[c_0]);
	int mIdx = idx*c_3;
	vec4 pos = vec4(dot(a_position, u_matrixPalette[mIdx]), dot(a_position, u_matrixPalette[mIdx+c_1]), dot(a_position, u_matrixPalette[mIdx+c_2]), a_position.w);

    v_uv = a_uv;
    gl_Position = u_modelViewProjectionMatrix * pos;
}
