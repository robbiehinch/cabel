<?xml version="1.0" encoding="utf-8"?>
<workspace name="formant_butterlp">
	<referencesModules>
		<moduleReference description="Midi input of frequency, note number, velocity and channel aftertouch" name="control/MidiNoteIn">
			<input>
				<vardef csType="i" description="Scaling of MIDI velocity" max="32000.0" min="0.0" name="velscale"/>
				<vardef csType="i" description="Minimal value for scaled channel aftertouch" name="minafttch"/>
				<vardef csType="i" description="Maximal value for scaled channel aftertouch" name="maxafttch"/>
			</input>
			<output>
				<vardef csType="k" description="Frequency of MIDI note with pitch bend information" name="frq"/>
				<vardef csType="k" description="MIDI note number of last pressed key" name="note"/>
				<vardef csType="i" description="Velocity of MIDI note" name="vel"/>
				<vardef csType="k" description="Scaled channel aftertouch" name="afttch"/>
			</output>
			<opcode>
				/* Midi keyboard input of note number and velocity */
opcode MidiNoteIn, kkik, iii
  ivelscale, iminafttch, imaxafttch xin

  knote init 0
  kvel init 0
  kafttch init 0

  midinoteonkey knote, kvel
  midichannelaftertouch kafttch, iminafttch, imaxafttch
  kfrq cpsmidib
  ivel ampmidi  ivelscale

  xout kfrq, knote, ivel, kafttch
endop
			</opcode>
		</moduleReference>
		<moduleReference description="Saw oscillator (aplitude 1)" name="sound sources/SawVco">
			<input>
				<vardef csType="k" description="Frequency of oscillator" min="0.0" name="frq"/>
				<vardef csType="k" description="Shape of wave, sawtooth/triangle/ramp" max="0.999" min="0.001" name="shape"/>
			</input>
			<output>
				<vardef csType="a" description="Output of oscillator (amplitude 1)" name="out"/>
			</output>
			<opcode>
				/* Saw oscillator */
opcode SawVco, a, kk
  kfrq, kshape xin

  kfrq     limit     kfrq, 0, 50000
  kshape   limit     kshape, 0.001, 0.999
  aout     vco2      1, kfrq, 4, kshape

  xout aout
endop
			</opcode>
		</moduleReference>
		<moduleReference description="Output mono signal to sound card" name="input output/PcmMonoOut">
			<input>
				<vardef csType="a" description="Audio input" name="in"/>
			</input>
			<opcode>
				/* Output mono signal to sound card */
opcode PcmMonoOut, 0, a
  ain xin
     out ain
endop
			</opcode>
		</moduleReference>
		<moduleReference description="Formant filter (be careful with amplitude of output)" name="filters/Formant">
			<input>
				<vardef csType="a" description="Audio rate input" name="in"/>
				<vardef csType="k" description="Filter center frequency" min="0.0" name="fcf"/>
				<vardef csType="k" description="Impulse response attack time in seconds" max="100.0" min="0.0" name="atk"/>
				<vardef csType="k" description="Impulse response decay time in seconds" max="100.0" min="0.0" name="dec"/>
			</input>
			<output>
				<vardef csType="a" description="Filtered audio signal" name="out"/>
			</output>
			<opcode>
				/* Formant filter */
opcode Formant, a, akkk
  ain, kfcf, katk, kdec  xin

  kfcf    limit kfcf, 0, 50000
  katk    limit katk, 0, 100
  kdec    limit kdec, 0, 100
  aout    fofilter ain, kfcf, katk, kdec

  xout aout
endop
			</opcode>
		</moduleReference>
		<moduleReference description="Sine low frequency oscillator" name="modulators/SineLfo">
			<input>
				<vardef csType="k" description="Frequency of LFO" max="100.0" min="0.0" name="frq"/>
				<vardef csType="k" description="Amplitude of LFO" min="0.0" name="amp"/>
				<vardef csType="i" description="Initial phase of LFO (negativ to skip initialisation)" max="1.0" min="-0.001" name="phi"/>
			</input>
			<output>
				<vardef csType="k" description="Output of LFO" name="out"/>
			</output>
			<global>
				<def description="Sine table">
					gisinelfo   ftgen  0, 0, 2048, 10 ,1
				</def>
			</global>
			<opcode>
				/* Sine low frequency oscillator */
opcode SineLfo, k, kki
  kfrq, kamp, iphi xin

  kfrq     limit      kfrq, 0, 100
  kamp     limit      kamp, 0, 50000
  iphi     limit      iphi, -1, 1
  kout     oscil      kamp, kfrq, gisinelfo, iphi

  xout kout
endop
			</opcode>
		</moduleReference>
		<moduleReference description="Add two control signals" name="maths/ControlAdd">
			<input>
				<vardef csType="k" description="First control signal" name="in1"/>
				<vardef csType="k" description="Second control signal" name="in2"/>
			</input>
			<output>
				<vardef csType="k" description="Sum of input signals" name="sum"/>
			</output>
			<opcode>
				/* Add two control signals */
