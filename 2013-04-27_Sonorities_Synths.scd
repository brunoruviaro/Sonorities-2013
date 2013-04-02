// ============================================
// Sonorities 2013 - SynthDefs
// 2013-04-27, BTR
// ============================================

// ************
// LOAD SAMPLES
// ************

Buffer.freeAll;

b=(); // <== Buffers will be stored here

b.media = "/home/ruviaro/Music/SuperCollider/2013-04-27_Sonorities_Belfast/samples/*.wav".pathMatch.collect { |i| Buffer.read(s, i)};

b.media.size;

["number of samples", b.media.size].postln;
"File loaded successfully".postln;
" ".postln;

// *************
// SYNTHDEFs etc
// *************

~sampleBus1 = Bus.audio(s, 1);
~sampleBus2 = Bus.audio(s, 1);

// Create a SynthDef for playing back samples
// Note it outputs mono into TBA "outbus"

SynthDef("midi-sample-playback", {
	arg bufnum = 0, rate = 1, mul = 1, gate, outbus;
	var env = EnvGen.ar(Env([0, mul, mul * 0.7, 0], [0.01, 0.5, 0.6], -5, 2), gate, doneAction: 2);
	var out;
	out = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum) * rate, loop: 1) * env;
	Out.ar(outbus, out);
}).add;

// Synth intro from Bernardo

SynthDef("intro", {arg amp = 0.1;
  var sig;
  sig =  amp * LPF.ar( LPF.ar(
	NLFiltC.ar(
		SinOsc.ar([40, 34.3, 44.5, 55].midicps +
LFNoise2.kr(0.1!4, 17, 0) , LFNoise2.kr(0.2!4, 0.4, 0.4),
LFNoise2.kr(0.2!4, 0.3, 0.5)) ,
		LFNoise1.kr(0.1, 0.5, 0.5),
		LFNoise1.kr(0.2, 0.5, 0.5) * -1,
		LFNoise1.kr(0.3, 0.5, 0.5),
		LFNoise1.kr(0.4, 0.5, 0.5),
		LFCub.kr(0.2, [0, 0.5 * pi], 100, 400)
	), 4000, 0.4), LFNoise2.kr(0.08, 2000, 5000), 1) * SinOsc.kr(rrand(7,
[8, 9, 10, 11] * SinOsc.kr(0.1, 0, 1).range(0.081, 3.0)), 0.4, 0.4);

Out.ar(0, sig);

}).add;

// Create SynthDef for controlling Pan4

SynthDef.new("iPan4", {
	arg xorigin, yorigin, xtarget, ytarget, dur, inbus, t_trig;
	var sig = In.ar(inbus, 1);
	var xenv = EnvGen.ar(Env.new( [xorigin, xtarget], [dur] ), gate: t_trig);
	var yenv = EnvGen.ar(Env.new( [yorigin, ytarget], [dur] ), gate: t_trig);
	Out.ar(0, Pan4.ar(sig, xenv, yenv));
}).add;

// SynthDef to control amplitude (MASTER OUT)

 SynthDef(\amp, {arg inbus, amp = 0.5;
     ReplaceOut.ar(inbus, In.ar(inbus, 4) * amp * 0.7);
     }).add;


