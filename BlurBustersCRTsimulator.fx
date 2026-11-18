//-------------------------------------------------------------------------------------------------
// Blur Busters Blacklight Strobe Simulator
// ReShade edition - Blacklight / UV Fluorescence & Strobe Pass (Fully Cleaned & Balanced)
//-------------------------------------------------------------------------------------------------

#include "ReShade.fxh"

//-------------------------------------------------------------------------------------------------
// BLACKLIGHT & UV CONTROLS
//-------------------------------------------------------------------------------------------------

uniform bool ENABLE_BLACKLIGHT <
    ui_category = "Blacklight & UV";
    ui_label = "Enable Blacklight Strobe Effect";
    ui_tooltip = "Transforms the output into a high-contrast UV / blacklight reactive environment.";
> = true;

uniform float UV_INTENSITY <
    ui_category = "Blacklight & UV";
    ui_type = "slider";
    ui_label = "UV Fluorescence Glow Boost";
    ui_tooltip = "Amplifies bright/reactive colors (whites, greens, pinks) to mimic fluorescent paint under blacklight.";
    ui_min = 0.5; ui_max = 5.0; ui_step = 0.05;
> = 1.8;

uniform float3 UV_TINT <
    ui_category = "Blacklight & UV";
    ui_type = "color";
    ui_label = "Blacklight Bulb Tint";
    ui_tooltip = "The characteristic deep violet/indigo hue cast by UV-A blacklight tubes.";
> = float3(0.35, 0.08, 0.85);

uniform float UV_TINT_STRENGTH <
    ui_category = "Blacklight & UV";
    ui_type = "slider";
    ui_label = "Blacklight Tint Strength";
    ui_tooltip = "Controls how intensely the purple/indigo bulb tint colors the scene without washing out actual colors.";
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.05;
> = 0.4;

uniform bool PRESERVE_TRUE_COLORS <
    ui_category = "Blacklight & UV";
    ui_label = "Preserve Natural Color Hues (Anti-Soak)";
    ui_tooltip = "Prevents the purple tint from soaking up and muddying other colors, keeping fluorescent reactions vibrant and true.";
> = true;

uniform float DARK_CRUSH <
    ui_category = "Blacklight & UV";
    ui_type = "slider";
    ui_label = "Shadow / Dark Suppression";
    ui_tooltip = "Blacklights leave shadows pitch black or tinted dark purple. Higher = deeper shadows.";
    ui_min = 0.0; ui_max = 2.0; ui_step = 0.05;
> = 1.2;

uniform float STROBE_FREQ <
    ui_category = "Blacklight & UV";
    ui_type = "slider";
    ui_label = "Strobe Pulse Frequency (Hz)";
    ui_tooltip = "Strobe flash frequency independent of frame rate. 0 = continuous glow.";
    ui_min = 0.0; ui_max = 30.0; ui_step = 0.5;
> = 6.0;

//-------------------------------------------------------------------------------------------------
// CRT TIMING & MPRT CONTROLS
//-------------------------------------------------------------------------------------------------

uniform bool ENABLE_MPRT <
    ui_category = "CRT Timing";
    ui_label = "Enable Variable MPRT (Strobing)";
    ui_tooltip = "ON = rolling-scan strobe simulation (reduces motion blur).\nOFF = shows the live frame at full brightness.";
> = true;

uniform float SUBFRAMES <
    ui_category = "CRT Timing";
    ui_type = "slider";
    ui_label = "Subframes per CRT Refresh";
    ui_min = 1.0; ui_max = 16.0; ui_step = 0.01;
> = 4.0;

uniform bool LCD_ANTI_RETENTION <
    ui_category = "CRT Timing";
    ui_label = "LCD Anti-Retention";
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
    ui_min = 0.01; ui_max = 1.0; ui_step = 0.01;
> = 1.0;

//-------------------------------------------------------------------------------------------------
// BEAM / BRIGHTNESS & HISTORY BLENDING
//-------------------------------------------------------------------------------------------------

