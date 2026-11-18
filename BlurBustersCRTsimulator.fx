//-------------------------------------------------------------------------------------------------
// Blur Busters Blacklight Strobe Simulator (Ultimate True RNG & Analog Standard Edition)
//-------------------------------------------------------------------------------------------------

#include "ReShade.fxh"

//-------------------------------------------------------------------------------------------------
// BLACKLIGHT & UV CONTROLS
//-------------------------------------------------------------------------------------------------

uniform bool ENABLE_BLACKLIGHT <
    ui_category = "Blacklight & UV";
    ui_label = "Enable Blacklight Strobe Effect";
> = true;

uniform float UV_INTENSITY <
    ui_category = "Blacklight & UV";
    ui_type = "slider";
    ui_label = "UV Fluorescence Glow Boost";
    ui_min = 0.5; ui_max = 5.0; ui_step = 0.05;
> = 1.8;

uniform float3 UV_TINT <
    ui_category = "Blacklight & UV";
    ui_type = "color";
    ui_label = "Blacklight Bulb Tint";
> = float3(0.35, 0.08, 0.85);

uniform float UV_TINT_STRENGTH <
    ui_category = "Blacklight & UV";
    ui_type = "slider";
    ui_label = "Blacklight Tint Strength";
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.05;
> = 0.4;

uniform bool PRESERVE_TRUE_COLORS <
    ui_category = "Blacklight & UV";
    ui_label = "Preserve Natural Color Hues (Anti-Soak)";
> = true;

uniform float DARK_CRUSH <
    ui_category = "Blacklight & UV";
    ui_type = "slider";
    ui_label = "Shadow / Dark Suppression";
    ui_min = 0.0; ui_max = 2.0; ui_step = 0.05;
> = 1.2;

uniform float STROBE_FREQ <
    ui_category = "Blacklight & UV";
    ui_type = "slider";
    ui_label = "Strobe Pulse Frequency (Hz)";
    ui_min = 0.0; ui_max = 30.0; ui_step = 0.5;
> = 6.0;

//-------------------------------------------------------------------------------------------------
// ANALOGUE SIGNAL PATHS (Distinct Cable & Broadcast Standards)
//-------------------------------------------------------------------------------------------------

uniform int SIGNAL_PRESET <
    ui_category = "Analogue Signal Paths";
    ui_type = "combo";
    ui_label = "Select Signal Path / Cable Type";
    ui_items = "HDMI (Pure Digital)\0HDMI Mod (Sharp Analog Conversion)\0Composite (Standard NTSC)\0Composite (Coaxial / Direct AV)\0RF Cables (Standard Antenna)\0RF Cables (VHF/UHF Fringe Reception)\0RF Cables (VCR / Channel 3 Modulator)\0PAL-B (Composite)\0PAL-B (RF Cables)\0PAL-M (Brazilian Famiclone)\0PAL-N (Argentinian Famiclone)\0PAL-D (Dendy Famiclone)\0";
> = 2;

uniform float CUSTOM_LUMA_BANDWIDTH <
    ui_category = "Analogue Signal Paths / Fine-Tuning";
    ui_type = "slider";
    ui_label = "Manual Luma Bandwidth / Smear Blur";
    ui_min = 0.0; ui_max = 3.0; ui_step = 0.05;
> = 0.9;

uniform float CUSTOM_CHROMA_BLEED <
    ui_category = "Analogue Signal Paths / Fine-Tuning";
    ui_type = "slider";
    ui_label = "Manual Chroma Subcarrier Bleed";
    ui_min = 0.0; ui_max = 6.0; ui_step = 0.05;
> = 3.5;

uniform float HUM_BAR <
    ui_category = "Analogue Signal Paths / Fine-Tuning";
    ui_type = "slider";
    ui_label = "Power Supply Hum Bar (60Hz Roll)";
    ui_min = 0.0; ui_max = 0.2; ui_step = 0.005;
> = 0.0;

//-------------------------------------------------------------------------------------------------
// ADVANCED REAL CRT GLASS & OPTICAL REFRACTION
//-------------------------------------------------------------------------------------------------

uniform int CURVATURE_MODE <
    ui_category = "Advanced CRT Glass & Optics";
    ui_type = "combo";
    ui_label = "CRT Glass Curvature Mode";
    ui_items = "Off (Flat Screen)\0Classic Cylindrical (Horizontal Curve)\0Bulbous Bubble (Protruding Front)\0Authentic Thick CRT Glass (Refractive Bevel)\0";
> = 3;

uniform float CURVATURE_AMOUNT <
    ui_category = "Advanced CRT Glass & Optics";
    ui_type = "slider";
    ui_label = "Curvature / Distortion Intensity";
    ui_min = 0.0; ui_max = 0.5; ui_step = 0.005;
> = 0.15;

