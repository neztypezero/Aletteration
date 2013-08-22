/*
 *  NezAnimationEasingFunction.c
 *  Aletteration
 *
 *  Created by David Nesbitt on 2/12/11.
 *  Copyright 2011 David Nesbitt. All rights reserved.
 *
 */

#include "NezAnimationEasingFunction.h"
#include <math.h>

float easeLinear(float t, float b, float c, float d) {
	return b+(c*(t/d));
}

float easeInQuad(float t, float b, float c, float d) {
	return c*(t/=d)*t + b;
}

float easeOutQuad(float t, float b, float c, float d) {
	return -c *(t/=d)*(t-2) + b;
}

float easeInOutQuad(float t, float b, float c, float d) {
	if ((t/=d/2) < 1) return c/2*t*t + b;
	return -c/2 * ((--t)*(t-2) - 1) + b;
}

float easeInCubic(float t, float b, float c, float d) {
	return c*(t/=d)*t*t + b;
}

float easeOutCubic(float t, float b, float c, float d) {
	return c*((t=t/d-1)*t*t + 1) + b;
}

float easeInOutCubic(float t, float b, float c, float d) {
	if ((t/=d/2) < 1) return c/2*t*t*t + b;
	return c/2*((t-=2)*t*t + 2) + b;
}

float easeInQuart(float t, float b, float c, float d) {
	return c*(t/=d)*t*t*t + b;
}

float easeOutQuart(float t, float b, float c, float d) {
	return -c * ((t=t/d-1)*t*t*t - 1) + b;
}

float easeInOutQuart(float t, float b, float c, float d) {
	if ((t/=d/2) < 1) return c/2*t*t*t*t + b;
	return -c/2 * ((t-=2)*t*t*t - 2) + b;
}

float easeInQuint(float t, float b, float c, float d) {
	return c*(t/=d)*t*t*t*t + b;
}

float easeOutQuint(float t, float b, float c, float d) {
	return c*((t=t/d-1)*t*t*t*t + 1) + b;
}

float easeInOutQuint(float t, float b, float c, float d) {
	if ((t/=d/2) < 1) return c/2*t*t*t*t*t + b;
	return c/2*((t-=2)*t*t*t*t + 2) + b;
}

float easeInSine(float t, float b, float c, float d) {
	return -c * cos(t/d * (M_PI/2)) + c + b;
}

float easeOutSine(float t, float b, float c, float d) {
	return c * sin(t/d * (M_PI/2)) + b;
}

float easeInOutSine(float t, float b, float c, float d) {
	return -c/2 * (cos(M_PI*t/d) - 1) + b;
}

float easeInExpo(float t, float b, float c, float d) {
	return (t==0) ? b : c * pow(2, 10 * (t/d - 1)) + b;
}

float easeOutExpo(float t, float b, float c, float d) {
	return (t==d) ? b+c : c * (-pow(2, -10 * t/d) + 1) + b;
}

float easeInOutExpo(float t, float b, float c, float d) {
	if (t==0) return b;
	if (t==d) return b+c;
	if ((t/=d/2) < 1) return c/2 * pow(2, 10 * (t - 1)) + b;
	return c/2 * (-pow(2, -10 * --t) + 2) + b;
}

float easeInCirc(float t, float b, float c, float d) {
	return -c * (sqrt(1 - (t/=d)*t) - 1) + b;
}

float easeOutCirc(float t, float b, float c, float d) {
	return c * sqrt(1 - (t=t/d-1)*t) + b;
}

float easeInOutCirc(float t, float b, float c, float d) {
	if ((t/=d/2) < 1) return -c/2 * (sqrt(1 - t*t) - 1) + b;
	return c/2 * (sqrt(1 - (t-=2)*t) + 1) + b;
}

float easeInElastic(float t, float b, float c, float d) {
	float s=1.70158, p=0, a=c;
	if (t==0) return b;  if ((t/=d)==1) return b+c;  if (!p) p=d*.3;
	if (a < fabs(c)) { a=c; s=p/4; }
	else { s = p/(2*M_PI) * asin (c/a); }
	return -(a*pow(2,10*(t-=1)) * sin( (t*d-s)*(2*M_PI)/p )) + b;
}