uniform float GAIN_VS_BLUR <
    ui_category = "Beam & Brightness";
    ui_type = "slider";
    ui_label = "Gain vs Blur";
    ui_min = 0.001; ui_max = 1.0; ui_step = 0.001;
> = 0.7;

uniform float HISTORY_WEIGHT_PREV1 <
    ui_category = "Beam & Brightness";
    ui_type = "slider";
    ui_label = "Previous Frame Contribution (Prev 1)";
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
> = 1.0;

uniform float HISTORY_WEIGHT_PREV2 <
    ui_category = "Beam & Brightness";
    ui_type = "slider";
    ui_label = "Older Frame Contribution (Prev 2)";
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
> = 1.0;

uniform bool HUE_LOCK <
    ui_category = "Beam & Brightness";
    ui_label = "Shared On-Time For All Channels";
> = true;

uniform float RASTER_FEATHER <
    ui_category = "Beam & Brightness";
    ui_type = "slider";
    ui_label = "Raster Feathering (Seam Width)";
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
    ui_min = 0.0; ui_max = 100.0; ui_step = 0.01;
> = 1.2;

uniform bool SOFT_CLIP <
    ui_category = "Beam & Brightness";
    ui_label = "Hue-Preserving Soft Clip";
> = true;

uniform float EDGE_SHARPEN <
    ui_category = "Beam & Brightness";
    ui_type = "slider";
    ui_label = "Edge Sharpening (anti-ringing)";
    ui_min = 0.0; ui_max = 2.0; ui_step = 0.01;
> = 0.35;

//-------------------------------------------------------------------------------------------------
// COMPARISON
//-------------------------------------------------------------------------------------------------

uniform bool SPLITSCREEN <
    ui_category = "Comparison";
    ui_label = "Split Screen (Blacklight left, original right)";
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
    ui_min = 1.0; ui_max = 3.0; ui_step = 0.01;
> = 2.2;

uniform float DITHER_STRENGTH <
    ui_category = "Gamma & Dither";
    ui_type = "slider";
    ui_label = "Dither Strength";
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
    ui_min = 1.5; ui_max = 12.0; ui_step = 0.01;
> = 3.0;

uniform float GRILLE_FILL <
    ui_category = "Trinitron Aperture Grille";
    ui_type = "slider";
    ui_label = "Phosphor Stripe Fill";
    ui_min = 0.3; ui_max = 1.0; ui_step = 0.01;
> = 0.85;

uniform float GRILLE_SOFTNESS <
    ui_category = "Trinitron Aperture Grille";
    ui_type = "slider";
    ui_label = "Stripe Edge Softness";
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
> = 0.15;

uniform float GRILLE_INTENSITY <
    ui_category = "Trinitron Aperture Grille";
    ui_label = "Mask Intensity";
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
> = 1.0;

uniform float GRILLE_COMPENSATION <
    ui_category = "Trinitron Aperture Grille";
    ui_label = "Mask Brightness Compensation";
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
> = 0.6;

uniform int DAMPER_WIRES <
    ui_category = "Trinitron Aperture Grille";
    ui_type = "combo";
    ui_label = "Damper Wires";
    ui_items = "None\0One (center)\0Two (1/3 and 2/3)\0";
> = 2;

uniform float DAMPER_STRENGTH <
    ui_category = "Trinitron Aperture Grille";
    ui_type = "slider";
    ui_label = "Damper Wire Shadow Strength";
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
> = 0.25;

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
    ui_min = 0.0; ui_max = 0.5; ui_step = 0.005;
> = 0.0;

//-------------------------------------------------------------------------------------------------
// BUILT-INS & TEXTURES
//-------------------------------------------------------------------------------------------------

uniform int framecount < source = "framecount"; >;
uniform float timer < source = "timer"; >;

sampler2D PointSampler
{
    Texture   = ReShade::BackBufferTex;
    MagFilter = POINT; MinFilter = POINT; MipFilter = POINT;
    AddressU  = CLAMP; AddressV  = CLAMP; SRGBTexture = false;
};

