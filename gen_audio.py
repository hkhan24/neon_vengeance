import wave, struct, math, random

RATE = 44100
DURATION = 8  # 8-second loop

def sine(freq, t, vol=1.0):
    return vol * math.sin(2 * math.pi * freq * t)

def saw(freq, t, vol=1.0):
    phase = (freq * t) % 1.0
    return vol * (2.0 * phase - 1.0)

def square(freq, t, vol=1.0):
    phase = (freq * t) % 1.0
    return vol * (1.0 if phase < 0.5 else -1.0)

def lowpass(samples, alpha=0.05):
    """Simple single-pole low-pass filter"""
    out = [samples[0]]
    for i in range(1, len(samples)):
        out.append(out[-1] + alpha * (samples[i] - out[-1]))
    return out

def generate_bgm():
    total_samples = RATE * DURATION
    samples = []
    
    # Streets of Rage style: minor key, slow groove
    # Key of A minor / E minor
    bass_pattern = [82.41, 82.41, 110.0, 110.0, 98.0, 98.0, 73.42, 82.41]  # E2, A2, G2, D2, E2
    
    # Pad chord (Am7 vibe)
    pad_freqs = [220.0, 261.63, 329.63]  # A3, C4, E4
    
    # Arp pattern (pentatonic)
    arp_notes = [329.63, 392.0, 440.0, 523.25, 440.0, 392.0, 329.63, 293.66]
    
    for i in range(total_samples):
        t = i / RATE
        beat = t * 2  # 120 BPM = 2 beats per second
        bar_pos = beat % 8  # 8 beats per loop segment
        
        sample = 0.0
        
        # Bass - deep saw with low-pass feel (volume reduced for smoothness)
        bass_idx = int(bar_pos) % len(bass_pattern)
        bass_freq = bass_pattern[bass_idx]
        bass_env = 0.8 - 0.3 * ((beat % 1.0))  # slight decay per beat
        sample += saw(bass_freq, t, 0.12 * max(bass_env, 0.3))
        
        # Sub bass - pure sine one octave below
        sample += sine(bass_freq / 2, t, 0.15)
        
        # Pad - warm sine chords with slow attack
        pad_env = 0.5 + 0.3 * sine(0.25, t)  # slow breathing
        for pf in pad_freqs:
            sample += sine(pf, t, 0.06 * pad_env)
            sample += sine(pf * 1.003, t, 0.03 * pad_env)  # slight detune for warmth
        
        # Arp - gentle square wave melody
        arp_idx = int(beat * 2) % len(arp_notes)  # 16th note arps
        arp_freq = arp_notes[arp_idx]
        arp_env = max(0, 1.0 - ((beat * 2) % 1.0) * 3)  # short plucky decay
        sample += square(arp_freq, t, 0.04 * arp_env)
        
        # Hi-hat - noise on every other 16th
        if int(beat * 4) % 2 == 0:
            hat_env = max(0, 1.0 - ((beat * 4) % 1.0) * 8)
            sample += random.uniform(-1, 1) * 0.02 * hat_env
        
        # Kick drum sim - low sine burst on beats 1 and 3
        kick_pos = beat % 2
        if kick_pos < 0.08:
            kick_env = 1.0 - kick_pos / 0.08
            sample += sine(55 * (1 + kick_env * 2), t, 0.2 * kick_env)
        
        # Soft clamp
        sample = max(-0.9, min(0.9, sample))
        samples.append(sample)
    
    # Apply lowpass filter for that warm retro feel
    samples = lowpass(samples, alpha=0.15)
    
    # Write WAV
    with wave.open('assets/audio/bgm.wav', 'w') as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(RATE)
        for s in samples:
            f.writeframes(struct.pack('<h', int(s * 32767)))

def generate_hit():
    """Crunchy retro hit sound - 0.15s"""
    total = int(RATE * 0.15)
    samples = []
    for i in range(total):
        t = i / RATE
        env = max(0, 1.0 - t / 0.12)  # fast decay
        # Mix noise with low tone for crunch
        noise = random.uniform(-1, 1) * 0.4 * env
        tone = sine(120, t, 0.5 * env) + sine(80, t, 0.3 * env * env)
        samples.append(max(-0.95, min(0.95, noise + tone)))
    
    with wave.open('assets/audio/hit.wav', 'w') as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(RATE)
        for s in samples:
            f.writeframes(struct.pack('<h', int(s * 32767)))

if __name__ == '__main__':
    generate_bgm()
    generate_hit()
    print("Audio generated successfully!")
