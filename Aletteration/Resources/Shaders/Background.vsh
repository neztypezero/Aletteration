//
//  Background.vsh
//  Aletteration
//
//  Created by David Nesbitt on 8/21/10.
//  Copyright David Nesbitt 2010. All rights reserved.
//
attribute vec2 a_position;
attribute vec2 a_uv;

varying vec2 v_uv;

void main(void) {
    v_uv = a_uv;
    gl_Position = vec4(a_position.x, a_position.y, 0.0, 1.0);
}
