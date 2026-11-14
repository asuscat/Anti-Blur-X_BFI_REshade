//-------------------------------------------------------------------------------------------------
// Blur Busters CRT Beam Simulator (reference-accurate Variable MPRT) + Sony Trinitron Aperture Grille
// ReShade edition (v3)
//
// ALGORITHM CREDIT: Mark Rejhon (@BlurBusters) & Timothy Lottes (@NOTimothyLottes),
// "Blur Busters CRT Beam Simulator BFI With Seamless Gamma Correction" (MIT License).
// https://www.blurbusters.com/area51   https://blurbusters.com/crt
// Please credit Blur Busters & Timothy Lottes if this is used in your project.
//
// Install: place in  reshade-shaders/Shaders/BlurBustersCRT.fx
//-------------------------------------------------------------------------------------------------

#include "ReShade.fxh"

//-------------------------------------------------------------------------------------------------
// CRT TIMING
//-------------------------------------------------------------------------------------------------

uniform float SUBFRAMES <
    ui_category = "CRT Timing";
    ui_type = "slider";
    ui_label = "Subframes per CRT Refresh";
    ui_tooltip = "Display Hz divided by CRT Hz. 240/60 = 4.0, 144/60 = 2.4.\nDecimals allowed. Ctrl+Click to type an exact value.";
    ui_min = 1.0; ui_max = 16.0; ui_step = 0.01;
> = 4.0;

uniform bool LCD_ANTI_RETENTION <
    ui_category = "CRT Timing";
    ui_label = "LCD Anti-Retention";
    ui_tooltip = "Reference behaviour: when Subframes is an EVEN integer, add 0.001 so the beam slowly drifts instead of hitting identical pixels every cycle (prevents LCD image retention / polarity inversion artifacts).";
> = true;

uniform int SCAN_DIRECTION <
    ui_category = "CRT Timing";
    ui_type = "combo";
    ui_label = "Scan Direction";
    ui_items = "Off (global strobe)\0Top to Bottom\0Bottom to Top\0Left to Right\0Right to Left\0";
> = 1;

uniform float SIM_SPEED <
    ui_category = "CRT Timing";
    ui_type = "slider";
    ui_label = "Slow-Motion Speed (educational)";
    ui_tooltip = "1.0 = real time. Lower values slow the beam down so you can watch it scan (the reference's FPS_DIVISOR).";
    ui_min = 0.01; ui_max = 1.0; ui_step = 0.01;
> = 1.0;

//-------------------------------------------------------------------------------------------------
// BEAM / BRIGHTNESS
//-------------------------------------------------------------------------------------------------

uniform float GAIN_VS_BLUR <
    ui_category = "Beam & Brightness";
    ui_type = "slider";
    ui_label = "Gain vs Blur";
    ui_tooltip = "Reference gain. Average screen brightness = Gain x original (so 0.7 = 70% brightness).\nLower = less motion blur but dimmer. 1.0 = full brightness, no blur reduction.\nOn-time of every pixel = linear brightness x Subframes x Gain (variable MPRT).";
    ui_min = 0.001; ui_max = 1.0; ui_step = 0.001;
> = 0.7;

uniform bool HUE_LOCK <
    ui_category = "Beam & Brightness";
    ui_label = "Shared On-Time For All Channels (non-reference)";
    ui_tooltip = "OFF (reference): R, G and B each get their own on-time, so saturated colours can show slight colour shifts at the edges of the beam band within a single frame (they average out in time).\nON: all channels share one on-time and keep their ratio, so hue never shifts across the band. Same average energy.";
> = false;

uniform float RASTER_FEATHER <
    ui_category = "Beam & Brightness";
    ui_type = "slider";
    ui_label = "Raster Feathering (Seam Width)";
    ui_tooltip = "Width of the soft seam at the top and bottom edge of the scanning band, as a fraction of the beam width.\n0.0 = exact reference (hard seam).\n1.0 = fully triangular beam profile (widest seam).\nSeams cross-fade between frames, so total brightness is unchanged.";
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
> = 0.5;

