/**
* Ported from the original unity shader by Erik Roystan Ross
* https://roystan.net/articles/toon-water.html
* https://github.com/IronWarrior/ToonWaterShader
* Camera Depth taken from Bastiaan Olij's video on: https://www.youtube.com/watch?v=Jq3he9Lbj7M
*/

shader_type spatial;

const float SMOOTHSTEP_AA = 0.01;

uniform sampler2D surfaceNoise;
uniform sampler2D distortNoise;
uniform bool enabled;
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
uniform float amount: hint_range(0.2, 5.0, 0.1) = 0.8;
uniform float speed: hint_range(0.1, 5.0, 0.1) = 1;
uniform float beer_factor = 0.8;

uniform float foam_distance = 0.01;
uniform float foam_max_distance = 0.4;
uniform float foam_min_distance = 0.04;
uniform vec4 foam_color: source_color = vec4(1.0);

uniform vec2 surface_noise_tiling = vec2(1.0, 4.0);
uniform vec3 surface_noise_scroll = vec3(0.03, 0.03, 0.0);
uniform float surface_noise_cutoff: hint_range(0, 1) = 0.777;
uniform float surface_distortion_amount: hint_range(0, 1) = 0.27;

uniform vec4 _DepthGradientShallow: source_color = vec4(0.325, 0.807, 0.971, 0.725);
uniform vec4 _DepthGradientDeep: source_color = vec4(0.086, 0.407, 1, 0.749);
uniform float _DepthMaxDistance: hint_range(0, 1) = 1.0;
uniform float _DepthFactor = 1.0;

varying vec2 noiseUV;
varying vec2 distortUV;
varying vec3 viewNormal;

vec4 alphaBlend(vec4 top, vec4 bottom)
{
	vec3 color = (top.rgb * top.a) + (bottom.rgb * (1.0 - top.a));
	float alpha = top.a + bottom.a * (1.0 - top.a);

	return vec4(color, alpha);
}

float generateOffset(float x, float z, float val1, float val2, float time) {
	float radiansX = ((mod(x + z * x * val1, amount) / amount) + (time * speed) * mod(x * 0.8 + z, 1.5)) * 2.0 * 3.14;
	float radiansZ = ((mod(val2 * (z * x + x * z), amount) / amount) + (time * speed) * 2.0 * mod(x, 2.0)) * 2.0 * 3.14;

	return amount * 0.5 * (sin(radiansZ) * cos(radiansX));
}
vec3 applyDistortion(vec3 vertex, float time) {
	float xd = generateOffset(vertex.x, vertex.z, 0.2, 0.1, time);
	float yd = generateOffset(vertex.x, vertex.z, 0.1, 0.3, time);
	float zd = generateOffset(vertex.x, vertex.z, 0.15, 0.2, time);

	return vertex + vec3(xd, yd, zd);
}

void vertex() {
	//VERTEX = applyDistortion(VERTEX, TIME * 0.1);
	viewNormal = (MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
	noiseUV = UV * surface_noise_tiling;
	distortUV = UV;

}

void fragment(){
	// https://www.youtube.com/watch?v=Jq3he9Lbj7M
	if(enabled){
		float depth = texture(DEPTH_TEXTURE, SCREEN_UV).r;
		//depth = depth * 2.0 - 1.0;
		//depth = PROJECTION_MATRIX[3][2] / (depth + PROJECTION_MATRIX[2][2]);
		//depth = depth + VERTEX.z;
		//depth = exp(-depth * beer_factor);
		//depth = 1.0 - depth;

		// Still unsure how to get properly the NORMAL from the camera
		// this was my best attempt
		vec3 existingNormal = vec3(dFdx(depth), dFdy(depth), 0);

		float normalDot = clamp(dot(existingNormal.xyz, viewNormal), 0.0, 1.0);
		float foamDistance = mix(foam_max_distance, foam_min_distance, normalDot);

		float foamDepth = clamp(depth / foamDistance, 0.0, 1.0);
		float surfaceNoiseCutoff = foamDepth * surface_noise_cutoff;

		vec4 distortNoiseSample = texture(distortNoise, distortUV);
		vec2 distortAmount = (distortNoiseSample.xy * 2.0 -1.0) * surface_distortion_amount;

		vec2 noise_uv = vec2(
			(noiseUV.x + TIME * surface_noise_scroll.x) + distortAmount.x ,
			(noiseUV.y + TIME * surface_noise_scroll.y + distortAmount.y)
		);
		float surfaceNoiseSample = texture(surfaceNoise, noise_uv).r;
		float surfaceNoiseAmount = smoothstep(surfaceNoiseCutoff - SMOOTHSTEP_AA, surfaceNoiseCutoff + SMOOTHSTEP_AA, surfaceNoiseSample);

		float waterDepth = clamp(depth / _DepthMaxDistance, 0.0, 1.0) * _DepthFactor;
		vec4 waterColor = mix(_DepthGradientShallow, _DepthGradientDeep, waterDepth);

		vec4 surfaceNoiseColor = foam_color;
	    surfaceNoiseColor.a *= surfaceNoiseAmount;
		vec4 color = alphaBlend(surfaceNoiseColor, waterColor);

		ALBEDO = color.rgb;
		ALPHA = color.a;
		}
}