opcode ControlAdd, k, kk
  kin1, kin2 xin
  ksum = kin1 + kin2
  xout ksum
endop
			</opcode>
		</moduleReference>
		<moduleReference description="MIDI activated linear ADSR envelope" name="modulators/AdsrLinMidi">
			<input>
				<vardef csType="i" description="Amplitude scale factor" name="amp"/>
				<vardef csType="i" description="Attack time in seconds" min="0.0" name="atk"/>
				<vardef csType="i" description="Decay time in seconds" min="0.0" name="dec"/>
				<vardef csType="i" description="Sustain level" max="1.0" min="0.0" name="slev"/>
				<vardef csType="i" description="Release time in seconds" min="0.0" name="rel"/>
			</input>
			<output>
				<vardef csType="k" description="Envelope at control rate" name="env"/>
			</output>
			<opcode>
				/* MIDI activated linear ADSR envelope */
opcode AdsrLinMidi, k, iiiii
  iamp, iatk, idec, islev, irel xin

  kenv     madsr      iatk, idec, islev, irel
  kenv     =          iamp*kenv

  xout kenv
endop
			</opcode>
		</moduleReference>
		<moduleReference description="Mixer for two audio signals" name="amps mixers/Mixer2">
			<input>
				<vardef csType="a" description="First audio rate signal" name="in1"/>
				<vardef csType="k" description="Amplitude multiplicator for in1" min="0.0" name="gain1"/>
				<vardef csType="a" description="Second audio rate signal" name="in2"/>
				<vardef csType="k" description="Amplitude multiplicator for in2" min="0.0" name="gain2"/>
			</input>
			<output>
				<vardef csType="a" description="Mixed input signals" name="out"/>
			</output>
			<opcode>
				/* Mixer for two audio signals */
opcode Mixer2, a, akak
  ain1, kgain1, ain2, kgain2 xin
  aout = ain1*kgain1 + ain2*kgain2
  xout aout
endop
			</opcode>
		</moduleReference>
		<moduleReference description="Amplify audio signal" name="amps mixers/Amp">
			<input>
				<vardef csType="a" description="Audio signal" name="in"/>
				<vardef csType="k" description="Gain" name="gain"/>
			</input>
			<output>
				<vardef csType="a" description="Amplified audio signal" name="out"/>
			</output>
			<opcode>
				/* Amplify audio signal */
opcode Amp, a, ak
  ain, kgain xin
  aout = ain * kgain
  xout aout
endop
			</opcode>
		</moduleReference>
		<moduleReference description="A second-order low-pass Butterworth filter" name="filters/ButterLp">
			<input>
				<vardef csType="a" description="Audio rate input" name="in"/>
				<vardef csType="k" description="Filter cut-off frequency" min="0.0" name="fco"/>
			</input>
			<output>
				<vardef csType="a" description="Filtered audio signal" name="out"/>
			</output>
			<opcode>
				/* Second-order Butterworth low-pass filter */
opcode ButterLp, a, ak
  ain, kfco  xin

  kfco    limit kfco, 0, 50000
  aout    butterlp ain, kfco

  xout aout
endop
			</opcode>
		</moduleReference>
		<moduleReference description="Reverb based on the MN3011 IC" name="effects/AnalogEcho">
			<input>
				<vardef csType="a" description="Audio input" name="in"/>
				<vardef csType="i" description="Output level" max="1.0" min="0.0" name="lvl"/>
				<vardef csType="i" description="Delay factor" max="1.0" min="0.0" name="delay"/>
				<vardef csType="i" description="Feedback amount" max="1.0" min="0.0" name="fdbk"/>
				<vardef csType="i" description="Reverb amount" max="1.0" min="0.0" name="echo"/>
			</input>
			<output>
				<vardef csType="a" description="Input with applied echo" name="out"/>
			</output>
			<opcode>
				/* Reverb based on the MN3011 IC */
opcode AnalogEcho, a, aiiii
  ain, ilvl, idelay, ifdbk, iecho  xin

  afdbk     init     0
  ain       =        ain+afdbk*ifdbk
  atemp     delayr   1
  atap1     deltapi  0.0396*idelay
  atap2     deltapi  0.0662*idelay
  atap3     deltapi  0.1194*idelay
  atap4     deltapi  0.1726*idelay
  atap5     deltapi  0.2790*idelay
  atap6     deltapi  0.3328*idelay
            delayw   ain
  afdbk     butterlp atap6, 7000
  abbd      sum      atap1, atap2, atap3, atap4, atap5, atap6
  abbd      butterlp abbd, 7000
  aout      =        (ain+abbd*iecho)*ilvl

  ; stay triggered until echo fades out
  kfade     linsegr  1, 0.01, 1, 0.33*idelay*(1+ifdbk)*(1+iecho), 0
  aout      =        aout*kfade
  xout aout
