shader_type spatial;

// =====================================================================
//  MAP SPACE
//  All road geometry below is written in METERS on a 400 x 360 map.
//    origin (0,0) = north-west corner (top-left in the editor's top view)
//    x: 0 -> 400  = west -> east
//    y: 0 -> 360  = north (-Z) -> south (+Z)
//  Left half  (x < 200) = town (top) + airport (bottom)
//  Right half (x > 200) = forest
//  Set Split Position to 0.5 so the colour split matches the roads.
// =====================================================================

// Must match the Floor CSGBox3D size (x, z)
uniform vec2 map_size = vec2(400.0, 360.0);

// ---- your original parameters (names unchanged) ----
uniform vec4 concrete_color : source_color = vec4(0.82, 0.82, 0.82, 1.0);
uniform vec4 forest_color : source_color = vec4(0.37, 0.91, 0.76, 1.0);
uniform float split_position : hint_range(0.0, 1.0) = 0.5;
uniform float smoothness : hint_range(0.0, 0.2) = 0.0;

// ---- roads ----
uniform vec4 road_color : source_color = vec4(0.16, 0.16, 0.18, 1.0);
uniform vec4 island_color : source_color = vec4(0.55, 0.72, 0.40, 1.0);
uniform vec4 airport_color : source_color = vec4(0.60, 0.60, 0.62, 1.0);
uniform float town_road_width : hint_range(2.0, 20.0) = 10.0;
uniform float forest_road_width : hint_range(2.0, 20.0) = 8.0;

// ---- guides (turn off when you are done placing things) ----
uniform bool show_guides = false;
uniform vec4 fence_color : source_color = vec4(0.95, 0.55, 0.15, 1.0);
uniform vec4 gate_color : source_color = vec4(1.0, 0.9, 0.1, 1.0);
uniform vec4 mountain_guide_color : source_color = vec4(0.2, 0.8, 1.0, 1.0);

// ---------------------------------------------------------------------
//  LAYOUT CONSTANTS (meters)
// ---------------------------------------------------------------------
const float TOWN_W = 200.0;

// Town: roundabout in the middle of the town block
const vec2  ROUND_C = vec2(100.0, 85.0);
const float ROUND_ISLAND_R = 25.0;

// Airport: fence rectangle x 6..194, y 234..354  (town+strip 65% / airport 35%)
const float AIRPORT_TOP = 234.0;
const vec2  AIRPORT_C = vec2(100.0, 294.0);
const vec2  AIRPORT_HALF = vec2(94.0, 60.0);

// Forest: radio-tower roundabout and the free zone for your mountain
const vec2  TOWER_C = vec2(300.0, 326.0);
const float TOWER_ISLAND_R = 11.0;
const vec2  MOUNTAIN_C = vec2(300.0, 185.0);
const float MOUNTAIN_GUIDE_R = 48.0;

// Forest loop. Leaves the town on the north street (y=40) and returns on
// the south street (y=145). Control points are smoothed with a Catmull-Rom
// spline, so just move a point to reshape the road. Keep them roughly
// 25-35 m apart. Point #5 (322, 38) is where the exit road branches off.
const int FOREST_N = 15;
const vec2 FOREST_ROAD[FOREST_N] = vec2[FOREST_N](
	vec2(200.0, 40.0),  vec2(228.0, 26.0),  vec2(258.0, 44.0),  vec2(290.0, 28.0),  vec2(322.0, 38.0),  
	vec2(381.0, 85.0), vec2(350.0, 180.0), vec2(390.0, 225.0), vec2(360.0, 290.0), vec2(330.0, 320.0), 
	vec2(268.0, 330.0), vec2(250.0, 250.0), vec2(300.0, 200.0), vec2(214.0, 150.0), vec2(200.0, 145.0)
);

// Exit road: starts ON the loop (same point as #5) and leaves the map
// through the top-right corner.
const int BRANCH_N = 2;
const vec2 BRANCH_ROAD[BRANCH_N] = vec2[BRANCH_N](
	vec2(322.0, 38.0), vec2(412.0, -8.0)
);

// ---------------------------------------------------------------------
//  HELPERS
// ---------------------------------------------------------------------
varying vec2 map_pos;

void vertex() {
	// Local position, so it does not depend on the CSG UV layout
	map_pos = VERTEX.xz + map_size * 0.5;
}

float seg_dist(vec2 p, vec2 a, vec2 b) {
	vec2 pa = p - a;
	vec2 ba = b - a;
	float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
	return length(pa - ba * h);
}

