//--------------------------------------------------------------------------------------
// Colour Tint Post-Processing Pixel Shader
//--------------------------------------------------------------------------------------
// Just samples a pixel from the scene texture and multiplies it by a fixed colour to tint the scene

#include "Common.hlsli"


//--------------------------------------------------------------------------------------
// Textures (texture maps)
//--------------------------------------------------------------------------------------

// The scene has been rendered to a texture, these variables allow access to that texture
Texture2D    SceneTexture : register(t0);
SamplerState PointSample  : register(s0); // We don't usually want to filter (bilinear, trilinear etc.) the scene texture when
                                          // post-processing so this sampler will use "point sampling" - no filtering


//--------------------------------------------------------------------------------------
// Shader code
//--------------------------------------------------------------------------------------

// Post-processing shader that tints the scene texture to a given colour
float4 main(PostProcessingInput input) : SV_Target
{
	const float effectStrength = 0.005f;
	
	float3 oceanBlue = { 0, 0.4, 0.6 };
	//// Sample a pixel from the scene texture and multiply it with the tint colour (comes from a constant buffer defined in Common.hlsli)
	//float3 colour = (SceneTexture.Sample(PointSample, (input.sceneUV + sin(gWiggle) / 100)).rgb) * oceanBlue;

	// Haze is a combination of sine waves in x and y dimensions
	float SinX = sin(input.areaUV.x * radians(1440.0f) + gUnderwaterTimer * 3.0f);
	float SinY = sin(input.areaUV.y * radians(3600.0f) + gUnderwaterTimer * 3.7f);
	
	// Offset for scene texture UV based on haze effect
	// Adjust size of UV offset based on the constant EffectStrength, the overall size of area being processed, and the alpha value calculated above
	float2 hazeOffset = float2(SinY, SinX) * effectStrength * gArea2DSize;

	// Get pixel from scene texture, offset using haze
	float3 colour = SceneTexture.Sample(PointSample, input.sceneUV + hazeOffset).rgb * oceanBlue;
	
	// Got the RGB from the scene texture, set alpha to 1 for final output
	return float4(colour, 1.0f);
}