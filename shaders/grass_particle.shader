// -----------------------------------------------------------------------------
// VEGETATION PARTICLE SHADER - simplified
// -----------------------------------------------------------------------------
// based on many tutorials / final version by Krzysztof Jankowski
// (c) P1X 2018 / fill free to use just don't bother me
// -----------------------------------------------------------------------------

shader_type particles;

// SETTINGS --------------------------------------------------------------------

// SET RANDOM FLOAT FOR EACH VEGETATION TYPE
uniform float SEED = 0.1234;

// TERRAIN SETTINGS
uniform float TERRAIN_HEIGHT_SCALE = 64.0;
uniform float TERRAIN_MIN_H = 0.4;
uniform float TERRAIN_MAX_H = 0.65;

// VEGETATION SETTINGS
uniform float GRASS_ROWS = 64;
uniform float GRASS_SPACING = 12.0;
uniform float GRASS_SCALE_MIN = 0.5;
uniform float GRASS_SCALE_MAX = 2.0;

// MAPS
uniform sampler2D HEIGHT_MAP;
uniform sampler2D NOISE_MAP;
uniform vec2 MAP_SIZE = vec2(1024.0, 1024.0);


// HELPERS ---------------------------------------------------------------------

// RETURNS HEIGHT FROM HEIGHT_MAP
float get_height(vec2 pos) {
	pos -= 0.5 * MAP_SIZE;
	pos /= MAP_SIZE; // center
	float h = texture(HEIGHT_MAP, pos).r; // read height from texture
	return h; // adjust for the overall terrain SCALE
}

// THREE DIMENSIONAL MATRIX MANIPULATION
mat4 enterTheMatrix(vec3 pos, vec3 axis, float angle, float SCALE){
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;

	// converts matrix for position, angle (for each axix) and SCALE
    return mat4(vec4((oc * axis.x * axis.x + c)* SCALE,		oc * axis.x * axis.y - axis.z * s,	oc * axis.z * axis.x + axis.y * s,	0.0),
                vec4(oc * axis.x * axis.y + axis.z * s,		(oc * axis.y * axis.y + c) * SCALE,	oc * axis.y * axis.z - axis.x * s,	0.0),
                vec4(oc * axis.z * axis.x - axis.y * s,		oc * axis.y * axis.z + axis.x * s,	(oc * axis.z * axis.z + c) * SCALE,	0.0),
                vec4(pos.x,									pos.y,								pos.z,								1.0));
}

// VERTEX ----------------------------------------------------------------------

void vertex() {

	vec3 pos = vec3(0.0, 0.0, 0.0);
	pos.z = float(INDEX);
	pos.x = mod(pos.z, GRASS_ROWS);
	pos.z = (pos.z - pos.x) / GRASS_ROWS; // obtain our position based on which particle we're rendering


	pos.x -= GRASS_ROWS * 0.5;
	pos.z -= GRASS_ROWS * 0.5; // center
	pos *= GRASS_SPACING; // apply grass spacing

	// center on our particle location but within our spacing and SCALE
	pos.x += (EMISSION_TRANSFORM[3][0] - mod(EMISSION_TRANSFORM[3][0], GRASS_SPACING));
	pos.z += (EMISSION_TRANSFORM[3][2] - mod(EMISSION_TRANSFORM[3][2], GRASS_SPACING));


	vec2 noise = texture(NOISE_MAP, pos.xz).xy; // generate some noise based on our _world_ position

	pos.x += (noise.x * 8.0 ) * GRASS_SPACING;
	pos.z += (noise.y * 8.0 ) * GRASS_SPACING; // apply noise and spacing
	pos.y = get_height(pos.xz); // apply height

	vec2 feat_pos = pos.xz;
	feat_pos -= 0.5 * MAP_SIZE;
	feat_pos /= MAP_SIZE; // center
	
	// remove particle if
	if (pos.y < TERRAIN_MIN_H - noise.y * 0.1 || pos.y > TERRAIN_MAX_H + noise.x * 0.1) { // don't fit any terrain mask or is underwater
		pos.y = -100000.0;
	}
	
	pos.y *= TERRAIN_HEIGHT_SCALE;
	pos.y -= 2. + noise.x * 4.0;
	
	// calculate random scaling but within min/max
	float scale = noise.x * GRASS_SCALE_MAX;

	// do the final transformation
	TRANSFORM = enterTheMatrix(
		vec3(pos.x, pos.y, pos.z), // set position
		vec3(0.0, 1.0, 0.0), // lock Y axis
		clamp(noise.x * 320.0, 0.0, 320.0), // rotate 0-360 (over Y)
		scale); // SCALE
}

// -----------------------------------------------------------------------------
// EOF.
// -----------------------------------------------------------------------------