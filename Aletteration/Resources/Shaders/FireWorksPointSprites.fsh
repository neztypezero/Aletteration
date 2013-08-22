//
//  Background.fsh
//  Aletteration
//
//  Created by David Nesbitt on 8/21/10.
//  Copyright David Nesbitt 2010. All rights reserved.

precision mediump float;

uniform sampler2D u_texUnit;

varying vec2 v_uv;
varying float v_alpha;

void main(void) {
	vec2 texCoord = vec2(gl_PointCoord.y/4.0, (1.0-gl_PointCoord.x)/4.0)+v_uv;
	gl_FragColor = texture2D(u_texUnit, texCoord) * vec4(1.0, 1.0, 1.0, v_alpha);
}