#importonce

* = * "D_IRQ"
.namespace IRQ{

	// IRQ...

	.label IRQ_CONTROL_REGISTER = $d01a
	.label IRQ_STATUS_REGISTER  = $d019

	.label IRQ_CONTROL_STATUS_REGISTER_NOT_MASKABLE = $dd0d
	.label IRQ_CONTROL_STATUS_REGISTER_MASKABLE     = $dc0d




	.label IRQ_POINTER = $0314 // Permet de libérer le basic car ne nécessite pas de copier la ROM en RAM

	// Pour un jeu full assembleur, on utilisera $fffe >> dans une vidéo future !


	.label IRQ_POINTER_BASIC = $EA31


}