uniform float DARK_FLOOR_GAIN <
    ui_category = "Beam & Brightness";
    ui_type = "slider";
    ui_label = "Dark Floor Gain";
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
> = 0.0;

uniform float POST_BRIGHTNESS <
    ui_category = "Beam & Brightness";
    ui_type = "slider";
    ui_label = "Post Brightness";
    ui_tooltip = "1.0 = reference (no extra boost). Raise to compensate for the dimming from Gain and the grille.";
    ui_min = 0.0; ui_max = 100.0; ui_step = 0.01;
> = 1.0;

uniform float EDGE_SHARPEN <
    ui_category = "Beam & Brightness";
    ui_type = "slider";
    ui_label = "Sub-Pixel Edge Sharpening";
    ui_min = 0.0; ui_max = 2.0; ui_step = 0.01;
> = 0.35;

//-------------------------------------------------------------------------------------------------
// COMPARISON
//-------------------------------------------------------------------------------------------------

uniform bool SPLITSCREEN <
    ui_category = "Comparison";
    ui_label = "Split Screen (CRT left, original right)";
    ui_tooltip = "The right side shows the original image at Gain x brightness, matching the average brightness of the CRT side.";
> = false;

uniform float SPLITSCREEN_X <
    ui_category = "Comparison";
    ui_type = "slider";
    ui_label = "Split Position";
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
> = 0.5;

//-------------------------------------------------------------------------------------------------
// GAMMA & DITHER
//-------------------------------------------------------------------------------------------------

uniform int GAMMA_MODE <
    ui_category = "Gamma & Dither";
    ui_type = "combo";
    ui_label = "Transfer Function";
    ui_tooltip = "sRGB: the reference's piecewise sRGB curve (recommended).\nPure power: uses the Input/Output gamma sliders (CRTs were close to a 2.4-2.5 power law).";
    ui_items = "sRGB (piecewise)\0Pure power (gamma sliders)\0";
> = 0;

uniform float INPUT_GAMMA <
    ui_category = "Gamma & Dither";
    ui_type = "slider";
    ui_label = "Input Gamma (power mode)";
    ui_min = 1.0; ui_max = 3.0; ui_step = 0.01;
> = 2.2;

uniform float OUTPUT_GAMMA <
    ui_category = "Gamma & Dither";
    ui_type = "slider";
    ui_label = "Output Gamma (power mode)";
    ui_tooltip = "Keep equal to Input Gamma for a neutral image.";
    ui_min = 1.0; ui_max = 3.0; ui_step = 0.01;
> = 2.2;

uniform float DITHER_STRENGTH <
    ui_category = "Gamma & Dither";
    ui_type = "slider";
    ui_label = "Dither Strength";
    ui_tooltip = "Triangular-PDF noise added before final quantization to break up horizontal banding. 1.0 = one least-significant bit.";
    ui_min = 0.0; ui_max = 2.0; ui_step = 0.01;
> = 1.0;

uniform int DITHER_BITS <
    ui_category = "Gamma & Dither";
    ui_type = "combo";
    ui_label = "Output Bit Depth";
    ui_items = "8-bit\010-bit\0";
> = 0;

//-------------------------------------------------------------------------------------------------
// TRINITRON APERTURE GRILLE
//-------------------------------------------------------------------------------------------------

uniform bool GRILLE_ENABLE <
    ui_category = "Trinitron Aperture Grille";
    ui_label = "Enable Aperture Grille";
> = true;

uniform float GRILLE_PITCH_PX <
    ui_category = "Trinitron Aperture Grille";
    ui_type = "slider";
    ui_label = "Triad Width (output pixels)";
    ui_tooltip = "Width of one R+G+B stripe triad in screen pixels.\n3.0 = one pixel per stripe (1080p minimum), 6.0 suits 4K. Integer values avoid moire.";
    ui_min = 1.5; ui_max = 12.0; ui_step = 0.01;
> = 3.0;

