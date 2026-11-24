class_name PlaceholderSfx
extends RefCounted
## Makes simple placeholder sounds in code, until real sound effects exist
## (GDD: jsfxr / Bfxr). Delete a call here once its real sound is in.

const MIX_RATE: int = 22050
const MAX_AMPLITUDE: float = 32767.0


## A short metallic "ting": a sine tone that fades out quickly.
static func ping(frequency: float, duration: float, volume: float = 0.6) -> AudioStreamWAV:
	var sample_count := int(duration * MIX_RATE)
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	for i in sample_count:
		var t := float(i) / MIX_RATE
		var fade := 1.0 - float(i) / sample_count
		var value := sin(TAU * frequency * t) * fade * fade * volume
		data.encode_s16(i * 2, int(value * MAX_AMPLITUDE))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	stream.data = data
	return stream