// Distance to one Catmull-Rom piece (p1 -> p2). Pieces far from the pixel
// are skipped using the straight chord, which keeps the shader cheap.
float spline_seg_dist(vec2 p, vec2 p0, vec2 p1, vec2 p2, vec2 p3, float reach) {
	float chord = seg_dist(p, p1, p2);
	if (chord > reach + 0.45 * distance(p1, p2)) {
		return chord;
	}
	float d = 100000.0;
	vec2 prev = p1;
	for (int k = 1; k <= 6; k++) {
		float t = float(k) / 6.0;
		vec2 q = 0.5 * ((2.0 * p1)
			+ (p2 - p0) * t
			+ (2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * t * t
			+ (3.0 * p1 - p0 - 3.0 * p2 + p3) * t * t * t);
		d = min(d, seg_dist(p, prev, q));
		prev = q;
	}
	return d;
}

float forest_road_dist(vec2 p, float reach) {
	float d = 100000.0;
	for (int i = 0; i < FOREST_N - 1; i++) {
		vec2 p0 = FOREST_ROAD[max(i - 1, 0)];
		vec2 p1 = FOREST_ROAD[i];
		vec2 p2 = FOREST_ROAD[i + 1];
		vec2 p3 = FOREST_ROAD[min(i + 2, FOREST_N - 1)];
		d = min(d, spline_seg_dist(p, p0, p1, p2, p3, reach));
	}
	return d;
}

float branch_road_dist(vec2 p, float reach) {
	float d = 100000.0;
	for (int i = 0; i < BRANCH_N - 1; i++) {
		vec2 p0 = BRANCH_ROAD[max(i - 1, 0)];
		vec2 p1 = BRANCH_ROAD[i];
		vec2 p2 = BRANCH_ROAD[i + 1];
		vec2 p3 = BRANCH_ROAD[min(i + 2, BRANCH_N - 1)];
		d = min(d, spline_seg_dist(p, p0, p1, p2, p3, reach));
	}
	return d;
}

float town_road_dist(vec2 p, float width) {
	float d = 100000.0;
	// three north-south avenues, all run down to the airport fence
	d = min(d, seg_dist(p, vec2(40.0, 0.0),  vec2(40.0, AIRPORT_TOP)));
	d = min(d, seg_dist(p, vec2(100.0, 0.0), vec2(100.0, AIRPORT_TOP)));
	d = min(d, seg_dist(p, vec2(160.0, 0.0), vec2(160.0, AIRPORT_TOP)));
	// three east-west streets (the middle one passes through the roundabout)
	d = min(d, seg_dist(p, vec2(0.0, 40.0),  vec2(TOWN_W, 40.0)));
	d = min(d, seg_dist(p, vec2(0.0, 85.0),  vec2(TOWN_W, 85.0)));
	d = min(d, seg_dist(p, vec2(0.0, 145.0), vec2(TOWN_W, 145.0)));
	// border road between town and forest
	d = min(d, seg_dist(p, vec2(TOWN_W, 0.0), vec2(TOWN_W, 145.0)));
	// roundabout ring
	d = min(d, abs(length(p - ROUND_C) - (ROUND_ISLAND_R + width * 0.5)));
	return d;
}

float sd_box(vec2 p, vec2 c, vec2 h) {
	vec2 q = abs(p - c) - h;
	return length(max(q, vec2(0.0))) + min(max(q.x, q.y), 0.0);
}

// 1 inside the stroke, 0 outside, anti-aliased by one pixel footprint
float stroke(float d, float half_w, float aa) {
	return 1.0 - smoothstep(half_w - aa, half_w + aa, d);
}

float box_mask(vec2 p, vec2 c, vec2 h, float aa) {
	return 1.0 - smoothstep(-aa, aa, sd_box(p, c, h));
}

// ---------------------------------------------------------------------
//  FRAGMENT
// ---------------------------------------------------------------------
void fragment() {
	vec2 p = map_pos;
	vec2 fw = fwidth(p);
	float aa = max(max(fw.x, fw.y), 0.0001);

	// 1. ground: concrete (town side) / forest, same split as before
	float u = p.x / map_size.x;
	float town_amt = 1.0 - smoothstep(split_position - smoothness - 0.0005,
			split_position + smoothness + 0.0005, u);
	vec3 col = mix(forest_color.rgb, concrete_color.rgb, town_amt);

	// 2. roads
	float tw = town_road_width * 0.5;
	float fh = forest_road_width * 0.5;
	float reach = fh + 2.0 * aa;

	float road = stroke(town_road_dist(p, town_road_width), tw, aa);

	float d_forest = 100000.0;
	if (p.x > TOWN_W - reach) {
		d_forest = min(forest_road_dist(p, reach), branch_road_dist(p, reach));
	}
	// radio-tower roundabout ring (the loop passes through its centre)
	//d_forest = min(d_forest, abs(length(p - TOWER_C) - (TOWER_ISLAND_R + fh)));
	road = max(road, stroke(d_forest, fh, aa));

	col = mix(col, road_color.rgb, road);

	// 3. roundabout islands (drawn over the roads that cross them)
	float isl_town = 1.0 - smoothstep(ROUND_ISLAND_R - aa, ROUND_ISLAND_R + aa, length(p - ROUND_C));
	//float isl_tower = 1.0 - smoothstep(TOWER_ISLAND_R - aa, TOWER_ISLAND_R + aa, length(p - TOWER_C));
	col = mix(col, island_color.rgb, isl_town);

	// 4. airport ground (covers the road ends inside the fence)
	float air = box_mask(p, AIRPORT_C, AIRPORT_HALF, aa);
	col = mix(col, airport_color.rgb, air);

	// 5. guides: fence, gate markers, mountain zone
	if (show_guides) {
		float fence = stroke(abs(sd_box(p, AIRPORT_C, AIRPORT_HALF)), 0.8, aa);
		col = mix(col, fence_color.rgb, fence);

		// one gate marker where each of the three avenues meets the fence
		float gates = box_mask(p, vec2(40.0, AIRPORT_TOP), vec2(6.0, 2.5), aa);
		gates = max(gates, box_mask(p, vec2(100.0, AIRPORT_TOP), vec2(10.0, 2.5), aa)); // main gate
		gates = max(gates, box_mask(p, vec2(160.0, AIRPORT_TOP), vec2(6.0, 2.5), aa));
		col = mix(col, gate_color.rgb, gates);

		float mtn = stroke(abs(length(p - MOUNTAIN_C) - MOUNTAIN_GUIDE_R), 0.7, aa);
		col = mix(col, mountain_guide_color.rgb, mtn);
	}

	ALBEDO = col;
	ROUGHNESS = 0.9;
}