uniform float GRILLE_FILL <
    ui_category = "Trinitron Aperture Grille";
    ui_type = "slider";
    ui_label = "Phosphor Stripe Fill";
    ui_tooltip = "Fraction of each 1/3 triad cell covered by phosphor. The rest is the black guard stripe between phosphors.";
    ui_min = 0.3; ui_max = 1.0; ui_step = 0.01;
> = 0.85;

uniform float GRILLE_SOFTNESS <
    ui_category = "Trinitron Aperture Grille";
    ui_type = "slider";
    ui_label = "Stripe Edge Softness";
    ui_tooltip = "Beam landing blur / phosphor edge softness, in units of one stripe width.";
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
> = 0.15;

uniform float GRILLE_INTENSITY <
    ui_category = "Trinitron Aperture Grille";
    ui_type = "slider";
    ui_label = "Mask Intensity";
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
> = 1.0;

uniform float GRILLE_COMPENSATION <
    ui_category = "Trinitron Aperture Grille";
    ui_type = "slider";
    ui_label = "Mask Brightness Compensation";
    ui_tooltip = "Restores average brightness lost to the mask. 1.0 = fully energy-preserving (can clip bright pixels).";
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
> = 0.6;

uniform int DAMPER_WIRES <
    ui_category = "Trinitron Aperture Grille";
    ui_type = "combo";
    ui_label = "Damper Wires";
    ui_tooltip = "Trinitron tubes have 1 or 2 fine tungsten wires (~20um) stretched horizontally across the grille. Their shadows show as faint horizontal lines.";
    ui_items = "None\0One (center)\0Two (1/3 and 2/3)\0";
> = 2;

uniform float DAMPER_STRENGTH <
    ui_category = "Trinitron Aperture Grille";
    ui_type = "slider";
    ui_label = "Damper Wire Shadow Strength";
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
> = 0.35;

uniform float DAMPER_THICKNESS <
    ui_category = "Trinitron Aperture Grille";
    ui_type = "slider";
    ui_label = "Damper Wire Shadow Thickness (px)";
    ui_min = 0.25; ui_max = 8.0; ui_step = 0.05;
> = 1.5;

uniform float DAMPER_POS_1 <
    ui_category = "Trinitron Aperture Grille";
    ui_type = "slider";
    ui_label = "Wire 1 Vertical Position";
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
> = 0.333;

uniform float DAMPER_POS_2 <
    ui_category = "Trinitron Aperture Grille";
    ui_type = "slider";
    ui_label = "Wire 2 Vertical Position";
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
> = 0.667;

uniform float CURVATURE <
    ui_category = "Trinitron Aperture Grille";
    ui_type = "slider";
    ui_label = "Cylindrical Curvature";
    ui_tooltip = "Trinitron screens are curved horizontally but flat vertically. Warps X only; horizontal lines stay straight.";
    ui_min = 0.0; ui_max = 0.5; ui_step = 0.005;
> = 0.0;

//-------------------------------------------------------------------------------------------------
// ReShade built-in sources
//-------------------------------------------------------------------------------------------------

uniform int framecount < source = "framecount"; >;

//-------------------------------------------------------------------------------------------------
// TEXTURES
//-------------------------------------------------------------------------------------------------

sampler2D PointSampler
{
    Texture   = ReShade::BackBufferTex;
    MagFilter = POINT;
    MinFilter = POINT;
    MipFilter = POINT;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
    SRGBTexture = false;
};

texture TexCurr  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; };
texture TexPrev1 { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; };
texture TexPrev2 { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; };

sampler2D sCurr
{
    Texture = TexCurr;  MagFilter = POINT; MinFilter = POINT; MipFilter = POINT;
    AddressU = CLAMP; AddressV = CLAMP; SRGBTexture = false;
};
sampler2D sPrev1
{
    Texture = TexPrev1; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT;
    AddressU = CLAMP; AddressV = CLAMP; SRGBTexture = false;
};
sampler2D sPrev2
{
    Texture = TexPrev2; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT;
    AddressU = CLAMP; AddressV = CLAMP; SRGBTexture = false;
};

//-------------------------------------------------------------------------------------------------
// COLOR SPACE
//-------------------------------------------------------------------------------------------------

