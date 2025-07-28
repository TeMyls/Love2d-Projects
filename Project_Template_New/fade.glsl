extern number time;
extern number duration;
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
  // Sample the texture color
  vec4 texColor = Texel(texture, texture_coords);

  // Set fade duration (in seconds)
  number fadeDuration = duration;

  // Calculate alpha fade factor 
  number alpha = 1.0 - clamp(time / fadeDuration, 0.0, 1.0);

  // Apply fade to the texture's alpha and multiply with vertex color
  texColor.a *= alpha;
  return texColor * color;
}