uniform float GLASS_THICKNESS_REFRACTION <
    ui_category = "Advanced CRT Glass & Optics";
    ui_type = "slider";
    ui_label = "Physical Glass Depth / Refractive Index";
    ui_min = 0.0; ui_max = 0.05; ui_step = 0.001;
> = 0.012;

uniform float GLASS_SPECULAR_SHEEN <
    ui_category = "Advanced CRT Glass & Optics";
    ui_type = "slider";
    ui_label = "Upper Surface Glass Specular Sheen";
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
> = 0.35;

uniform float GLASS_FRESNEL_EDGE <
    ui_category = "Advanced CRT Glass & Optics";
    ui_type = "slider";
    ui_label = "Bevel Rim Light Trapping / Fresnel";
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
> = 0.60;

uniform float CORNER_DEPRESSION <
    ui_category = "Advanced CRT Glass & Optics";
    ui_type = "slider";
    ui_label = "Corner Shadow & Glass Depressions";
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
> = 0.45;

//-------------------------------------------------------------------------------------------------
// CYBERLAB ANALOG EXTRAS & ADVANCED CRT PHYSICS
//-------------------------------------------------------------------------------------------------

uniform bool ENABLE_CYBERLAB_EXTRAS <
    ui_category = "Cyberlab Analog Extras";
    ui_label = "Enable Cyberlab Analog Glow & Bleed Pack";
> = true;

uniform float BLOOM_STRENGTH <
    ui_category = "Cyberlab Analog Extras";
    ui_type = "slider";
    ui_label = "Phosphor Bloom / Light Diffusion";
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
> = 0.25;

uniform float SCANLINE_INTENSITY <
    ui_category = "Cyberlab Analog Extras";
    ui_type = "slider";
    ui_label = "Scanline Depth / Darkening";
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
> = 0.50;

uniform float SCANLINE_WIDTH <
    ui_category = "Cyberlab Analog Extras";
    ui_type = "slider";
    ui_label = "Scanline Beam Thickness";
    ui_min = 0.5; ui_max = 2.0; ui_step = 0.05;
> = 1.0;

uniform float CONVERGENCE_SHIFT <
    ui_category = "Cyberlab Analog Extras";
    ui_type = "slider";
    ui_label = "RGB Convergence Error (Chromatic Aberration)";
    ui_min = 0.0; ui_max = 0.003; ui_step = 0.0001;
> = 0.0006;

uniform float HIGH_VOLTAGE_SAG <
    ui_category = "Cyberlab Analog Extras";
    ui_type = "slider";
    ui_label = "Dynamic High-Voltage Power Supply Sag / Bloom";
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
> = 0.35;

uniform float3 PHOSPHOR_DECAY <
    ui_category = "Cyberlab Analog Extras";
    ui_type = "slider";
    ui_label = "P22 Phosphor Tail Persistence (RGB Weights)";
    ui_min = 0.5; ui_max = 1.0; ui_step = 0.01;
> = float3(0.88, 0.96, 0.82);

uniform bool INTERLACE_FIELD_FLICKER <
    ui_category = "Cyberlab Analog Extras";
    ui_label = "Enable Interlaced Field Alternation / Flicker";
> = true;

//-------------------------------------------------------------------------------------------------
// CRT TIMING & ORGANIC BFI CONTROLS
//-------------------------------------------------------------------------------------------------

uniform bool ENABLE_MPRT <
    ui_category = "CRT Timing & BFI";
    ui_label = "Enable Variable MPRT (Strobing)";
> = true;

uniform float SUBFRAMES <
    ui_category = "CRT Timing & BFI";
    ui_type = "slider";
    ui_label = "Subframes per CRT Refresh";
    ui_min = 1.0; ui_max = 16.0; ui_step = 0.01;
> = 4.0;

uniform float BFI_DUTY_CYCLE <
    ui_category = "CRT Timing & BFI";
    ui_type = "slider";
    ui_label = "BFI Strobe Duty Cycle (Anti-Blinding)";
    ui_min = 0.1; ui_max = 1.0; ui_step = 0.05;
> = 0.5;

uniform bool SINE_BFI_ENABLE <
    ui_category = "CRT Timing & BFI";
    ui_label = "Enable Sine-Wave BFI Modulation";
> = false;

uniform float SINE_BFI_FREQUENCY <
    ui_category = "CRT Timing & BFI";
    ui_type = "slider";
    ui_label = "Sine BFI Frequency Multiplier";
    ui_min = 0.5; ui_max = 8.0; ui_step = 0.1;
> = 2.0;

uniform bool ORGANIC_DRIFT_ENABLE <
    ui_category = "CRT Timing & BFI";
    ui_label = "Enable Organic Roll Breathing (Smooth Drift)";
> = true;

