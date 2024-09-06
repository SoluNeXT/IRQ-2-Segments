#importonce

#import "../assets/a_musics.asm"
#import "../definitions/d_musics.asm"
#import "../macros/m_musics.asm"

* = * "L_MUSICS"

.namespace MUSICS{

	//Variables et pointeurs...
	//Les variables peuvent être n'importe où en mémoire...
	//ici on les a laissé dans l'emplacement de compilation
		.label NbVoices 		=	MEMORY.NbVoices
		.label MusicStatus 		=	MEMORY.MusicStatus
		.label Disabled 		=	MEMORY.Disabled

		.label Speed 			=	MEMORY.Speed
		.label SpeedCountDown 	=	MEMORY.SpeedCountDown
		.label PatListPos 		=	MEMORY.PatListPos
		.label PatternPosV1 	=	MEMORY.PatternPosV1
		.label PatternPosV2 	=	MEMORY.PatternPosV2
		.label PatternPosV3 	=	MEMORY.PatternPosV3
		.label DurationV1 		=	MEMORY.DurationV1
		.label DurationV2 		=	MEMORY.DurationV2
		.label DurationV3 		=	MEMORY.DurationV3

		.label	Temp8bits		=	MEMORY.Temp8bits
		.label	Temp8bits2		=	MEMORY.Temp8bits2

	MEMORY:{
		NbVoices:
		MusicStatus:
		Disabled:
			.byte	0 		// Bits 0,1,2 	= Voices To Play ON/OFF
							// Bit  7		= Music Status ON/OFF
							// Bits 4,5,6 	= Voice Enabled ON/OFF
		Speed:
			.byte	0
		SpeedCountDown:
			.byte	0
		PatListPos:
			.byte	0
		PatternPosV1:
			.byte	0
		PatternPosV2:
			.byte	0
		PatternPosV3:
			.byte	0
		DurationV1:
			.byte	0
		DurationV2:
			.byte	0
		DurationV3:
			.byte	0		
		Temp8bits:
			.byte	0		
		Temp8bits2:
			.byte	0
	}

	//Les pointeurs doivent être positionnés en page zéro
		.label	StartZP	=	$02

		.label	MusicPointer	=	StartZP		// Les pointeurs utilisent 2 octets (WORD)
		.label	InstPointer		=	StartZP + 2
		.label	V1PatLstPointer	=	$fb
		.label	V2PatLstPointer	=	$fd
		.label	V3PatLstPointer	=	$92  
		.label	PatternPointer	=	$96 
		.label	Temp16bits		=	MusicPointer 	//MusicPointer n'est plus utilisé après le INIT
		.label	Temp16bits2		=	$9b


	RESET:{
			ldx #0
			lda #0
		!:
			sta MUSICS.VOICE1,x
			inx
			cpx #32
			bne !-

			rts
	}
	INIT:{
			cmp MUSICS.NbMusics
			bcc	ok
			rts
		ok:
			ldy #0
			sty	SpeedCountDown
			sty	PatListPos
			sty	PatternPosV1
			sty PatternPosV2
			sty PatternPosV3
			sty	DurationV1
			sty	DurationV2
			sty	DurationV3

			//Prepare Music Pointer
			asl  // A * 2 (le pointeur est un WORD sur 2 bits)
			tax
			lda	MUSICS.MusicsTable,x
			sta MusicPointer
			inx
			lda	MUSICS.MusicsTable,x
			sta MusicPointer+1

			//Prepare Instruments Pointer
			lda #<MUSICS.InstrumentsTable
			sta InstPointer
			lda #>MUSICS.InstrumentsTable
			sta InstPointer+1

			//Initialisation des paramètres de la musique
			//Volume et filtres
			lda	(MusicPointer),y
			sta MUSICS.VOLUMEANDFILTERMODES
			//Filter Cut Frequency
			iny
			lda	(MusicPointer),y
			sta MUSICS.FILTERCUTOFFFREQUENCEYLO
			iny
			lda	(MusicPointer),y
			sta MUSICS.FILTERCUTOFFFREQUENCEYHI
			//Filter control
			iny
			lda	(MusicPointer),y
			sta MUSICS.FILTERCONTROL
			//Active voices
			iny
			lda	(MusicPointer),y
			sta NbVoices
			//Speed
			iny
			lda	(MusicPointer),y
			sta Speed
			//si Speed est = 0 alors on ne fait rien... Sinon, on va décrémenter Speed
			beq !+
			dec Speed
		!:
			//Nb patterns per voice
			iny
			lda	(MusicPointer),y
			tax
			//Voices pattern list
			iny
			tya
			clc
			adc MusicPointer
			sta V1PatLstPointer
			sta V2PatLstPointer
			sta V3PatLstPointer
			sta PatternPointer
			lda MusicPointer+1
			adc #0
			sta V1PatLstPointer+1
			sta V2PatLstPointer+1
			sta V3PatLstPointer+1
			sta PatternPointer+1

			// Set Pattern Table ! // Il faut rajouter autant qu'il y a de voix...
			txa
			adc PatternPointer
			sta PatternPointer
			lda PatternPointer+1
			adc #0
			sta PatternPointer+1
			
			lda NbVoices
			and #2
			beq NoMoreVoice
			
			txa
			adc V2PatLstPointer
			sta V2PatLstPointer
			lda V2PatLstPointer+1
			adc #0
			sta V2PatLstPointer+1

			// Set Pattern Table ! // Il faut rajouter autant qu'il y a de voix...
			txa
			adc PatternPointer
			sta PatternPointer
			lda PatternPointer+1
			adc #0
			sta PatternPointer+1

			lda NbVoices
			and #4
			beq NoMoreVoice

			txa
			asl
			adc V3PatLstPointer
			sta V3PatLstPointer
			lda V3PatLstPointer+1
			adc #0
			sta V3PatLstPointer+1

			// Set Pattern Table ! // Il faut rajouter autant qu'il y a de voix...
			txa
			adc PatternPointer
			sta PatternPointer
			lda PatternPointer+1
			adc #0
			sta PatternPointer+1

		NoMoreVoice:
			lda MusicStatus
			ora #%10000000			// Music Status = PLAY
			sta MusicStatus
	
			rts
	}


	PLAY:{
			lda MusicStatus
			asl
			bcc exit

		okPlay:
			ldx SpeedCountDown
			beq NextCountDown
			dec SpeedCountDown

		exit:
			rts

		NextCountDown:
			lda Speed
			sta SpeedCountDown

		ReadPattern:
			lda NbVoices
			lsr
			bcs Voice1
			jmp NoMoreVoice

		Voice1:
			ldx DurationV1
			beq NextNoteV1
			dec DurationV1
			jmp IsVoice2

		NextNoteV1:
			ldy PatListPos
			lda (V1PatLstPointer),y
			asl
			tay	
			lda (PatternPointer),y
			sta Temp16bits
			iny
			lda (PatternPointer),y
			sta Temp16bits + 1

			ldy PatternPosV1
			lda (Temp16bits),y 		// Instrument
			tax
			asl // bit 7 = end of pattern
			bcc NextNoteV1OK
			jmp EndOfPattern

		NextNoteV1OK:
			lda Disabled
			and #%00010000 // bit 4 pour la voix 1
			beq V1Enabled
			iny
			iny
			bne V1Disabled

		V1Enabled:
			iny
			lda (Temp16bits),y 		// Frequency Low
			sta Temp8bits
			iny
			lda (Temp16bits),y 		// Frequency Hi
			jsr SetVoice1

		V1Disabled:
			iny
			lda (Temp16bits),y 		// Durée
			sta DurationV1
			iny
			sty PatternPosV1		// pour le prochain passage
			dec DurationV1


		IsVoice2:
			lda NbVoices
			lsr
			lsr 
			bcs Voice2
			jmp NoMoreVoice

		Voice2:
			ldx DurationV2
			beq NextNoteV2
			dec DurationV2
			jmp IsVoice3

		NextNoteV2:
			ldy PatListPos
			lda (V2PatLstPointer),y
			asl
			tay	
			lda (PatternPointer),y
			sta Temp16bits
			iny
			lda (PatternPointer),y
			sta Temp16bits + 1

			ldy PatternPosV2
			lda (Temp16bits),y 		// Instrument
			tax
			asl // bit 7 = end of pattern
			bcc NextNoteV2OK
			jmp EndOfPattern

		NextNoteV2OK:
			lda Disabled
			and #%00100000 // bit 5 pour la voix 2
			beq V2Enabled
			iny
			iny
			bne V2Disabled

		V2Enabled:
			iny
			lda (Temp16bits),y 		// Frequency Low
			sta Temp8bits
			iny
			lda (Temp16bits),y 		// Frequency Hi
			jsr SetVoice2

		V2Disabled:
			iny
			lda (Temp16bits),y 		// Durée
			sta DurationV2
			iny
			sty PatternPosV2		// pour le prochain passage
			dec DurationV2


		IsVoice3:
			lda NbVoices
			lsr
			lsr
			lsr
			bcs Voice3
			jmp NoMoreVoice

		Voice3:
			ldx DurationV3
			beq NextNoteV3
			dec DurationV3
			jmp NoMoreVoice

		NextNoteV3:
			ldy PatListPos
			lda (V3PatLstPointer),y
			asl
			tay	
			lda (PatternPointer),y
			sta Temp16bits
			iny
			lda (PatternPointer),y
			sta Temp16bits + 1

			ldy PatternPosV3
			lda (Temp16bits),y 		// Instrument
			tax
			asl // bit 7 = end of pattern
			bcc NextNoteV3OK
			jmp EndOfPattern

		NextNoteV3OK:
			lda Disabled
			and #%01000000 // bit 6 pour la voix 3
			beq V3Enabled
			iny
			iny
			bne V3Disabled

		V3Enabled:
			iny
			lda (Temp16bits),y 		// Frequency Low
			sta Temp8bits
			iny
			lda (Temp16bits),y 		// Frequency Hi
			jsr SetVoice3

		V3Disabled:
			iny
			lda (Temp16bits),y 		// Durée
			sta DurationV3
			iny
			sty PatternPosV3		// pour le prochain passage
			dec DurationV3



		NoMoreVoice:
			rts

		EndOfPattern:
			//Fin du pattern
			ldy PatListPos
			iny
			lda (V1PatLstPointer),y
			tax
			asl // Si bit 7 ON ==> STOP
			bcs EndOfMusic

			asl // Si bit 6 ON ==> Jump to N Pattern
			bcs JumpToPattern

		InitNextPattern:
			sty PatListPos

			ldy #0
			sty SpeedCountDown
			sty PatternPosV1
			sty PatternPosV2
			sty PatternPosV3
			sty DurationV1
			sty DurationV2
			sty DurationV3

			jmp NextCountDown


		JumpToPattern:
			txa
			and #%00111111 // On ne prend pas les bits 6 et 7
			tay
			jmp InitNextPattern

		EndOfMusic:
			lda MusicStatus
			and #%01111111 //bit 7 OFF = Not playing
			sta MusicStatus
			rts

		SetVoice1:{
				// X = ID instrument
				// A Note Freq Hi
				// Temp8bits = Note Freq Lo

				//On va sauver Y car on l'a besoin pour continuer au retour de la méthode
				sty Temp8bits2

				//On va sauver A
				pha

				//on a donc A et Y de libérés pour travailler

				//Récupération de l'instrument ...
				txa
				and #%01000000 // si le bit 6 est actif, on change la note sans affecter l'instrument
				bne OnlyChangeNote

				txa
				asl //On multiplie par 2 car les pointeurs référencent de la mémoire en 16 bits
				tax
				lda MUSICS.InstrumentsTable,x
				sta Temp16bits2
				lda MUSICS.InstrumentsTable + 1,x 
				sta Temp16bits2 + 1

				ldy #0
				lda (Temp16bits2),y
				and #%11111110								// On coupe le son de la voix
				sta MUSICS.VOICE1 + MUSICS.CONTROLREG
				ora #%00000001
				tax 								// On met dans X le son activé pour le controleur

				iny
				lda (Temp16bits2),y
				sta MUSICS.VOICE1 + MUSICS.ATTACKDECAY

				iny
				lda (Temp16bits2),y
				sta MUSICS.VOICE1 + MUSICS.SUSTAINRELEASE

				iny
				lda (Temp16bits2),y
				sta MUSICS.VOICE1 + MUSICS.PULSEWIDTHLO

				iny
				lda (Temp16bits2),y
				sta MUSICS.VOICE1 + MUSICS.PULSEWIDTHHI

				stx MUSICS.VOICE1 + MUSICS.CONTROLREG

			OnlyChangeNote:
				pla //On récupère A

				sta MUSICS.VOICE1 + FREQUENCEHI
				lda Temp8bits
				sta MUSICS.VOICE1 + FREQUENCELO

				//On récupère Y
				ldy Temp8bits2
				rts
		}

		SetVoice2:{
				// X = ID instrument
				// A Note Freq Hi
				// Temp8bits = Note Freq Lo

				//On va sauver Y car on l'a besoin pour continuer au retour de la méthode
				sty Temp8bits2

				//On va sauver A
				pha

				//on a donc A et Y de libérés pour travailler

				//Récupération de l'instrument ...
				txa
				and #%01000000 // si le bit 6 est actif, on change la note sans affecter l'instrument
				bne OnlyChangeNote

				txa
				asl //On multiplie par 2 car les pointeurs référencent de la mémoire en 16 bits
				tax
				lda MUSICS.InstrumentsTable,x
				sta Temp16bits2
				lda MUSICS.InstrumentsTable + 1,x 
				sta Temp16bits2 + 1

				ldy #0
				lda (Temp16bits2),y
				and #%11111110								// On coupe le son de la voix
				sta MUSICS.VOICE2 + MUSICS.CONTROLREG
				ora #%00000001
				tax 								// On met dans X le son activé pour le controleur

				iny
				lda (Temp16bits2),y
				sta MUSICS.VOICE2 + MUSICS.ATTACKDECAY

				iny
				lda (Temp16bits2),y
				sta MUSICS.VOICE2 + MUSICS.SUSTAINRELEASE

				iny
				lda (Temp16bits2),y
				sta MUSICS.VOICE2 + MUSICS.PULSEWIDTHLO

				iny
				lda (Temp16bits2),y
				sta MUSICS.VOICE2 + MUSICS.PULSEWIDTHHI

				stx MUSICS.VOICE2 + MUSICS.CONTROLREG

			OnlyChangeNote:
				pla //On récupère A

				sta MUSICS.VOICE2 + FREQUENCEHI
				lda Temp8bits
				sta MUSICS.VOICE2 + FREQUENCELO

				//On récupère Y
				ldy Temp8bits2
				rts
		}

		SetVoice3:{
				// X = ID instrument
				// A Note Freq Hi
				// Temp8bits = Note Freq Lo

				//On va sauver Y car on l'a besoin pour continuer au retour de la méthode
				sty Temp8bits2

				//On va sauver A
				pha

				//on a donc A et Y de libérés pour travailler

				//Récupération de l'instrument ...
				txa
				and #%01000000 // si le bit 6 est actif, on change la note sans affecter l'instrument
				bne OnlyChangeNote

				txa
				asl //On multiplie par 2 car les pointeurs référencent de la mémoire en 16 bits
				tax
				lda MUSICS.InstrumentsTable,x
				sta Temp16bits2
				lda MUSICS.InstrumentsTable + 1,x 
				sta Temp16bits2 + 1

				ldy #0
				lda (Temp16bits2),y
				and #%11111110								// On coupe le son de la voix
				sta MUSICS.VOICE3 + MUSICS.CONTROLREG
				ora #%00000001
				tax 								// On met dans X le son activé pour le controleur

				iny
				lda (Temp16bits2),y
				sta MUSICS.VOICE3 + MUSICS.ATTACKDECAY

				iny
				lda (Temp16bits2),y
				sta MUSICS.VOICE3 + MUSICS.SUSTAINRELEASE

				iny
				lda (Temp16bits2),y
				sta MUSICS.VOICE3 + MUSICS.PULSEWIDTHLO

				iny
				lda (Temp16bits2),y
				sta MUSICS.VOICE3 + MUSICS.PULSEWIDTHHI

				stx MUSICS.VOICE3 + MUSICS.CONTROLREG

			OnlyChangeNote:
				pla //On récupère A

				sta MUSICS.VOICE3 + FREQUENCEHI
				lda Temp8bits
				sta MUSICS.VOICE3 + FREQUENCELO

				//On récupère Y
				ldy Temp8bits2
				rts
		}




	}





	DISABLEVOICES:{
			// A contains voiceS to disable
		disV1:
			lsr
			tax
			bcc disV2
			jsr DisableVoice1

		disV2:
			txa
			lsr
			tax
			bcc disV3
			jsr DisableVoice2

		disV3:
			txa
			lsr
			tax
			bcc end
			jmp DisableVoice3

		end:
			rts

		DisableVoice1:{
			lda Disabled
			ora #%00010000 //bit 4
			sta Disabled
			lda #0
			sta MUSICS.VOICE1+MUSICS.CONTROLREG
			rts
		}
		DisableVoice2:{
			lda Disabled
			ora #%00100000 //bit 5
			sta Disabled
			lda #0
			sta MUSICS.VOICE2+MUSICS.CONTROLREG
			rts
		}
		DisableVoice3:{
			lda Disabled
			ora #%01000000 //bit 6
			sta Disabled
			lda #0
			sta MUSICS.VOICE3+MUSICS.CONTROLREG
			rts
		}
	}

	ENABLEVOICES:{
			// A contains voiceS to enable
		enV1:
			lsr
			tax
			bcc enV2
			jsr EnableVoice1

		enV2:
			txa
			lsr
			tax
			bcc enV3
			jsr EnableVoice2

		enV3:
			txa
			lsr
			tax
			bcc end
			jmp EnableVoice3

		end:
			rts

		EnableVoice1:{
			lda Disabled
			and #%11101111 //bit 4
			sta Disabled
			rts
		}
		EnableVoice2:{
			lda Disabled
			and #%11011111 //bit 5
			sta Disabled
			rts
		}
		EnableVoice3:{
			lda Disabled
			and #%10111111 //bit 6
			sta Disabled
			rts
		}
	}

}