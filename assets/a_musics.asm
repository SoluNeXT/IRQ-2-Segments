#importonce


#import "../macros/m_musics.asm"

* = * "A_MUSICS"
.namespace MUSICS{

	NbMusics:
		.byte	1

	MusicsTable:
		.word	Music0



	InstrumentsTable:
		.word	Instrument0
		.word	Instrument1
		.word	Instrument2
		.word	Instrument3

	Instrument0:{		//brass
		.label Waveform 	=	MUSICS.WAVEFORM_TRIANGLE
		.label Attack		=	12
		.label Decay		=	13
		.label Sustain		=	0
		.label Release		=	3
		.label PulseWidth	=	2048	// 0 ---> 4096 Uniquement pour les RECTANGLE

		.byte	Waveform
		.byte	Attack  * 16 + Decay
		.byte	Sustain * 16 + Release
		.word	PulseWidth
	}

	Instrument1:{		//Battement
		.label Waveform 	=	MUSICS.WAVEFORM_TRIANGLE
		.label Attack		=	4
		.label Decay		=	8
		.label Sustain		=	0
		.label Release		=	0
		.label PulseWidth	=	0	// 0 ---> 4096

		.byte	Waveform
		.byte	Attack  * 16 + Decay
		.byte	Sustain * 16 + Release
		.word	PulseWidth
	}

	Instrument2:{		//no sound
		.label Waveform 	=	MUSICS.WAVEFORM_TRIANGLE
		.label Attack		=	3
		.label Decay		=	7
		.label Sustain		=	3
		.label Release		=	0
		.label PulseWidth	=	0	// 0 ---> 4096

		.byte	Waveform
		.byte	Attack  * 16 + Decay
		.byte	Sustain * 16 + Release
		.word	PulseWidth
	}

	Instrument3:{		//synth
		.label Waveform 	=	MUSICS.WAVEFORM_RECTANGLE
		.label Attack		=	0
		.label Decay		=	7
		.label Sustain		=	0
		.label Release		=	11
		.label PulseWidth	=	2048	// 0 ---> 4096

		.byte	Waveform
		.byte	Attack  * 16 + Decay
		.byte	Sustain * 16 + Release
		.word	PulseWidth
	}

	Patterns:{
		Pat0:{
				//  BYTE : bits 0=>5 : Instrument ID
				//		   bit 6 : 0 = cut then play new frequency | 1 = no cut
				//		   bit 7 : 0 = nothing | 1 = end of pattern
				//	WORD : Note Frequency
				//  BYTE : Note Length : qc=0,tc=1,dc=2,c=4,n=8,b=16,r=32,dr=64

			SetNote(1,"DO",2,1)
			SetNote(1,"DO",2,2)
			SetNote(1,"DO",2,2)
			SetNote(1,"DO",2,1)
			SetNote(1,"DO",2,2)
			SetNote(1,"DO",2,2)
			SetNote(1,"SIb",1,2)
			SetNote(1,"DO",2,1)
			SetNote(1,"DO",2,2)
			SetNote(1,"DO",2,2)
			SetNote(1,"DO",2,1)
			SetNote(1,"DO",2,2)
			SetNote(1,"DO",2,2)
			SetNote(1,"SIb",1,2)

			SetEndOfPattern()

		}
		Pat1:{
			SetNote(0,"DO",2,24)
			SetEndOfPattern()
		}
		Pat2:{
			SetNote(2,"DO",4,1)
			SetNote(2,"RE",4,1)
			SetNote(2,"MIb",4,16)
			SetNote(2,"RE",4,3)
			SetNote(2,"SIb",3,3)
			SetEndOfPattern()
		}
		Pat3:{
			SetNote(2,"MIb",3,24)
			SetEndOfPattern()
		}
		Pat4:{
			SetNote(2,"SOL",4,12)
			SetNote(2,"FA",4,12)
			SetEndOfPattern()
		}
		Pat5:{
			SetNote(2,"FA",3,24)
			SetEndOfPattern()
		}
		Pat6:{
			SetNote(2,"MIb",3,22)
			SetNote(2,"DO",3,2)
			SetEndOfPattern()
		}
		Pat7:{
			SetNote(2,"MIb",3,12)
			SetNote(2,"RE",3,12)
			SetEndOfPattern()
		}
		Pat8:{
			SetNote(2,"DO",3,24)
			SetEndOfPattern()
		}
		Pat9:{
			SetNote(3,"DO",3,1)
			SetNote(3,"DO",3,2)
			SetNote(3,"DO",3,2)
			SetNote(3,"DO",3,1)
			SetNote(3,"DO",3,6)
			SetNote(3,"DO",3,1)
			SetNote(3,"DO",3,2)
			SetNote(3,"DO",3,2)
			SetNote(3,"DO",3,1)
			SetNote(3,"DO",3,6)
			SetEndOfPattern()
		}		
		Pat10:{
			SetNote(3,"DO",5,1)
			SetNote(3,"DO",5,2)
			SetNote(3,"DO",5,2)
			SetNote(3,"DO",5,1)
			SetNote(3,"DO",5,6)
			SetNote(3,"DO",5,1)
			SetNote(3,"DO",5,2)
			SetNote(3,"DO",5,2)
			SetNote(3,"DO",5,1)
			SetNote(3,"DO",5,6)
			SetEndOfPattern()
		}		
		Pat11:{
			SetNote(1,"DO",2,1)
			SetNote(1,"DO",2,2)
			SetNote(1,"DO",2,2)
			SetNote(1,"DO",2,1)
			SetNote(1,"DO",2,2)
			SetNote(1,"DO",2,2)
			SetNote(1,"SIb",1,2)
			SetNote(1,"DO",2,1)
			SetNote(1,"DO",2,2)
			SetNote(1,"DO",2,2)
			SetNote(1,"DO",2,1)
			SetNote(1,"DO",2,2)
			SetNote(1,"DO",2,2)
			SetNote(1,"SIb",1,2)

			SetEndOfPattern()

		}
	}

	Music0:{
		VolumeAndFilterMode:
		.byte	15
		FilterCutFreq:
		.word	0
		FilterControl:
		.byte	0
		ActiveVoices:	
		.byte	1 + 2 + 4 //bit0=1=voix1 //bit1=2=voix2 //bit2=4=voix3
		Speed:
		.byte	8
		NbPatternsPerVoice:
		.byte	14
		PatternsVoice1Table:
		.byte	0,0,2,3,2,4,2,5,6,7,8,9,9,64+2	// 0 < n < 63 = IDPattern (bits 0 à 5) + bit 6 = JUMP TO PATTERN POSITION n
							//									   + bit 7 = STOP
		PatternsVoice2Table:
		.byte	0,1,0,1,0,0,0,1,0,0,0,10,10,128
		PatternsVoice3Table:
		.byte	0,0,0,0,0,0,0,0,0,0,0,11,11,128

		PatternsTable:
		.word	Patterns.Pat0
		.word	Patterns.Pat1
		.word	Patterns.Pat2
		.word	Patterns.Pat3
		.word	Patterns.Pat4
		.word	Patterns.Pat5
		.word	Patterns.Pat6
		.word	Patterns.Pat7
		.word	Patterns.Pat8
		.word	Patterns.Pat9
		.word	Patterns.Pat10
		.word	Patterns.Pat11
	}



}