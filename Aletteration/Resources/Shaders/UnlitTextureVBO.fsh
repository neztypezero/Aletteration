//
//  GameBoard.fsh
//  GmoLoader
//
//  Created by David Nesbitt on 8/21/10.
//  Copyright David Nesbitt 2010. All rights reserved.

precision mediump float;

uniform sampler2D u_texUnit;

varying vec2 v_uv; 

void main() {
	vec4 texel = texture2D(u_texUnit, v_uv);
	gl_FragColor = texel;
}
