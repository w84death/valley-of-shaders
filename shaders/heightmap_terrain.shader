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

float get_height(vec2 pos) {
	pos -= .5 * HEIGHTMAP_SIZE;
	pos /= HEIGHTMAP_SIZE;
	return texture(heightmap, pos).r;
}

void vertex() {
	float h = get_height(VERTEX.xz);
	color_height = h;
	
	
	float shore_line = step(blue_line, color_height);
	float mountains_line = smoothstep(green_line, white_line, color_height);
	float ran = texture(noisemap, VERTEX.xz * 8.).x * MOUNTAINS_FACTOR;
	h = mix(blue_line, h, shore_line);
	VERTEX.y = h * HEIGHT_FACTOR ;
	float anim = mix(sin(TIME * 2. + VERTEX.z * ran) * cos(TIME * 2. + VERTEX.x * ran), 0., shore_line);

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
	alb.g = mix(.2 + ran * .05, 	alb.g, b_line);
	alb.b = mix(.7, 				alb.b, b_line);
	
	EMISSION = mix(vec3(0.), vec3(.1, .2, 1.), g_line);
	TRANSMISSION = mix(vec3(0.), vec3(.3, .3, 1.), g_line);
	TRANSMISSION += mix(vec3(color_height * ran * 8.), vec3(0.), b_line);
	TRANSMISSION += mix(vec3(.5, 0.8, .2), TRANSMISSION, g_line);
	
	SPECULAR = mix(1., .4, b_line);
	ROUGHNESS = .7;
	METALLIC = mix(0.3, 0., b_line);
	
	ALBEDO = alb;
}