#importonce

#import "../definitions/d_irq.asm"
#import "../definitions/d_vic.asm"
#import "../macros/m_irq.asm"

* = * "L_IRQ"
.namespace IRQ{

	.label IRQ_MUSIC_LINE	= 280
	.label IRQ_MUSIC_CALL	= MUSICS.PLAY


	INIT:{
		sei

		lda #$7f
		sta IRQ_CONTROL_STATUS_REGISTER_MASKABLE
		sta IRQ_CONTROL_STATUS_REGISTER_NOT_MASKABLE

		lda #$01
		sta IRQ_CONTROL_REGISTER

		lda VIC.RASTER_MSB
		.if(IRQ_MUSIC_LINE>255){
			ora #%10000000
		} else {
			and #%01111111 // si > 255 alors ora #%10000000
		}
		sta VIC.RASTER_MSB

		lda #<MUSIC_IRQ
		ldx #>MUSIC_IRQ
		ldy #IRQ_MUSIC_LINE
		sta IRQ_POINTER
		stx IRQ_POINTER+1
		sty VIC.RASTER

		lda IRQ_CONTROL_STATUS_REGISTER_MASKABLE
		lda IRQ_CONTROL_STATUS_REGISTER_NOT_MASKABLE
		asl IRQ_STATUS_REGISTER

		cli
		rts
	}



	MUSIC_IRQ:{
		//sei

		dec VIC.BORDER_COLOR
		jsr IRQ_MUSIC_CALL
		inc VIC.BORDER_COLOR

		asl IRQ_STATUS_REGISTER

		//cli
		jmp IRQ_POINTER_BASIC
	}

}