import wave
import math
import struct
import random

def generate_wav(filename, sample_rate, duration, generator_func):
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(sample_rate)

        num_frames = int(sample_rate * duration)
        data = bytearray()

        for i in range(num_frames):
            t = float(i) / sample_rate
            sample = generator_func(t, i)
            # Clip and pack
            sample = max(-32768, min(32767, int(sample * 32767)))
            data.extend(struct.pack('<h', sample))

        wav_file.writeframes(data)

# 1. Bounce (low thud, decaying sine wave)
def bounce_gen(t, i):
    freq = 150 - (t * 500)
    if freq < 20: freq = 20
    env = max(0, 1.0 - t * 5.0)
    return math.sin(2 * math.pi * freq * t) * env * 0.8

generate_wav('bounce.wav', 44100, 0.3, bounce_gen)

# 2. Explosion (white noise with decay)
def explosion_gen(t, i):
    env = max(0, 1.0 - t * 1.5)
    noise = random.uniform(-1.0, 1.0)
    return noise * env * 0.8

generate_wav('explosion.wav', 44100, 1.0, explosion_gen)

# 3. Boost (high pitch chime)
def boost_gen(t, i):
    freq = 800 + (t * 1000)
    env = max(0, 1.0 - t * 2.0)
    return math.sin(2 * math.pi * freq * t) * env * 0.5

generate_wav('boost.wav', 44100, 0.5, boost_gen)

# 4. Siren (alternating high/low pitch)
def siren_gen(t, i):
    # toggle every 0.5 seconds
    if int(t * 4) % 2 == 0:
        freq = 600
    else:
        freq = 800
    env = 0.3 # continuous
    return math.sin(2 * math.pi * freq * t) * env

generate_wav('siren.wav', 44100, 1.0, siren_gen)

print("Sounds generated.")
