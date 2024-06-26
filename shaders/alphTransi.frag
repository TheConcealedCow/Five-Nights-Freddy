#pragma header

uniform float alph;
vec2 uv = openfl_TextureCoordv;
void main() {
	vec4 newCol = flixel_texture2D(bitmap, uv);
	newCol *= alph;
	gl_FragColor = newCol;
}
