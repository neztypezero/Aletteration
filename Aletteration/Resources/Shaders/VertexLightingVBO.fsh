//
//  GameBoard.fsh
//  GmoLoader
//
//  Created by David Nesbitt on 8/21/10.
//  Copyright David Nesbitt 2010. All rights reserved.

precision mediump float;

uniform sampler2D u_texUnit;

varying vec2 v_uv;
varying vec3 v_diffuse;
varying vec3 v_ambientPlusSpecular;

void main(void) {
	vec4 letterColor = texture2D(u_texUnit, v_uv);
	vec3 diffuseColor = (((v_diffuse)*(1.0-letterColor.a))+(letterColor.rgb*letterColor.a));
	vec3 color = v_ambientPlusSpecular + diffuseColor;
	gl_FragColor = vec4(color, 1.0);
}