endop
			</opcode>
		</moduleReference>
	</referencesModules>
	<instancesModules>
		<moduleInstance id="1" name="control/MidiNoteIn" xPos="35" yPos="48">
			<inputs>
				<val description="Scaling of MIDI velocity" id="0" value="15000.0"/>
				<val description="Minimal value for scaled channel aftertouch" id="1" value="0.0"/>
				<val description="Maximal value for scaled channel aftertouch" id="2" value="127.0"/>
			</inputs>
		</moduleInstance>
		<moduleInstance id="2" name="sound sources/SawVco" xPos="190" yPos="51">
			<inputs>
				<val description="Frequency of oscillator" id="0" value="0"/>
				<val description="Shape of wave, sawtooth/triangle/ramp" id="1" value="0.001"/>
			</inputs>
		</moduleInstance>
		<moduleInstance id="4" name="input output/PcmMonoOut" xPos="842" yPos="73">
			<inputs>
				<val description="Audio input" id="0" value="0"/>
			</inputs>
		</moduleInstance>
		<moduleInstance id="5" name="filters/Formant" xPos="351" yPos="138">
			<inputs>
				<val description="Audio rate input" id="0" value="0"/>
				<val description="Filter center frequency" id="1" value="2000.0"/>
				<val description="Impulse response attack time in seconds" id="2" value="0.01"/>
				<val description="Impulse response decay time in seconds" id="3" value="0.003"/>
			</inputs>
		</moduleInstance>
		<moduleInstance id="7" name="modulators/SineLfo" xPos="93" yPos="172">
			<inputs>
				<val description="Frequency of LFO" id="0" value="0.2"/>
				<val description="Amplitude of LFO" id="1" value="500.0"/>
				<val description="Initial phase of LFO (negativ to skip initialisation)" id="2" value="0.0"/>
			</inputs>
		</moduleInstance>
		<moduleInstance id="8" name="maths/ControlAdd" xPos="208" yPos="158">
			<inputs>
				<val description="First control signal" id="0" value="0"/>
				<val description="Second control signal" id="1" value="600.0"/>
			</inputs>
		</moduleInstance>
		<moduleInstance id="9" name="modulators/AdsrLinMidi" xPos="460" yPos="179">
			<inputs>
				<val description="Amplitude scale factor" id="0" value="1.0"/>
				<val description="Attack time in seconds" id="1" value="0.07"/>
				<val description="Decay time in seconds" id="2" value="0"/>
				<val description="Sustain level" id="3" value="1.0"/>
				<val description="Release time in seconds" id="4" value="0.06"/>
			</inputs>
		</moduleInstance>
		<moduleInstance id="10" name="amps mixers/Mixer2" xPos="471" yPos="67">
			<inputs>
				<val description="First audio rate signal" id="0" value="0"/>
				<val description="Amplitude multiplicator for in1" id="1" value="10000.0"/>
				<val description="Second audio rate signal" id="2" value="0"/>
				<val description="Amplitude multiplicator for in2" id="3" value="300.0"/>
			</inputs>
		</moduleInstance>
		<moduleInstance id="11" name="amps mixers/Amp" xPos="609" yPos="75">
			<inputs>
				<val description="Audio signal" id="0" value="0"/>
				<val description="Gain" id="1" value="0"/>
			</inputs>
		</moduleInstance>
		<moduleInstance id="12" name="filters/ButterLp" xPos="340" yPos="27">
			<inputs>
				<val description="Audio rate input" id="0" value="0"/>
				<val description="Filter cut-off frequency" id="1" value="300.0"/>
			</inputs>
		</moduleInstance>
		<moduleInstance id="13" name="effects/AnalogEcho" xPos="714" yPos="69">
			<inputs>
				<val description="Audio input" id="0" value="0"/>
				<val description="Output level" id="1" value="1.0"/>
				<val description="Delay factor" id="2" value="0.718"/>
				<val description="Feedback amount" id="3" value="0.387"/>
				<val description="Reverb amount" id="4" value="0.04"/>
			</inputs>
		</moduleInstance>
	</instancesModules>
	<connections>
		<connection inModule="2" inputNum="0" outModule="1" outputNum="0"/>
		<connection inModule="5" inputNum="0" outModule="2" outputNum="0"/>
		<connection inModule="8" inputNum="0" outModule="7" outputNum="0"/>
		<connection inModule="5" inputNum="1" outModule="8" outputNum="0"/>
		<connection inModule="11" inputNum="0" outModule="10" outputNum="0"/>
		<connection inModule="11" inputNum="1" outModule="9" outputNum="0"/>
		<connection inModule="10" inputNum="2" outModule="5" outputNum="0"/>
		<connection inModule="12" inputNum="0" outModule="2" outputNum="0"/>
		<connection inModule="10" inputNum="0" outModule="12" outputNum="0"/>
		<connection inModule="13" inputNum="0" outModule="11" outputNum="0"/>
		<connection inModule="4" inputNum="0" outModule="13" outputNum="0"/>
	</connections>
	<additionalInfo>
		<param name="actualModule" value="13"/>
		<param name="lastModuleId" value="13"/>
	</additionalInfo>
</workspace>

