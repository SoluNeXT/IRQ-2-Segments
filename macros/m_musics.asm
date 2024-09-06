#importonce

#import "../definitions/d_musics.asm"

*=* "M_MUSICS"

.function GetNoteFrequency(note, octave){
	.var idNote = 0 // LA-4 - A4
	.if(note == "LA#"  || note == "SIb" || note == "A#" || note == "Bb")	.eval idNote = 1
	.if(note == "SI"   				    || note == "B" )					.eval idNote = 2
	.if(note == "DO"   				    || note == "C" )					.eval idNote = -9
	.if(note == "DO#"  || note == "REb" || note == "C#" || note == "Db")	.eval idNote = -8
	.if(note == "RE"   				    || note == "D" )					.eval idNote = -7
	.if(note == "RE#"  || note == "MIb" || note == "D#" || note == "Eb")	.eval idNote = -6
	.if(note == "MI"   				    || note == "E" )					.eval idNote = -5
	.if(note == "FA"   				    || note == "F" )					.eval idNote = -4
	.if(note == "FA#"  || note == "SOLb"|| note == "F#" || note == "Gb")	.eval idNote = -3
	.if(note == "SOL"  				    || note == "G" )					.eval idNote = -2
	.if(note == "SOL#" || note == "LAb" || note == "G#" || note == "Ab")	.eval idNote = -1
	.eval idNote = idNote + 12 * (octave - 4)
	.return round(MUSICS.LA4 * MUSICS.SFC * pow(2,idNote /12))
}

.macro SetNote(Instrument,Note,Octave,Duree){
	.byte	Instrument
	.if(Note == '-'){
		.word 0,0
	} else {
		.word	GetNoteFrequency(Note,Octave)
	}
	.byte	Duree
}

.macro SetEndOfPattern(){
	.byte	%11111111
}