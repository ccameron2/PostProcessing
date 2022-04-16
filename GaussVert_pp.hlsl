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
	// Offsets and weights
	const float offset[] = { 0.0, 1.0, 2.0, 3.0, 4.0 };
	const float weight[] = {0.2270270270, 0.1945945946, 0.1216216216, 0.0540540541, 0.0162162162};
	
	// Sample texture colour at first weight 
	float3 colour = SceneTexture.Sample(PointSample, input.sceneUV / gViewportHeight) * weight[0];

	// Sample pixels around current pixel at decreasing weights and increasing offsets and add to original colour
	for (int i = 1; i < 5; i++)
	{
		colour += SceneTexture.Sample(PointSample, (input.sceneUV + float2(0, offset[i]) / gViewportHeight)) * weight[i];
		colour += SceneTexture.Sample(PointSample, (input.sceneUV - float2(0, offset[i]) / gViewportHeight)) * weight[i];
	}
	
	return float4(colour, 1);
}