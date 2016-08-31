varying vec4 f_position;
varying vec3 f_view_normal;
varying vec4 f_shadow_coords;

uniform vec3 u_view_position;
uniform mat4 u_model, u_view; 

#ifdef VERTEX
	attribute vec3 VertexNormal;

	uniform mat4 u_projection;
	uniform mat4 u_shadow_vp;

	vec4 position(mat4 mvp, vec4 v_position) {
		f_position = v_position;

		vec4 world_pos = u_model * v_position;
		f_shadow_coords = u_shadow_vp * world_pos;

		f_view_normal = normalize(u_view_position - world_pos.xyz);

		return u_projection * u_view * world_pos;
	}
#endif

#ifdef PIXEL
	#define MAX_LIGHTS 4
	uniform float u_time;
	uniform int  u_lights = 1;
	uniform int  u_shadow_index = 0;
	uniform sampler2DShadow shadow_texture;
	uniform vec3 u_light_direction[MAX_LIGHTS];
	uniform vec3 u_light_color[MAX_LIGHTS];
	uniform vec4 u_fog_color;
	uniform vec2 u_clips;

	vec3 permute(vec3 x) { return mod(((x*34.0)+1.0)*x, 289.0); }
	float snoise(vec2 v) {
		const vec4 C = vec4(
			 0.211324865405187, 0.366025403784439,
			-0.577350269189626, 0.024390243902439
		);
		vec2 i  = floor(v + dot(v, C.yy) );
		vec2 x0 = v - i + dot(i, C.xx);
		vec2 i1;
		i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
		vec4 x12 = x0.xyxy + C.xxzz;
		x12.xy -= i1;
		i = mod(i, 289.0);
		vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
		+ i.x + vec3(0.0, i1.x, 1.0 ));
		vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy),
		dot(x12.zw,x12.zw)), 0.0);
		m = m*m ;
		m = m*m ;
		vec3 x = 2.0 * fract(p * C.www) - 1.0;
		vec3 h = abs(x) - 0.5;
		vec3 ox = floor(x + 0.5);
		vec3 a0 = x - ox;
		m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );
		vec3 g;
		g.x  = a0.x  * x0.x  + h.x  * x0.y;
		g.yz = a0.yz * x12.xz + h.yz * x12.yw;
		return 130.0 * dot(m, g);
	}

	vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
		// vec2 uv = screen_coords.xy / love_ScreenSize.xy;
		vec2 uv = texture_coords;
		uv += vec2(-0.05 * u_time, 0.025 * u_time);
		uv *= vec2(0.8, 1.1);

		float wave = 0.0;
		wave += snoise(uv *  5. - vec2(u_time, u_time * 0.125));
		wave += snoise(uv *  5. + vec2(u_time, u_time * 0.125));
		wave += snoise(uv * 15. - vec2(u_time * 0.07, u_time));
		wave += snoise(uv * 15. + vec2(u_time * 0.07, u_time));

		wave *= 0.5;
		wave += 0.5;

		vec3 normal;
		normal.x = dFdx(wave);
		normal.y = dFdy(wave);
		normal.z = sqrt(1.0 - normal.x*normal.x - normal.y*normal.y);

		float fresnel = clamp(dot(normal, f_view_normal), 0.0, 1.0);
		fresnel = pow(fresnel, 2.0);

		normal = normalize(mat3(u_view * u_model) * normal);

		vec3 r = reflect(normalize((u_view * u_model * f_position).xyz), normal);
		float m = 2. * sqrt( 
			pow( r.x, 2. ) + 
			pow( r.y, 2. ) + 
			pow( r.z + 1., 2. ) 
		);

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

		vec4 final = vec4(Texel(texture, r.xy / m + .5).rgb, 1.0);
		vec3 light = vec3(0.0);
		for (int i = 0; i < u_lights; ++i) {
			light += u_light_color[i] * dot(normal, u_light_direction[i]);
			if (i == u_shadow_index && f_shadow_coords.w > 0.0) {
				float illuminated = 0.0;
				for (int k = 0; k < 6; k++){
					float factor = shadow2DProj(shadow_texture, f_shadow_coords + vec4(vec2(poisson_disk[k]/2048.0), 0.0, 0.0)).z;
					illuminated += factor * (1.0/6.0);
				}
				final.rgb *= illuminated;
			}
		}
		final.rgb *= light;

		float depth = 1.0 / gl_FragCoord.w;
		float scaled = (depth - u_clips.x) / (u_clips.y - u_clips.x);
		scaled = clamp(pow(scaled, 3.0), 0.0, 1.0);

		vec4 fog_color = gammaToLinear(u_fog_color);
		fog_color.a = 1.0;

		return mix(mix(final, color, clamp(fresnel + 0.25, 0.0, 1.0)), fog_color, scaled);

		// return vec4(normal * 0.5 + 0.5, 1.0);
	}
#endif