float easeOutElastic(float t, float b, float c, float d) {
	float s=1.70158, p=0, a=c;
	if (t==0) return b;  if ((t/=d)==1) return b+c;  if (!p) p=d*.3;
	if (a < fabs(c)) { a=c; s=p/4; }
	else s = p/(2*M_PI) * asin (c/a);
	return a*pow(2,-10*t) * sin( (t*d-s)*(2*M_PI)/p ) + c + b;
}

float easeInOutElastic(float t, float b, float c, float d) {
	float s=1.70158, p=0, a=c;
	if (t==0) return b;  if ((t/=d/2)==2) return b+c;  if (!p) p=d*(.3*1.5);
	if (a < fabs(c)) { a=c; s=p/4; }
	else s = p/(2*M_PI) * asin (c/a);
	if (t < 1) return -.5*(a*pow(2,10*(t-=1)) * sin( (t*d-s)*(2*M_PI)/p )) + b;
	return a*pow(2,-10*(t-=1)) * sin( (t*d-s)*(2*M_PI)/p )*.5 + c + b;
}

float easeInBack(float t, float b, float c, float d) {
	float s = 1.70158;
	return c*(t/=d)*t*((s+1)*t - s) + b;
}

float easeOutBack(float t, float b, float c, float d) {
	float s = 1.70158;
	return c*((t=t/d-1)*t*((s+1)*t + s) + 1) + b;
}

float easeInOutBack(float t, float b, float c, float d) {
	float s = 1.70158; 
	if ((t/=d/2) < 1) return c/2*(t*t*(((s*=(1.525))+1)*t - s)) + b;
	return c/2*((t-=2)*t*(((s*=(1.525))+1)*t + s) + 2) + b;
}

float easeInBounce(float t, float b, float c, float d) {
	return c - easeOutBounce(d-t, 0, c, d) + b;
}

float easeOutBounce(float t, float b, float c, float d) {
	if ((t/=d) < (1/2.75)) {
		return c*(7.5625*t*t) + b;
	} else if (t < (2/2.75)) {
		return c*(7.5625*(t-=(1.5/2.75))*t + .75) + b;
	} else if (t < (2.5/2.75)) {
		return c*(7.5625*(t-=(2.25/2.75))*t + .9375) + b;
	} else {
		return c*(7.5625*(t-=(2.625/2.75))*t + .984375) + b;
	}
}

float easeInOutBounce(float t, float b, float c, float d) {
	if (t < d/2) return easeInBounce(t*2, 0, c, d) * .5 + b;
	return easeOutBounce(t*2-d, 0, c, d) * .5 + c*.5 + b;
}

/*
 * jQuery Easing v1.3 - http://gsgd.co.uk/sandbox/jquery/easing/
 *
 * Uses the built in easing capabilities added In jQuery 1.1
 * to offer multiple easing options
 *
 * TERMS OF USE - jQuery Easing
 * 
 * Open source under the BSD License. 
 * 
 * Copyright Â© 2008 George McGinley Smith
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without modification, 
 * are permitted provided that the following conditions are met:
 * 
 * Redistributions of source code must retain the above copyright notice, this list of 
 * conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list 
 * of conditions and the following disclaimer in the documentation and/or other materials 
 * provided with the distribution.
 * 
 * Neither the name of the author nor the names of contributors may be used to endorse 
 * or promote products derived from this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY 
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 *  COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 *  GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED 
 * AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
 * OF THE POSSIBILITY OF SUCH DAMAGE. 
 *
 */
/*
 *
 * TERMS OF USE - EASING EQUATIONS
 * 
 * Open source under the BSD License. 
 * 
 * Copyright Â© 2001 Robert Penner
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without modification, 
 * are permitted provided that the following conditions are met:
 * 
 * Redistributions of source code must retain the above copyright notice, this list of 
 * conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list 
 * of conditions and the following disclaimer in the documentation and/or other materials 
 * provided with the distribution.
 * 
 * Neither the name of the author nor the names of contributors may be used to endorse 
 * or promote products derived from this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY 
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 *  COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 *  GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED 
 * AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
 * OF THE POSSIBILITY OF SUCH DAMAGE. 
 *
 */