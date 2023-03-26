shader_type spatial;
render_mode blend_mix;

uniform vec3 pulsating_color = vec3(1.0, 0.0, 0.0);
uniform float min_frequency = .1;
uniform float max_frequency = 2.0;
uniform float pulsation_duration = 2.0;
uniform float red_duration = .2;
uniform float min_alpha = 0.4;
uniform float max_alpha = .8;

float pulsate() {
    float time = mod(TIME, pulsation_duration + red_duration);
    if (time > pulsation_duration) {
        return 1.0;
    }
    float progress = time / pulsation_duration;
    float frequency = mix(min_frequency, max_frequency, progress);
    return (sin(time * frequency * 2.0 * 3.14159265) + 1.0) / 2.0;
}

void fragment() {
    float intensity = pulsate();
    float progress = mod(TIME, pulsation_duration + red_duration) / (pulsation_duration + red_duration);
    float alpha = mix(min_alpha, max_alpha, progress);
    ALBEDO = pulsating_color * intensity;
    ALPHA = alpha;
}