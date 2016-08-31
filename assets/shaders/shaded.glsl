// Shadows
uniform mat4 u_shadow_vp;
uniform int  u_shadow_index = 0;
uniform sampler2DShadow shadow_texture;

varying vec3 f_normal, f_view_normal;
varying vec4 f_shadow_coords;
varying vec3 f_view_direction;

#define MAX_LIGHTS 4
#define MAX_CASCADES 3
#define PI 3.14159265

#ifdef VERTEX
	 attribute vec3 VertexNormal;
	 attribute vec4 VertexWeight;
	 attribute vec4 VertexBone; // used as ints!

	 uniform vec3 u_view_direction, u_view_position;
	 uniform mat4 u_model, u_view, u_projection;
	 uniform mat4 u_bone_matrices[100]; // this is why I want UBOs...
	 uniform int	 u_skinning;

	 mat4 getDeformMatrix() {
			if (u_skinning != 0) {
				 // *255 because byte data is normalized against our will.
				 return
						u_bone_matrices[int(VertexBone.x*255.0)] * VertexWeight.x +
						u_bone_matrices[int(VertexBone.y*255.0)] * VertexWeight.y +
						u_bone_matrices[int(VertexBone.z*255.0)] * VertexWeight.z +
						u_bone_matrices[int(VertexBone.w*255.0)] * VertexWeight.w;
			}
			return mat4(1.0);
	 }

	 vec4 position(mat4 mvp, vec4 v_position) {
			mat4 transform = u_model * getDeformMatrix();
			f_normal = mat3(transform) * VertexNormal;
			f_view_direction = u_view_direction;
			f_shadow_coords = u_shadow_vp * transform * v_position;

			vec3 world_pos = (transform * v_position).xyz;
			f_view_normal = mat3(u_view) * normalize(u_view_position - world_pos.xyz);

			// f_shadow_coords *= 0.5;
			// f_shadow_coords += 0.5;
			return u_projection * u_view * transform * v_position;
	 }
#endif