uniform bool LCD_ANTI_RETENTION <
    ui_category = "CRT Timing & BFI";
    ui_label = "LCD Anti-Retention";
> = true;

uniform int SCAN_DIRECTION <
    ui_category = "CRT Timing & BFI";
    ui_type = "combo";
    ui_label = "Scan Direction";
    ui_items = "Off (global strobe)\0Top to Bottom\0Bottom to Top\0Left to Right\0Right to Left\0";
> = 1;

uniform float SIM_SPEED <
    ui_category = "CRT Timing & BFI";
    ui_type = "slider";
    ui_label = "Slow-Motion Speed (educational)";
    ui_min = 0.01; ui_max = 1.0; ui_step = 0.01;
> = 1.0;

// === LCD BURN-IN PROTECTION ===
uniform bool LCDSafeMode <
    ui_category="LCD Burn-in Protection";
    ui_label="Enable LCD Safe Mode (BFI Phase Shifting)";
> = true;

uniform int PhaseFlipMethod <
    ui_category="LCD Burn-in Protection / Phase Flip";
    ui_type="combo";
    ui_items="Phase Jump\0Frame Drop\0";
    ui_label="Phase Flip Method";
> = 0;

uniform float JumpRate <
    ui_category="LCD Burn-in Protection / Phase Flip";
    ui_type="slider";
    ui_min=0.0001; ui_max=0.1; ui_step=0.0001;
    ui_label="Phase Jump Rate";
> = 0.0001;

uniform int FlipRate <
    ui_category="LCD Burn-in Protection / Phase Flip";
    ui_type="slider";
    ui_min=1000; ui_max=100000; ui_step=1;
    ui_label="Frame Drop Interval";
> = 1000;

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
// COMPARISON & GAMMA
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

uniform bool FORCE_16BIT_COLOR <
    ui_category = "Gamma & Dither";
    ui_label = "Force 16-Bit Color (RGB565 High Color)";
> = false;

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
// PHOSPHOR MASK & APERTURE GRILLE
//-------------------------------------------------------------------------------------------------

uniform bool GRILLE_ENABLE <
    ui_category = "Phosphor Mask & Aperture Grille";
    ui_label = "Enable Phosphor Mask";
> = true;

uniform int MASK_TYPE <
    ui_category = "Phosphor Mask & Aperture Grille";
    ui_type = "combo";
    ui_label = "Mask Pattern Style";
    ui_items = "Trinitron Aperture Grille (Vertical Stripes)\0Shadow / Slot Mask (Grid Triads)\0";
> = 0;

uniform float GRILLE_PITCH_PX <
    ui_category = "Phosphor Mask & Aperture Grille";
    ui_type = "slider";
    ui_label = "Triad Width (output pixels)";
    ui_min = 1.5; ui_max = 12.0; ui_step = 0.01;
> = 3.0;

uniform float GRILLE_FILL <
    ui_category = "Phosphor Mask & Aperture Grille";
    ui_type = "slider";
    ui_label = "Phosphor Stripe Fill";
    ui_min = 0.3; ui_max = 1.0; ui_step = 0.01;
> = 0.85;

uniform float GRILLE_SOFTNESS <
    ui_category = "Phosphor Mask & Aperture Grille";
    ui_type = "slider";
    ui_label = "Stripe Edge Softness";
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
> = 0.15;

uniform float GRILLE_INTENSITY <
    ui_category = "Phosphor Mask & Aperture Grille";
    ui_label = "Mask Intensity";
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
> = 1.0;

uniform float GRILLE_COMPENSATION <
    ui_category = "Phosphor Mask & Aperture Grille";
    ui_label = "Mask Brightness Compensation";
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
> = 0.6;

uniform int DAMPER_WIRES <
    ui_category = "Phosphor Mask & Aperture Grille";
    ui_type = "combo";
    ui_label = "Damper Wires";
    ui_items = "None\0One (center)\0Two (1/3 and 2/3)\0";
> = 2;

uniform float DAMPER_STRENGTH <
    ui_category = "Phosphor Mask & Aperture Grille";
    ui_type = "slider";
    ui_label = "Damper Wire Shadow Strength";
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
> = 0.25;

uniform float DAMPER_THICKNESS <
    ui_category = "Phosphor Mask & Aperture Grille";
    ui_type = "slider";
    ui_label = "Damper Wire Shadow Thickness (px)";
    ui_min = 0.25; ui_max = 8.0; ui_step = 0.05;
> = 1.5;

uniform float DAMPER_POS_1 <
    ui_category = "Phosphor Mask & Aperture Grille";
    ui_type = "slider";
    ui_label = "Wire 1 Vertical Position";
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
> = 0.333;

uniform float DAMPER_POS_2 <
    ui_category = "Phosphor Mask & Aperture Grille";
    ui_type = "slider";
    ui_label = "Wire 2 Vertical Position";
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
> = 0.667;

