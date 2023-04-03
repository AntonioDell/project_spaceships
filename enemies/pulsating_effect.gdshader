shader_type spatial;
render_mode unshaded;

uniform vec3 pulsating_color = vec3(1.0, 0.0, 0.0);
uniform float min_frequency = 1.0;
uniform float max_frequency = 10.0;
uniform float pulsation_duration = 5.0;
uniform float red_duration = 1.0;
uniform float min_alpha = 0.2;
uniform float max_alpha = 1.0;
uniform float glow_intensity = 1.5;
uniform float glow_threshold = 0.8;
uniform bool is_visible = false;

varying float start_time;

void vertex(){
	if(is_visible && start_time == 0.0){
		start_time = TIME;
	} else if(!is_visible) {
		start_time = 0.0;
	}
}

// Function to generate a seeded random value between 0 and 1
float seeded_random(vec2 seed) {
	return fract(sin(dot(seed, vec2(12.9898, 78.233))) * 43758.5453);
}

float pulsate(vec2 seed) {
	if (!is_visible) {
		return 0.0;
	}
	float time = mod(TIME-start_time, pulsation_duration + red_duration);
	if (time > pulsation_duration) {
		return 1.0;
	}
	float progress = time / pulsation_duration;
	float frequency = mix(min_frequency, max_frequency, progress);
	float random_offset = seeded_random(seed) * 0.5 + 0.5;
	return (sin((time + random_offset) * frequency * 2.0 * 3.14159265) + 1.0) / 2.0;
}

float fade_in(float progress){
	if (!is_visible) {
		return min_alpha;
	}
	return  mix(min_alpha, max_alpha, smoothstep(0.0, 1.0, progress));
}

void fragment() {
	vec2 seed = NODE_POSITION_WORLD.xy;
	float intensity = pulsate(seed);
	float progress = mod(TIME-start_time, pulsation_duration + red_duration) / (pulsation_duration + red_duration);
	float glow = intensity > glow_threshold ? (intensity - glow_threshold) * glow_intensity : 0.0;
	// Needs to be changed to COLOR
	ALBEDO = pulsating_color * (intensity + glow);
	ALPHA = fade_in(progress);
}