float3 decodeToLinear(float3 c)
{
    float3 lo = c / 12.92;
    float3 hi = pow(max((c + 0.055) / 1.055, 0.0), 2.4);
    float3 srgb = (c <= 0.04045) ? lo : hi;
    float3 power = pow(max(c, 0.0), max(INPUT_GAMMA, 0.1));
    return (GAMMA_MODE == 0) ? srgb : power;
}

float3 encodeFromLinear(float3 c)
{
    float3 lo = c * 12.92;
    float3 hi = 1.055 * pow(max(c, 0.0), 1.0 / 2.4) - 0.055;
    float3 srgb = (c <= 0.0031308) ? lo : hi;
    float3 power = pow(max(c, 0.0), 1.0 / max(OUTPUT_GAMMA, 0.1));
    return (GAMMA_MODE == 0) ? srgb : power;
}

float IGN(float2 p)
{
    return frac(52.9829189 * frac(dot(p, float2(0.06711056, 0.00583715))));
}

float3 TPDFDither(float2 p, int frame)
{
    float2 animated = p + float(frame % 64) * 5.588238;

    float3 n1 = float3(IGN(animated),
                       IGN(animated + float2(17.0, 31.0)),
                       IGN(animated + float2(43.0, 7.0)));
    float3 n2 = float3(IGN(animated + float2(101.0, 59.0)),
                       IGN(animated + float2(73.0, 89.0)),
                       IGN(animated + float2(29.0, 113.0)));

    return n1 + n2 - 1.0;
}

//-------------------------------------------------------------------------------------------------
// TIMING
//-------------------------------------------------------------------------------------------------

bool IsEvenInteger(float x)
{
    return (floor(x) == x) && (floor(x / 2.0) == x / 2.0);
}

float EffectivePeriod()
{
    float p = max(SUBFRAMES, 1.0);
    if (LCD_ANTI_RETENTION && IsEvenInteger(p))
        p += 0.001;
    return p;
}

float EffectiveFrame(int frame)
{
    return floor(float(frame) * SIM_SPEED);
}

bool IsNewCrtRefresh()
{
    float p = EffectivePeriod();
    float now  = floor(EffectiveFrame(framecount)     / p);
    float prev = floor(EffectiveFrame(framecount - 1) / p);
    return now != prev;
}

//-------------------------------------------------------------------------------------------------
// FEATHERED BEAM WINDOW (Fixed Width = 1.0)
//-------------------------------------------------------------------------------------------------

float TrapCDF(float x, float b0, float b1, float f)
{
    float total = b1 - b0;
    float u = clamp(x - b0, 0.0, total);

    float r    = min(u, f);
    float rise = r * r / (2.0 * f);
    float flat = clamp(u - f, 0.0, max(total - 2.0 * f, 0.0));
    float d    = clamp(u - (total - f), 0.0, f);
    float fall = d - d * d / (2.0 * f);

    return rise + flat + fall;
}

float BeamOverlap(float a0, float a1, float fStart, float fEnd)
{
    float width = max(fEnd - fStart, 1e-4);
    float f  = max(saturate(RASTER_FEATHER) * width, 1e-4);
    float b0 = fStart - 0.5 * f;
    float b1 = fEnd   + 0.5 * f;

    return TrapCDF(a1, b0, b1, f) - TrapCDF(a0, b0, b1, f);
}

float3 FrameContribution(float3 lin, float startTime, float fStart, float fEnd, float period)
{
    float3 onTime = lin * (period * GAIN_VS_BLUR);

    if (HUE_LOCK)
    {
        float m = max(max(onTime.r, onTime.g), onTime.b);
        if (m <= 1e-6)
            return float3(0.0, 0.0, 0.0);

        return (onTime / m) * BeamOverlap(startTime, startTime + m, fStart, fEnd);
    }

    return float3(
        BeamOverlap(startTime, startTime + onTime.r, fStart, fEnd),
        BeamOverlap(startTime, startTime + onTime.g, fStart, fEnd),
        BeamOverlap(startTime, startTime + onTime.b, fStart, fEnd));
}

