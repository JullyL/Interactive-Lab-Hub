number_prompt.sh
=================

This small shell script verbally prompts a user for a numeric answer (phone number, zipcode, number of pets, etc.), plays a short beep, records the spoken response to a WAV file, and writes a small metadata file.

Files
- `number_prompt.sh` — the script to run

Dependencies
- TTS: `espeak-ng` or `espeak` or `festival` (espeak-ng recommended)
- Recorder: `arecord` (from `alsa-utils`) or `sox` (provides `rec` and `play`)
- Optional: `sox`'s `play` for beep sound (script falls back to terminal bell if not available)

Install on Debian/Raspbian (example):

```bash
sudo apt update
sudo apt install -y espeak-ng alsa-utils sox
```

Usage

1. Make the script executable:

```bash
cd "$(dirname "${BASH_SOURCE[0]}")"
chmod +x number_prompt.sh
```

2. Run it (it will create `recordings/` in the same folder):

```bash
./number_prompt.sh
```

3. After recording you'll find a WAV file and a `.txt` metadata file in `recordings/`.

Transcription (optional)

If you want to transcribe the recorded audio to text, you can use OpenAI Whisper locally (`whisper.cpp`/`whisper`), the Python `whisper` package, or a cloud STT API.

Example with OpenAI Whisper (python package):

```bash
# create a venv and install
python3 -m venv venv
source venv/bin/activate
pip install -U openai-whisper
python -m whisper recordings/number_response_YYYYMMDDTHHMMSSZ.wav
```

Notes and tips
- Increase `DURATION` inside the script if you expect longer answers.
- The script records a fixed-length clip; for more robust UX you can implement VAD (voice activity detection) using `webrtcvad` or `sox silence` to stop recording after silence.
- For data privacy, store recordings securely and add consent wording to the spoken prompt if used in studies.

License
- CC0 / public domain — feel free to adapt for your lab exercises.
