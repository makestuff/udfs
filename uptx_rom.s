	!to "uptx_rom.o", plain	; set output file and format

	* = $8000
	drb = $fe60
	ddrb = $fe62
	pcr = $fe6c
	ifr = $fe6d
	base = $380
	channel = base+0
	command = base+1
	param1 = base+2
	param2 = base+3
	send_length = base+4
	send_addr = base+6
	recv_addr = base+8
	dest_rom = base+9
	data_ptr = $da
	line = $f2
	OSASCI = $ffe3
	
rom_start	!byte $00, $00, $00
	jmp service
	!byte $82, (copyright - rom_start), $00
title	!text $0a, "UPCOMM", $00, "1.00", $0d
copyright	!text $00, "(C)2011 Chris McClelland", $00
cmd_name	!text "MMOCPU"
service	cmp #4	; unknown command
	beq unrecognised_command
	cmp #9	; help
	beq star_help
	rts

star_help	lda (line),y
	cmp #$0d
	beq +
	lda #9
	rts
+	tya
	pha
	txa
	pha
	ldx #0
-	lda title,x
	bne +
	lda #$20
+	jsr OSASCI
	inx
	cpx #copyright-title
	bne -
	pla
	tax
	pla
	tay
	lda #9
	rts

unrecognised_command	tya
	pha
	txa
	pha
	ldx #6
-	lda (line),y
	cmp cmd_name-1,x
	bne +
	iny
	dex
	bne -
	beq upcomm
+	pla
	tax
	pla
	tay
	lda #4
	rts

upcomm	jsr chomp
	jsr get_byte	; channel
	sta channel

	jsr chomp
	jsr get_byte	; command
	sta command

	jsr chomp
	jsr get_byte	; param1
	sta param1

	jsr chomp
	jsr get_byte	; param2
	sta param2

	jsr chomp
	jsr get_byte	; send_length msb
	sta send_length+1
	jsr get_byte	; send_length lsb
	sta send_length
	
	jsr chomp
	jsr get_byte	; send_addr msb
	sta send_addr+1
	jsr get_byte	; send_addr lsb
	sta send_addr
	
	jsr chomp
	jsr get_byte	; recv_addr msb
	sta recv_addr+1
	jsr get_byte	; recv_addr lsb
	sta recv_addr

	lda #$00
	sta ddrb	; Reading from AVR.
	lda #$C0
	sta pcr	; Drive CB2 low.
	lda send_addr
	sta data_ptr
	lda send_addr+1
	sta data_ptr+1
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	lda #$E0
	sta pcr	; Drive CB2 high.
	lda #$80
	sta pcr	; Drive CB2 low after next drb write.
	lda #$FF
	sta ddrb	; Writing to AVR.
	ldy #0
-	lda base,y
	jsr send_byte
	iny
	cpy #6
	bne -
	ldy send_length+1	; Get length high byte
	beq send_final_page
	ldy #0
-	lda (data_ptr),y
	jsr send_byte
	iny
	bne -
	inc data_ptr+1
	dec send_length+1
	bne -
	beq send_final_page
-	lda (data_ptr),y
	jsr send_byte
	iny
send_final_page	cpy send_length
	bne -
	lda recv_addr
	sta data_ptr
	lda recv_addr+1
	sta data_ptr+1
	ldy #$00
	sty ddrb	; Reading from AVR.
	jsr send_byte	; Tell AVR to send.
	jsr send_byte	; Get AVR's status byte.
	ldx drb	; Load it into X.
	stx channel	; Save status byte.
	jsr send_byte	; Get AVR's length low byte.
	ldx drb	; Load it into X.
	stx param1	; Save it.
	stx send_length	; ...and in the counter.
	jsr send_byte	; Get AVR's length high byte.
	ldx drb	; Load it into X.
	stx param2	; Save it first in out param block...
	stx send_length+1	; ...and in the counter.
	beq recv_final_page
-	jsr send_byte
	lda drb
	sta (data_ptr),y
	iny
	bne -
	inc data_ptr+1	; Inc addr high byte.
	dec param2	; Dec count high byte.
	bne -
	beq recv_final_page

-	jsr send_byte
	lda drb
	sta (data_ptr),y
	iny
recv_final_page	cpy param1	; Compare with count low byte.
	bne -
	jsr send_byte	; Tell AVR to drop bus.
	
	pla
	tax
	pla
	tay
	lda #0	; claim service call
	rts

send_byte	sta drb	; Send byte to AVR and strobe CB2.
-	lda ifr	; Load the interrupt flag register.
	and #$10	; Test bit CB1 (AVR acknowledge).
	beq -	; Loop until CB1 set.
	rts

get_byte	lda (line),y
	iny
	jsr get_nibble
	asl
	asl
	asl
	asl
	sta data_ptr
	lda (line),y
	iny
	jsr get_nibble
	ora data_ptr
	rts

get_nibble	cmp #'0'
	bcc error
	cmp #'0'+10
	bcs try_alpha
	sec
	sbc #'0'
	rts
try_alpha	and #$df
	cmp #'A'
	bcc error
	cmp #'G'
	bcs error
	sec
	sbc #'A'-10
	rts

chomp	lda (line),y
	iny
	cmp #$20
	bne error
	rts

error	ldx #$ff
-	inx
	lda syntax,x
	sta $0100,x
	cmp #$ff
	bne -
	jmp $0100
syntax	!text $00, $00, "Syntax: UPCOMM <ch> <cmd> <p1> <p2>", $0a, $0d, "               <rql> <rqa> <rsa>", $00, $ff
