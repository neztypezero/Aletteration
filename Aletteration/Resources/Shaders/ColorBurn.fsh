//
//  Background.fsh
//  Aletteration
//
//  Created by David Nesbitt on 8/21/10.
//  Copyright David Nesbitt 2010. All rights reserved.

precision mediump float;

uniform sampler2D u_texUnit;

varying vec2 v_uv;
varying vec4 v_color;

#define Blend(base, blend, funcf) vec4(funcf(base.r, blend.r), funcf(base.g, blend.g), funcf(base.b, blend.b), base.a*blend.a)

#define BlendColorBurn(base, blend) Blend(base, blend, BlendColorBurnf)
#define BlendSoftLight(base, blend) Blend(base, blend, BlendSoftLightf)

#define BlendColorBurnf(base, blend) ((blend == 0.0) ? blend : max((1.0 - ((1.0 - base) / blend)), 0.0))
#define BlendSoftLightf(base, blend) ((blend < 0.5) ? (2.0 * base * blend + base * base * (1.0 - 2.0 * blend)) : (sqrt(base) * (2.0 * blend - 1.0) + 2.0 * base * (1.0 - blend)))

void main(void) {
	vec4 texel = texture2D(u_texUnit, v_uv);
	gl_FragColor = BlendSoftLight(texel, v_color);
}