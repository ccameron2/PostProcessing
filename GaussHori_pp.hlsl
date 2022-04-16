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

// Where sigma is blur amount and x is kernal values from negative to positive
float guassianFunction(float x, float sigma)
{
	float guassianWeight = exp(pow(-x, 2.0f) / (2.0f * sigma * sigma));
	return guassianWeight;
}


//--------------------------------------------------------------------------------------
// Shader code
//--------------------------------------------------------------------------------------

// Post-processing shader that tints the scene texture to a given colour
float4 main (PostProcessingInput input) : SV_Target
{
	const float offset[] = { 0.0, 1.0, 2.0, 3.0, 4.0 };
	const float weight[] = {0.2270270270, 0.1945945946, 0.1216216216, 0.0540540541, 0.0162162162};	

	float3 colour = SceneTexture.Sample(PointSample, input.sceneUV / gViewportWidth) * weight[0];

	for (int i = 1; i < 5; i++)
	{
		colour += SceneTexture.Sample(PointSample, (input.sceneUV + float2(offset[i], 0) / gViewportWidth)) * weight[i];
		colour += SceneTexture.Sample(PointSample, (input.sceneUV - float2(offset[i], 0) / gViewportWidth)) * weight[i];
	}			  

	return float4(colour, 0.1);
}