sampler2D LinearSampler
{
    Texture   = ReShade::BackBufferTex;
    MagFilter = LINEAR; MinFilter = LINEAR; MipFilter = LINEAR;
    AddressU  = CLAMP; AddressV  = CLAMP; SRGBTexture = false;
};

texture TexCurr  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; };
texture TexPrev1 { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; };
texture TexPrev2 { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; };

sampler2D sCurr  { Texture = TexCurr;  MagFilter = POINT; MinFilter = POINT; MipFilter = POINT; AddressU = CLAMP; AddressV = CLAMP; };
sampler2D sPrev1 { Texture = TexPrev1; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT; AddressU = CLAMP; AddressV = CLAMP; };
sampler2D sPrev2 { Texture = TexPrev2; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT; AddressU = CLAMP; AddressV = CLAMP; };

sampler2D sCurrL  { Texture = TexCurr;  MagFilter = LINEAR; MinFilter = LINEAR; MipFilter = LINEAR; AddressU = CLAMP; AddressV = CLAMP; };
sampler2D sPrev1L { Texture = TexPrev1; MagFilter = LINEAR; MinFilter = LINEAR; MipFilter = LINEAR; AddressU = CLAMP; AddressV = CLAMP; };
sampler2D sPrev2L { Texture = TexPrev2; MagFilter = LINEAR; MinFilter = LINEAR; MipFilter = LINEAR; AddressU = CLAMP; AddressV = CLAMP; };

//-------------------------------------------------------------------------------------------------
// COLOR & BLACKLIGHT TRANSFORMATION
//-------------------------------------------------------------------------------------------------

float3 decodeToLinear(float3 c)
{
    if (GAMMA_MODE == 0)
    {
        float3 lo = c / 12.92;
        float3 hi = pow(max((c + 0.055) / 1.055, 0.0), 2.4);
        return (c <= 0.04045) ? lo : hi;
    }
    return pow(max(c, 0.0), max(INPUT_GAMMA, 0.1));
}

float3 encodeFromLinear(float3 c)
{
    if (GAMMA_MODE == 0)
    {
        float3 lo = c * 12.92;
        float3 hi = 1.055 * pow(max(c, 0.0), 1.0 / 2.4) - 0.055;
        return (c <= 0.0031308) ? lo : hi;
    }
    return pow(max(c, 0.0), 1.0 / max(OUTPUT_GAMMA, 0.1));
}

float3 ApplyBlacklightFilter(float3 color)
{
    if (!ENABLE_BLACKLIGHT)
        return color;

    float luma = dot(color, float3(0.299, 0.587, 0.114));
    float crushedLuma = pow(max(luma, 0.0), DARK_CRUSH);
    float fluorescence = pow(max(luma, 0.0), 2.2) * UV_INTENSITY;

    float3 uvColor = 0.0;

    if (PRESERVE_TRUE_COLORS)
    {
        float maxCh = max(color.r, max(color.g, color.b));
        float3 normalizedColor = (maxCh > 1e-5) ? color / maxCh : 0.0;
        float3 brightGlow = normalizedColor * fluorescence;
        float3 shadowTint = UV_TINT * crushedLuma * 0.5 * UV_TINT_STRENGTH;
        
        uvColor = shadowTint + brightGlow * lerp(1.0, UV_TINT, UV_TINT_STRENGTH * 0.3);
    }
    else
    {
        float3 effectiveTint = lerp(float3(1.0, 1.0, 1.0), UV_TINT, UV_TINT_STRENGTH);
        uvColor = effectiveTint * crushedLuma * 0.4 + color * fluorescence * effectiveTint;
    }

    if (STROBE_FREQ > 0.0)
    {
        float strobePulse = saturate(sin(timer * 0.001 * STROBE_FREQ * 6.28318) * 0.5 + 0.5);
        strobePulse = lerp(0.3, 1.0, pow(strobePulse, 4.0));
        uvColor *= strobePulse;
    }

    return uvColor;
}

float3 HueSoftClip(float3 c)
{
    float m = max(c.r, max(c.g, c.b));
    const float knee = 0.8;
    if (m <= knee)
        return c;

    float x  = (m - knee) / (1.0 - knee);
    float mc = knee + (1.0 - knee) * (x / (1.0 + x));
    return c * (mc / m);
}