float3 CrtPixel(float2 sampleUV, float tubeFrame, float fStart, float fEnd, float period)
{
    float3 pixelPrev2 = decodeToLinear(tex2D(sPrev2, sampleUV).rgb);
    float3 pixelPrev1 = decodeToLinear(tex2D(sPrev1, sampleUV).rgb);
    float3 pixelCurr  = decodeToLinear(tex2D(sCurr,  sampleUV).rgb);

    float3 result = FrameContribution(pixelPrev2, tubeFrame - period, fStart, fEnd, period)
                  + FrameContribution(pixelPrev1, tubeFrame,          fStart, fEnd, period)
                  + FrameContribution(pixelCurr,  tubeFrame + period, fStart, fEnd, period);

    return max(result, pixelPrev1 * max(DARK_FLOOR_GAIN, 0.0));
}

//-------------------------------------------------------------------------------------------------
// TRINITRON APERTURE GRILLE
//-------------------------------------------------------------------------------------------------

float StripeOverlap(float a0, float a1, float b0, float b1)
{
    return max(0.0, min(a1, b1) - max(a0, b0));
}

float StripeCyclic(float a0, float a1, float b0, float b1)
{
    return StripeOverlap(a0, a1, b0 - 1.0, b1 - 1.0)
         + StripeOverlap(a0, a1, b0,       b1)
         + StripeOverlap(a0, a1, b0 + 1.0, b1 + 1.0);
}

float3 ApertureGrille(float px)
{
    const float triadPx = max(GRILLE_PITCH_PX, 1.0);

    float w = max(1.0 / triadPx, GRILLE_SOFTNESS / 3.0);

    float t  = frac(px / triadPx);
    float a0 = t - 0.5 * w;
    float a1 = t + 0.5 * w;

    float hw = GRILLE_FILL / 6.0;

    float3 cov;
    cov.r = StripeCyclic(a0, a1, 1.0 / 6.0 - hw, 1.0 / 6.0 + hw);
    cov.g = StripeCyclic(a0, a1, 3.0 / 6.0 - hw, 3.0 / 6.0 + hw);
    cov.b = StripeCyclic(a0, a1, 5.0 / 6.0 - hw, 5.0 / 6.0 + hw);
    cov /= w;

    float meanCov = GRILLE_FILL / 3.0;
    float gain = lerp(1.0, 1.0 / meanCov, GRILLE_COMPENSATION);

    return lerp(float3(1.0, 1.0, 1.0), cov * gain, GRILLE_INTENSITY);
}

float DamperShadow(float py)
{
    if (DAMPER_WIRES == 0)
        return 1.0;

    const float sigma = max(DAMPER_THICKNESS, 0.1) / 2.355;
    float screenH = BUFFER_HEIGHT;

    float s;

    if (DAMPER_WIRES == 1)
    {
        float d = py - 0.5 * screenH;
        s = exp(-(d * d) / (2.0 * sigma * sigma));
    }
    else
    {
        float d1 = py - DAMPER_POS_1 * screenH;
        float d2 = py - DAMPER_POS_2 * screenH;
        s = max(exp(-(d1 * d1) / (2.0 * sigma * sigma)),
                exp(-(d2 * d2) / (2.0 * sigma * sigma)));
    }

    return 1.0 - DAMPER_STRENGTH * s;
}

//-------------------------------------------------------------------------------------------------
// HISTORY LATCH PASSES
//-------------------------------------------------------------------------------------------------

float4 PS_LatchPrev2(float4 vpos : SV_Position, float2 uv : TEXCOORD) : SV_Target
{
    if (!IsNewCrtRefresh())
        discard;
    return tex2D(sPrev1, uv);
}

float4 PS_LatchPrev1(float4 vpos : SV_Position, float2 uv : TEXCOORD) : SV_Target
{
    if (!IsNewCrtRefresh())
        discard;
    return tex2D(sCurr, uv);
}

