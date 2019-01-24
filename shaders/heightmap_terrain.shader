shader_type spatial;

uniform vec2 HEIGHTMAP_SIZE = vec2(1024.0, 1024.0);
uniform float HEIGHT_FACTOR = 128.0;
uniform float MOUNTAINS_FACTOR = 24.;
uniform float RANDOM_UV_FACTOR = 4.;
uniform float GRASS_UV_FACTOR = 4.;

varying float color_height;
uniform sampler2D heightmap;
uniform sampler2D noisemap;
uniform float white_line = 0.9;
uniform float green_line = 0.35;
uniform float ground_line = 0.33;
uniform float blue_line = 0.32;
uniform float GOLDEN_ANGLE_RADIAN = 2.39996;

float get_height(vec2 pos) {
	pos -= .5 * HEIGHTMAP_SIZE;
	pos /= HEIGHTMAP_SIZE;
	return texture(heightmap, pos).r;
}

float wave(vec2 uv, vec2 emitter, float speed, float phase, float iTime){
	float dst = distance(uv, emitter);
	return pow((0.5 + 0.5 * sin(dst * phase - iTime * speed)), 5.0);
}

float get_waves(vec2 uv, float iTime){
	float w = 0.0;
	float sw = 0.0;
	float iter = 0.0;
	float ww = 1.0;
	uv += iTime * 0.5;
	for(int i=0;i<6;i++){
		w += ww * wave(uv * 0.06 , vec2(sin(iter), cos(iter)) * 10.0, 2.0 + iter * 0.08, 2.0 + iter * 3.0, iTime);
		sw += ww;
		ww = mix(ww, 0.0115, 0.4);
		iter += GOLDEN_ANGLE_RADIAN;
	}
	
	return w / sw;
}

void vertex() {
	float h = get_height(VERTEX.xz);
	color_height = h;
	
	float shore_line = step(blue_line, color_height);
	float mountains_line = smoothstep(green_line, white_line, color_height);
	float ran = texture(noisemap, VERTEX.xz * 8.).x * MOUNTAINS_FACTOR;
	h = mix(blue_line, h, shore_line);
	
	float w = get_waves(VERTEX.xz, TIME) * 2.;
	float anim = mix(w, 0., shore_line);
	
	h = h * HEIGHT_FACTOR + anim;
	float fh = mix(h, h + ran, mountains_line);
	VERTEX.y = fh;
}

void fragment() {
	float ran = texture(noisemap, UV * RANDOM_UV_FACTOR).x;
	float ran2 = texture(noisemap, UV * GRASS_UV_FACTOR * 32.).x;
	vec3 alb = vec3(color_height);
	
	// sand (yellow) vs grass (green)
	float y_line = step(ground_line + ran * .15, color_height);
	alb.r = mix(.2 + ran *.3, 	(.3 - ran * .1) * ran2, 	y_line);
	alb.g = mix(.3 + ran *.2, 	(.9 - ran * .1) * ran2, 	y_line);
	alb.b = mix(.2 + ran *.2, 	(0.1) * ran2, 				y_line);
	
	// rest vs white top
	float g_line = step(green_line + ran * .3, color_height);
	alb.r = mix(alb.r, 1., g_line);
	alb.g = mix(alb.g, 1., g_line);
	alb.b = mix(alb.b, 1., g_line);
	
	// water (blue) vs rest
	float b_line = step(blue_line, color_height);
	alb.r = mix(.0 + ran * .05, 	alb.r, b_line);
	alb.g = mix(.2 + ran * .15, 	alb.g, b_line);
	alb.b = mix(.6, 				alb.b, b_line);
	
	EMISSION = mix(vec3(0.), vec3(.1, .2, 1.), g_line);
	TRANSMISSION = mix(vec3(0.), vec3(.3, .3, 1.), g_line);
	TRANSMISSION += mix(vec3(color_height * ran * 2.), vec3(0.), b_line);
	TRANSMISSION += mix(vec3(.5, 0.8, .2), TRANSMISSION, g_line);
	
	SPECULAR = mix(1., .4, b_line);
	ROUGHNESS = mix(.6, 1., b_line);
	METALLIC = mix(0.5, 0., b_line);
	
	ALBEDO = alb;
}