#ifdef PIXEL
	// Lighting
	uniform vec3 u_light_direction[MAX_LIGHTS];
	uniform vec3 u_light_specular[MAX_LIGHTS];
	uniform vec3 u_light_color[MAX_LIGHTS];
	uniform int  u_lights = 1;
	uniform vec3 u_ambient = vec3(0.05, 0.05, 0.05);

	// Material
	uniform float u_roughness = 0.25;
	uniform float u_fresnel   = 0.0;

	// Debug
	uniform int force_color;
	uniform vec2 u_clips;
	uniform vec4 u_fog_color;

	// Diffuse
	float oren_nayar_diffuse(vec3 lightDirection, vec3 viewDirection, vec3 surfaceNormal, float roughness, float albedo) {
		float LdotV = dot(lightDirection, viewDirection);
		float NdotL = dot(lightDirection, surfaceNormal);
		float NdotV = dot(surfaceNormal, viewDirection);

		float s = LdotV - NdotL * NdotV;
		float t = mix(1.0, max(NdotL, NdotV), step(0.0, s));

		float sigma2 = roughness * roughness;
		float A = 1.0 + sigma2 * (albedo / (sigma2 + 0.13) + 0.5 / (sigma2 + 0.33));
		float B = 0.45 * sigma2 / (sigma2 + 0.09);

		return albedo * max(0.0, NdotL) * (A + B * s / t) / PI;
	}

	// Specular
	float ggx_specular(vec3 L, vec3 V, vec3 N, float roughness, float fresnel) {
		vec3 H = normalize(V+L);

		float dotNL = clamp(dot(N,L), 0.0, 1.0);
		float dotLH = clamp(dot(L,H), 0.0, 1.0);
		float dotNH = clamp(dot(N,H), 0.0, 1.0);

		float alpha = roughness * roughness;
		float alphaSqr = alpha * alpha;
		float denom = dotNH * dotNH *(alphaSqr-1.0) + 1.0;
		float D = alphaSqr/(PI * denom * denom);

		float dotLH5 = pow(1.0-dotLH,5.0);
		float F = fresnel + (1.0-fresnel) * (dotLH5);

		float k = alpha * 0.5;
		float g1v = 1.0/(dotLH*(1.0-k)+k);
		float Vs = g1v * g1v;

		return dotNL * D * F * Vs;
	}

	float random(vec3 seed, int i) {
		vec4 seed4 = vec4(seed,i);
		float dot_product = dot(seed4, vec4(12.9898,78.233,45.164,94.673));
		return fract(sin(dot_product) * 43758.5453);
	}

	vec3 shade(vec3 normal, vec4 albedo, int i, float fresnel) {
		vec3 view_direction  = normalize(f_view_direction);
		vec3 light_direction = normalize(u_light_direction[i]);

		// This Oren-nayar function causes some lighting bugs. dot(N, L) will suffice if needed... 
		// float diff = oren_nayar_diffuse(light_direction, view_direction, normal, u_roughness, 1.0);
		float diff = dot(normal, light_direction) * pow(dot(normal, light_direction), 1.0-pow(u_roughness, 2.0));
		float spec = ggx_specular(light_direction, view_direction, normal, u_roughness, fresnel);

		vec2 poisson_disk[16] = vec2[](
			vec2(-0.94201624, -0.39906216),
			vec2( 0.94558609, -0.76890725),
			vec2(-0.09418410, -0.92938870), 
			vec2( 0.34495938,  0.29387760),
			vec2(-0.91588581,  0.45771432),
			vec2(-0.81544232, -0.87912464), 
			vec2(-0.38277543,  0.27676845), 
			vec2( 0.97484398,  0.75648379),
			vec2( 0.44323325, -0.97511554),
			vec2( 0.53742981, -0.47373420),
			vec2(-0.26496911, -0.41893023), 
			vec2( 0.79197514,  0.19090188),
			vec2(-0.24188840,  0.99706507),
			vec2(-0.81409955,  0.91437590), 
			vec2( 0.19984126,  0.78641367),
			vec2( 0.14383161, -0.14100790)
		);

		// Factor in shadow for the casting light
		for (int j = 0; j < MAX_CASCADES; j++) {
			if (i == u_shadow_index && f_shadow_coords.w > 0.0) {
				float illuminated = 0.0;
				for (int k = 0; k < 6; k++){
					float factor = shadow2DProj(shadow_texture, f_shadow_coords + vec4(vec2(poisson_disk[k]/2048.0), 0.0, 0.0)).z;
					illuminated += factor * (1.0/6.0);
				}
				diff *= illuminated;
				spec *= illuminated;
			}
			break; // until we have the cascade data in...
		}
		diff = clamp(diff, 0.02, 1.0);

		vec3 color = u_light_color[i] * albedo.rgb * diff;
		color += u_light_specular[i] * spec * fresnel;

		return color;
		// return mix(color, vec3(fresnel), 0.99);
	}

	vec4 effect(vec4 tint, Image texture, vec2 texture_coords, vec2 _s) {
		if (force_color != 0)
			return tint;

		// float fresnel = pow(1.-clamp(dot(normal, normalize(f_view_normal)), 0.0, 1.0), 2.0);
		float fresnel = 0.01;
		vec3 normal = normalize(f_normal);
		vec4 albedo = texture2D(texture, texture_coords) * tint;
		vec3 color = u_ambient;

		for (int i = 0; i < u_lights; ++i) {
			color += max(shade(normal, albedo, i, fresnel), vec3(0.0));
		}

		color = mix(albedo.rgb, color, 0.9);
		// color = mix(color, vec3(fresnel), 0.995);

		float depth = 1.0 / gl_FragCoord.w;
		float scaled = (depth - u_clips.x) / (u_clips.y - u_clips.x);
		scaled = clamp(pow(scaled, 3.0), 0.0, 1.0);

		vec4 fog_color = gammaToLinear(u_fog_color);
		fog_color.a = 1.0;

		return mix(vec4(color, albedo.a), fog_color, scaled);
	}
#endif
