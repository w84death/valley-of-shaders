shader_type spatial;

uniform vec2 heightmap_size = vec2(1024.0, 512.0);
uniform float height_factor = 64.0;
uniform float UV_FACTOR = 16.;
varying float color_height;
uniform sampler2D heightmap;
uniform sampler2D noisemap;
uniform float green_line = 0.45;
uniform float blue_line = 0.2;

float get_height(vec2 pos) {
	pos -= .5 * heightmap_size;
	pos /= heightmap_size;
	return texture(heightmap, pos).r;
}

void vertex() {
	float h = get_height(VERTEX.xz);
	color_height = h;
	float shore_line = step(blue_line, color_height);
	h = mix(blue_line, h, shore_line);
	float anim = mix(sin(TIME*4.+VERTEX.z*.2) * sin(TIME*6.+VERTEX.x*.5), 0., shore_line);
	VERTEX.y = h * height_factor + anim;
	
	float A = 0.4;
	float B = 0.2;
	TANGENT = normalize( vec3(0., get_height(VERTEX.xz + vec2(0.0, B)) - get_height(VERTEX.xz + vec2(0.0, -0.1)), A));
	BINORMAL = normalize( vec3(A, get_height(VERTEX.xz + vec2(B, 0.0)) - get_height(VERTEX.xz + vec2(-0.1, 0.0)), 0.0));
	NORMAL = cross(TANGENT, BINORMAL);
}

void fragment() {
	float ran = texture(noisemap, UV * UV_FACTOR).x;
	vec3 alb = vec3(color_height);
	
	float g_line = step(green_line + ran * .3, color_height);
	alb.g *= mix(1.5 - ran*.5, 1., g_line);
	alb.b *= mix(0.4, 1., g_line);
	alb *=  mix(1.0 - ran*.7, 1., g_line);
	
	float b_line = step(blue_line + ran * .1, color_height);
	alb.g = mix(.4, alb.g, b_line);
	alb.b = mix(1., alb.b, b_line);
	
	ALBEDO = alb;
	SPECULAR = 0.5;
	ROUGHNESS = 1.;
	METALLIC = 0.;
}