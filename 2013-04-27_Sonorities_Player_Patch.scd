// ==============================
// Sonorities 2013 PLAYER PATCH
// ==============================

// Rehearsal 2013-04-16

// "qjackctl --start".unixCmd; // open and start JACK

// acorde ikeda (layer 3, mi) com panning automatico rapido
// junto com layer 2, sol la si, graves "aveludados" meio bolha/
// bernardo talvez quebrar o som longo (agua) em samples menores
// tocaveis pelo teclado (talvez filtros LP, transpor, etc).
// Objetivo: chegar num outro tipo de interacao de pequenos gestos
// que se concentrem no medio-grave

"slgui".unixCmd;

"slgui -L /home/ruviaro/Music/SuperCollider/Sonorities-2013/sooperlooper_4ch_2013-04-27.slsess -m /home/ruviaro/Music/SuperCollider/Sonorities-2013/sooperlooper_midi_bindings.slb".unixCmd;// open and start SooperLooper

s.boot;// boot SC server
().play;

MIDIIn.connect;// open SC MIDI connections

//"jmess -D".unixCmd; // JACK disconnect all
//"jmess -c /home/ruviaro/Music/SuperCollider/2013-04-27_Sonorities/jmess_rehearsal_with_built-in_audio.xml".unixCmd; // Load JACK connections

"aconnect 20:1 129:0".unixCmd; "aconnect 20:1 131:1".unixCmd;  // connect PCR1 to SuperCollider

("/home/ruviaro/Music/SuperCollider/Sonorities-2013/2013-04-27_Sonorities_Synths.scd").load;
("/home/ruviaro/Music/SuperCollider/Sonorities-2013/2013-04-27_Sonorities_MIDI.scd").load;

// Run iPan4, starting with sounds in the center of square
~iPan4 = Synth("iPan4", [\xorigin, 0, \yorigin, 0, \xtarget, 0, \ytarget, 0, \dur, 0, \inbus, ~sampleBus1, \t_trig, 1])

~intro = Synth("intro-cleancode", [\amp, ~kbus_intro_vol.asMap, \freq1, ~kbus_intro_freq1.asMap, \freq2, ~kbus_intro_freq2.asMap, \fifreq, ~kbus_intro_fifreq.asMap], addAction: \addToTail);

// older call
// ~intro = Synth("intro-cleancode", [\amp, ~kbus_intro.asMap], addAction: \addToTail);

// Start the global volume control
~masterOut = Synth("amp", target: ~intro , addAction: \addBefore);

s.meter;

"meterbridge -t dpm x x x x".unixCmd;


/*
0. connect audio & MIDI interfaces
1. open qjackctl (uncheck pulseaudio options)
2. start JACK
3. disconnect all
4. open SooperLooper, load session
5. open emacs, start SuperCollider, boot server
*/





/*
n = NoteOnResponder({|src, chan, num, vel| [src, chan, num, vel].postln}, nil, nil, (0..127), (0..127) );
n.remove;
*/
