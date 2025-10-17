shader_type spatial;
render_mode cull_disabled;

uniform vec3 color : source_color;
uniform vec3 color2 : source_color;
uniform sampler2D noise;
uniform float noiseScale = 20.0;

varying vec3 worldPos;

// Wind, might use later
float worley2(vec2 p){
	vec2 points[3];
	points[0] = vec2(0.5, 0.5);
	points[1] = vec2(0.25, 0.11);
	points[2] = vec2(0.75, 0.8);
	float dist = 1.0;
	for(int i=0;i<3;i++){
		dist = min(dist, length(p - points[i]));
	}
	return dist;
}

void vertex() {
	worldPos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec3 noiseLevel = texture(noise, worldPos.xz / noiseScale).rgb;
	ALBEDO = mix(color, color2, UV.y);// * mix(color, color2, noiseLevel.r);
	if(!FRONT_FACING){
		NORMAL = -NORMAL;
	}
}
