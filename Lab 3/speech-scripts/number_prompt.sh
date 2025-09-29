#!/usr/bin/env bash
# number_prompt.sh
# Verbally asks for a numeric answer and records the respondent's spoken reply.
# Saves the recording and a small metadata file with timestamp and prompt.

set -euo pipefail

# Configuration
PROMPT_TEXT="Please say your five-digit ZIP code now. Speak each digit clearly after the beep."
OUT_DIR="./recordings"
FORMAT="wav"
SAMPLE_RATE=16000
CHANNELS=1
DURATION=6  # seconds to record (adjust if you expect longer answers)

mkdir -p "$OUT_DIR"

timestamp() { date -u +%Y%m%dT%H%M%SZ; }

TS=$(timestamp)
OUT_FILE="$OUT_DIR/zipcode_response_$TS.$FORMAT"
META_FILE="$OUT_DIR/zipcode_response_$TS.txt"

# Helper: speak text using available TTS (espeak-ng or espeak)
speak() {
  local text="$1"
  if command -v espeak-ng >/dev/null 2>&1; then
    espeak-ng --stdout "$text" | aplay 2>/dev/null || true
  elif command -v espeak >/dev/null 2>&1; then
    espeak --stdout "$text" | aplay 2>/dev/null || true
  elif command -v festival >/dev/null 2>&1; then
    # festival may need different syntax
    echo "$text" | festival --tts
  else
    # Fallback: print to console only
    echo "TTS not found. Please install espeak-ng, espeak, or festival to enable speech." >&2
    echo "$text"
  fi
}

# Helper: play beep (simple sine using sox or beep)
beep() {
  if command -v play >/dev/null 2>&1; then
    # play a 1-second beep (sox)
    play -n synth 1.0 sine 800 >/dev/null 2>&1 || true
  elif command -v aplay >/dev/null 2>&1 && command -v python3 >/dev/null 2>&1; then
  # Generate a 1-second 800Hz sine wave with Python into memory and play via aplay
  python3 - <<'PY' | aplay -q -t wav -
import sys, math, wave, struct, io
fr = 16000
dur = 1.0
freq = 800.0
n = int(fr * dur)
bio = io.BytesIO()
wf = wave.open(bio, 'wb')
wf.setnchannels(1)
wf.setsampwidth(2)
wf.setframerate(fr)
frames = bytearray()
for i in range(n):
  v = int(32767 * 0.5 * math.sin(2 * math.pi * freq * i / fr))
  frames += struct.pack('<h', v)
wf.writeframes(frames)
wf.close()
sys.stdout.buffer.write(bio.getvalue())
PY
  else
    # no beep available
    printf "\a" # terminal bell
  fi
}

speak_note="(This prompt asks for a ZIP code; only digits are expected.)"
echo "Prompt: $PROMPT_TEXT"
echo "$speak_note"
speak "$PROMPT_TEXT"
beep

echo "Recording for $DURATION seconds to $OUT_FILE..."

# Record using arecord (ALSA) if available, otherwise try sox (rec)
if command -v arecord >/dev/null 2>&1; then
  arecord -f S16_LE -r "$SAMPLE_RATE" -c "$CHANNELS" -d "$DURATION" "$OUT_FILE"
elif command -v rec >/dev/null 2>&1; then
  rec -c "$CHANNELS" -r "$SAMPLE_RATE" "$OUT_FILE" trim 0 "$DURATION"
else
  echo "No recorder found (arecord or sox's rec). Install alsa-utils or sox." >&2
  exit 2
fi

echo "Recording finished."

# Save metadata
cat > "$META_FILE" <<EOF
timestamp: $TS
prompt: $PROMPT_TEXT
file: $OUT_FILE
duration_s: $DURATION
sample_rate: $SAMPLE_RATE
channels: $CHANNELS
EOF

echo "Saved metadata to $META_FILE"
echo "You can transcribe the file with your preferred STT (Whisper, Google Speech-to-Text, etc)."

exit 0
