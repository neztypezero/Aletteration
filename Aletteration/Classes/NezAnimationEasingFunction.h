/*
 *  NezAnimationEasingFunction.h
 *  Aletteration
 *
 *  Created by David Nesbitt on 2/12/11.
 *  Copyright 2011 David Nesbitt. All rights reserved.
 *
 */
#ifndef NEZANIMATION_JQUERY_EASING_FUNCTIONS_H
#define NEZANIMATION_JQUERY_EASING_FUNCTIONS_H

typedef float(*EasingFunctionPtr)(float, float, float, float);

float easeLinear(float t, float b, float c, float d);

float easeInQuad(float t, float b, float c, float d);
float easeOutQuad(float t, float b, float c, float d);
float easeInOutQuad(float t, float b, float c, float d);
float easeInCubic(float t, float b, float c, float d);
float easeOutCubic(float t, float b, float c, float d);
float easeInOutCubic(float t, float b, float c, float d);
float easeInQuart(float t, float b, float c, float d);
float easeOutQuart(float t, float b, float c, float d);
float easeInOutQuart(float t, float b, float c, float d);
float easeInQuint(float t, float b, float c, float d);
float easeOutQuint(float t, float b, float c, float d);
float easeInOutQuint(float t, float b, float c, float d);
float easeInSine(float t, float b, float c, float d);
float easeOutSine(float t, float b, float c, float d);
float easeInOutSine(float t, float b, float c, float d);
float easeInExpo(float t, float b, float c, float d);
float easeOutExpo(float t, float b, float c, float d);
float easeInOutExpo(float t, float b, float c, float d);
float easeInCirc(float t, float b, float c, float d);
float easeOutCirc(float t, float b, float c, float d);
float easeInOutCirc(float t, float b, float c, float d);
float easeInElastic(float t, float b, float c, float d);
float easeOutElastic(float t, float b, float c, float d);
float easeInOutElastic(float t, float b, float c, float d);
float easeInBack(float t, float b, float c, float d);
float easeOutBack(float t, float b, float c, float d);
float easeInOutBack(float t, float b, float c, float d);
float easeOutBounce(float t, float b, float c, float d);
float easeInBounce(float t, float b, float c, float d);
float easeInOutBounce(float t, float b, float c, float d);

#endif

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