//-------------------------------------------------------------------------------------------------
// TEXTURES & SAMPLERS
//-------------------------------------------------------------------------------------------------

uniform int framecount < source = "framecount"; >;
uniform float timer < source = "timer"; >;

texture TexCurr  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; };
texture TexPrev1 { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; };
texture TexPrev2 { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; };

sampler2D PointSampler  { Texture = ReShade::BackBufferTex; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT; AddressU = CLAMP; AddressV = CLAMP; };
sampler2D LinearSampler { Texture = ReShade::BackBufferTex; MagFilter = LINEAR; MinFilter = LINEAR; MipFilter = LINEAR; AddressU = CLAMP; AddressV = CLAMP; };

sampler2D sCurr  { Texture = TexCurr;  MagFilter = POINT; MinFilter = POINT; MipFilter = POINT; AddressU = CLAMP; AddressV = CLAMP; };
sampler2D sPrev1 { Texture = TexPrev1; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT; AddressU = CLAMP; AddressV = CLAMP; };
sampler2D sPrev2 { Texture = TexPrev2; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT; AddressU = CLAMP; AddressV = CLAMP; };

sampler2D sCurrL  { Texture = TexCurr;  MagFilter = LINEAR; MinFilter = LINEAR; MipFilter = LINEAR; AddressU = CLAMP; AddressV = CLAMP; };
sampler2D sPrev1L { Texture = TexPrev1; MagFilter = LINEAR; MinFilter = LINEAR; MipFilter = LINEAR; AddressU = CLAMP; AddressV = CLAMP; };

//-------------------------------------------------------------------------------------------------
// TRUE RNG & ANALOG SIGNAL PATHS
//-------------------------------------------------------------------------------------------------

float trueRNG(float3 p)
{
    p = frac(p * 0.1031);
    p += dot(p, p.yzx + 33.33);
    return frac((p.x + p.y) * p.z);
}

float3 RGBToYIQ(float3 rgb)
{
    return float3(
        dot(rgb, float3(0.299, 0.587, 0.114)),
        dot(rgb, float3(0.596, -0.274, -0.523)),
        dot(rgb, float3(0.211, -0.523, 0.312))
    );
}

float3 YIQToRGB(float3 yiq)
{
    return float3(
        dot(yiq, float3(1.0, 0.956, 0.621)),
        dot(yiq, float3(1.0, -0.272, -0.647)),
        dot(yiq, float3(1.0, -1.106, 1.703))
    );
}

