#importonce

BasicUpstart2(main)


* = * "MAIN"
main:{
		jsr CopyCode

		jsr	MUSICS.RESET

		lda #0
		jsr	MUSICS.INIT

		jsr IRQ.INIT
		rts
}

CopyCode:{
	ldy #ceil(CodeSize/256)
	ldx #0

loop:
	lda src: CodeToCopy,x
	sta dst: MemC000,x
	inx
	bne loop

	inc src + 1
	inc dst + 1
	dey
	bne loop

	rts
}



CodeToCopy: .segmentout [segments="MemC000Code"]
.label CodeSize = *-CodeToCopy
.print CodeSize

.segment MemC000Code [start=$c000]
MemC000: 
#import "./libs/l_vic.asm"
#import "./libs/l_musics.asm"
#import "./assets/a_musics.asm"
#import "./libs/l_irq.asm"