float IGN(float2 p)
{
    return frac(52.9829189 * frac(dot(p, float2(0.06711056, 0.00583715))));
}

float3 TPDFDither(float2 p, int frame)
{
    float frameWrapped = float(frame) - 64.0 * floor(float(frame) / 64.0);
    float2 animated = p + frameWrapped * 5.588238;

    float3 n1 = float3(IGN(animated), IGN(animated + float2(17.0, 31.0)), IGN(animated + float2(43.0, 7.0)));
    float3 n2 = float3(IGN(animated + float2(101.0, 59.0)), IGN(animated + float2(73.0, 89.0)), IGN(animated + float2(29.0, 113.0)));
    return n1 + n2 - 1.0;
}

//-------------------------------------------------------------------------------------------------
// TIMING & BEAM MATH
//-------------------------------------------------------------------------------------------------

bool IsEvenInteger(float x) { return (floor(x) == x) && (floor(x / 2.0) == x / 2.0); }
float EffectivePeriod()
{
    float p = max(SUBFRAMES, 1.0);
    if (LCD_ANTI_RETENTION && IsEvenInteger(p)) p += 0.001;
    return p;
}
float EffectiveFrame(int frame) { return floor(float(frame) * SIM_SPEED); }
bool IsNewCrtRefresh()
{
    float p = EffectivePeriod();
    return floor(EffectiveFrame(framecount) / p) != floor(EffectiveFrame(framecount - 1) / p);
}

float TrapCDF(float x, float b0, float b1, float f)
{
    float total = b1 - b0;
    float u = clamp(x - b0, 0.0, total);
    float r = min(u, f);
    float rise = r * r / (2.0 * f);
    float flat = clamp(u - f, 0.0, max(total - 2.0 * f, 0.0));
    float d = clamp(u - (total - f), 0.0, f);
    float fall = d - d * d / (2.0 * f);
    return rise + flat + fall;
}

float BeamOverlap(float a0, float a1, float fStart, float fEnd)
{
    float width = max(fEnd - fStart, 1e-4);
    float f = max(saturate(RASTER_FEATHER) * width, 1e-4);
    return TrapCDF(a1, fStart - 0.5 * f, fEnd + 0.5 * f, f) - TrapCDF(a0, fStart - 0.5 * f, fEnd + 0.5 * f, f);
}

float3 FrameContribution(float3 lin, float startTime, float fStart, float fEnd)
{
    float3 onTime = lin * (EffectivePeriod() * GAIN_VS_BLUR);
    if (HUE_LOCK)
    {
        float m = max(max(onTime.r, onTime.g), onTime.b);
        if (m <= 1e-6) return 0.0;
        return (onTime / m) * BeamOverlap(startTime, startTime + m, fStart, fEnd);
    }
    return float3(
        BeamOverlap(startTime, startTime + onTime.r, fStart, fEnd),
        BeamOverlap(startTime, startTime + onTime.g, fStart, fEnd),
        BeamOverlap(startTime, startTime + onTime.b, fStart, fEnd));
}

float3 FetchLive(float2 uv)  { return (CURVATURE > 0.0005) ? tex2D(LinearSampler, uv).rgb : tex2D(PointSampler, uv).rgb; }
float3 FetchCurr(float2 uv)  { return (CURVATURE > 0.0005) ? tex2D(sCurrL, uv).rgb : tex2D(sCurr, uv).rgb; }
float3 FetchPrev1(float2 uv) { return (CURVATURE > 0.0005) ? tex2D(sPrev1L, uv).rgb : tex2D(sPrev1, uv).rgb; }
float3 FetchPrev2(float2 uv) { return (CURVATURE > 0.0005) ? tex2D(sPrev2L, uv).rgb : tex2D(sPrev2, uv).rgb; }