float3 ApplyAnalogSignalPath(sampler2D samp, float2 uv, float2 fragCoord, int frame)
{
    float3 col = tex2D(samp, uv).rgb;
    if (SIGNAL_PRESET == 0) return col; // 0: HDMI Pure Digital

    float lumaSmear = CUSTOM_LUMA_BANDWIDTH;
    float chromaBleed = CUSTOM_CHROMA_BLEED;
    float dotCrawl = 0.0;
    float ghost = 0.0;
    float noise = 0.0;
    float jitter = 0.0;
    bool isPAL = false;

    if (SIGNAL_PRESET == 1) // HDMI Mod
    {
        lumaSmear = 0.35; chromaBleed = 0.35; dotCrawl = 0.05;
    }
    else if (SIGNAL_PRESET == 2) // Composite (Standard NTSC)
    {
        lumaSmear = 0.9; chromaBleed = 3.5; dotCrawl = 0.35; jitter = 0.15; noise = 0.04;
    }
    else if (SIGNAL_PRESET == 3) // Composite (Coaxial / Direct AV)
    {
        lumaSmear = 1.1; chromaBleed = 3.9; dotCrawl = 0.40; ghost = 0.02; jitter = 0.2; noise = 0.06;
    }
    else if (SIGNAL_PRESET == 4) // RF Cables (Standard Antenna)
    {
        lumaSmear = 1.5; chromaBleed = 4.5; dotCrawl = 0.45; ghost = 0.12; jitter = 0.6; noise = 0.14;
    }
    else if (SIGNAL_PRESET == 5) // RF Cables (VHF/UHF Fringe Reception)
    {
        lumaSmear = 1.8; chromaBleed = 5.2; dotCrawl = 0.55; ghost = 0.25; jitter = 0.9; noise = 0.26;
    }
    else if (SIGNAL_PRESET == 6) // RF Cables (VCR / Channel 3 Modulator)
    {
        lumaSmear = 1.6; chromaBleed = 4.8; dotCrawl = 0.50; ghost = 0.18; jitter = 0.7; noise = 0.18;
    }
    else if (SIGNAL_PRESET == 7) // PAL-B (Composite)
    {
        lumaSmear = 1.0; chromaBleed = 3.8; dotCrawl = 0.08; jitter = 0.15; noise = 0.04; isPAL = true;
    }
    else if (SIGNAL_PRESET == 8) // PAL-B (RF Cables)
    {
        lumaSmear = 1.6; chromaBleed = 4.8; dotCrawl = 0.10; ghost = 0.12; jitter = 0.6; noise = 0.14; isPAL = true;
    }
    else if (SIGNAL_PRESET == 9) // PAL-M (Brazilian Famiclone)
    {
        lumaSmear = 0.95; chromaBleed = 3.6; dotCrawl = 0.10; jitter = 0.2; noise = 0.05; isPAL = true;
    }
    else if (SIGNAL_PRESET == 10) // PAL-N (Argentinian Famiclone)
    {
        lumaSmear = 1.1; chromaBleed = 4.2; dotCrawl = 0.10; ghost = 0.0; jitter = 0.2; noise = 0.05; isPAL = true;
    }
    else if (SIGNAL_PRESET == 11) // PAL-D (Dendy Famiclone)
    {
        lumaSmear = 1.0; chromaBleed = 3.6; dotCrawl = 0.12; ghost = 0.0; jitter = 0.25; noise = 0.05; isPAL = true;
    }

    float lineIndex = floor(uv.y * 240.0);
    float trueJitterHash = trueRNG(float3(lineIndex, floor(timer * 0.03), 1.0)) - 0.5;
    float lineJitter = trueJitterHash * jitter / BUFFER_WIDTH;
    float2 suv = uv + float2(lineJitter, 0.0);

    float3 linCol = pow(max(col, 0.0), float3(2.4, 2.4, 2.4));
    float3 yiq = RGBToYIQ(linCol);

    if (lumaSmear > 0.0)
    {
        float lumaAcc = 0.0;
        for (int i = -2; i <= 2; i++)
        {
            float u = float(i) * 0.5;
            float3 sampleRGB = pow(max(tex2D(samp, suv + float2(u * lumaSmear / BUFFER_WIDTH, 0.0)).rgb, 0.0), float3(2.4, 2.4, 2.4));
            lumaAcc += RGBToYIQ(sampleRGB).x * (1.0 / (abs(i) + 1.0));
        }
        yiq.x = lumaAcc * 0.5;
    }

    float parity = float(frame % 2);
    float checker = (frac((fragCoord.x * 0.5) + lineIndex + parity) < 0.5 ? 1.0 : -1.0);
    yiq.x += dotCrawl * 0.35 * length(yiq.yz) * checker;

    if (ghost > 0.0)
    {
        float3 ghostCol = tex2D(samp, suv - float2(16.0 / BUFFER_WIDTH, 0.0)).rgb;
        yiq.x += ghost * RGBToYIQ(ghostCol).x;
    }

    if (isPAL)
    {
        float lineH = 1.0 / 240.0;
        float2 yiqUp = RGBToYIQ(tex2D(samp, suv - float2(0.0, lineH)).rgb).yz;
        float2 yiqDn = RGBToYIQ(tex2D(samp, suv + float2(0.0, lineH)).rgb).yz;
        yiq.yz = 0.5 * yiq.yz + 0.25 * (yiqUp + yiqDn);
    }

    float3 processedRGB = max(YIQToRGB(yiq), 0.0);

    if (noise > 0.0)
    {
        // HLSL-safe integer modulo replacement for fmod
        float t = (float)(((int)floor(timer * 0.06)) % 4096);
        float snow = trueRNG(float3(fragCoord.xy, t)) - 0.5;
        float sx = max(1.0, BUFFER_WIDTH / 1920.0 * 6.0);
        float streak = trueRNG(float3(floor(fragCoord.x / sx), floor(fragCoord.y / (BUFFER_HEIGHT / 240.0)), t)) - 0.5;
        processedRGB += noise * (0.65 * snow + 0.7 * streak);
    }

    return saturate(processedRGB);
}

float2 ApplyAdvancedGlassCurvature(float2 uv, float lumaAvg, out float2 refractedUV)
{
    if (CURVATURE_MODE == 0 || CURVATURE_AMOUNT <= 0.0005)
    {
        refractedUV = uv;
        return uv;
    }

    float sagDynamic = CURVATURE_AMOUNT + (lumaAvg * HIGH_VOLTAGE_SAG * 0.015);
    float2 cc = uv - 0.5;
    float r2 = dot(cc, cc);

    float distortion = 1.0;
    if (CURVATURE_MODE == 1)
    {
        float cx = cc.x * (1.0 + sagDynamic * cc.x * cc.x);
        refractedUV = float2(cx, cc.y) + 0.5;
    }
    else if (CURVATURE_MODE == 2)
    {
        float factor = 1.0 + r2 * sagDynamic * 2.5;
        refractedUV = cc * factor + 0.5;
    }
    else if (CURVATURE_MODE == 3)
    {
        distortion = 1.0 + r2 * sagDynamic * 4.0 + pow(r2, 2.0) * sagDynamic * 6.0;
        refractedUV = cc * distortion + 0.5;
    }

    refractedUV -= cc * distortion * GLASS_THICKNESS_REFRACTION;
    return cc * distortion + 0.5;
}

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
    if (!ENABLE_BLACKLIGHT) return color;

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
    float knee = 0.8;
    if (m <= knee) return c;
    float x = (m - knee) / (1.0 - knee);
    float mc = knee + (1.0 - knee) * (x / (1.0 + x));
    return c * (mc / m);
}