float4 PS_LatchCurr(float4 vpos : SV_Position, float2 uv : TEXCOORD) : SV_Target
{
    if (!IsNewCrtRefresh())
        discard;
    return tex2D(PointSampler, uv);
}

//-------------------------------------------------------------------------------------------------
// MAIN PIXEL SHADER
//-------------------------------------------------------------------------------------------------

float4 PS_BlurBustersCRT(float4 vpos : SV_Position, float2 uvIn : TEXCOORD) : SV_Target
{
    float alpha = tex2D(PointSampler, uvIn).a;

    if (SPLITSCREEN && uvIn.x > SPLITSCREEN_X)
    {
        if (abs(vpos.x - SPLITSCREEN_X * BUFFER_WIDTH) < 2.0)
            return float4(0.0, 0.0, 0.0, alpha);

        float3 orig = decodeToLinear(tex2D(PointSampler, uvIn).rgb) * GAIN_VS_BLUR;
        return float4(saturate(encodeFromLinear(orig)), alpha);
    }

    float2 uv = uvIn;
    float cx = uv.x * 2.0 - 1.0;
    cx = cx * (1.0 + CURVATURE * cx * cx) / (1.0 + CURVATURE);
    uv.x = cx * 0.5 + 0.5;

    const float period = EffectivePeriod();

    // Hardcoded reference width of exactly 1.0 subframe
    float effectiveFrame = EffectiveFrame(framecount);
    float fStart = effectiveFrame - period * floor(effectiveFrame / period);
    float fEnd   = fStart + 1.0;

    float tubePos = 0.0;
    if (SCAN_DIRECTION == 1)      tubePos = uv.y;
    else if (SCAN_DIRECTION == 2) tubePos = 1.0 - uv.y;
    else if (SCAN_DIRECTION == 3) tubePos = uv.x;
    else if (SCAN_DIRECTION == 4) tubePos = 1.0 - uv.x;

    float tubeFrame = tubePos * period;

    float3 result = CrtPixel(uv, tubeFrame, fStart, fEnd, period);

    float2 texelSize = float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT);
    float3 beamL = CrtPixel(uv + float2(-texelSize.x * 0.33, 0.0), tubeFrame, fStart, fEnd, period);
    float3 beamR = CrtPixel(uv + float2( texelSize.x * 0.33, 0.0), tubeFrame, fStart, fEnd, period);

    float3 edgeMask = result - (beamL + beamR) * 0.5;
    result = max(result + edgeMask * EDGE_SHARPEN, 0.0);

    if (GRILLE_ENABLE)
    {
        result *= ApertureGrille(vpos.x);
        result *= DamperShadow(vpos.y);
    }

    float3 outColor = encodeFromLinear(result);
    outColor *= POST_BRIGHTNESS;

    float levels = (DITHER_BITS == 0) ? 255.0 : 1023.0;
    outColor += TPDFDither(vpos.xy, framecount) * (DITHER_STRENGTH / levels);

    return float4(saturate(outColor), alpha);
}

//-------------------------------------------------------------------------------------------------
// TECHNIQUE
//-------------------------------------------------------------------------------------------------

technique BlurBustersCRT <
    ui_label = "Blur Busters CRT Beam Simulator";
    ui_tooltip = "Reference-accurate CRT rolling-scan simulation with variable MPRT, frame history, and a Trinitron aperture grille.";
>
{
    pass LatchPrev2
    {
        VertexShader = PostProcessVS;
        PixelShader  = PS_LatchPrev2;
        RenderTarget = TexPrev2;
        ClearRenderTargets = false;
    }
    pass LatchPrev1
    {
        VertexShader = PostProcessVS;
        PixelShader  = PS_LatchPrev1;
        RenderTarget = TexPrev1;
        ClearRenderTargets = false;
    }
    pass LatchCurr
    {
        VertexShader = PostProcessVS;
        PixelShader  = PS_LatchCurr;
        RenderTarget = TexCurr;
        ClearRenderTargets = false;
    }
    pass Main
    {
        VertexShader = PostProcessVS;
        PixelShader  = PS_BlurBustersCRT;
    }
}