float3 CrtPixel(float2 sampleUV, float tubeFrame, float fStart, float fEnd, float period)
{
    if (!ENABLE_MPRT)
        return decodeToLinear(FetchLive(sampleUV));

    float maxOn = period * GAIN_VS_BLUR;
    float feather = max(saturate(RASTER_FEATHER) * (fEnd - fStart), 1e-4);
    float w0 = fStart - 0.5 * feather;
    float w1 = fEnd + 0.5 * feather;

    float3 result = 0.0;
    float s2 = tubeFrame - period;
    if (HISTORY_WEIGHT_PREV2 > 0.0 && s2 + maxOn > w0 && s2 < w1)
        result += FrameContribution(decodeToLinear(FetchPrev2(sampleUV)), s2, fStart, fEnd) * HISTORY_WEIGHT_PREV2;

    float s1 = tubeFrame;
    if (HISTORY_WEIGHT_PREV1 > 0.0 && s1 + maxOn > w0 && s1 < w1)
        result += FrameContribution(decodeToLinear(FetchPrev1(sampleUV)), s1, fStart, fEnd) * HISTORY_WEIGHT_PREV1;

    float s0 = tubeFrame + period;
    if (s0 + maxOn > w0 && s0 < w1)
        result += FrameContribution(decodeToLinear(FetchCurr(sampleUV)), s0, fStart, fEnd);

    if (DARK_FLOOR_GAIN > 0.0)
        result = max(result, decodeToLinear(FetchPrev1(sampleUV)) * DARK_FLOOR_GAIN);

    return result;
}

float StripeOverlap(float a0, float a1, float b0, float b1) { return max(0.0, min(a1, b1) - max(a0, b0)); }
float StripeCyclic(float a0, float a1, float b0, float b1)
{
    return StripeOverlap(a0, a1, b0 - 1.0, b1 - 1.0) + StripeOverlap(a0, a1, b0, b1) + StripeOverlap(a0, a1, b0 + 1.0, b1 + 1.0);
}

float3 ApertureGrille(float px)
{
    float triadPx = max(GRILLE_PITCH_PX, 1.0);
    float w = max(1.0 / triadPx, GRILLE_SOFTNESS / 3.0);
    float t = frac(px / triadPx);
    float a0 = t - 0.5 * w, a1 = t + 0.5 * w;
    float hw = GRILLE_FILL / 6.0;

    float3 cov;
    cov.r = StripeCyclic(a0, a1, 1.0 / 6.0 - hw, 1.0 / 6.0 + hw);
    cov.g = StripeCyclic(a0, a1, 3.0 / 6.0 - hw, 3.0 / 6.0 + hw);
    cov.b = StripeCyclic(a0, a1, 5.0 / 6.0 - hw, 5.0 / 6.0 + hw);
    cov /= w;

    // Corrected subpixel gain balance to prevent green cast buildup
    cov.g *= 0.88;

    return lerp(1.0, cov * lerp(1.0, 3.0 / GRILLE_FILL, GRILLE_COMPENSATION), GRILLE_INTENSITY);
}

float DamperShadow(float py)
{
    if (DAMPER_WIRES == 0) return 1.0;
    float sigma = max(DAMPER_THICKNESS, 0.1) / 2.355;
    float s = (DAMPER_WIRES == 1) ? 
        exp(-pow(py - 0.5 * BUFFER_HEIGHT, 2.0) / (2.0 * sigma * sigma)) :
        max(exp(-pow(py - DAMPER_POS_1 * BUFFER_HEIGHT, 2.0) / (2.0 * sigma * sigma)),
            exp(-pow(py - DAMPER_POS_2 * BUFFER_HEIGHT, 2.0) / (2.0 * sigma * sigma)));
    return 1.0 - DAMPER_STRENGTH * s;
}

//-------------------------------------------------------------------------------------------------
// PASSES
//-------------------------------------------------------------------------------------------------

float4 PS_LatchPrev2(float4 vpos : SV_Position, float2 uv : TEXCOORD) : SV_Target { if (!ENABLE_MPRT || !IsNewCrtRefresh()) discard; return tex2D(sPrev1, uv); }
float4 PS_LatchPrev1(float4 vpos : SV_Position, float2 uv : TEXCOORD) : SV_Target { if (!ENABLE_MPRT || !IsNewCrtRefresh()) discard; return tex2D(sCurr, uv); }
float4 PS_LatchCurr(float4 vpos : SV_Position, float2 uv : TEXCOORD) : SV_Target  { if (!ENABLE_MPRT || !IsNewCrtRefresh()) discard; return tex2D(PointSampler, uv); }