float3 SafeDither(float2 p)
{
    float n1 = trueRNG(float3(p, 1.0));
    float n2 = trueRNG(float3(p + 1.333, 2.0));
    return float3(n1, n1, n1) + float3(n2, n2, n2) - 1.0;
}

bool IsEvenInteger(float x) { return (floor(x) == x) && (floor(x / 2.0) == x / 2.0); }
float EffectivePeriod()
{
    float p = max(SUBFRAMES, 1.0);
    if (LCD_ANTI_RETENTION && IsEvenInteger(p)) p += 0.001;
    return p;
}

float EffectiveFrame(int frame) 
{
    int effectiveFrameCount = frame;
    if (LCDSafeMode && (int(SUBFRAMES) % 2 == 0))
    {
        int protectionInterval = FlipRate;
        if ((protectionInterval % int(SUBFRAMES)) == 0) protectionInterval += 1;
        if (PhaseFlipMethod == 0) effectiveFrameCount += int(frame * JumpRate);
        else effectiveFrameCount -= frame / protectionInterval;
    }
    float base = (float(effectiveFrameCount) + 12.345) * SIM_SPEED;
    if (ORGANIC_DRIFT_ENABLE)
        base += sin((timer + 1000.0) * 0.0003) * 1.0 + sin((timer + 1000.0) * 0.0001) * 0.5;
    return floor(base);
}

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
    float activeGain = GAIN_VS_BLUR * BFI_DUTY_CYCLE;
    float3 onTime = lin * (EffectivePeriod() * activeGain);
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

float3 FetchLive(float2 uv, float2 vpos)  { return decodeToLinear(ApplyAnalogSignalPath(LinearSampler, uv, vpos, framecount)); }
float3 FetchCurr(float2 uv, float2 vpos)  { return decodeToLinear(ApplyAnalogSignalPath(sCurrL, uv, vpos, framecount)); }
float3 FetchPrev1(float2 uv, float2 vpos) { return decodeToLinear(ApplyAnalogSignalPath(sPrev1L, uv, vpos, framecount)); }
float3 FetchPrev2(float2 uv, float2 vpos) { return decodeToLinear(ApplyAnalogSignalPath(sPrev2, uv, vpos, framecount)); }

float3 CrtPixel(float2 sampleUV, float2 vpos, float tubeFrame, float fStart, float fEnd, float period)
{
    if (!ENABLE_MPRT) return FetchLive(sampleUV, vpos);

    float maxOn = period * GAIN_VS_BLUR * BFI_DUTY_CYCLE;
    float feather = max(saturate(RASTER_FEATHER) * (fEnd - fStart), 1e-4);
    float w0 = fStart - 0.5 * feather;
    float w1 = fEnd + 0.5 * feather;

    float3 result = 0.0;
    float s2 = tubeFrame - period;
    if (HISTORY_WEIGHT_PREV2 > 0.0 && s2 + maxOn > w0 && s2 < w1)
        result += FrameContribution(FetchPrev2(sampleUV, vpos), s2, fStart, fEnd) * HISTORY_WEIGHT_PREV2;

    float s1 = tubeFrame;
    if (HISTORY_WEIGHT_PREV1 > 0.0 && s1 + maxOn > w0 && s1 < w1)
        result += FrameContribution(FetchPrev1(sampleUV, vpos), s1, fStart, fEnd) * HISTORY_WEIGHT_PREV1;

    float s0 = tubeFrame + period;
    if (s0 + maxOn > w0 && s0 < w1)
        result += FrameContribution(FetchCurr(sampleUV, vpos), s0, fStart, fEnd);

    result *= PHOSPHOR_DECAY;
    if (DARK_FLOOR_GAIN > 0.0)
        result = max(result, FetchPrev1(sampleUV, vpos) * DARK_FLOOR_GAIN);

    return result;
}

