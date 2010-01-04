//
//  VSColorAdditions.m
//  VillainousStyle
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "NSColorAdditions.h"
#import "NSColor+CGColor.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
// Color algorithms from http://www.cs.rit.edu/~ncs/color/t_convert.html

#define MAX3(a,b,c) (a > b ? (a > c ? a : c) : (b > c ? b : c))
#define MIN3(a,b,c) (a < b ? (a < c ? a : c) : (b < c ? b : c))

void VS_RGBtoHSV(float r, float g, float b, float* h, float* s, float* v) {
	float min, max, delta;
	min = MIN3(r, g, b);
	max = MAX3(r, g, b);
	*v = max;				// v
	delta = max - min;
	if( max != 0 )
		*s = delta / max;		// s
	else {
		// r = g = b = 0		// s = 0, v is undefined
		*s = 0;
		*h = -1;
		return;
	}
	if( r == max )
		*h = ( g - b ) / delta;		// between yellow & magenta
	else if( g == max )
		*h = 2 + ( b - r ) / delta;	// between cyan & yellow
	else
		*h = 4 + ( r - g ) / delta;	// between magenta & cyan
	*h *= 60;				// degrees
	if( *h < 0 )
		*h += 360;
}

void VS_HSVtoRGB( float *r, float *g, float *b, float h, float s, float v )
{
	int i;
	float f, p, q, t;
	if( s == 0 ) {
		// achromatic (grey)
		*r = *g = *b = v;
		return;
	}
	h /= 60;			// sector 0 to 5
	i = floor( h );
	f = h - i;			// factorial part of h
	p = v * ( 1 - s );
	q = v * ( 1 - s * f );
	t = v * ( 1 - s * ( 1 - f ) );
	switch( i ) {
		case 0:
			*r = v;
			*g = t;
			*b = p;
			break;
		case 1:
			*r = q;
			*g = v;
			*b = p;
			break;
		case 2:
			*r = p;
			*g = v;
			*b = t;
			break;
		case 3:
			*r = p;
			*g = q;
			*b = v;
			break;
		case 4:
			*r = t;
			*g = p;
			*b = v;
			break;
		default:		// case 5:
			*r = v;
			*g = p;
			*b = q;
			break;
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation VSColor (Additions)

+ (VSColor*)colorWithHue:(CGFloat)h saturation:(CGFloat)s value:(CGFloat)v alpha:(CGFloat)a {
	CGFloat r, g, b;
	VS_HSVtoRGB(&r, &g, &b, h, s, v);
	return VSColorRGBA(r,g,b,a);
}

- (VSColor*)multiplyHue:(CGFloat)hd saturation:(CGFloat)sd value:(CGFloat)vd {
	const CGFloat* rgba = CGColorGetComponents(self.CGColor);
	CGFloat r = rgba[0];
	CGFloat g = rgba[1];
	CGFloat b = rgba[2];
	CGFloat a = rgba[3];
	
	CGFloat h, s, v;
	VS_RGBtoHSV(r, g, b, &h, &s, &v);
	
	h *= hd;
	v *= vd;
	s *= sd;
	
	VS_HSVtoRGB(&r, &g, &b, h, s, v);
	
	return VSColorRGBA(r,g,b,a);
}

- (VSColor*)copyWithAlpha:(CGFloat)newAlpha {
	const CGFloat* rgba = CGColorGetComponents(self.CGColor);
	CGFloat r = rgba[0];
	CGFloat g = rgba[1];
	CGFloat b = rgba[2];
	
	return VSColorRGBA(r,g,b,newAlpha);
}

- (VSColor*)addHue:(CGFloat)hd saturation:(CGFloat)sd value:(CGFloat)vd {
	const CGFloat* rgba = CGColorGetComponents(self.CGColor);
	CGFloat r = rgba[0];
	CGFloat g = rgba[1];
	CGFloat b = rgba[2];
	CGFloat a = rgba[3];
	
	CGFloat h, s, v;
	VS_RGBtoHSV(r, g, b, &h, &s, &v);
	
	h += hd;
	v += vd;
	s += sd;
	
	VS_HSVtoRGB(&r, &g, &b, h, s, v);
	
	return [VSColorRGBA(r,g,b,a) retain];
}

- (VSColor*)highlight {
	return [self multiplyHue:1 saturation:0.4 value:1.2];
}

- (VSColor*)shadow {
	return [self multiplyHue:1 saturation:0.6 value:0.6];
}

- (CGFloat)hue {
	const CGFloat* rgba = CGColorGetComponents(self.CGColor);
	CGFloat h, s, v;
	VS_RGBtoHSV(rgba[0], rgba[1], rgba[2], &h, &s, &v);
	return h;
}

- (CGFloat)saturation {
	const CGFloat* rgba = CGColorGetComponents(self.CGColor);
	CGFloat h, s, v;
	VS_RGBtoHSV(rgba[0], rgba[1], rgba[2], &h, &s, &v);
	return s;
}

- (CGFloat)value {
	const CGFloat* rgba = CGColorGetComponents(self.CGColor);
	CGFloat h, s, v;
	VS_RGBtoHSV(rgba[0], rgba[1], rgba[2], &h, &s, &v);
	return v;
}

@end
