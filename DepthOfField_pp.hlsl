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

// This shader also uses a bloom texture
Texture2D BlurTexture : register(t1);
SamplerState TrilinearWrap : register(s1);

// This shader also uses a star texture
Texture2D DistanceTexture : register(t2);


//--------------------------------------------------------------------------------------
// Shader code
//--------------------------------------------------------------------------------------

// Post-processing shader that tints the scene texture to a given colour
float4 main(PostProcessingInput input) : SV_Target
{
	// Sample a pixel from the scene texture and multiply it with the tint colour (comes from a constant buffer defined in Common.hlsli)
	float3 finalColour = SceneTexture.Sample(PointSample, input.sceneUV).rgb;
	
	// Sample a pixel from the bloom map created in the lighting pixel shader
	float3 blurColour = BlurTexture.Sample(TrilinearWrap, input.sceneUV).rgb;
	
	float distance = DistanceTexture.Sample(TrilinearWrap, input.sceneUV).a;
	
	if (distance >= gMax || distance <= gMin)
	{
		finalColour = blurColour;
	}
	
	// Got the RGB from the scene texture, set alpha to 1 for final output
	return float4(finalColour, 1.0f);
}