float3 ApertureGrille(float px, float py)
{
    float triadPx = max(GRILLE_PITCH_PX, 1.0);
    float w = max(1.0 / triadPx, GRILLE_SOFTNESS / 3.0);
    float t = frac(px / triadPx);
    float a0 = t - 0.5 * w, a1 = t + 0.5 * w;
    float hw = GRILLE_FILL / 6.0;

    float3 cov;
    cov.r = max(0.0, min(a1, 1.0/6.0 + hw) - max(a0, 1.0/6.0 - hw));
    cov.g = max(0.0, min(a1, 3.0/6.0 + hw) - max(a0, 3.0/6.0 - hw));
    cov.b = max(0.0, min(a1, 5.0/6.0 + hw) - max(a0, 5.0/6.0 - hw));
    cov /= w;

    if (MASK_TYPE == 1)
    {
        float ty = frac(py / (triadPx * 2.0));
        cov *= (ty < 0.5) ? 1.0 : 0.4;
    }

    return lerp(1.0, cov * lerp(1.0, 3.0 / GRILLE_FILL, GRILLE_COMPENSATION), GRILLE_INTENSITY);
}

float ScanlineModulation(float py, float3 col)
{
    if (!ENABLE_CYBERLAB_EXTRAS) return 1.0;
    float luma = dot(col, float3(0.299, 0.587, 0.114));
    float scanPhase = sin(py * 3.14159265 * SCANLINE_WIDTH);
    return lerp(1.0 - SCANLINE_INTENSITY, 1.0, pow(abs(scanPhase), lerp(1.0, 0.5, luma)));
}

