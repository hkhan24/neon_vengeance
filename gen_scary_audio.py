import wave, struct, math, random

RATE = 44100
DURATION = 8  # 8-second loop

def sine(freq, t, vol=1.0):
    return vol * math.sin(2 * math.pi * freq * t)

def lowpass(samples, alpha=0.05):
    out = [samples[0]]
    for i in range(1, len(samples)):
        out.append(out[-1] + alpha * (samples[i] - out[-1]))
    return out

def generate_scary_bgm():
    total_samples = RATE * DURATION
    samples = []
    
    # Eerie, low rumbling and dissonant high pitches
    for i in range(total_samples):
        t = i / RATE
        sample = 0.0
        
        # Deep rumble
        sample += sine(40, t, 0.4)
        sample += sine(42, t, 0.3)
        
        # Eerie high pitch sweeping
        sweep = 400 + 100 * math.sin(t * 0.5)
        sample += sine(sweep, t, 0.1)
        sample += sine(sweep * 1.1, t, 0.05)
        
        # Random noise for wind
        sample += random.uniform(-1, 1) * 0.02
        
        # Soft clamp
        sample = max(-0.9, min(0.9, sample))
        samples.append(sample)
    
    samples = lowpass(samples, alpha=0.2)
    
    with wave.open('assets/audio/level2_bgm.wav', 'w') as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(RATE)
        for s in samples:
            f.writeframes(struct.pack('<h', int(s * 32767)))

if __name__ == '__main__':
    generate_scary_bgm()