float4 PS_BlacklightStrobe(float4 vpos : SV_Position, float2 uvIn : TEXCOORD) : SV_Target
{
    float alpha = tex2D(PointSampler, uvIn).a;

    if (SPLITSCREEN && uvIn.x > SPLITSCREEN_X)
    {
        if (abs(vpos.x - SPLITSCREEN_X * BUFFER_WIDTH) < 2.0) return float4(0.0, 0.0, 0.0, alpha);
        float3 orig = decodeToLinear(tex2D(PointSampler, uvIn).rgb) * (ENABLE_MPRT ? GAIN_VS_BLUR : 1.0);
        return float4(saturate(encodeFromLinear(orig)), alpha);
    }

    float2 uv = uvIn;
    if (CURVATURE > 0.0005)
    {
        float cx = (uv.x * 2.0 - 1.0);
        cx = cx * (1.0 + CURVATURE * cx * cx) / (1.0 + CURVATURE);
        uv.x = cx * 0.5 + 0.5;
    }

    float period = EffectivePeriod();
    float effectiveFrame = EffectiveFrame(framecount);
    float fStart = effectiveFrame - period * floor(effectiveFrame / period);
    float fEnd = fStart + 1.0;

    float tubePos = (SCAN_DIRECTION == 1) ? uv.y : (SCAN_DIRECTION == 2) ? (1.0 - uv.y) : (SCAN_DIRECTION == 3) ? uv.x : (SCAN_DIRECTION == 4) ? (1.0 - uv.x) : 0.0;
    float tubeFrame = tubePos * period;

    float3 result = CrtPixel(uv, tubeFrame, fStart, fEnd, period);

    if (EDGE_SHARPEN > 0.0)
    {
        float texelX = BUFFER_RCP_WIDTH;
        float3 beamL = CrtPixel(uv - float2(texelX, 0.0), tubeFrame, fStart, fEnd, period);
        float3 beamR = CrtPixel(uv + float2(texelX, 0.0), tubeFrame, fStart, fEnd, period);
        float3 sharp = result + (result - 0.5 * (beamL + beamR)) * EDGE_SHARPEN;
        result = clamp(sharp, min(result, min(beamL, beamR)), max(result, max(beamL, beamR)));
    }

    float3 outColor = encodeFromLinear(result) * POST_BRIGHTNESS;

    outColor = ApplyBlacklightFilter(outColor);

    if (GRILLE_ENABLE)
    {
        outColor *= ApertureGrille(vpos.x);
        outColor *= DamperShadow(vpos.y);
    }

    if (SOFT_CLIP)
        outColor = HueSoftClip(outColor);

    float levels = (DITHER_BITS == 0) ? 255.0 : 1023.0;
    outColor += TPDFDither(vpos.xy, framecount) * (DITHER_STRENGTH / levels);

    return float4(saturate(outColor), alpha);
}

technique BlurBustersBlacklightStrobe <
    ui_label = "Blur Busters Blacklight Strobe Simulator";
    ui_tooltip = "Transforms the CRT beam simulator into a high-contrast UV blacklight fluorescent strobe effect.";
>
{
    pass LatchPrev2 { VertexShader = PostProcessVS; PixelShader = PS_LatchPrev2; RenderTarget = TexPrev2; ClearRenderTargets = false; }
    pass LatchPrev1 { VertexShader = PostProcessVS; PixelShader = PS_LatchPrev1; RenderTarget = TexPrev1; ClearRenderTargets = false; }
    pass LatchCurr  { VertexShader = PostProcessVS; PixelShader = PS_LatchCurr;  RenderTarget = TexCurr;  ClearRenderTargets = false; }
    pass Main       { VertexShader = PostProcessVS; PixelShader = PS_BlacklightStrobe; }
}