float3 ApplyBloom(float2 uv, float3 baseColor)
{
    if (!ENABLE_CYBERLAB_EXTRAS || BLOOM_STRENGTH <= 0.0) return baseColor;
    float off = 1.5 * BUFFER_RCP_HEIGHT;
    float3 bloom = (
        tex2D(sCurrL, uv + float2(0, off)).rgb +
        tex2D(sCurrL, uv + float2(0, -off)).rgb +
        tex2D(sCurrL, uv + float2(off, 0)).rgb +
        tex2D(sCurrL, uv + float2(-off, 0)).rgb
    ) * 0.25;
    return baseColor + bloom * BLOOM_STRENGTH;
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
// PASSES & TECHNIQUE
//-------------------------------------------------------------------------------------------------

float4 PS_LatchPrev2(float4 vpos : SV_Position, float2 uv : TEXCOORD) : SV_Target 
{ 
    if (framecount < 3) return tex2D(PointSampler, uv);
    if (!ENABLE_MPRT || !IsNewCrtRefresh()) discard; 
    return tex2D(sPrev1, uv); 
}

float4 PS_LatchPrev1(float4 vpos : SV_Position, float2 uv : TEXCOORD) : SV_Target 
{ 
    if (framecount < 3) return tex2D(PointSampler, uv);
    if (!ENABLE_MPRT || !IsNewCrtRefresh()) discard; 
    return tex2D(sCurr, uv); 
}

float4 PS_LatchCurr(float4 vpos : SV_Position, float2 uv : TEXCOORD) : SV_Target  
{ 
    if (framecount < 3) return tex2D(PointSampler, uv);
    if (!ENABLE_MPRT || !IsNewCrtRefresh()) discard; 
    return tex2D(PointSampler, uv); 
}

float4 PS_BlacklightStrobe(float4 vpos : SV_Position, float2 uvIn : TEXCOORD) : SV_Target
{
    float alpha = tex2D(PointSampler, uvIn).a;

    if (SPLITSCREEN && uvIn.x > SPLITSCREEN_X)
    {
        if (abs(vpos.x - SPLITSCREEN_X * BUFFER_WIDTH) < 2.0) return float4(0.0, 0.0, 0.0, alpha);
        float3 orig = decodeToLinear(tex2D(PointSampler, uvIn).rgb) * (ENABLE_MPRT ? GAIN_VS_BLUR : 1.0);
        return float4(saturate(encodeFromLinear(orig)), alpha);
    }

    float3 sampleCenter = tex2D(PointSampler, uvIn).rgb;
    float lumaEst = dot(sampleCenter, float3(0.299, 0.587, 0.114));

    float2 refractedUV;
    float2 uv = ApplyAdvancedGlassCurvature(uvIn, lumaEst, refractedUV);

    if (CURVATURE_MODE > 0 && (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0))
        return float4(0.0, 0.0, 0.0, alpha);

    float2 uvR = refractedUV + (refractedUV - 0.5) * CONVERGENCE_SHIFT;
    float2 uvB = refractedUV - (refractedUV - 0.5) * CONVERGENCE_SHIFT;
    float2 uvG = refractedUV;

    float period = EffectivePeriod();
    float effectiveFrame = EffectiveFrame(framecount);
    float fStart = effectiveFrame - period * floor(effectiveFrame / period);
    float fEnd = fStart + 1.0;

    float tubePos = (SCAN_DIRECTION == 1) ? refractedUV.y : (SCAN_DIRECTION == 2) ? (1.0 - refractedUV.y) : (SCAN_DIRECTION == 3) ? refractedUV.x : (SCAN_DIRECTION == 4) ? (1.0 - refractedUV.x) : 0.0;
    float tubeFrame = tubePos * period;

    float3 result;
    result.r = CrtPixel(uvR, vpos.xy, tubeFrame, fStart, fEnd, period).r;
    result.g = CrtPixel(uvG, vpos.xy, tubeFrame, fStart, fEnd, period).g;
    result.b = CrtPixel(uvB, vpos.xy, tubeFrame, fStart, fEnd, period).b;

    if (SINE_BFI_ENABLE)
    {
        float sineWave = sin((tubeFrame * SINE_BFI_FREQUENCY + (timer * 0.001 * 6.28318))) * 0.5 + 0.5;
        result *= pow(sineWave, max(2.0 - (BFI_DUTY_CYCLE * 2.0), 0.1));
    }

    if (EDGE_SHARPEN > 0.0)
    {
        float texelX = BUFFER_RCP_WIDTH;
        float3 beamL = CrtPixel(refractedUV - float2(texelX, 0.0), vpos.xy, tubeFrame, fStart, fEnd, period);
        float3 beamR = CrtPixel(refractedUV + float2(texelX, 0.0), vpos.xy, tubeFrame, fStart, fEnd, period);
        float3 sharp = result + (result - 0.5 * (beamL + beamR)) * EDGE_SHARPEN;
        result = clamp(sharp, min(result, min(beamL, beamR)), max(result, max(beamL, beamR)));
    }

    float3 outColor = encodeFromLinear(result) * POST_BRIGHTNESS;

    outColor = ApplyBloom(refractedUV, outColor);
    outColor = ApplyBlacklightFilter(outColor);

    if (GRILLE_ENABLE)
    {
        outColor *= ApertureGrille(vpos.x, vpos.y);
        outColor *= DamperShadow(vpos.y);
    }

    outColor *= ScanlineModulation(vpos.y, outColor);

    if (INTERLACE_FIELD_FLICKER)
    {
        float fieldFlicker = (frac((vpos.y + float(framecount % 2)) * 0.5) < 0.5) ? 0.985 : 1.015;
        outColor *= fieldFlicker;
    }

    if (HUM_BAR > 0.0)
    {
        float hum = sin(refractedUV.y * 6.28318 * 2.0 - timer * 0.005) * 0.5 + 0.5;
        outColor *= (1.0 - HUM_BAR * hum);
    }

    if (CURVATURE_MODE > 0)
    {
        float2 vigCoord = uvIn * (1.0 - uvIn.xy);
        if (CORNER_DEPRESSION > 0.0)
        {
            float cornerShade = pow(saturate(vigCoord.x * vigCoord.y * 16.0), CORNER_DEPRESSION * 0.4);
            outColor *= cornerShade;
        }
        if (GLASS_FRESNEL_EDGE > 0.0)
        {
            float fresnel = pow(1.0 - saturate(4.0 * vigCoord.x * vigCoord.y), 3.0);
            outColor += fresnel * GLASS_FRESNEL_EDGE * float3(0.12, 0.15, 0.25);
        }
        if (GLASS_SPECULAR_SHEEN > 0.0)
        {
            float spec = pow(saturate(1.0 - abs(uvIn.y - 0.18) * 4.0), 6.0) * GLASS_SPECULAR_SHEEN;
            outColor += spec * 0.15;
        }
    }

    if (SOFT_CLIP) outColor = HueSoftClip(outColor);

    if (FORCE_16BIT_COLOR)
    {
        outColor.r = floor(outColor.r * 31.0 + 0.5) / 31.0;
        outColor.g = floor(outColor.g * 63.0 + 0.5) / 63.0;
        outColor.b = floor(outColor.b * 31.0 + 0.5) / 31.0;
    }

    float levels = (DITHER_BITS == 0) ? 255.0 : 1023.0;
    outColor += SafeDither(vpos.xy + float2(framecount, 0.0)) * (DITHER_STRENGTH / levels);

    return float4(saturate(outColor), alpha);
}

technique BlurBustersBlacklightStrobe <
    ui_label = "Blur Busters Blacklight Strobe Simulator (Ultimate True RNG & Analog Standard Edition)";
>
{
    pass LatchPrev2 { VertexShader = PostProcessVS; PixelShader = PS_LatchPrev2; RenderTarget = TexPrev2; ClearRenderTargets = false; }
    pass LatchPrev1 { VertexShader = PostProcessVS; PixelShader = PS_LatchPrev1; RenderTarget = TexPrev1; ClearRenderTargets = false; }
    pass LatchCurr  { VertexShader = PostProcessVS; PixelShader = PS_LatchCurr;  RenderTarget = TexCurr;  ClearRenderTargets = false; }
    pass Main       { VertexShader = PostProcessVS; PixelShader = PS_BlacklightStrobe; }
}