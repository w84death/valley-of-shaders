shader_type spatial;

uniform vec2 heightmap_size = vec2(1024.0, 1024.0);
uniform float height_factor = 64.0;
uniform float mountains_factor = 24.;
uniform float UV_FACTOR = 4.;
varying float color_height;
uniform sampler2D heightmap;
uniform sampler2D noisemap;
uniform float white_line = 0.9;
uniform float green_line = 0.35;
uniform float ground_line = 0.33;
uniform float blue_line = 0.32;

float get_height(vec2 pos) {
	pos -= .5 * heightmap_size;
	pos /= heightmap_size;
	return texture(heightmap, pos).r;
}

void vertex() {
	float h = get_height(VERTEX.xz);
	color_height = h;
	float shore_line = step(blue_line, color_height);
	float mountains_line = smoothstep(green_line, white_line, color_height);
	float ran = texture(noisemap, VERTEX.xz * 8.).x * mountains_factor;
	h = mix(blue_line, h, shore_line);
	float waves_factor = 1.;
	float anim = mix(sin(TIME * 2. + VERTEX.z * ran) * cos(TIME * 2. + VERTEX.x * ran) * waves_factor, 0., shore_line);
	h = h * height_factor + anim;
	float fh = mix(h, h + ran, mountains_line);
	VERTEX.y = fh;
	
	/*
	float A = 0.4;
	float B = 0.2;
	TANGENT = normalize( vec3(0., get_height(VERTEX.xz + vec2(0.0, B)) - get_height(VERTEX.xz + vec2(0.0, -0.1)), A));
	BINORMAL = normalize( vec3(A, get_height(VERTEX.xz + vec2(B, 0.0)) - get_height(VERTEX.xz + vec2(-0.1, 0.0)), 0.0));
	notEqual(RMAL = cross(TANGENT, BINORMAL);
	*/
}

void fragment() {
	float ran = texture(noisemap, UV * UV_FACTOR).x;
	vec3 alb = vec3(color_height);
	
	float g_line = step(green_line + ran * .3, color_height);
	alb.r = mix(alb.r, 1.,g_line);
	alb.g = mix(alb.g, 1., g_line);
	alb.b = mix(alb.b, 1., g_line);
	
	float y_line = step(ground_line + ran * .15, color_height);
	alb.r = mix(.2 + ran *.3, 	.3 - ran * .1, y_line);
	alb.g = mix(.2 + ran *.3, 	.9 - ran * .1, y_line);
	alb.b = mix(.1 + ran *.2, 	0.1, y_line);
	
	float b_line = step(blue_line, color_height);
	alb.r = mix(.0 + ran * .05, alb.r, b_line);
	alb.g = mix(.2 + ran * .05, alb.g, b_line);
	alb.b = mix(.7, alb.b, b_line);
	
	EMISSION = mix(vec3(0.), vec3(.1, .2, 1.), g_line);
	TRANSMISSION = mix(vec3(0.), vec3(.3, .3, 1.), g_line);
	TRANSMISSION += mix(vec3(color_height * ran * 8.), vec3(0.), b_line);
	ALBEDO = alb;
	SPECULAR = mix(1., .4, b_line);
	ROUGHNESS = 1.;
	METALLIC = mix(0.3, 0., b_line);
}