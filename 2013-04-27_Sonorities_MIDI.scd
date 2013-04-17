// *******************
//  Sonorities 2013
//  MIDI keyboard input
// *******************

// This file mixes new MIDI notation MIDIFunc with old Responder stuff... one day I'll clean it up...

var noteDict = Dictionary.new;
NoteOnResponder.removeAll;
NoteOffResponder.removeAll;
CCResponder.removeAll;
MIDIdef.freeAll;

~layer = 1;

//MIDIFunc.cc({arg ...args; args.postln}, (1..10)); // match cc 1-10

CCResponder
    ({ |src, chan, num, vel|
		case
		{num==37} {~layer = 1}
		{num==38} {~layer = 2}
		{num==39} {~layer = 3};

		["ACTIVE LAYER: "++~layer].postln;
		" ".postln;
    }, nil, nil, (37..39), 127);

CCResponder
    ({ |src, chan, num, val|
	~masterOut.set(\amp, val.linexp(0,127,0.001,2));
	    }, nil, nil, 18, nil);

//////////////////////////
// Stuff for intro synth
//////////////////////////

~kbus_intro_vol = Bus.control;
~kbus_intro_freq1 = Bus.control;
~kbus_intro_freq2 = Bus.control;
~kbus_intro_fifreq = Bus.control;

// set initial values
~kbus_intro_vol.set(0.0);
~kbus_intro_freq1.set(56);
~kbus_intro_freq2.set(61);
~kbus_intro_fifreq.set(3000);

~kbus_intro_vol.getSynchronous;
~kbus_intro_freq1.getSynchronous;
~kbus_intro_freq2.getSynchronous;
~kbus_intro_fifreq.getSynchronous;

MIDIdef.cc(
	key: \myintrovol,
	func: { |val, ccnum| ~kbus_intro_vol.set(val.linexp(0,127,0.001,1.5))},
	ccNum: 11); // First fader controls intro volume

MIDIdef.cc(
	key: \myfreq1,
	func: { |val, ccnum| ~kbus_intro_freq1.set(val.linlin(0,127,56,59))},
	ccNum: 21); // first knob controls one of the intro notes

MIDIdef.cc(
	key: \myfreq2,
	func: { |val, ccnum| ~kbus_intro_freq2.set(val.linlin(0,127,61,64))},
	ccNum: 22); // second knob controls another of intro notes

MIDIdef.cc(
	key: \fifreq,
	func: { |val, ccnum| ~kbus_intro_fifreq.set(val.linexp(0,127,100,4400))},
	ccNum: 23); // third knob controls LPF cutoff frequency (subtle)

/* OLD
CCResponder
    ({ |src, chan, num, val|
		~kbus_intro_vol.set(val/127);
	    }, nil, nil, 14, nil);
*/
/*
CCResponder
    ({ |src, chan, num, val|
		case
		{val>0} {w = Synth("intro", [\amp, ~kbus_intro.asMap], addAction: \addToTail)}
		{val==0} {w.free};
	}, nil, nil, 34, nil);
*/

//////////////////////////////////////////////////
// Keys playing samples
// note on becomes bufnum, gate=1 triggers envelope
// note off sends gate=0, triggers release envelope
//////////////////////////////////////////////////////
NoteOnResponder
	({|src, chan, note, vel|

		var offsetBuffer, bufnum, rate, amp;

		case
		 {~layer==1} {offsetBuffer = 0}
		 {~layer==2} {offsetBuffer = 12}
		 {~layer==3} {offsetBuffer = 24};

		bufnum = note.linlin(48, 72, (0+offsetBuffer), (24+offsetBuffer));
		rate =  vel.linlin(0, 127, 0.9, 1.5);
		amp = vel/127;

		noteDict.put(note, Synth("midi-sample-playback",
			[\bufnum, bufnum,
			 \rate, rate,
			 \mul, amp,
			 \gate, 1,
			 \outbus, ~sampleBus1],
		     addAction: \addToHead));

		//["L"++~layer, "buffer "++bufnum].postln;
		["L"++~layer, b.media[bufnum]].postln;

	}, nil, nil, (48..72), nil);

NoteOffResponder
	({|src, chan, note, vel|
		noteDict.at(note).set(\gate, 0);
		noteDict.removeAt(note);
	}, nil, nil, (48..72), nil);

//
// Section below: keyboard control of Pan4
//

~switch = 1; // turn on and off interpolation between pan keys
~thisvel = 127; // to be used by Task below;
~taskflag = 0; // task flag

// This Task will be used as automated panning; player can turn it on with Bb key

~autoPanTask = Task({
inf.do({
var thisx = (2.0.rand - 1).round(0.01);
var thisy = (2.0.rand - 1).round(0.01);
var thisdur = ~thisvel.linlin(0, 127, 5, 0.1).round(0.01);
~iPan4.set(
	\xtarget, thisx,
	\ytarget, thisy,
	\dur, thisdur,
	\t_trig, 1);
	[thisx, thisy, thisdur].postln;
	(thisdur+(thisdur*0.05)).wait;
})});


// Responds to MIDI notes 41-47 to control Panning features
NoteOnResponder
	({|src, chan, note, vel|
		var dur;

		if(note==42, {if(~switch == 1,
			               {~switch = 0; "Interpolation OFF".postln},   // turn off interpolation
			               {~switch = 1; "Interpolation ON".postln})}); // turn on interpolation

		if(note==46, {if(~taskflag == 0,
			               {~thisvel = vel; ~autoPanTask.start; ~taskflag = 1; "Auto Pan is ON".postln},
			               {~autoPanTask.stop; ~taskflag = 0; "Auto Pan is OFF".postln})});

		dur = vel.linexp(0, 127, 8, 0.1).round(0.01) * ~switch + 0.01; // 0.01 is shortest dur allowed

	case
		{note==41} {~iPan4.set(\xtarget, -1, \ytarget, 1, \dur, dur, \t_trig, 1); ["LF in "++dur++" seconds" ].postln}     // left front
		{note==43} {~iPan4.set(\xtarget, 1, \ytarget, 1, \dur, dur, \t_trig, 1); ["RF in "++dur++" seconds" ].postln}      // right front
		{note==44} {~iPan4.set(\xtarget, 0, \ytarget, 0, \dur, dur, \t_trig, 1); ["CENTER in "++dur++" seconds" ].postln}  // CENTER
		{note==45} {~iPan4.set(\xtarget, 1, \ytarget, -1, \dur, dur, \t_trig, 1); ["RR in "++dur++" seconds" ].postln}     // right rear
		{note==47} {~iPan4.set(\xtarget, -1, \ytarget, -1, \dur, dur, \t_trig, 1); ["LR in "++dur++" seconds" ].postln};   // left rear



	}, nil, nil, (41..47), nil);

 // end of MIDI keyboard input




