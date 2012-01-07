	!to "dfs_rom.o", plain	; set output file and format

	* = $8000
	data_ptr = $a0
	sector = $a2
	sector_count = $a5
	attempts = $a6
	bytes_last_sector = $a7
	temp = $b0
	err_ptr = $b8
	filename_param = $c7
	directory_param = $ce
	cur_drv = $cf
	txt_ptr = $f2
	FSCV = $021e
	nmi_prev = $0d01
	mmc_status = $0d02
	mmc_mode = $0d03
	mmc_first_mode = $0d04
	mmc_flags = $0d40
	cur_seq = $0d41
	cmd_seq = $0d42
	par1 = $0d44
	par2 = $0d4c
	start_opts = $0d52
	buf = $0e00
	cur_drv_cat = $1082
	nmi_status = $10c9
	tube_txf = $10d6
	tube_present_if_zero = $10d7
	MM_REG = $fe18
	ROM_PAGE = $fe30
	SV_IOB = $fe40
	UV_IOB = $fe60
	UV_DDRB = $fe62
	UV_SR = $fe6a
	UV_ACR = $fe6b
	UV_IER = $fe6e
	TUBE_R0 = $fee0
	TUBE_R1 = $fee1
	TUBE_R2 = $fee2
	TUBE_R3 = $fee3
	TUBE_DAT = $fee5
	GSINIT = $ffc2
	GSREAD = $ffc5
	OSFIND = $ffce
	OSBPUT = $ffd4
	OSBGET = $ffd7
	OSRDCH = $ffe0
	OSASCI = $ffe3
	OSNEWL = $ffe7
	OSWRCH = $ffee
	OSWORD = $fff1
	OSBYTE = $fff4
	OSCLI = $fff7

	drb = $FE60
	ddrb = $FE62
	acr = $FE6B
	pcr = $FE6C
	ifr = $FE6D
	zp = $0d42
	channel = 0
	command = 1
	param1 = 2
	param2 = 3
	send_length = 4
	send_addr = 6
	recv_addr = 8
	block_data = 10
	
lang_entry	brk	; 0x8000
	brk	; 0x8001
	brk	; 0x8002
serv_entry	jmp serv_claim_absworkspace	; 0x8003
	!byte $82, $11, $5a
	!text "DFS", $00, "0.90", $00, "(C)"
	jmp (FSCV)	; 0x8015
	jsr brk100_noerrno	; 0x8018
	!text "Disk "
	bcc brk100_errno	; 0x8020
err_bad	jsr brk100_noerrno	; 0x8022
	!text "Bad "
	bcc brk100_errno	; 0x8029
err_file	jsr brk100_noerrno	; 0x802b
	!text "File "
brk100_errno	sta $b3	; 0x8033
	pla	; 0x8035
	sta $ae	; 0x8036
	pla	; 0x8038
	sta $af	; 0x8039
	lda $b3	; 0x803b
	pha	; 0x803d
	tya	; 0x803e
	pha	; 0x803f
	ldy #$00	; 0x8040
	jsr inc_word_ae	; 0x8042
	lda ($ae),y	; 0x8045
	sta $0101	; 0x8047
	bit $10de	; 0x804a
	bpl prtstr_loop	; 0x804d
	lda #$02	; 0x804f
	sta $10de	; 0x8051
	lda #$00	; 0x8054
	sta $0100	; 0x8056
	beq prtstr_loop	; 0x8059
brk100_noerrno	lda #$02	; 0x805b
	sta $10de	; 0x805d
	lda #$00	; 0x8060
	sta $0100	; 0x8062
prtstr	sta $b3	; 0x8065
	pla	; 0x8067
	sta $ae	; 0x8068
	pla	; 0x806a
	sta $af	; 0x806b
	lda $b3	; 0x806d
	pha	; 0x806f
	tya	; 0x8070
	pha	; 0x8071
	ldy #$00	; 0x8072
prtstr_loop	jsr inc_word_ae	; 0x8074
	lda ($ae),y	; 0x8077
	bmi ptrstr_return	; 0x8079
	beq prtstr_brk	; 0x807b
	jsr prtchr	; 0x807d
	jmp prtstr_loop	; 0x8080
ptrstr_return	pla	; 0x8083
	tay	; 0x8084
	pla	; 0x8085
	clc	; 0x8086
	jmp ($00ae)	; 0x8087
prtstr_brk	lda #$00	; 0x808a
	ldx $10de	; 0x808c
	sta $0100,x	; 0x808f
	lda #$ff	; 0x8092
	sta $10de	; 0x8094
	jmp $0100	; 0x8097
	lda #$2e	; 0x809a
prtchr	jsr remember_axy	; 0x809c
	bit $10de	; 0x809f
	bpl prtchr_add100	; 0x80a2
	pha	; 0x80a4
	jsr osbyte_ec	; 0x80a5
	txa	; 0x80a8
	pha	; 0x80a9
	ora #$10	; 0x80aa
	jsr osbyte_03a	; 0x80ac
	pla	; 0x80af
	tax	; 0x80b0
	pla	; 0x80b1
	jsr OSASCI	; 0x80b2
	jmp osbyte_03x	; 0x80b5
prtchr_add100	ldx $10de	; 0x80b8
	sta $0100,x	; 0x80bb
	inc $10de	; 0x80be
	rts	; 0x80c1
prthex	pha	; 0x80c2
	jsr lsr4	; 0x80c3
	jsr prthex_ln	; 0x80c6
	pla	; 0x80c9
prthex_ln	pha	; 0x80ca
	and #$0f	; 0x80cb
	cmp #$0a	; 0x80cd
	bcc +	; 0x80cf
	adc #$06	; 0x80d1
+	adc #$30	; 0x80d3
	jsr prtchr	; 0x80d5
	pla	; 0x80d8
	rts	; 0x80d9
	jsr $80ea	; 0x80da
	dex	; 0x80dd
	dex	; 0x80de
	jsr $80e2	; 0x80df
	lda (temp),y	; 0x80e2
	sta $1072,x	; 0x80e4
	inx	; 0x80e7
	iny	; 0x80e8
	rts	; 0x80e9
	jsr $80ed	; 0x80ea
	lda (temp),y	; 0x80ed
	sta $bc,x	; 0x80ef
	inx	; 0x80f1
	iny	; 0x80f2
	rts	; 0x80f3
	lda #$20	; 0x80f4
	ldx #$06	; 0x80f6
-	sta filename_param,x	; 0x80f8
	dex	; 0x80fa
	bpl -	; 0x80fb
fsp_exit	rts	; 0x80fd
	jsr $834d	; 0x80fe
	jsr $80f4	; 0x8101
	bmi fsp_cont	; 0x8104
	jsr $834d	; 0x8106
	jsr $80f4	; 0x8109
	lda $bc	; 0x810c
	sta txt_ptr	; 0x810e
	lda $bd	; 0x8110
	sta $f3	; 0x8112
	ldy #$00	; 0x8114
	jsr $86bf	; 0x8116
fsp_cont	ldx #$01	; 0x8119
	jsr GSREAD	; 0x811b
	bcs fsp_exit	; 0x811e
	sta filename_param	; 0x8120
	cmp #$2e	; 0x8122
	bne +	; 0x8124
	lda #$20	; 0x8126
	bne fsp_cont3	; 0x8128
+	cmp #$3a	; 0x812a
	bne $814f	; 0x812c
	jsr GSREAD	; 0x812e
	bcs $8148	; 0x8131
	sec	; 0x8133
	sbc #$30	; 0x8134
	bcc $8148	; 0x8136
	cmp #$04	; 0x8138
	bcs $8148	; 0x813a
	jsr $877e	; 0x813c
	jsr GSREAD	; 0x813f
	bcs $81a0	; 0x8142
	cmp #$2e	; 0x8144
	beq $814b	; 0x8146
	jmp $8374	; 0x8148
	lda #$24	; 0x814b
	bne fsp_cont3	; 0x814d
	cmp #$2a	; 0x814f
	bne $816c	; 0x8151
	jsr GSREAD	; 0x8153
	bcs $8160	; 0x8156
	cmp #$2e	; 0x8158
	bne bad_filename	; 0x815a
	lda #$23	; 0x815c
	bne fsp_cont3	; 0x815e
	ldx #$00	; 0x8160
	lda #$23	; 0x8162
	sta filename_param,x	; 0x8164
	inx	; 0x8166
	cpx #$07	; 0x8167
	bne $8164	; 0x8169
	rts	; 0x816b
	jsr GSREAD	; 0x816c
	bcs $81a0	; 0x816f
	cmp #$2e	; 0x8171
	bne $8185	; 0x8173
	lda filename_param	; 0x8175
fsp_cont3	sta directory_param	; 0x8177
	jmp $811b	; 0x8179
	jsr GSREAD	; 0x817c
	bcs $81a0	; 0x817f
	cpx #$07	; 0x8181
	beq bad_filename	; 0x8183
	cmp #$2a	; 0x8185
	bne $819b	; 0x8187
	jsr GSREAD	; 0x8189
	bcs $8162	; 0x818c
bad_filename	jsr err_bad	; 0x818e
	!text $cc, "filename", $00
	sta filename_param,x	; 0x819b
	inx	; 0x819d
	bne $817c	; 0x819e
	rts	; 0x81a0
	jsr remember_axy	; 0x81a1
	lda $0f04	; 0x81a4
	jsr ld_cur_drv_cat	; 0x81a7
	cmp $0f04	; 0x81aa
	beq $81a0	; 0x81ad
	jsr brk100_errno	; 0x81af
	!text $c8, "Disk changed", $00
prt_filename	jsr remember_axy	; 0x81c0
	lda $0e0f,y	; 0x81c3
	php	; 0x81c6
	and #$7f	; 0x81c7
	bne $81d0	; 0x81c9
	jsr prt_2spc	; 0x81cb
	beq $81d6	; 0x81ce
	jsr prtchr	; 0x81d0
	jsr $809a	; 0x81d3
	ldx #$06	; 0x81d6
	lda $0e08,y	; 0x81d8
	and #$7f	; 0x81db
	jsr prtchr	; 0x81dd
	iny	; 0x81e0
	dex	; 0x81e1
	bpl $81d8	; 0x81e2
	jsr prt_2spc	; 0x81e4
	lda #$20	; 0x81e7
	plp	; 0x81e9
	bpl $81ee	; 0x81ea
	lda #$4c	; 0x81ec
	jsr prtchr	; 0x81ee
	jmp prt_spc	; 0x81f1
	jsr prt_spc	; 0x81f4
	dey	; 0x81f7
	bne $81f4	; 0x81f8
	rts	; 0x81fa
lsr6_and3	lsr	; 0x81fb
lsr5_and3	lsr	; 0x81fc
lsr4_and3	lsr	; 0x81fd
lsr3_and3	lsr	; 0x81fe
lsr2_and3	lsr	; 0x81ff
lsr1_and3	lsr	; 0x8200
	and #$03	; 0x8201
	rts	; 0x8203
lsr5	lsr	; 0x8204
lsr4	lsr	; 0x8205
lsr3	lsr	; 0x8206
lsr2	lsr	; 0x8207
lsr1	lsr	; 0x8208
	rts	; 0x8209
	asl	; 0x820a
	asl	; 0x820b
	asl	; 0x820c
	asl	; 0x820d
	asl	; 0x820e
	rts	; 0x820f
	iny	; 0x8210
	iny	; 0x8211
	iny	; 0x8212
	iny	; 0x8213
	iny	; 0x8214
	iny	; 0x8215
	iny	; 0x8216
	iny	; 0x8217
	rts	; 0x8218
	dey	; 0x8219
	dey	; 0x821a
	dey	; 0x821b
	dey	; 0x821c
	dey	; 0x821d
	dey	; 0x821e
	dey	; 0x821f
	dey	; 0x8220
	rts	; 0x8221
	brk	; 0x8222
	brk	; 0x8223
	brk	; 0x8224
	brk	; 0x8225
	brk	; 0x8226
	brk	; 0x8227
	brk	; 0x8228
	brk	; 0x8229
	brk	; 0x822a
	brk	; 0x822b
	brk	; 0x822c
	brk	; 0x822d
	brk	; 0x822e
	brk	; 0x822f
	brk	; 0x8230
	brk	; 0x8231
	brk	; 0x8232
	brk	; 0x8233
	brk	; 0x8234
	brk	; 0x8235
	brk	; 0x8236
	brk	; 0x8237
	brk	; 0x8238
	brk	; 0x8239
	brk	; 0x823a
	brk	; 0x823b
	brk	; 0x823c
	brk	; 0x823d
	brk	; 0x823e
	brk	; 0x823f
	brk	; 0x8240
	brk	; 0x8241
	brk	; 0x8242
	brk	; 0x8243
	brk	; 0x8244
	brk	; 0x8245
	brk	; 0x8246
	brk	; 0x8247
	brk	; 0x8248
	brk	; 0x8249
	brk	; 0x824a
	brk	; 0x824b
	brk	; 0x824c
	brk	; 0x824d
	brk	; 0x824e
	brk	; 0x824f
	brk	; 0x8250
	brk	; 0x8251
	brk	; 0x8252
	brk	; 0x8253
	brk	; 0x8254
	brk	; 0x8255
	brk	; 0x8256
	brk	; 0x8257
	brk	; 0x8258
	brk	; 0x8259
	brk	; 0x825a
	brk	; 0x825b
	brk	; 0x825c
	rts	; 0x825d
	lda #$23	; 0x825e
	bne $8264	; 0x8260
	lda #$ff	; 0x8262
	sta $10cf	; 0x8264
	rts	; 0x8267
	jsr $80fe	; 0x8268
	jmp $8271	; 0x826b
	jsr $8106	; 0x826e
	jsr $8296	; 0x8271
	bcs $825d	; 0x8274
	jsr err_file	; 0x8276
	!text $d6, "not found", $00
	jsr $825e	; 0x8284
	jsr init_param	; 0x8287
	jsr $8268	; 0x828a
	jsr $8301	; 0x828d
	jsr $829d	; 0x8290
	bcs $828d	; 0x8293
	rts	; 0x8295
	jsr mmc_load_cur_drv_cat	; 0x8296
	ldy #$f8	; 0x8299
	bne get_cat_nextentry2	; 0x829b
	ldy $10ce	; 0x829d
get_cat_nextentry2	jsr $8210	; 0x82a0
	cpy $0f05	; 0x82a3
	bcs $82ec	; 0x82a6
	jsr $8210	; 0x82a8
	ldx #$07	; 0x82ab
	lda filename_param,x	; 0x82ad
	cmp $10cf	; 0x82af
	beq $82c2	; 0x82b2
	jsr $82ee	; 0x82b4
	eor $0e07,y	; 0x82b7
	bcs $82be	; 0x82ba
	and #$df	; 0x82bc
	and #$7f	; 0x82be
	bne get_cat_nomatch_loop	; 0x82c0
	dey	; 0x82c2
	dex	; 0x82c3
	bpl $82ad	; 0x82c4
	sty $10ce	; 0x82c6
	sec	; 0x82c9
	rts	; 0x82ca
get_cat_nomatch_loop	dey	; 0x82cb
	dex	; 0x82cc
	bpl get_cat_nomatch_loop	; 0x82cd
	bmi get_cat_nextentry2	; 0x82cf
	jsr $984c	; 0x82d1
	lda $0e10,y	; 0x82d4
	sta $0e08,y	; 0x82d7
	lda $0f10,y	; 0x82da
	sta $0f08,y	; 0x82dd
	iny	; 0x82e0
	cpy $0f05	; 0x82e1
	bcc $82d4	; 0x82e4
	tya	; 0x82e6
	sbc #$08	; 0x82e7
	sta $0f05	; 0x82e9
	clc	; 0x82ec
	rts	; 0x82ed
	pha	; 0x82ee
	and #$df	; 0x82ef
	cmp #$41	; 0x82f1
	bcc $82f9	; 0x82f3
	cmp #$5b	; 0x82f5
	bcc $82fa	; 0x82f7
	sec	; 0x82f9
	pla	; 0x82fa
	rts	; 0x82fb
	bit $10c7	; 0x82fc
	bmi $82ed	; 0x82ff
	jsr remember_axy	; 0x8301
	jsr prt_filename	; 0x8304
	tya	; 0x8307
	pha	; 0x8308
	lda #$60	; 0x8309
	sta temp	; 0x830b
	lda #$10	; 0x830d
	sta temp+1	; 0x830f
	jsr $837e	; 0x8311
	ldy #$02	; 0x8314
	jsr prt_spc	; 0x8316
	jsr $8335	; 0x8319
	jsr $8335	; 0x831c
	jsr $8335	; 0x831f
	pla	; 0x8322
	tay	; 0x8323
	lda $0f0e,y	; 0x8324
	and #$03	; 0x8327
	jsr prthex_ln	; 0x8329
	lda $0f0f,y	; 0x832c
	jsr prthex	; 0x832f
	jmp prt_newline	; 0x8332
	ldx #$03	; 0x8335
	lda $1062,y	; 0x8337
	jsr prthex	; 0x833a
	dey	; 0x833d
	dex	; 0x833e
	bne $8337	; 0x833f
	jsr $8211	; 0x8341
	jmp prt_spc	; 0x8344
ld_cur_drv_cat	jsr remember_axy	; 0x8347
	jmp mmc_load_cur_drv_cat	; 0x834a
	lda $10ca	; 0x834d
	sta directory_param	; 0x8350
	lda $10cb	; 0x8352
	jmp $877e	; 0x8355
	jsr $86bf	; 0x8358
	beq $8352	; 0x835b
get_drv_num	jsr GSREAD	; 0x835d
	bcs $8374	; 0x8360
	cmp #$3a	; 0x8362
	beq get_drv_num	; 0x8364
	sec	; 0x8366
	sbc #$30	; 0x8367
	bcc $8374	; 0x8369
	cmp #$04	; 0x836b
	bcs $8374	; 0x836d
	jsr $877e	; 0x836f
	clc	; 0x8372
	rts	; 0x8373
	jsr err_bad	; 0x8374
	cmp $7264	; 0x8377
	adc #$76	; 0x837a
	adc $00	; 0x837c
	jsr remember_axy	; 0x837e
	tya	; 0x8381
	pha	; 0x8382
	tax	; 0x8383
	ldy #$02	; 0x8384
	lda #$00	; 0x8386
	sta (temp),y	; 0x8388
	iny	; 0x838a
	cpy #$12	; 0x838b
	bne $8388	; 0x838d
	ldy #$02	; 0x838f
	jsr $83cf	; 0x8391
	iny	; 0x8394
	iny	; 0x8395
	cpy #$0e	; 0x8396
	bne $8391	; 0x8398
	pla	; 0x839a
	tax	; 0x839b
	lda $0e0f,x	; 0x839c
	bpl $83a7	; 0x839f
	lda #$0a	; 0x83a1
	ldy #$0e	; 0x83a3
	sta (temp),y	; 0x83a5
	lda $0f0e,x	; 0x83a7
	ldy #$04	; 0x83aa
	jsr $83bb	; 0x83ac
	ldy #$0c	; 0x83af
	lsr	; 0x83b1
	lsr	; 0x83b2
	pha	; 0x83b3
	and #$03	; 0x83b4
	sta (temp),y	; 0x83b6
	pla	; 0x83b8
	ldy #$08	; 0x83b9
	lsr	; 0x83bb
	lsr	; 0x83bc
	pha	; 0x83bd
	and #$03	; 0x83be
	sta (temp),y	; 0x83c0
	cmp #$03	; 0x83c2
	bne $83cd	; 0x83c4
	lda #$ff	; 0x83c6
	sta (temp),y	; 0x83c8
	iny	; 0x83ca
	sta (temp),y	; 0x83cb
	pla	; 0x83cd
	rts	; 0x83ce
	jsr $83d2	; 0x83cf
	lda $0f08,x	; 0x83d2
	sta (temp),y	; 0x83d5
	inx	; 0x83d7
	iny	; 0x83d8
	rts	; 0x83d9
inc_word_ae	inc $ae	; 0x83da
	bne $83e0	; 0x83dc
	inc $af	; 0x83de
	rts	; 0x83e0
remember_axy	pha	; 0x83e1
	txa	; 0x83e2
	pha	; 0x83e3
	tya	; 0x83e4
	pha	; 0x83e5
	lda #$84	; 0x83e6
	pha	; 0x83e8
	lda #$03	; 0x83e9
	pha	; 0x83eb
	ldy #$05	; 0x83ec
	tsx	; 0x83ee
	lda $0107,x	; 0x83ef
	pha	; 0x83f2
	dey	; 0x83f3
	bne $83ee	; 0x83f4
	ldy #$0a	; 0x83f6
	lda $0109,x	; 0x83f8
	sta $010b,x	; 0x83fb
	dex	; 0x83fe
	dey	; 0x83ff
	bne $83f8	; 0x8400
	pla	; 0x8402
	pla	; 0x8403
	pla	; 0x8404
	tay	; 0x8405
	pla	; 0x8406
	tax	; 0x8407
	pla	; 0x8408
	rts	; 0x8409
	tsx	; 0x840a
	sta $0103,x	; 0x840b
	jmp $8404	; 0x840e
	pha	; 0x8411
	txa	; 0x8412
	pha	; 0x8413
	tya	; 0x8414
	pha	; 0x8415
	lda #$84	; 0x8416
	pha	; 0x8418
	lda #$09	; 0x8419
	pha	; 0x841b
	bne $83ec	; 0x841c
	jsr $86b8	; 0x841e
	jsr mmc_load_cur_drv_cat2	; 0x8421
	ldy #$ff	; 0x8424
	sty $a8	; 0x8426
	iny	; 0x8428
	sty $aa	; 0x8429
	lda buf,y	; 0x842b
	cpy #$08	; 0x842e
	bcc $8435	; 0x8430
	lda $0ef8,y	; 0x8432
	jsr prtchr	; 0x8435
	iny	; 0x8438
	cpy #$0c	; 0x8439
	bne $842b	; 0x843b
	jsr prtstr	; 0x843d
	!text " ("
	lda $0f04	; 0x8442
	jsr prthex	; 0x8445
	jsr prtstr	; 0x8448
	!text ")", $0d, "Drive "
	lda cur_drv	; 0x8453
	jsr prthex_ln	; 0x8455
	ldy #$0d	; 0x8458
	jsr $81f4	; 0x845a
	jsr prtstr	; 0x845d
	!text "Option "
	lda $0f06	; 0x8467
	jsr lsr4	; 0x846a
	jsr prthex_ln	; 0x846d
	jsr prtstr	; 0x8470
	!text " ("
	ldy #$03	; 0x8475
	asl	; 0x8477
	asl	; 0x8478
	tax	; 0x8479
	lda diskoptions_table,x	; 0x847a
	jsr prtchr	; 0x847d
	inx	; 0x8480
	dey	; 0x8481
	bpl $847a	; 0x8482
	jsr prtstr	; 0x8484
	!text ")", $0d, "Directory :"
	lda $10cb	; 0x8494
	jsr prthex_ln	; 0x8497
	jsr $809a	; 0x849a
	lda $10ca	; 0x849d
	jsr prtchr	; 0x84a0
	ldy #$06	; 0x84a3
	jsr $81f4	; 0x84a5
	jsr prtstr	; 0x84a8
	!text "Library :"
	lda $10cd	; 0x84b4
	jsr prthex_ln	; 0x84b7
	jsr $809a	; 0x84ba
	lda $10cc	; 0x84bd
	jsr prtchr	; 0x84c0
	jsr prt_newline	; 0x84c3
	ldy #$00	; 0x84c6
	cpy $0f05	; 0x84c8
	bcs pc12	; 0x84cb
	lda $0e0f,y	; 0x84cd
	eor $10ca	; 0x84d0
	and #$7f	; 0x84d3
	bne $84df	; 0x84d5
	lda $0e0f,y	; 0x84d7
	and #$80	; 0x84da
	sta $0e0f,y	; 0x84dc
	jsr $8210	; 0x84df
	bcc $84c8	; 0x84e2
pc12	ldy #$00	; 0x84e4
	jsr $84f6	; 0x84e6
	bcc pc14	; 0x84e9
	lda #$ff	; 0x84eb
	sta cur_drv_cat	; 0x84ed
	jmp prt_newline	; 0x84f0
	jsr $8210	; 0x84f3
	cpy $0f05	; 0x84f6
	bcs $8500	; 0x84f9
	lda $0e08,y	; 0x84fb
	bmi $84f3	; 0x84fe
	rts	; 0x8500
pc14	sty $ab	; 0x8501
	ldx #$00	; 0x8503
	lda $0e08,y	; 0x8505
	and #$7f	; 0x8508
	sta $1060,x	; 0x850a
	iny	; 0x850d
	inx	; 0x850e
	cpx #$08	; 0x850f
	bne $8505	; 0x8511
	jsr $84f6	; 0x8513
	bcs $8537	; 0x8516
	sec	; 0x8518
	ldx #$06	; 0x8519
	lda $0e0e,y	; 0x851b
	sbc $1060,x	; 0x851e
	dey	; 0x8521
	dex	; 0x8522
	bpl $851b	; 0x8523
	jsr $8211	; 0x8525
	lda $0e0f,y	; 0x8528
	and #$7f	; 0x852b
	sbc $1067	; 0x852d
	bcc pc14	; 0x8530
	jsr $8210	; 0x8532
	bcs $8513	; 0x8535
	ldy $ab	; 0x8537
	lda $0e08,y	; 0x8539
	ora #$80	; 0x853c
	sta $0e08,y	; 0x853e
	lda $1067	; 0x8541
	cmp $aa	; 0x8544
	beq pc15	; 0x8546
	ldx $aa	; 0x8548
	sta $aa	; 0x854a
	bne pc15	; 0x854c
	jsr prt_newline	; 0x854e
	jsr prt_newline	; 0x8551
	ldy #$ff	; 0x8554
	bne $8561	; 0x8556
pc15	ldy $a8	; 0x8558
	bne $8551	; 0x855a
	ldy #$05	; 0x855c
	jsr $81f4	; 0x855e
	iny	; 0x8561
	sty $a8	; 0x8562
	ldy $ab	; 0x8564
	jsr prt_2spc	; 0x8566
	jsr prt_filename	; 0x8569
	jmp pc12	; 0x856c
diskoptions_table	!text "off", $00, "LOADRUN", $00, "EXEC"
get_next_block	lda $0f0e,y	; 0x857f
	jsr lsr4_and3	; 0x8582
	sta $c4	; 0x8585
	clc	; 0x8587
	lda #$ff	; 0x8588
	adc $0f0c,y	; 0x858a
	lda $0f0f,y	; 0x858d
	adc $0f0d,y	; 0x8590
	sta $c5	; 0x8593
	lda $0f0e,y	; 0x8595
	and #$03	; 0x8598
	adc $c4	; 0x859a
	sta $c4	; 0x859c
get_first_block	sec	; 0x859e
	lda $0f07,y	; 0x859f
	sbc $c5	; 0x85a2
	pha	; 0x85a4
	lda $0f06,y	; 0x85a5
	and #$03	; 0x85a8
	sbc $c4	; 0x85aa
	tax	; 0x85ac
	lda #$00	; 0x85ad
	cmp $c2	; 0x85af
	pla	; 0x85b1
	sbc $c3	; 0x85b2
	txa	; 0x85b4
	sbc $c6	; 0x85b5
	rts	; 0x85b7
cmdtxt_access	!text "ACCESS", $88, $d1, "2"
cmdtxt_backup	!text "BACKUP", $9c, $ba, "T"
cmdtxt_compact	!text "COMPACT", $9a, $bf, $0a
cmdtxt_copy	!text "COPY", $9d, "&d"
cmdtxt_delete	!text "DELETE", $86, $fd, $01
cmdtxt_destroy	!text "DESTROY", $87, $0f, $02
cmdtxt_dir	!text "DIR", $88, "M", $09
cmdtxt_drive	!text "DRIVE", $87, "t", $0a
cmdtxt_enable	!text "ENABLE", $8a, "8", $00
cmdtxt_info	!text "INFO", $82, $83, $02
cmdtxt_lib	!text "LIB", $88, "Q", $09
cmdtxt_rename	!text "RENAME", $8a, "l", $87
cmdtxt_title	!text "TITLE", $88, $a2, $0b
cmdtxt_wipe	!text "WIPE", $86, $c2, $02, $b0, "&", $00
cmdtxt_build	!text "BUILD", $9f, "G", $01
cmdtxt_disc	!text "UDFS", $93, "7", $00
cmdtxt_dump	!text "DUMP", $9e, $cf, $01
cmdtxt_list	!text "LIST", $9e, $8d, $01
cmdtxt_type	!text "TYPE", $9e, $86, $01
cmdtxt_disk	!text "UDFS", $93, "7", $00, $85, $b6, $00
hlptxt_dfs	!text "DFS", $99, $c5, $00
hlptxt_utils	!text "UTILS", $99, $ed, $00, $99, $f4, $00
fscv3_unrecognised_cmd	jsr $86b8	; 0x866c
	ldx #$fd	; 0x866f
	txa	; 0x8671
	tsx	; 0x8672
	stx $b6	; 0x8673
	tax	; 0x8675
	tya	; 0x8676
	pha	; 0x8677
unrecognised_loop	inx	; 0x8678
	inx	; 0x8679
	pla	; 0x867a
	pha	; 0x867b
	tay	; 0x867c
	jsr $86bf	; 0x867d
	inx	; 0x8680
	lda cmdtxt_access,x	; 0x8681
	bmi go_cmd_code	; 0x8684
	dex	; 0x8686
	dey	; 0x8687
	stx err_ptr	; 0x8688
	inx	; 0x868a
	iny	; 0x868b
	lda cmdtxt_access,x	; 0x868c
	bmi $86a7	; 0x868f
	eor (txt_ptr),y	; 0x8691
	and #$5f	; 0x8693
	beq $868a	; 0x8695
	dex	; 0x8697
	inx	; 0x8698
	lda cmdtxt_access,x	; 0x8699
	bpl $8698	; 0x869c
	lda (txt_ptr),y	; 0x869e
	cmp #$2e	; 0x86a0
	bne unrecognised_loop	; 0x86a2
	iny	; 0x86a4
	bcs go_cmd_code	; 0x86a5
	lda (txt_ptr),y	; 0x86a7
	jsr $82ee	; 0x86a9
	bcc unrecognised_loop	; 0x86ac
go_cmd_code	pla	; 0x86ae
	lda cmdtxt_access,x	; 0x86af
	pha	; 0x86b2
	lda $85b9,x	; 0x86b3
	pha	; 0x86b6
	rts	; 0x86b7
	stx txt_ptr	; 0x86b8
	sty $f3	; 0x86ba
	ldy #$00	; 0x86bc
	rts	; 0x86be
	clc	; 0x86bf
	jmp GSINIT	; 0x86c0
cmd_wipe	jsr $825e	; 0x86c3
	jsr init_param	; 0x86c6
	jsr $8268	; 0x86c9
	lda $0e0f,y	; 0x86cc
	bmi $86e3	; 0x86cf
	jsr prt_filename	; 0x86d1
	jsr prtstr	; 0x86d4
	!text " : "
	nop	; 0x86da
	jsr $9c9e	; 0x86db
	beq $86e9	; 0x86de
	jsr prt_newline	; 0x86e0
	jsr $829d	; 0x86e3
	bcs $86cc	; 0x86e6
	rts	; 0x86e8
	jsr $81a1	; 0x86e9
	jsr $82d1	; 0x86ec
	jsr $8ab4	; 0x86ef
	ldy $10ce	; 0x86f2
	jsr $8219	; 0x86f5
	sty $10ce	; 0x86f8
	jmp $86e0	; 0x86fb
cmd_delete	jsr $8262	; 0x86fe
	jsr init_param	; 0x8701
	jsr $8268	; 0x8704
	jsr $82fc	; 0x8707
	jsr $82d1	; 0x870a
	jmp $8ab4	; 0x870d
cmd_destroy	jsr $9bbd	; 0x8710
	jsr $825e	; 0x8713
	jsr init_param	; 0x8716
	jsr $8268	; 0x8719
	lda $0e0f,y	; 0x871c
	bmi $8727	; 0x871f
	jsr prt_filename	; 0x8721
	jsr prt_newline	; 0x8724
	jsr $829d	; 0x8727
	bcs $871c	; 0x872a
	jsr prtstr	; 0x872c
	!text $0d, "Delete (Y/N) ? "
	nop	; 0x873f
	jsr $9c9e	; 0x8740
	beq $8748	; 0x8743
	jmp prt_newline	; 0x8745
	jsr $81a1	; 0x8748
	jsr $8296	; 0x874b
	lda $0e0f,y	; 0x874e
	bmi $875f	; 0x8751
	jsr $82d1	; 0x8753
	ldy $10ce	; 0x8756
	jsr $8219	; 0x8759
	sty $10ce	; 0x875c
	jsr $829d	; 0x875f
	bcs $874e	; 0x8762
	jsr $8ab4	; 0x8764
	jsr prtstr	; 0x8767
	ora $6544	; 0x876a
	jmp ($7465)	; 0x876d
	adc $64	; 0x8770
	ora $60ea	; 0x8772
cmd_drive	jsr init_param	; 0x8775
	jsr get_drv_num	; 0x8778
	sta $10cb	; 0x877b
	nop	; 0x877e
	nop	; 0x877f
	nop	; 0x8780
	and #$03	; 0x8781
	sta cur_drv	; 0x8783
	rts	; 0x8785
	jsr $8961	; 0x8786
	jsr $986e	; 0x8789
	jsr $837e	; 0x878c
	jmp mmc_save_mem_block	; 0x878f
	nop	; 0x8792
	nop	; 0x8793
	jsr $826e	; 0x8794
	jsr $986e	; 0x8797
	jsr $837e	; 0x879a
	sty $bc	; 0x879d
	ldx #$00	; 0x879f
	lda $c0	; 0x87a1
	bne $87ab	; 0x87a3
	iny	; 0x87a5
	iny	; 0x87a6
	ldx #$02	; 0x87a7
	bne load_copyfileinfo_loop	; 0x87a9
	lda $0f0e,y	; 0x87ab
	sta $c4	; 0x87ae
	jsr $8a3f	; 0x87b0
load_copyfileinfo_loop	lda $0f08,y	; 0x87b3
	sta $be,x	; 0x87b6
	iny	; 0x87b8
	inx	; 0x87b9
	cpx #$08	; 0x87ba
	bne load_copyfileinfo_loop	; 0x87bc
	jsr $8a56	; 0x87be
	ldy $bc	; 0x87c1
	jsr $82fc	; 0x87c3
	jmp mmc_load_mem_block	; 0x87c6
	brk	; 0x87c9
	brk	; 0x87ca
	brk	; 0x87cb
	brk	; 0x87cc
	brk	; 0x87cd
	brk	; 0x87ce
	brk	; 0x87cf
	brk	; 0x87d0
	brk	; 0x87d1
	brk	; 0x87d2
	brk	; 0x87d3
	jsr $86b8	; 0x87d4
	jsr $8841	; 0x87d7
	sty $10db	; 0x87da
	jsr $8106	; 0x87dd
	sty $10da	; 0x87e0
	jsr $8296	; 0x87e3
	bcs runfile_found	; 0x87e6
	ldy $10db	; 0x87e8
	lda $10cc	; 0x87eb
	sta directory_param	; 0x87ee
	lda $10cd	; 0x87f0
	jsr $877e	; 0x87f3
	jsr $8109	; 0x87f6
	jsr $8296	; 0x87f9
	bcs runfile_found	; 0x87fc
	jsr err_bad	; 0x87fe
	inc $6f63,x	; 0x8801
	adc $616d	; 0x8804
	ror $0064	; 0x8807
runfile_found	jsr $879d	; 0x880a
	clc	; 0x880d
	lda $10da	; 0x880e
	tay	; 0x8811
	adc txt_ptr	; 0x8812
	sta $10da	; 0x8814
	lda $f3	; 0x8817
	adc #$00	; 0x8819
	sta $10db	; 0x881b
	lda $1076	; 0x881e
	and $1077	; 0x8821
	ora tube_present_if_zero	; 0x8824
	cmp #$ff	; 0x8827
	beq $883e	; 0x8829
	lda $c0	; 0x882b
	sta $1074	; 0x882d
	lda $c1	; 0x8830
	sta $1075	; 0x8832
	ldx #$74	; 0x8835
	ldy #$10	; 0x8837
	lda #$04	; 0x8839
	jmp $0406	; 0x883b
	jmp ($00c0)	; 0x883e
	lda #$ff	; 0x8841
	sta $c0	; 0x8843
	lda txt_ptr	; 0x8845
	sta $bc	; 0x8847
	lda $f3	; 0x8849
	sta $bd	; 0x884b
	rts	; 0x884d
cmd_dir	ldx #$00	; 0x884e
	beq $8854	; 0x8850
cmd_lib	ldx #$02	; 0x8852
	jsr $8860	; 0x8854
	sta $10cb,x	; 0x8857
	lda directory_param	; 0x885a
	sta $10ca,x	; 0x885c
	rts	; 0x885f
	lda #$24	; 0x8860
	sta directory_param	; 0x8862
	jsr $86bf	; 0x8864
	bne $8870	; 0x8867
	lda #$00	; 0x8869
	jsr $877e	; 0x886b
	beq good_directory	; 0x886e
	lda $10cb	; 0x8870
	jsr $877e	; 0x8873
-	jsr GSREAD	; 0x8876
	bcs bad_directory	; 0x8879
	cmp #$3a	; 0x887b
	bne $8899	; 0x887d
	jsr get_drv_num	; 0x887f
	jsr GSREAD	; 0x8882
	bcs good_directory	; 0x8885
	cmp #$2e	; 0x8887
	beq -	; 0x8889
bad_directory	jsr err_bad	; 0x888b
	!text $ce, "directory", $00
	sta directory_param	; 0x8899
	jsr GSREAD	; 0x889b
	bcc bad_directory	; 0x889e
good_directory	lda cur_drv	; 0x88a0
	rts	; 0x88a2
cmd_title	jsr init_param	; 0x88a3
	jsr $834d	; 0x88a6
	jsr ld_cur_drv_cat	; 0x88a9
	jmp $aea7	; 0x88ac
	brk	; 0x88af
	jsr $88c6	; 0x88b0
	dex	; 0x88b3
	bpl $88b0	; 0x88b4
	inx	; 0x88b6
	jsr GSREAD	; 0x88b7
	bcs goto_save_cat	; 0x88ba
	jsr $88c6	; 0x88bc
	cpx #$0b	; 0x88bf
	bcc $88b6	; 0x88c1
goto_save_cat	jmp $8ab4	; 0x88c3
	cpx #$08	; 0x88c6
	bcc $88ce	; 0x88c8
	sta $0ef8,x	; 0x88ca
	rts	; 0x88cd
	sta buf,x	; 0x88ce
	rts	; 0x88d1
cmd_access	jsr $825e	; 0x88d2
	jsr init_param	; 0x88d5
	jsr $80fe	; 0x88d8
	ldx #$00	; 0x88db
	jsr $86bf	; 0x88dd
	bne $8905	; 0x88e0
	stx $aa	; 0x88e2
	jsr $8296	; 0x88e4
	bcs file_found	; 0x88e7
	jmp $8276	; 0x88e9
file_found	jsr $984f	; 0x88ec
	lda $0e0f,y	; 0x88ef
	and #$7f	; 0x88f2
	ora $aa	; 0x88f4
	sta $0e0f,y	; 0x88f6
	jsr $82fc	; 0x88f9
	jsr $829d	; 0x88fc
	bcs file_found	; 0x88ff
	bcc goto_save_cat	; 0x8901
	ldx #$80	; 0x8903
	jsr GSREAD	; 0x8905
	bcs $88e2	; 0x8908
	cmp #$4c	; 0x890a
	beq $8903	; 0x890c
	jsr err_bad	; 0x890e
	!text $cf, "attribute", $00
	jsr remember_axy	; 0x891c
	txa	; 0x891f
	cmp #$04	; 0x8920
	beq $893e	; 0x8922
	cmp #$02	; 0x8924
	bcc $8933	; 0x8926
	jsr err_bad	; 0x8928
	!text $cb, "option", $00
	ldx #$ff	; 0x8933
	tya	; 0x8935
	beq $893a	; 0x8936
	ldx #$00	; 0x8938
	stx $10c7	; 0x893a
	rts	; 0x893d
	tya	; 0x893e
	pha	; 0x893f
	jsr $834d	; 0x8940
	jsr mmc_load_cur_drv_cat	; 0x8943
	pla	; 0x8946
	jsr $820b	; 0x8947
	eor $0f06	; 0x894a
	and #$30	; 0x894d
	eor $0f06	; 0x894f
	sta $0f06	; 0x8952
	jmp $8ab4	; 0x8955
err_disk_full	jsr $8018	; 0x8958
	!text $c6, "full", $00
	jsr $8106	; 0x8961
	jsr $8296	; 0x8964
	bcc $896c	; 0x8967
	jsr $82d1	; 0x8969
	lda $c2	; 0x896c
	pha	; 0x896e
	lda $c3	; 0x896f
	pha	; 0x8971
	sec	; 0x8972
	lda $c4	; 0x8973
	sbc $c2	; 0x8975
	sta $c2	; 0x8977
	lda $c5	; 0x8979
	sbc $c3	; 0x897b
	sta $c3	; 0x897d
	lda $107a	; 0x897f
	sbc $1078	; 0x8982
	sta $c6	; 0x8985
	jsr $899d	; 0x8987
	lda $1079	; 0x898a
	sta $1075	; 0x898d
	lda $1078	; 0x8990
	sta $1074	; 0x8993
	pla	; 0x8996
	sta $bf	; 0x8997
	pla	; 0x8999
	sta $be	; 0x899a
	rts	; 0x899c
	lda #$00	; 0x899d
	sta $c4	; 0x899f
	lda #$02	; 0x89a1
	sta $c5	; 0x89a3
	ldy $0f05	; 0x89a5
	beq createfile_endofdisk	; 0x89a8
	cpy #$f8	; 0x89aa
	bcs $8a04	; 0x89ac
	jsr get_first_block	; 0x89ae
	jmp $89bc	; 0x89b1
	beq err_disk_full	; 0x89b4
	jsr $8219	; 0x89b6
	jsr get_next_block	; 0x89b9
	tya	; 0x89bc
	bcc $89b4	; 0x89bd
	sty temp	; 0x89bf
	ldy $0f05	; 0x89c1
	cpy temp	; 0x89c4
	beq createfile_endofdisk	; 0x89c6
	lda $0e07,y	; 0x89c8
	sta $0e0f,y	; 0x89cb
	lda $0f07,y	; 0x89ce
	sta $0f0f,y	; 0x89d1
	dey	; 0x89d4
	bcs $89c4	; 0x89d5
createfile_endofdisk	ldx #$00	; 0x89d7
	jsr $8a17	; 0x89d9
	lda filename_param,x	; 0x89dc
	sta $0e08,y	; 0x89de
	iny	; 0x89e1
	inx	; 0x89e2
	cpx #$08	; 0x89e3
	bne $89dc	; 0x89e5
	lda $bd,x	; 0x89e7
	dey	; 0x89e9
	sta $0f08,y	; 0x89ea
	dex	; 0x89ed
	bne $89e7	; 0x89ee
	jsr $82fc	; 0x89f0
	tya	; 0x89f3
	pha	; 0x89f4
	ldy $0f05	; 0x89f5
	jsr $8210	; 0x89f8
	sty $0f05	; 0x89fb
	jsr $8ab4	; 0x89fe
	pla	; 0x8a01
	tay	; 0x8a02
	rts	; 0x8a03
	jsr brk100_errno	; 0x8a04
	!text $be, "Catalogue full", $00
	lda $1076	; 0x8a17
	and #$03	; 0x8a1a
	asl	; 0x8a1c
	asl	; 0x8a1d
	eor $c6	; 0x8a1e
	and #$fc	; 0x8a20
	eor $c6	; 0x8a22
	asl	; 0x8a24
	asl	; 0x8a25
	eor $1074	; 0x8a26
	and #$fc	; 0x8a29
	eor $1074	; 0x8a2b
	asl	; 0x8a2e
	asl	; 0x8a2f
	eor $c4	; 0x8a30
	and #$fc	; 0x8a32
	eor $c4	; 0x8a34
	sta $c4	; 0x8a36
	rts	; 0x8a38
cmd_enable	lda #$01	; 0x8a39
	sta $10c8	; 0x8a3b
	rts	; 0x8a3e
	lda #$00	; 0x8a3f
	sta $1075	; 0x8a41
	lda $c4	; 0x8a44
	jsr lsr2_and3	; 0x8a46
	cmp #$03	; 0x8a49
	bne $8a52	; 0x8a4b
	lda #$ff	; 0x8a4d
	sta $1075	; 0x8a4f
	sta $1074	; 0x8a52
	rts	; 0x8a55
	lda #$00	; 0x8a56
	sta $1077	; 0x8a58
	lda $c4	; 0x8a5b
	jsr lsr6_and3	; 0x8a5d
	cmp #$03	; 0x8a60
	bne $8a69	; 0x8a62
	lda #$ff	; 0x8a64
	sta $1077	; 0x8a66
	sta $1076	; 0x8a69
	rts	; 0x8a6c
cmd_rename	jsr $8262	; 0x8a6d
	jsr $86bf	; 0x8a70
	bne $8a78	; 0x8a73
	jmp $9a06	; 0x8a75
	jsr $80fe	; 0x8a78
	tya	; 0x8a7b
	pha	; 0x8a7c
	jsr $8296	; 0x8a7d
	bcs $8a85	; 0x8a80
	jmp $8276	; 0x8a82
	jsr $984c	; 0x8a85
	sty $b3	; 0x8a88
	pla	; 0x8a8a
	tay	; 0x8a8b
	jsr $86bf	; 0x8a8c
	beq $8a75	; 0x8a8f
	jsr $80fe	; 0x8a91
	jsr $8296	; 0x8a94
	bcc $8aa4	; 0x8a97
	jsr err_file	; 0x8a99
	!text $c4, "exists", $00
	ldy $b3	; 0x8aa4
	jsr $8210	; 0x8aa6
	ldx #$07	; 0x8aa9
	lda filename_param,x	; 0x8aab
	sta $0e07,y	; 0x8aad
	dey	; 0x8ab0
	dex	; 0x8ab1
	bpl $8aab	; 0x8ab2
	clc	; 0x8ab4
	sed	; 0x8ab5
	lda $0f04	; 0x8ab6
	adc #$01	; 0x8ab9
	cld	; 0x8abb
	sta $0f04	; 0x8abc
	jmp mmc_save_cur_drv_cat	; 0x8abf
	lda #$ff	; 0x8ac2
	jsr $069e	; 0x8ac4
	lda TUBE_R3	; 0x8ac7
	lda #$00	; 0x8aca
	jsr $0695	; 0x8acc
	tay	; 0x8acf
	lda ($fd),y	; 0x8ad0
	jsr $0695	; 0x8ad2
	iny	; 0x8ad5
	lda ($fd),y	; 0x8ad6
	jsr $0695	; 0x8ad8
	tax	; 0x8adb
	bne $8ad5	; 0x8adc
	ldx #$ff	; 0x8ade
	txs	; 0x8ae0
	cli	; 0x8ae1
	bit TUBE_R0	; 0x8ae2
	bpl $8aed	; 0x8ae5
	lda TUBE_R1	; 0x8ae7
	jsr OSWRCH	; 0x8aea
	bit TUBE_R2	; 0x8aed
	bpl $8ae2	; 0x8af0
	bit TUBE_R0	; 0x8af2
	bmi $8ae7	; 0x8af5
	ldx TUBE_R3	; 0x8af7
	stx $51	; 0x8afa
	jmp ($0500)	; 0x8afc
	!text $00, $80, $00, $00, "L", $84, $04, "L", $a7, $06, $c9, $80, $90, "+", $c9, $c0, $b0, $1a, $09, "@", $c5, $15, $d0, " ", $08, "x", $a9, $05, " ", $9e, $06, $a5, $15, " ", $9e, $06, "(", $a9, $80, $85, $15, $85, $14, "`", $06, $14, $b0, $06, $c5, $15, $f0, $04, $18, "`", $85, $15, "`", $08, "x", $84, $13, $86, $12, " ", $9e, $06, $aa, $a0, $03, $a5, $15, " ", $9e, $06, $b1, $12, " ", $9e, $06, $88, $10, $f8, $a0, $18, $8c, $e0, $fe, $bd, $18, $05, $8d, $e0, $fe, "JJ", $90, $06, ",", $e5, $fe, ",", $e5, $fe, " ", $9e, $06, ",", $e6, $fe, "P", $fb, $b0, $0d, $e0, $04, $d0, $11, " ", $14, $04, " ", $95, $06, "L2", $00, "J", $90, $05, $a0, $88, $8c, $e0, $fe, "(`X", $b0, $11, $d0, $03, "L", $9c, $05, $a2, $00, $a0, $ff, $a9, $fd, " ", $f4, $ff, $8a, $f0, $d9, $a9, $ff, " ", $06, $04, $90, $f9, " ", $d2, $04, $a9, $07, " ", $cb, $04, $a0, $00, $84, $00, $b1, $00, $8d, $e5, $fe, $ea, $ea, $ea, $c8, $d0, $f5, $e6, "T", $d0, $06, $e6, "U", $d0, $02, $e6, "V", $e6, $01, "$", $01, "P", $dc, " ", $d2, $04, $a9, $04, $a0, $00, $a2, "SL", $06, $04, $a9, $80, $85, "T", $85, $01, $a9, " -", $06, $80, $a8, $84, "S", $f0, $19, $ae, $07, $80, $e8, $bd, $00, $80, $d0, $fa, $bd, $01, $80, $85, "S", $bd, $02, $80, $85, "T", $bc, $03, $80, $bd, $04, $80, $85, "V", $84, "U`7", $05, $96, $05, $f2, $05, $07, $06, "'", $06, "h", $06, "^", $05, "-", $05, " ", $05, "B", $05, $a9, $05, $d1, $05, $86, $88, $96, $98, $18, $18, $82, $18, " ", $c5, $06, $a8, " ", $c5, $06, " ", $d4, $ff, "L", $9c, $05, " ", $c5, $06, $a8, " ", $d7, $ff, "L:", $05, " ", $e0, $ff, "j ", $95, $06, "*L", $9e, $05, " ", $c5, $06, $f0, $0b, "H ", $82, $05, "h ", $ce, $ff, "L", $9e, $05, " ", $c5, $06, $a8, $a9, $00, " ", $ce, $ff, "L", $9c, $05, " ", $c5, $06, $a8, $a2, $04, " ", $c5, $06, $95, $ff, $ca, $d0, $f8, " ", $c5, $06, " ", $da, $ff, " ", $95, $06, $a2, $03, $b5, $00, " ", $95, $06, $ca, $10, $f8, "L6", $00, $a2, $00, $a0, $00, " ", $c5, $06, $99, $00, $07, $c8, $f0, $04, $c9, $0d, $d0, $f3, $a0, $07, "` ", $82, $05, " ", $f7, $ff, $a9, $7f, ",", $e2, $fe, "P", $fb, $8d, $e3, $fe, "L6", $00, $a2, $10, " ", $c5, $06, $95, $01, $ca, $d0, $f8, " ", $82, $05, $86, $00, $84, $01, $a0, $00, " ", $c5, $06, " ", $dd, $ff, " ", $95, $06, $a2, $10, $b5, $01, " ", $95, $06, $ca, $d0, $f8, $f0, $d5, $a2, $0d, " ", $c5, $06, $95, $ff, $ca, $d0, $f8, " ", $c5, $06, $a0, $00, " ", $d1, $ff, "H", $a2, $0c, $b5, $00, " ", $95, $06, $ca, $10, $f8, "hL:", $05, " ", $c5, $06, $aa, " ", $c5, $06, " ", $f4, $ff, ",", $e2, $fe, "P", $fb, $8e, $e3, $fe, "L6", $00, " ", $c5, $06, $aa, " ", $c5, $06, $a8, " ", $c5, $06, " ", $f4, $ff, "I", $9d, $f0, $eb, "j ", $95, $06, ",", $e2, $fe, "P", $fb, $8c, $e3, $fe, "p", $d5, " ", $c5, $06, $a8, ",", $e2, $fe, $10, $fb, $ae, $e3, $fe, $ca, "0", $0f, ",", $e2, $fe, $10, $fb, $ad, $e3, $fe, $9d, "(", $01, $ca, $10, $f2, $98, $a2, "(", $a0, $01, " ", $f1, $ff, ",", $e2, $fe, $10, $fb, $ae, $e3, $fe, $ca, "0", $0e, $bc, "(", $01, ",", $e2, $fe, "P", $fb, $8c, $e3, $fe, $ca, $10, $f2, "L6", $00, $a2, $04, " ", $c5, $06, $95, $00, $ca, $10, $f8, $e8, $a0, $00, $8a, " ", $f1, $ff, $90, $05, $a9, $ff, "L", $9e, $05, $a2, $00, $a9, $7f, " ", $95, $06, $bd, $00, $07, " ", $95, $06, $e8, $c9, $0d, $d0, $f5, "L6", $00, ",", $e2, $fe, "P", $fb, $8d, $e3, $fe, "`,", $e6, $fe, "P", $fb, $8d, $e7, $fe, "`", $a5, $ff, "8j0", $0f, "H", $a9, $00, " ", $bc, $06, $98, " ", $bc, $06, $8a, " ", $bc, $06, "h,", $e0, $fe, "P", $fb, $8d, $e1, $fe, "`,", $e2, $fe, $10, $fb, $ad, $e3, $fe, "`", $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
fscv7_handle_range	ldx #$11	; 0x8ddd
	ldy #$15	; 0x8ddf
	rts	; 0x8de1
fscv6_shutdown_filesys	jsr remember_axy	; 0x8de2
	lda #$77	; 0x8de5
	jmp OSBYTE	; 0x8de7
	jsr fscv6_shutdown_filesys	; 0x8dea
	lda #$00	; 0x8ded
	clc	; 0x8def
	adc #$20	; 0x8df0
	beq $8de1	; 0x8df2
	tay	; 0x8df4
	jsr update_catnfile	; 0x8df5
	bne $8def	; 0x8df8
	tya	; 0x8dfa
	beq $8dea	; 0x8dfb
	jsr $907b	; 0x8dfd
	bcc update_catnfile	; 0x8e00
	jmp err_channel	; 0x8e02
update_catnfile	pha	; 0x8e05
	jsr is_handle_in_use	; 0x8e06
	bcs $8e50	; 0x8e09
	lda $111b,y	; 0x8e0b
	eor #$ff	; 0x8e0e
	and $10c0	; 0x8e10
	sta $10c0	; 0x8e13
	lda $1117,y	; 0x8e16
	and #$60	; 0x8e19
	beq $8e50	; 0x8e1b
	jsr setup_save_to_media2	; 0x8e1d
	lda $1117,y	; 0x8e20
	and #$20	; 0x8e23
	beq $8e4d	; 0x8e25
	ldx $10c4	; 0x8e27
	lda $1114,y	; 0x8e2a
	sta $0f0c,x	; 0x8e2d
	lda $1115,y	; 0x8e30
	sta $0f0d,x	; 0x8e33
	lda $1116,y	; 0x8e36
	jsr $820b	; 0x8e39
	eor $0f0e,x	; 0x8e3c
	and #$30	; 0x8e3f
	eor $0f0e,x	; 0x8e41
	sta $0f0e,x	; 0x8e44
	jsr $8ab4	; 0x8e47
	ldy $10c2	; 0x8e4a
	jsr file_to_media_y	; 0x8e4d
	ldx $10c6	; 0x8e50
	pla	; 0x8e53
	rts	; 0x8e54
setup_save_to_media2	jsr set_file_drv	; 0x8e55
setup_save_to_media	ldx #$07	; 0x8e58
	lda $110c,y	; 0x8e5a
	sta $c6,x	; 0x8e5d
	dey	; 0x8e5f
	dey	; 0x8e60
	dex	; 0x8e61
	bne $8e5a	; 0x8e62
	jsr $8296	; 0x8e64
	bcc $8e90	; 0x8e67
	sty $10c4	; 0x8e69
	lda $0f0e,y	; 0x8e6c
	ldx $0f0f,y	; 0x8e6f
	ldy $10c2	; 0x8e72
	eor $110d,y	; 0x8e75
	and #$03	; 0x8e78
	bne $8e90	; 0x8e7a
	txa	; 0x8e7c
	cmp $110f,y	; 0x8e7d
	bne $8e90	; 0x8e80
	rts	; 0x8e82
set_file_drv	lda $110e,y	; 0x8e83
	and #$7f	; 0x8e86
	sta directory_param	; 0x8e88
	lda $1117,y	; 0x8e8a
	jmp $877e	; 0x8e8d
	jmp $81af	; 0x8e90
	cmp #$00	; 0x8e93
	bne $8e9d	; 0x8e95
	jsr remember_axy	; 0x8e97
	jmp $8dfa	; 0x8e9a
	jsr $8411	; 0x8e9d
	stx $bc	; 0x8ea0
	sty $bd	; 0x8ea2
	sta $b4	; 0x8ea4
	bit $b4	; 0x8ea6
	php	; 0x8ea8
	jsr $8106	; 0x8ea9
	jsr $8296	; 0x8eac
	bcs $8ecb	; 0x8eaf
	plp	; 0x8eb1
	bvc $8eb7	; 0x8eb2
	lda #$00	; 0x8eb4
	rts	; 0x8eb6
	php	; 0x8eb7
	lda #$00	; 0x8eb8
	ldx #$07	; 0x8eba
	sta $be,x	; 0x8ebc
	sta $1074,x	; 0x8ebe
	dex	; 0x8ec1
	bpl $8ebc	; 0x8ec2
	lda #$40	; 0x8ec4
	sta $c5	; 0x8ec6
	jsr $8961	; 0x8ec8
	plp	; 0x8ecb
	php	; 0x8ecc
	bvs $8ed2	; 0x8ecd
	jsr $983c	; 0x8ecf
	jsr $8f9e	; 0x8ed2
	bcc $8ee5	; 0x8ed5
	lda $110c,y	; 0x8ed7
	bpl err_file_open	; 0x8eda
	bit $b4	; 0x8edc
	bmi err_file_open	; 0x8ede
	jsr $8f99	; 0x8ee0
	bcs $8ed7	; 0x8ee3
	ldy $10c2	; 0x8ee5
	bne $8f0b	; 0x8ee8
err_too_many_files_open	jsr brk100_errno	; 0x8eea
	!text $c0, "Too many files open", $00
err_file_open	jsr err_file	; 0x8f02
	!text $c2, "open", $00
	lda #$08	; 0x8f0b
	sta $10c5	; 0x8f0d
	lda $0e08,x	; 0x8f10
	sta $1100,y	; 0x8f13
	iny	; 0x8f16
	lda $0f08,x	; 0x8f17
	sta $1100,y	; 0x8f1a
	iny	; 0x8f1d
	inx	; 0x8f1e
	dec $10c5	; 0x8f1f
	bne $8f10	; 0x8f22
	ldx #$10	; 0x8f24
	lda #$00	; 0x8f26
	sta $1100,y	; 0x8f28
	iny	; 0x8f2b
	dex	; 0x8f2c
	bne $8f28	; 0x8f2d
	lda $10c2	; 0x8f2f
	tay	; 0x8f32
	jsr lsr5	; 0x8f33
	adc #$11	; 0x8f36
	sta $1113,y	; 0x8f38
	lda $10c1	; 0x8f3b
	sta $111b,y	; 0x8f3e
	ora $10c0	; 0x8f41
	sta $10c0	; 0x8f44
	lda $1109,y	; 0x8f47
	adc #$ff	; 0x8f4a
	lda $110b,y	; 0x8f4c
	adc #$00	; 0x8f4f
	sta $1119,y	; 0x8f51
	lda $110d,y	; 0x8f54
	ora #$0f	; 0x8f57
	adc #$00	; 0x8f59
	jsr lsr4_and3	; 0x8f5b
	sta $111a,y	; 0x8f5e
	plp	; 0x8f61
	bvc $8f92	; 0x8f62
	bmi $8f6e	; 0x8f64
	lda #$80	; 0x8f66
	ora $110c,y	; 0x8f68
	sta $110c,y	; 0x8f6b
	lda $1109,y	; 0x8f6e
	sta $1114,y	; 0x8f71
	lda $110b,y	; 0x8f74
	sta $1115,y	; 0x8f77
	lda $110d,y	; 0x8f7a
	jsr lsr4_and3	; 0x8f7d
	sta $1116,y	; 0x8f80
	lda cur_drv	; 0x8f83
	ora $1117,y	; 0x8f85
	sta $1117,y	; 0x8f88
	tya	; 0x8f8b
	jsr lsr5	; 0x8f8c
	ora #$10	; 0x8f8f
	rts	; 0x8f91
	lda #$20	; 0x8f92
	sta $1117,y	; 0x8f94
	bne $8f83	; 0x8f97
	txa	; 0x8f99
	pha	; 0x8f9a
	jmp $8fdd	; 0x8f9b
	lda #$00	; 0x8f9e
	sta $10c2	; 0x8fa0
	lda #$08	; 0x8fa3
	sta $b5	; 0x8fa5
	tya	; 0x8fa7
	tax	; 0x8fa8
	ldy #data_ptr	; 0x8fa9
	sty $b3	; 0x8fab
	txa	; 0x8fad
	pha	; 0x8fae
	lda #$08	; 0x8faf
	sta $b2	; 0x8fb1
	lda $b5	; 0x8fb3
	bit $10c0	; 0x8fb5
	beq $8fd7	; 0x8fb8
	lda $1117,y	; 0x8fba
	eor cur_drv	; 0x8fbd
	and #$03	; 0x8fbf
	bne $8fdd	; 0x8fc1
	lda $0e08,x	; 0x8fc3
	eor $1100,y	; 0x8fc6
	and #$7f	; 0x8fc9
	bne $8fdd	; 0x8fcb
	inx	; 0x8fcd
	iny	; 0x8fce
	iny	; 0x8fcf
	dec $b2	; 0x8fd0
	bne $8fc3	; 0x8fd2
	sec	; 0x8fd4
	bcs $8fe7	; 0x8fd5
	sty $10c2	; 0x8fd7
	sta $10c1	; 0x8fda
	sec	; 0x8fdd
	lda $b3	; 0x8fde
	sbc #$20	; 0x8fe0
	sta $b3	; 0x8fe2
	asl $b5	; 0x8fe4
	clc	; 0x8fe6
	pla	; 0x8fe7
	tax	; 0x8fe8
	ldy $b3	; 0x8fe9
	lda $b5	; 0x8feb
	bcs $8ff1	; 0x8fed
	bne $8fab	; 0x8fef
	rts	; 0x8ff1
argsv_all_files_to_media2	lda $10c0	; 0x8ff2
	pha	; 0x8ff5
	jsr $8ded	; 0x8ff6
	beq $9002	; 0x8ff9
	lda $10c0	; 0x8ffb
	pha	; 0x8ffe
	jsr $8dfa	; 0x8fff
	pla	; 0x9002
	sta $10c0	; 0x9003
	rts	; 0x9006
argsv_entry	cpy #$00	; 0x9007
	beq $901c	; 0x9009
	jsr remember_axy	; 0x900b
	cmp #$ff	; 0x900e
	beq $8ffb	; 0x9010
	cmp #$03	; 0x9012
	bcs $902d	; 0x9014
	lsr	; 0x9016
	bcc argsv_rdseqptr_or_filelen	; 0x9017
	jmp $92a7	; 0x9019
	jsr $8411	; 0x901c
	tay	; 0x901f
	iny	; 0x9020
	cpy #$03	; 0x9021
	bcs $902d	; 0x9023
	lda $9981,y	; 0x9025
	pha	; 0x9028
	lda $997e,y	; 0x9029
	pha	; 0x902c
	rts	; 0x902d
argsv_rdseqptr_or_filelen	jsr remember_axy	; 0x902e
	jsr $90a5	; 0x9031
	sty $10c2	; 0x9034
	asl	; 0x9037
	asl	; 0x9038
	adc $10c2	; 0x9039
	tay	; 0x903c
	lda $1110,y	; 0x903d
	sta $00,x	; 0x9040
	lda $1111,y	; 0x9042
	sta $01,x	; 0x9045
	lda $1112,y	; 0x9047
	sta $02,x	; 0x904a
	lda #$00	; 0x904c
	sta $03,x	; 0x904e
	rts	; 0x9050
is_handle_in_use	pha	; 0x9051
	stx $10c6	; 0x9052
	tya	; 0x9055
	and #$e0	; 0x9056
	sta $10c2	; 0x9058
	beq $9070	; 0x905b
	jsr lsr5	; 0x905d
	tay	; 0x9060
	lda #$00	; 0x9061
	sec	; 0x9063
	ror	; 0x9064
	dey	; 0x9065
	bne $9064	; 0x9066
	ldy $10c2	; 0x9068
	bit $10c0	; 0x906b
	bne $9073	; 0x906e
	pla	; 0x9070
	sec	; 0x9071
	rts	; 0x9072
	pla	; 0x9073
	clc	; 0x9074
	rts	; 0x9075
	pha	; 0x9076
	txa	; 0x9077
	jmp $907d	; 0x9078
	pha	; 0x907b
	tya	; 0x907c
	cmp #$10	; 0x907d
	bcc $9085	; 0x907f
	cmp #$18	; 0x9081
	bcc $9087	; 0x9083
	lda #$08	; 0x9085
	jsr $820a	; 0x9087
	tay	; 0x908a
	pla	; 0x908b
	rts	; 0x908c
	pha	; 0x908d
	tya	; 0x908e
	pha	; 0x908f
	txa	; 0x9090
	tay	; 0x9091
	jsr $90a5	; 0x9092
	tya	; 0x9095
	jsr $92f8	; 0x9096
	bne $909f	; 0x9099
	ldx #$ff	; 0x909b
	bne $90a1	; 0x909d
	ldx #$00	; 0x909f
	pla	; 0x90a1
	tay	; 0x90a2
	pla	; 0x90a3
	rts	; 0x90a4
	jsr $907b	; 0x90a5
	jsr is_handle_in_use	; 0x90a8
	bcc $90a4	; 0x90ab
err_channel	jsr brk100_errno	; 0x90ad
	!text $de, "Channel", $00
err_eof	jsr brk100_errno	; 0x90b9
	!text $df, "EOF", $00
bgetv_entry	jsr $8411	; 0x90c1
	jsr $90a5	; 0x90c4
	tya	; 0x90c7
	jsr $92f8	; 0x90c8
	bne $90e0	; 0x90cb
	lda $1117,y	; 0x90cd
	and #$10	; 0x90d0
	bne err_eof	; 0x90d2
	lda #$10	; 0x90d4
	jsr $913c	; 0x90d6
	ldx $10c6	; 0x90d9
	lda #$fe	; 0x90dc
	sec	; 0x90de
	rts	; 0x90df
	lda $1117,y	; 0x90e0
	bmi $90ef	; 0x90e3
	jsr set_file_drv	; 0x90e5
	jsr file_to_media_y	; 0x90e8
	sec	; 0x90eb
	jsr $9153	; 0x90ec
	lda $1110,y	; 0x90ef
	sta $bc	; 0x90f2
	lda $1113,y	; 0x90f4
	sta $bd	; 0x90f7
	ldy #$00	; 0x90f9
	lda ($bc),y	; 0x90fb
	pha	; 0x90fd
	ldy $10c2	; 0x90fe
	ldx $bc	; 0x9101
	inx	; 0x9103
	txa	; 0x9104
	sta $1110,y	; 0x9105
	bne $911e	; 0x9108
	clc	; 0x910a
	lda $1111,y	; 0x910b
	adc #$01	; 0x910e
	sta $1111,y	; 0x9110
	lda $1112,y	; 0x9113
	adc #$00	; 0x9116
	sta $1112,y	; 0x9118
	jsr $9141	; 0x911b
	clc	; 0x911e
	pla	; 0x911f
	rts	; 0x9120
	clc	; 0x9121
	lda $110f,y	; 0x9122
	adc $1111,y	; 0x9125
	sta $c5	; 0x9128
	sta $111c,y	; 0x912a
	lda $110d,y	; 0x912d
	and #$03	; 0x9130
	adc $1112,y	; 0x9132
	sta $c4	; 0x9135
	sta $111d,y	; 0x9137
	lda #$80	; 0x913a
	ora $1117,y	; 0x913c
	bne $9146	; 0x913f
	lda #$7f	; 0x9141
	and $1117,y	; 0x9143
	sta $1117,y	; 0x9146
	clc	; 0x9149
	rts	; 0x914a
file_to_media_y	lda $1117,y	; 0x914b
	and #$40	; 0x914e
	beq $918f	; 0x9150
	clc	; 0x9152
	php	; 0x9153
	jsr mmc_set_fdc_drv	; 0x9154
	ldy $10c2	; 0x9157
	lda $1113,y	; 0x915a
	sta $bf	; 0x915d
	jsr mmc_set_7475	; 0x915f
	lda #$00	; 0x9162
	sta $be	; 0x9164
	sta $c2	; 0x9166
	lda #$01	; 0x9168
	sta $c3	; 0x916a
	plp	; 0x916c
	bcs $9186	; 0x916d
	lda $111c,y	; 0x916f
	sta $c5	; 0x9172
	lda $111d,y	; 0x9174
	sta $c4	; 0x9177
	jsr $878f	; 0x9179
	ldy $10c2	; 0x917c
	lda #$bf	; 0x917f
	jsr $9143	; 0x9181
	bcc $918c	; 0x9184
	jsr $9121	; 0x9186
	jsr $87c6	; 0x9189
	ldy $10c2	; 0x918c
	rts	; 0x918f
	jmp err_channel	; 0x9190
	jmp err_locked	; 0x9193
err_file_readonly	jsr err_file	; 0x9196
	!text $c1, "read only", $00
	jsr remember_axy	; 0x91a4
	jmp $91b0	; 0x91a7
bputv_entry	jsr remember_axy	; 0x91aa
	jsr $90a5	; 0x91ad
	pha	; 0x91b0
	lda $110c,y	; 0x91b1
	bmi err_file_readonly	; 0x91b4
	lda $110e,y	; 0x91b6
	bmi $9193	; 0x91b9
	jsr set_file_drv	; 0x91bb
	tya	; 0x91be
	clc	; 0x91bf
	adc #$04	; 0x91c0
	jsr $92f8	; 0x91c2
	bne $923d	; 0x91c5
	jsr setup_save_to_media	; 0x91c7
	ldx $10c4	; 0x91ca
	sec	; 0x91cd
	lda $0f07,x	; 0x91ce
	sbc $0f0f,x	; 0x91d1
	pha	; 0x91d4
	lda $0f06,x	; 0x91d5
	sbc $0f0e,x	; 0x91d8
	and #$03	; 0x91db
	sta $10c3	; 0x91dd
	asl	; 0x91e0
	asl	; 0x91e1
	asl	; 0x91e2
	asl	; 0x91e3
	eor $0f0e,x	; 0x91e4
	and #$30	; 0x91e7
	eor $0f0e,x	; 0x91e9
	sta $0f0e,x	; 0x91ec
	lda $10c3	; 0x91ef
	cmp $111a,y	; 0x91f2
	bne $9222	; 0x91f5
	pla	; 0x91f7
	cmp $1119,y	; 0x91f8
	bne $9223	; 0x91fb
	sty $b4	; 0x91fd
	jsr $9920	; 0x91ff
	jsr $9076	; 0x9202
	cpy $b4	; 0x9205
	bne $920c	; 0x9207
	jsr $9911	; 0x9209
	ldy $b4	; 0x920c
	jsr update_catnfile	; 0x920e
err_cannot_extend	jsr brk100_errno	; 0x9211
	!text $bf, "Can't extend", $00
	pla	; 0x9222
	sta $0f0d,x	; 0x9223
	sta $1119,y	; 0x9226
	lda $10c3	; 0x9229
	sta $111a,y	; 0x922c
	lda #$00	; 0x922f
	sta $0f0c,x	; 0x9231
	jsr $8ab4	; 0x9234
	nop	; 0x9237
	nop	; 0x9238
	nop	; 0x9239
	ldy $10c2	; 0x923a
	lda $1117,y	; 0x923d
	bmi $9259	; 0x9240
	jsr file_to_media_y	; 0x9242
	lda $1114,y	; 0x9245
	bne $9255	; 0x9248
	tya	; 0x924a
	jsr $92f8	; 0x924b
	bne $9255	; 0x924e
	jsr $9121	; 0x9250
	bne $9259	; 0x9253
	sec	; 0x9255
	jsr $9153	; 0x9256
	lda $1110,y	; 0x9259
	sta $bc	; 0x925c
	lda $1113,y	; 0x925e
	sta $bd	; 0x9261
	pla	; 0x9263
	ldy #$00	; 0x9264
	sta ($bc),y	; 0x9266
	ldy $10c2	; 0x9268
	lda #$40	; 0x926b
	jsr $913c	; 0x926d
	inc $bc	; 0x9270
	lda $bc	; 0x9272
	sta $1110,y	; 0x9274
	bne $928c	; 0x9277
	jsr $9141	; 0x9279
	lda $1111,y	; 0x927c
	adc #$01	; 0x927f
	sta $1111,y	; 0x9281
	lda $1112,y	; 0x9284
	adc #$00	; 0x9287
	sta $1112,y	; 0x9289
	tya	; 0x928c
	jsr $92f8	; 0x928d
	bcc rts_92a6	; 0x9290
	lda #$20	; 0x9292
	jsr $913c	; 0x9294
	ldx #$02	; 0x9297
	lda $1110,y	; 0x9299
	sta $1114,y	; 0x929c
	iny	; 0x929f
	dex	; 0x92a0
	bpl $9299	; 0x92a1
	dey	; 0x92a3
	dey	; 0x92a4
	dey	; 0x92a5
rts_92a6	rts	; 0x92a6
	jsr remember_axy	; 0x92a7
	jsr $90a5	; 0x92aa
	jsr mmc_set_ptr_to_ext	; 0x92ad
	nop	; 0x92b0
	nop	; 0x92b1
	nop	; 0x92b2
	nop	; 0x92b3
	nop	; 0x92b4
	nop	; 0x92b5
	jsr $9310	; 0x92b6
	bcs $92c3	; 0x92b9
	lda #$00	; 0x92bb
	jsr $91a4	; 0x92bd
	jmp $92b6	; 0x92c0
	lda $00,x	; 0x92c3
	sta $1110,y	; 0x92c5
	lda $01,x	; 0x92c8
	sta $1111,y	; 0x92ca
	lda $02,x	; 0x92cd
	sta $1112,y	; 0x92cf
	lda #$6f	; 0x92d2
	jsr $9143	; 0x92d4
	lda $110f,y	; 0x92d7
	adc $1111,y	; 0x92da
	sta $10c5	; 0x92dd
	lda $110d,y	; 0x92e0
	and #$03	; 0x92e3
	adc $1112,y	; 0x92e5
	cmp $111d,y	; 0x92e8
	bne rts_92a6	; 0x92eb
	lda $10c5	; 0x92ed
	cmp $111c,y	; 0x92f0
	bne rts_92a6	; 0x92f3
	jmp $913a	; 0x92f5
	tax	; 0x92f8
	lda $1112,y	; 0x92f9
	cmp $1116,x	; 0x92fc
	bne $930f	; 0x92ff
	lda $1111,y	; 0x9301
	cmp $1115,x	; 0x9304
	bne $930f	; 0x9307
	lda $1110,y	; 0x9309
	cmp $1114,x	; 0x930c
	rts	; 0x930f
	lda $1114,y	; 0x9310
	cmp $00,x	; 0x9313
	lda $1115,y	; 0x9315
	sbc $01,x	; 0x9318
	lda $1116,y	; 0x931a
	sbc $02,x	; 0x931d
	rts	; 0x931f
	lda $b3	; 0x9320
	pha	; 0x9322
	lda #$ff	; 0x9323
	sta $10de	; 0x9325
	jsr print_splash	; 0x9328
	bcc $933b	; 0x9336
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
cmd_disk	jmp mmc_cmd_disk	; 0x9338
	lda #$00	; 0x933b
	tsx	; 0x933d
	sta $0106,x	; 0x933e
	lda #$06	; 0x9341
	jsr $8015	; 0x9343
	ldx #$0d	; 0x9346
	lda $9949,x	; 0x9348
	sta $0212,x	; 0x934b
	dex	; 0x934e
	bpl $9348	; 0x934f
	jsr $9928	; 0x9351
	sty temp+1	; 0x9354
	stx temp	; 0x9356
	ldx #$07	; 0x9358
	ldy #$1b	; 0x935a
	lda $993c,y	; 0x935c
	sta (temp),y	; 0x935f
	iny	; 0x9361
	lda $993c,y	; 0x9362
	sta (temp),y	; 0x9365
	iny	; 0x9367
	lda $f4	; 0x9368
	sta (temp),y	; 0x936a
	iny	; 0x936c
	dex	; 0x936d
	bne $935c	; 0x936e
	stx cur_drv	; 0x9370
	sty cur_drv_cat	; 0x9372
	ldx #$0f	; 0x9375
	jsr $992c	; 0x9377
	jsr $989e	; 0x937a
	ldy #$d4	; 0x937d
	lda (temp),y	; 0x937f
	bpl $93b2	; 0x9381
	ldy #$d5	; 0x9383
	lda (temp),y	; 0x9385
	bmi $93b0	; 0x9387
	jsr $988f	; 0x9389
	ldy #$00	; 0x938c
	lda (temp),y	; 0x938e
	cpy #$c0	; 0x9390
	bcc $9399	; 0x9392
	sta $1000,y	; 0x9394
	bcs $939c	; 0x9397
	sta $1100,y	; 0x9399
	dey	; 0x939c
	bne $938e	; 0x939d
	lda #data_ptr	; 0x939f
	tay	; 0x93a1
	pha	; 0x93a2
	lda #$3f	; 0x93a3
	jsr $9143	; 0x93a5
	pla	; 0x93a8
	sta $111d,y	; 0x93a9
	sbc #$1f	; 0x93ac
	bne $93a1	; 0x93ae
	pla	; 0x93b0
	rts	; 0x93b1
	lda #$ff	; 0x93b2
	sta (temp),y	; 0x93b4
	sta $10d4	; 0x93b6
	jsr $988f	; 0x93b9
	jsr $9924	; 0x93bc
	txa	; 0x93bf
	eor #$ff	; 0x93c0
	sta tube_present_if_zero	; 0x93c2
	lda #$24	; 0x93c5
	sta $10ca	; 0x93c7
	sta $10cc	; 0x93ca
	ldy #$00	; 0x93cd
	sty $10cb	; 0x93cf
	sty $10cd	; 0x93d2
	ldy #$00	; 0x93d5
	sty $10c0	; 0x93d7
	sty nmi_status	; 0x93da
	dey	; 0x93dd
	sty $10c8	; 0x93de
	sty $10c7	; 0x93e1
	sty $10de	; 0x93e4
	jsr mmc_initialise	; 0x93e7
	jmp $9404	; 0x93ea
	brk	; 0x93ed
	brk	; 0x93ee
	brk	; 0x93ef
	brk	; 0x93f0
	brk	; 0x93f1
	brk	; 0x93f2
	brk	; 0x93f3
	brk	; 0x93f4
	brk	; 0x93f5
	brk	; 0x93f6
	brk	; 0x93f7
	brk	; 0x93f8
	brk	; 0x93f9
	brk	; 0x93fa
	brk	; 0x93fb
	brk	; 0x93fc
	brk	; 0x93fd
	brk	; 0x93fe
	brk	; 0x93ff
	brk	; 0x9400
	brk	; 0x9401
	brk	; 0x9402
	brk	; 0x9403
	pla	; 0x9404
	bne $943b	; 0x9405
	jsr mmc_load_cur_drv_cat	; 0x9407
	ldy #$00	; 0x940a
	ldx #$00	; 0x940c
	lda $0f06	; 0x940e
	jsr lsr4	; 0x9411
	beq $943b	; 0x9414
	pha	; 0x9416
	ldx #$43	; 0x9417
	ldy #$99	; 0x9419
	jsr $86b8	; 0x941b
	jsr $80fe	; 0x941e
	jsr $8296	; 0x9421
	pla	; 0x9424
	bcs $943c	; 0x9425
err_file_not_found	jsr prtstr	; 0x9427
	!text "File not found", $0d, $0d, $ea
	rts	; 0x943b
	cmp #$02	; 0x943c
	bcc $944e	; 0x943e
	beq $9448	; 0x9440
	ldx #$41	; 0x9442
	ldy #$99	; 0x9444
	bne $9452	; 0x9446
	ldx #$43	; 0x9448
	ldy #$99	; 0x944a
	bne $9452	; 0x944c
	ldx #$39	; 0x944e
	ldy #$99	; 0x9450
	jmp OSCLI	; 0x9452
serv_claim_absworkspace	cmp #$01	; 0x9455
	bne $9460	; 0x9457
	cpy #$17	; 0x9459
	bcs $945f	; 0x945b
	ldy #$17	; 0x945d
	rts	; 0x945f
	cmp #$02	; 0x9460
	bne serv_autoboot	; 0x9462
	pha	; 0x9464
	tya	; 0x9465
	clc	; 0x9466
	sta temp+1	; 0x9467
	sta $0df0,x	; 0x9469
	adc #$02	; 0x946c
	pha	; 0x946e
	lda #$00	; 0x946f
	sta temp	; 0x9471
	ldy #$d4	; 0x9473
	sta (temp),y	; 0x9475
	iny	; 0x9477
	sta (temp),y	; 0x9478
	pla	; 0x947a
	tay	; 0x947b
	pla	; 0x947c
	rts	; 0x947d
serv_autoboot	cmp #$03	; 0x947e
	bne serv_unrecognised_cmd	; 0x9480
	sty $b3	; 0x9482
	jsr remember_axy	; 0x9484
	jmp mmc_start_opts	; 0x9487
	!byte $f4, $ff
	txa	; 0x948c
	bmi $9498	; 0x948d
	cmp #$32	; 0x948f
	bne $947d	; 0x9491
	lda #$78	; 0x9493
	jsr OSBYTE	; 0x9495
	jmp $9320	; 0x9498
serv_unrecognised_cmd	cmp #$04	; 0x949b
	bne serv_help	; 0x949d
	jsr remember_axy	; 0x949f
	ldx #$72	; 0x94a2
	jmp $8671	; 0x94a4
serv_help	cmp #$09	; 0x94a7
	bne serv_claim_stat_workspace	; 0x94a9
	jsr remember_axy	; 0x94ab
	jmp mmc_dhelp	; 0x94ae
	ldy #$c9	; 0x94b1
	ora $eed0	; 0x94b3
	tya	; 0x94b6
	inx	; 0x94b7
	ldy #$02	; 0x94b8
	jmp $99cb	; 0x94ba
serv_claim_stat_workspace	cmp #$0a	; 0x94bd
	bne serv_unrecognised_osword	; 0x94bf
	jsr remember_axy	; 0x94c1
	jsr $989e	; 0x94c4
	ldy #$d5	; 0x94c7
	lda (temp),y	; 0x94c9
	bpl $94e9	; 0x94cb
	ldy #$00	; 0x94cd
	cpy #$c0	; 0x94cf
	bcc $94d8	; 0x94d1
	lda $1000,y	; 0x94d3
	bcs $94db	; 0x94d6
	lda $1100,y	; 0x94d8
	sta (temp),y	; 0x94db
	dey	; 0x94dd
	bne $94cf	; 0x94de
	jsr argsv_all_files_to_media2	; 0x94e0
	ldy #$d5	; 0x94e3
	lda #$00	; 0x94e5
	sta (temp),y	; 0x94e7
	rts	; 0x94e9
serv_unrecognised_osword	cmp #$08	; 0x94ea
	bne $9503	; 0x94ec
	jsr $8411	; 0x94ee
	ldy $f0	; 0x94f1
	sty temp	; 0x94f3
	ldy $f1	; 0x94f5
	sty temp+1	; 0x94f7
	ldy $ef	; 0x94f9
	cpy #$7f	; 0x94fb
	bne $954b	; 0x94fd
	jmp mmc_osword_7f	; 0x94ff
	brk	; 0x9502
	jmp mmc_service	; 0x9503
	brk	; 0x9506
	brk	; 0x9507
	brk	; 0x9508
	brk	; 0x9509
	brk	; 0x950a
	brk	; 0x950b
	brk	; 0x950c
	brk	; 0x950d
	brk	; 0x950e
	brk	; 0x950f
	brk	; 0x9510
	brk	; 0x9511
	brk	; 0x9512
	brk	; 0x9513
	brk	; 0x9514
	brk	; 0x9515
	brk	; 0x9516
	brk	; 0x9517
	brk	; 0x9518
	brk	; 0x9519
	brk	; 0x951a
	brk	; 0x951b
	brk	; 0x951c
	brk	; 0x951d
	brk	; 0x951e
	brk	; 0x951f
	brk	; 0x9520
	brk	; 0x9521
	brk	; 0x9522
	brk	; 0x9523
	brk	; 0x9524
	brk	; 0x9525
	brk	; 0x9526
	brk	; 0x9527
	brk	; 0x9528
	brk	; 0x9529
	brk	; 0x952a
	brk	; 0x952b
	brk	; 0x952c
	brk	; 0x952d
	brk	; 0x952e
	brk	; 0x952f
	brk	; 0x9530
	brk	; 0x9531
	brk	; 0x9532
	brk	; 0x9533
	brk	; 0x9534
	brk	; 0x9535
	brk	; 0x9536
	brk	; 0x9537
	brk	; 0x9538
	brk	; 0x9539
	brk	; 0x953a
	brk	; 0x953b
	brk	; 0x953c
	brk	; 0x953d
	brk	; 0x953e
	brk	; 0x953f
	brk	; 0x9540
	brk	; 0x9541
	brk	; 0x9542
	brk	; 0x9543
	brk	; 0x9544
	brk	; 0x9545
	brk	; 0x9546
	brk	; 0x9547
	brk	; 0x9548
	brk	; 0x9549
	brk	; 0x954a
	cpy #$7d	; 0x954b
	bcc $957a	; 0x954d
	jsr $834d	; 0x954f
	jsr ld_cur_drv_cat	; 0x9552
	cpy #$7e	; 0x9555
	beq $9562	; 0x9557
	ldy #$00	; 0x9559
	lda $0f04	; 0x955b
	sta (temp),y	; 0x955e
	tya	; 0x9560
	rts	; 0x9561
	lda #$00	; 0x9562
	tay	; 0x9564
	sta (temp),y	; 0x9565
	iny	; 0x9567
	lda $0f07	; 0x9568
	sta (temp),y	; 0x956b
	iny	; 0x956d
	lda $0f06	; 0x956e
	and #$03	; 0x9571
	sta (temp),y	; 0x9573
	iny	; 0x9575
	lda #$00	; 0x9576
	sta (temp),y	; 0x9578
	rts	; 0x957a
filev_entry	jsr $8411	; 0x957b
	pha	; 0x957e
	jsr $8262	; 0x957f
	stx temp	; 0x9582
	stx $10dc	; 0x9584
	sty temp+1	; 0x9587
	sty $10dd	; 0x9589
	ldx #$00	; 0x958c
	ldy #$00	; 0x958e
	jsr $80ea	; 0x9590
	jsr $80da	; 0x9593
	cpy #$12	; 0x9596
	bne $9593	; 0x9598
	pla	; 0x959a
	tax	; 0x959b
	inx	; 0x959c
	cpx #$08	; 0x959d
	bcs $95a9	; 0x959f
	lda $998c,x	; 0x95a1
	pha	; 0x95a4
	lda $9984,x	; 0x95a5
	pha	; 0x95a8
	rts	; 0x95a9
fscv_entry	cmp #$09	; 0x95aa
	bcs $95a9	; 0x95ac
	stx $b5	; 0x95ae
	tax	; 0x95b0
	lda $9975,x	; 0x95b1
	pha	; 0x95b4
	lda $996c,x	; 0x95b5
	pha	; 0x95b8
	txa	; 0x95b9
	ldx $b5	; 0x95ba
	rts	; 0x95bc
	lda #$ff	; 0x95bd
	sta $02,x	; 0x95bf
	sta $03,x	; 0x95c1
	lda $10da	; 0x95c3
	sta $00,x	; 0x95c6
	lda $10db	; 0x95c8
	sta $01,x	; 0x95cb
	lda #$00	; 0x95cd
	rts	; 0x95cf
gbpbv_entry	cmp #$09	; 0x95d0
	bcs $95cf	; 0x95d2
	jsr remember_axy	; 0x95d4
	stx $107d	; 0x95d7
	sty $107e	; 0x95da
	tay	; 0x95dd
	tsx	; 0x95de
	lda #$00	; 0x95df
	jmp mmc_gbpb1	; 0x95e1
	lda $99ab,y	; 0x95e4
	sta $10d8	; 0x95e7
	lda $99b4,y	; 0x95ea
	sta $10d9	; 0x95ed
	lda $99bd,y	; 0x95f0
	lsr	; 0x95f3
	php	; 0x95f4
	lsr	; 0x95f5
	php	; 0x95f6
	sta $107f	; 0x95f7
	jsr $9756	; 0x95fa
	ldy #$0c	; 0x95fd
	lda ($b4),y	; 0x95ff
	sta $1060,y	; 0x9601
	dey	; 0x9604
	bpl $95ff	; 0x9605
	lda $1063	; 0x9607
	and $1064	; 0x960a
	ora tube_present_if_zero	; 0x960d
	clc	; 0x9610
	adc #$01	; 0x9611
	jmp mmc_gbpb2	; 0x9613
	nop	; 0x9616
	sta $1081	; 0x9617
	lda $107f	; 0x961a
	bcs $9626	; 0x961d
	ldx #$61	; 0x961f
	ldy #$10	; 0x9621
	jsr $0406	; 0x9623
	plp	; 0x9626
	bcs $962d	; 0x9627
	plp	; 0x9629
	jmp ($10d8)	; 0x962a
	ldx #$03	; 0x962d
	lda $1069,x	; 0x962f
	sta $b6,x	; 0x9632
	dex	; 0x9634
	bpl $962f	; 0x9635
	ldx #$b6	; 0x9637
	ldy $1060	; 0x9639
	lda #$00	; 0x963c
	plp	; 0x963e
	bcs $9644	; 0x963f
	jsr $92a7	; 0x9641
	jsr argsv_rdseqptr_or_filelen	; 0x9644
	ldx #$03	; 0x9647
	lda $b6,x	; 0x9649
	sta $1069,x	; 0x964b
	dex	; 0x964e
	bpl $9649	; 0x964f
	jsr $9748	; 0x9651
	bmi $9663	; 0x9654
	ldy $1060	; 0x9656
	jsr $962a	; 0x9659
	bcs $966b	; 0x965c
	ldx #$09	; 0x965e
	jsr $973c	; 0x9660
	ldx #$05	; 0x9663
	jsr $973c	; 0x9665
	bne $9656	; 0x9668
	clc	; 0x966a
	php	; 0x966b
	jsr $9748	; 0x966c
	ldx #$05	; 0x966f
	jsr $973c	; 0x9671
	ldy #$0c	; 0x9674
	jsr $9756	; 0x9676
	lda $1060,y	; 0x9679
	sta ($b4),y	; 0x967c
	dey	; 0x967e
	bpl $9679	; 0x967f
	plp	; 0x9681
	rts	; 0x9682
	jsr $834d	; 0x9683
	jsr mmc_load_cur_drv_cat	; 0x9686
	lda #$95	; 0x9689
	sta $10d8	; 0x968b
	lda #$96	; 0x968e
	sta $10d9	; 0x9690
	bne $9651	; 0x9693
	ldy $1069	; 0x9695
	cpy $0f05	; 0x9698
	bcs $96c5	; 0x969b
	lda $0e0f,y	; 0x969d
	jsr $82ee	; 0x96a0
	eor directory_param	; 0x96a3
	bcs $96a9	; 0x96a5
	and #$df	; 0x96a7
	and #$7f	; 0x96a9
	beq $96b2	; 0x96ab
	jsr $8210	; 0x96ad
	bne $9698	; 0x96b0
	lda #$07	; 0x96b2
	jsr $976a	; 0x96b4
	sta temp	; 0x96b7
	lda $0e08,y	; 0x96b9
	jsr $976a	; 0x96bc
	iny	; 0x96bf
	dec temp	; 0x96c0
	bne $96b9	; 0x96c2
	clc	; 0x96c4
	sty $1069	; 0x96c5
	lda $0f04	; 0x96c8
	sta $1060	; 0x96cb
	rts	; 0x96ce
	jsr $834d	; 0x96cf
	jsr mmc_load_cur_drv_cat	; 0x96d2
	lda #$0c	; 0x96d5
	jsr $976a	; 0x96d7
	ldy #$00	; 0x96da
	lda buf,y	; 0x96dc
	jsr $976a	; 0x96df
	iny	; 0x96e2
	cpy #$08	; 0x96e3
	bne $96dc	; 0x96e5
	lda $0ef8,y	; 0x96e7
	jsr $976a	; 0x96ea
	iny	; 0x96ed
	cpy #$0c	; 0x96ee
	bne $96e7	; 0x96f0
	lda $0f06	; 0x96f2
	jsr lsr4	; 0x96f5
	jsr $976a	; 0x96f8
	lda cur_drv	; 0x96fb
	jmp $976a	; 0x96fd
	jsr $9761	; 0x9700
	lda $10cb	; 0x9703
	ora #$30	; 0x9706
	jsr $976a	; 0x9708
	jsr $9761	; 0x970b
	lda $10ca	; 0x970e
	jmp $976a	; 0x9711
	jsr $9761	; 0x9714
	lda $10cd	; 0x9717
	ora #$30	; 0x971a
	jsr $976a	; 0x971c
	jsr $9761	; 0x971f
	lda $10cc	; 0x9722
	jmp $976a	; 0x9725
	pha	; 0x9728
	lda $1061	; 0x9729
	sta err_ptr	; 0x972c
	lda $1062	; 0x972e
	sta err_ptr+1	; 0x9731
	ldx #$00	; 0x9733
	pla	; 0x9735
	rts	; 0x9736
	jsr remember_axy	; 0x9737
	ldx #$01	; 0x973a
	ldy #$04	; 0x973c
	inc $1060,x	; 0x973e
	bne $9747	; 0x9741
	inx	; 0x9743
	dey	; 0x9744
	bne $973e	; 0x9745
	rts	; 0x9747
	ldx #$03	; 0x9748
	lda #$ff	; 0x974a
	eor $1065,x	; 0x974c
	sta $1065,x	; 0x974f
	dex	; 0x9752
	bpl $974a	; 0x9753
	rts	; 0x9755
	lda $107d	; 0x9756
	sta $b4	; 0x9759
	lda $107e	; 0x975b
	sta $b5	; 0x975e
	rts	; 0x9760
	lda #$01	; 0x9761
	bne $976a	; 0x9763
	jsr bgetv_entry	; 0x9765
	bcs $9760	; 0x9768
	bit $1081	; 0x976a
	bpl $9775	; 0x976d
	sta TUBE_DAT	; 0x976f
	jmp $9737	; 0x9772
	jsr $9728	; 0x9775
	sta (err_ptr,x)	; 0x9778
	jmp $9737	; 0x977a
	jsr $9785	; 0x977d
	jsr bputv_entry	; 0x9780
	clc	; 0x9783
	rts	; 0x9784
	bit $1081	; 0x9785
	bpl $9790	; 0x9788
	lda TUBE_DAT	; 0x978a
	jmp $9737	; 0x978d
	jsr $9728	; 0x9790
	lda (err_ptr,x)	; 0x9793
	jmp $9737	; 0x9795
	bit $10c8	; 0x9798
	bmi $97a0	; 0x979b
	dec $10c8	; 0x979d
	rts	; 0x97a0
	jsr $985a	; 0x97a1
	jsr $837e	; 0x97a4
	lda #$01	; 0x97a7
	rts	; 0x97a9
	jsr $9837	; 0x97aa
	jsr $837e	; 0x97ad
	jsr $82d1	; 0x97b0
	bcc $97d9	; 0x97b3
	jsr $9837	; 0x97b5
	jsr $97df	; 0x97b8
	jsr $97fb	; 0x97bb
	bvc $97d6	; 0x97be
	jsr $9837	; 0x97c0
	jsr $97df	; 0x97c3
	bvc $97d9	; 0x97c6
	jsr $9837	; 0x97c8
	jsr $97fb	; 0x97cb
	bvc $97d9	; 0x97ce
	jsr $985a	; 0x97d0
	jsr $984f	; 0x97d3
	jsr $981e	; 0x97d6
	jsr goto_save_cat	; 0x97d9
	lda #$01	; 0x97dc
	rts	; 0x97de
	jsr remember_axy	; 0x97df
	ldy #$02	; 0x97e2
	lda (temp),y	; 0x97e4
	sta $0f08,x	; 0x97e6
	iny	; 0x97e9
	lda (temp),y	; 0x97ea
	sta $0f09,x	; 0x97ec
	iny	; 0x97ef
	lda (temp),y	; 0x97f0
	asl	; 0x97f2
	asl	; 0x97f3
	eor $0f0e,x	; 0x97f4
	and #$0c	; 0x97f7
	bpl $9816	; 0x97f9
	jsr remember_axy	; 0x97fb
	ldy #$06	; 0x97fe
	lda (temp),y	; 0x9800
	sta $0f0a,x	; 0x9802
	iny	; 0x9805
	lda (temp),y	; 0x9806
	sta $0f0b,x	; 0x9808
	iny	; 0x980b
	lda (temp),y	; 0x980c
	ror	; 0x980e
	ror	; 0x980f
	ror	; 0x9810
	eor $0f0e,x	; 0x9811
	and #$c0	; 0x9814
	eor $0f0e,x	; 0x9816
	sta $0f0e,x	; 0x9819
	clv	; 0x981c
	rts	; 0x981d
	jsr remember_axy	; 0x981e
	ldy #$0e	; 0x9821
	lda (temp),y	; 0x9823
	and #$0a	; 0x9825
	beq $982b	; 0x9827
	lda #$80	; 0x9829
	eor $0e0f,x	; 0x982b
	and #$80	; 0x982e
	eor $0e0f,x	; 0x9830
	sta $0e0f,x	; 0x9833
	rts	; 0x9836
	jsr $9864	; 0x9837
	bcc $985f	; 0x983a
	lda $0e0f,y	; 0x983c
	bpl $9863	; 0x983f
err_locked	jsr err_file	; 0x9841
	!text $c3, "locked", $00
	jsr $983c	; 0x984c
	jsr remember_axy	; 0x984f
	jsr $8f9e	; 0x9852
	bcc $9878	; 0x9855
	jmp err_file_open	; 0x9857
	jsr $9864	; 0x985a
	bcs $9878	; 0x985d
	pla	; 0x985f
	pla	; 0x9860
	lda #$00	; 0x9861
	rts	; 0x9863
	jsr $8106	; 0x9864
	jsr $8296	; 0x9867
	bcc $9878	; 0x986a
	tya	; 0x986c
	tax	; 0x986d
	lda $10dc	; 0x986e
	sta temp	; 0x9871
	lda $10dd	; 0x9873
	sta temp+1	; 0x9876
	rts	; 0x9878
	lda #$83	; 0x9879
	jsr OSBYTE	; 0x987b
	sty $10d0	; 0x987e
	lda #$84	; 0x9881
	jsr OSBYTE	; 0x9883
	tya	; 0x9886
	sec	; 0x9887
	sbc $10d0	; 0x9888
	sta $10d1	; 0x988b
	rts	; 0x988e
	ldx #$0a	; 0x988f
	jsr $992c	; 0x9891
	jsr $989e	; 0x9894
	ldy #$d5	; 0x9897
	lda #$ff	; 0x9899
	sta (temp),y	; 0x989b
	rts	; 0x989d
	pha	; 0x989e
	ldx $f4	; 0x989f
	lda #$00	; 0x98a1
	sta temp	; 0x98a3
	lda $0df0,x	; 0x98a5
	sta temp+1	; 0x98a8
	pla	; 0x98aa
	rts	; 0x98ab
	brk	; 0x98ac
	brk	; 0x98ad
	brk	; 0x98ae
	brk	; 0x98af
	brk	; 0x98b0
	brk	; 0x98b1
	brk	; 0x98b2
	brk	; 0x98b3
	brk	; 0x98b4
	brk	; 0x98b5
	brk	; 0x98b6
	brk	; 0x98b7
	brk	; 0x98b8
	brk	; 0x98b9
	brk	; 0x98ba
	brk	; 0x98bb
	brk	; 0x98bc
	brk	; 0x98bd
	brk	; 0x98be
	brk	; 0x98bf
	brk	; 0x98c0
	brk	; 0x98c1
	brk	; 0x98c2
	brk	; 0x98c3
	brk	; 0x98c4
	brk	; 0x98c5
	brk	; 0x98c6
	brk	; 0x98c7
	brk	; 0x98c8
	brk	; 0x98c9
	brk	; 0x98ca
	brk	; 0x98cb
	brk	; 0x98cc
	brk	; 0x98cd
	brk	; 0x98ce
	brk	; 0x98cf
	brk	; 0x98d0
	brk	; 0x98d1
	brk	; 0x98d2
	brk	; 0x98d3
	brk	; 0x98d4
	brk	; 0x98d5
	brk	; 0x98d6
	brk	; 0x98d7
	brk	; 0x98d8
	brk	; 0x98d9
	brk	; 0x98da
	brk	; 0x98db
	brk	; 0x98dc
	brk	; 0x98dd
	brk	; 0x98de
	brk	; 0x98df
	brk	; 0x98e0
	brk	; 0x98e1
	brk	; 0x98e2
	brk	; 0x98e3
	brk	; 0x98e4
	brk	; 0x98e5
	brk	; 0x98e6
	brk	; 0x98e7
	brk	; 0x98e8
	brk	; 0x98e9
	brk	; 0x98ea
	brk	; 0x98eb
	brk	; 0x98ec
	brk	; 0x98ed
	brk	; 0x98ee
	brk	; 0x98ef
	brk	; 0x98f0
	brk	; 0x98f1
	brk	; 0x98f2
	brk	; 0x98f3
	brk	; 0x98f4
	brk	; 0x98f5
	brk	; 0x98f6
	brk	; 0x98f7
	brk	; 0x98f8
	brk	; 0x98f9
	brk	; 0x98fa
	brk	; 0x98fb
	brk	; 0x98fc
	brk	; 0x98fd
	brk	; 0x98fe
	brk	; 0x98ff
	brk	; 0x9900
	brk	; 0x9901
	brk	; 0x9902
	brk	; 0x9903
	brk	; 0x9904
	rts	; 0x9905
	jsr remember_axy	; 0x9906
	lda #$0f	; 0x9909
	ldx #$01	; 0x990b
	ldy #$00	; 0x990d
	beq $9936	; 0x990f
	lda #filename_param	; 0x9911
	ldx #$00	; 0x9913
	beq $990d	; 0x9915
osbyte_03a	tax	; 0x9917
osbyte_03x	lda #$03	; 0x9918
	bne $9936	; 0x991a
osbyte_ec	lda #$ec	; 0x991c
	bne $9932	; 0x991e
	lda #filename_param	; 0x9920
	bne $9932	; 0x9922
	lda #$ea	; 0x9924
	bne $9932	; 0x9926
	lda #$a8	; 0x9928
	bne $9932	; 0x992a
	lda #$8f	; 0x992c
	bne $9936	; 0x992e
	lda #$ff	; 0x9930
	ldx #$00	; 0x9932
	ldy #$ff	; 0x9934
	jmp OSBYTE	; 0x9936
	!text "L.!BOOT", $0d, "E.!BOOT", $0d
	!byte $1b, $ff, $1e, $ff, $21, $ff, $24, $ff, $27, $ff, $2a, $ff, $2d, $ff, $7b, $95, $00, $07, $90, $00, $c1, $90, $00, $aa, $91, $00, $d0, $95, $00, $93, $8e, $00, $aa, $95, $00, $1b, $8c, $d3, $6b, $d3, $1d, $e1, $dc, $97, $89, $90, $87, $86, $87, $84, $8d, $8d, $97, $f1, $3c, $bc, $8f, $9b, $95, $93, $85, $b4, $bf, $c7, $cf, $a0, $a9, $87, $87, $97, $97, $97, $97, $97, $97, $12, $32, $5d, $cd, $a2, $bd, $87, $8d, $8d, $8d, $8d, $8d, $8d, $8d, $74, $54, $00, $0f, $1a, $0f, $1a, $63, $43, $b7, $7d, $7d, $65, $65, $cf, $00, $14, $83, $85, $97, $97, $97, $97, $96, $97, $97, $96, $04, $02, $03, $06, $07, $04, $04, $04, $04
cmd_dfs	tya	; 0x99c6
	ldx #$ff	; 0x99c7
	ldy #$0e	; 0x99c9
	pha	; 0x99cb
	jsr prtstr	; 0x99cc
	!text $0d, "DFS 0.90", $0d
	stx err_ptr	; 0x99d9
	jsr prt_2spc	; 0x99db
	jsr $9a19	; 0x99de
	jsr prt_newline	; 0x99e1
	dey	; 0x99e4
	bne $99db	; 0x99e5
	pla	; 0x99e7
	tay	; 0x99e8
	ldx #data_ptr	; 0x99e9
	jmp $8671	; 0x99eb
cmd_utils	tya	; 0x99ee
	ldx #$74	; 0x99ef
	ldy #$05	; 0x99f1
	bne $99cb	; 0x99f3
cmd_nothelptbl	jsr $86bf	; 0x99f5
	beq $9a5a	; 0x99f8
	jsr GSREAD	; 0x99fa
	bcc $99fa	; 0x99fd
	bcs $99e9	; 0x99ff
init_param	jsr $86bf	; 0x9a01
	bne $9a5a	; 0x9a04
	jsr brk100_errno	; 0x9a06
	!text $dc, "Syntax: "
	nop	; 0x9a12
	jsr $9a19	; 0x9a13
	jmp prtstr_brk	; 0x9a16
	ldx err_ptr	; 0x9a19
	inx	; 0x9a1b
	lda cmdtxt_access,x	; 0x9a1c
	bmi $9a27	; 0x9a1f
	jsr prtchr	; 0x9a21
	jmp $9a1b	; 0x9a24
	inx	; 0x9a27
	inx	; 0x9a28
	stx err_ptr	; 0x9a29
	lda cmdtxt_access,x	; 0x9a2b
	jsr $9a34	; 0x9a2e
	jsr lsr4	; 0x9a31
	jsr remember_axy	; 0x9a34
	and #$0f	; 0x9a37
	beq $9a5a	; 0x9a39
	tay	; 0x9a3b
	lda #$20	; 0x9a3c
	jsr prtchr	; 0x9a3e
	ldx #$00	; 0x9a41
	lda parameter_table,x	; 0x9a43
	beq $9a4b	; 0x9a46
	inx	; 0x9a48
	bne $9a43	; 0x9a49
	dey	; 0x9a4b
	bne $9a48	; 0x9a4c
	inx	; 0x9a4e
	lda parameter_table,x	; 0x9a4f
	beq $9a5a	; 0x9a52
	jsr prtchr	; 0x9a54
	jmp $9a4e	; 0x9a57
	rts	; 0x9a5a
parameter_table	!text $00, "<fsp>", $00, "<afsp>", $00, "(L)", $00, "<src drv>", $00, "<dest drv>", $00, "<dest drv> <afsp>", $00, "<old fsp>", $00, "<new fsp>", $00, "(<dir>)", $00, "(<drv>)", $00, "<title>", $00
cmd_compact	jsr $8358	; 0x9ac0
	jsr prtstr	; 0x9ac3
	!text "Compacting drive "
	sta $10d2	; 0x9ad7
	sta $10d3	; 0x9ada
	jsr prthex_ln	; 0x9add
	jsr prt_newline	; 0x9ae0
	ldy #$00	; 0x9ae3
	jsr update_catnfile	; 0x9ae5
	jsr $9879	; 0x9ae8
	jsr ld_cur_drv_cat	; 0x9aeb
	ldy $0f05	; 0x9aee
	sty $cc	; 0x9af1
	lda #$02	; 0x9af3
	sta $ca	; 0x9af5
	lda #$00	; 0x9af7
	sta $cb	; 0x9af9
	ldy $cc	; 0x9afb
	jsr $8219	; 0x9afd
	cpy #$f8	; 0x9b00
	bne $9b40	; 0x9b02
	jsr prtstr	; 0x9b04
	!text "Disk compacted "
	nop	; 0x9b16
	sec	; 0x9b17
	lda $0f07	; 0x9b18
	sbc $ca	; 0x9b1b
	pha	; 0x9b1d
	lda $0f06	; 0x9b1e
	and #$03	; 0x9b21
	sbc $cb	; 0x9b23
	jsr prthex_ln	; 0x9b25
	pla	; 0x9b28
	jsr prthex	; 0x9b29
	jsr prtstr	; 0x9b2c
	!text " free sectors", $0d
	lda #$04	; 0x9b3d
	rts	; 0x9b3f
	sty $cc	; 0x9b40
	jsr $82fc	; 0x9b42
	ldy $cc	; 0x9b45
	lda $0f0e,y	; 0x9b47
	and #$30	; 0x9b4a
	ora $0f0d,y	; 0x9b4c
	ora $0f0c,y	; 0x9b4f
	beq $9bb5	; 0x9b52
	lda #$00	; 0x9b54
	sta $be	; 0x9b56
	sta $c2	; 0x9b58
	lda #$ff	; 0x9b5a
	clc	; 0x9b5c
	adc $0f0c,y	; 0x9b5d
	lda #$00	; 0x9b60
	adc $0f0d,y	; 0x9b62
	sta $c6	; 0x9b65
	lda $0f0e,y	; 0x9b67
	php	; 0x9b6a
	jsr lsr4_and3	; 0x9b6b
	plp	; 0x9b6e
	adc #$00	; 0x9b6f
	sta filename_param	; 0x9b71
	lda $0f0f,y	; 0x9b73
	sta $c8	; 0x9b76
	lda $0f0e,y	; 0x9b78
	and #$03	; 0x9b7b
	sta $c9	; 0x9b7d
	cmp $cb	; 0x9b7f
	bne $9b97	; 0x9b81
	lda $c8	; 0x9b83
	cmp $ca	; 0x9b85
	bne $9b97	; 0x9b87
	clc	; 0x9b89
	adc $c6	; 0x9b8a
	sta $ca	; 0x9b8c
	lda $cb	; 0x9b8e
	adc filename_param	; 0x9b90
	sta $cb	; 0x9b92
	jmp $9bb5	; 0x9b94
	lda $ca	; 0x9b97
	sta $0f0f,y	; 0x9b99
	lda $0f0e,y	; 0x9b9c
	and #$fc	; 0x9b9f
	ora $cb	; 0x9ba1
	sta $0f0e,y	; 0x9ba3
	lda #$00	; 0x9ba6
	sta $a8	; 0x9ba8
	sta $a9	; 0x9baa
	jsr $8ab4	; 0x9bac
	jsr $9e06	; 0x9baf
	jsr ld_cur_drv_cat	; 0x9bb2
	ldy $cc	; 0x9bb5
	jsr $8301	; 0x9bb7
	jmp $9afb	; 0x9bba
	bit $10c8	; 0x9bbd
	bpl $9c37	; 0x9bc0
	jsr brk100_errno	; 0x9bc2
	!text $bd, "Not enabled", $00
	jsr $86bf	; 0x9bd2
	bne $9bda	; 0x9bd5
	jmp $9a06	; 0x9bd7
	jsr get_drv_num	; 0x9bda
	sta $10d2	; 0x9bdd
	jsr $86bf	; 0x9be0
	beq $9bd7	; 0x9be3
	jsr get_drv_num	; 0x9be5
	sta $10d3	; 0x9be8
	tya	; 0x9beb
	pha	; 0x9bec
	lda #$00	; 0x9bed
	sta $a9	; 0x9bef
	lda $10d3	; 0x9bf1
	cmp $10d2	; 0x9bf4
	bne $9bff	; 0x9bf7
	lda #$ff	; 0x9bf9
	sta $a9	; 0x9bfb
	sta $aa	; 0x9bfd
	jsr $9879	; 0x9bff
	jsr prtstr	; 0x9c02
	!text "Copying from drive "
	lda $10d2	; 0x9c18
	jsr prthex_ln	; 0x9c1b
	jsr prtstr	; 0x9c1e
	!text " to drive "
	lda $10d3	; 0x9c2b
	jsr prthex_ln	; 0x9c2e
	jsr prt_newline	; 0x9c31
	pla	; 0x9c34
	tay	; 0x9c35
	clc	; 0x9c36
	rts	; 0x9c37
	jsr remember_axy	; 0x9c38
	bit $a9	; 0x9c3b
	bpl $9c4a	; 0x9c3d
	lda #$00	; 0x9c3f
	beq $9c4d	; 0x9c41
	jsr remember_axy	; 0x9c43
	bit $a9	; 0x9c46
	bmi $9c4b	; 0x9c48
	rts	; 0x9c4a
	lda #$80	; 0x9c4b
	cmp $aa	; 0x9c4d
	beq $9c4a	; 0x9c4f
	sta $aa	; 0x9c51
	jsr prtstr	; 0x9c53
	!text "Insert "
	nop	; 0x9c5d
	bit $aa	; 0x9c5e
	bmi $9c6d	; 0x9c60
	jsr prtstr	; 0x9c62
	!text "source"
	bcc $9c7c	; 0x9c6b
	jsr prtstr	; 0x9c6d
	!text "destination"
	nop	; 0x9c7b
	jsr prtstr	; 0x9c7c
	!text " disk and hit a key"
	nop	; 0x9c92
	jsr $9906	; 0x9c93
	jsr OSRDCH	; 0x9c96
	bcs $9cb4	; 0x9c99
	jmp prt_newline	; 0x9c9b
	jsr $9906	; 0x9c9e
	jsr OSRDCH	; 0x9ca1
	bcs $9cb4	; 0x9ca4
	and #$5f	; 0x9ca6
	cmp #$59	; 0x9ca8
	php	; 0x9caa
	beq $9caf	; 0x9cab
	lda #$4e	; 0x9cad
	jsr prtchr	; 0x9caf
	plp	; 0x9cb2
	rts	; 0x9cb3
	ldx $b6	; 0x9cb4
	txs	; 0x9cb6
	rts	; 0x9cb7
err_disk_full2	jmp err_disk_full	; 0x9cb8
	jsr $9bbd	; 0x9cbb
	jsr $9bd2	; 0x9cbe
	lda #$00	; 0x9cc1
	sta $c9	; 0x9cc3
	sta $cb	; 0x9cc5
	sta $ca	; 0x9cc7
	sta $c8	; 0x9cc9
	sta $a8	; 0x9ccb
	jsr $9c38	; 0x9ccd
	lda $10d2	; 0x9cd0
	sta cur_drv	; 0x9cd3
	jsr mmc_load_cur_drv_cat	; 0x9cd5
	lda $0f07	; 0x9cd8
	sta $c6	; 0x9cdb
	lda $0f06	; 0x9cdd
	and #$03	; 0x9ce0
	sta filename_param	; 0x9ce2
	lda $0f06	; 0x9ce4
	and #$f0	; 0x9ce7
	sta $10d8	; 0x9ce9
	jsr $9c43	; 0x9cec
	lda $10d3	; 0x9cef
	sta cur_drv	; 0x9cf2
	jsr mmc_load_cur_drv_cat	; 0x9cf4
	lda $0f06	; 0x9cf7
	and #$03	; 0x9cfa
	cmp filename_param	; 0x9cfc
	bcc err_disk_full2	; 0x9cfe
	bne $9d09	; 0x9d00
	lda $0f07	; 0x9d02
	cmp $c6	; 0x9d05
	bcc err_disk_full2	; 0x9d07
	jsr $9e06	; 0x9d09
	lda $0f06	; 0x9d0c
	pha	; 0x9d0f
	lda $0f07	; 0x9d10
	pha	; 0x9d13
	jsr mmc_load_cur_drv_cat	; 0x9d14
	pla	; 0x9d17
	sta $0f07	; 0x9d18
	pla	; 0x9d1b
	and #$0f	; 0x9d1c
	ora $10d8	; 0x9d1e
	sta $0f06	; 0x9d21
	jmp $8ab4	; 0x9d24
	jsr $825e	; 0x9d27
	jsr $9bd2	; 0x9d2a
	jsr $86bf	; 0x9d2d
	bne $9d35	; 0x9d30
	jmp $9a06	; 0x9d32
	jsr $80fe	; 0x9d35
	jsr $9c38	; 0x9d38
	lda $10d2	; 0x9d3b
	jsr $877e	; 0x9d3e
	jsr $8296	; 0x9d41
	bcs $9d49	; 0x9d44
	jmp $8276	; 0x9d46
	sty $ab	; 0x9d49
	jsr $8301	; 0x9d4b
	ldx #$00	; 0x9d4e
	lda filename_param,x	; 0x9d50
	sta $1058,x	; 0x9d52
	lda $0e08,y	; 0x9d55
	sta filename_param,x	; 0x9d58
	sta $1050,x	; 0x9d5a
	lda $0f08,y	; 0x9d5d
	sta $bd,x	; 0x9d60
	sta $1047,x	; 0x9d62
	inx	; 0x9d65
	iny	; 0x9d66
	cpx #$08	; 0x9d67
	bne $9d50	; 0x9d69
	lda $c3	; 0x9d6b
	jsr lsr4_and3	; 0x9d6d
	sta $c5	; 0x9d70
	lda $c1	; 0x9d72
	clc	; 0x9d74
	adc #$ff	; 0x9d75
	lda $c2	; 0x9d77
	adc #$00	; 0x9d79
	sta $c6	; 0x9d7b
	lda $c5	; 0x9d7d
	adc #$00	; 0x9d7f
	sta filename_param	; 0x9d81
	lda $104e	; 0x9d83
	sta $c8	; 0x9d86
	lda $104d	; 0x9d88
	and #$03	; 0x9d8b
	sta $c9	; 0x9d8d
	lda #$ff	; 0x9d8f
	sta $a8	; 0x9d91
	jsr $9e06	; 0x9d93
	jsr $9c38	; 0x9d96
	lda $10d2	; 0x9d99
	jsr $877e	; 0x9d9c
	jsr ld_cur_drv_cat	; 0x9d9f
	ldx #$07	; 0x9da2
	lda $1058,x	; 0x9da4
	sta filename_param,x	; 0x9da7
	dex	; 0x9da9
	bpl $9da4	; 0x9daa
	ldy $ab	; 0x9dac
	sty $10ce	; 0x9dae
	jsr $829d	; 0x9db1
	bcs $9d49	; 0x9db4
	rts	; 0x9db6
	jsr $9df5	; 0x9db7
	jsr $9c43	; 0x9dba
	lda $10d3	; 0x9dbd
	sta cur_drv	; 0x9dc0
	lda directory_param	; 0x9dc2
	pha	; 0x9dc4
	jsr ld_cur_drv_cat	; 0x9dc5
	jsr $8296	; 0x9dc8
	bcc $9dd0	; 0x9dcb
	jsr $82d1	; 0x9dcd
	pla	; 0x9dd0
	sta directory_param	; 0x9dd1
	jsr $8a3f	; 0x9dd3
	jsr $8a56	; 0x9dd6
	lda $c4	; 0x9dd9
	jsr lsr4_and3	; 0x9ddb
	sta $c6	; 0x9dde
	jsr $899d	; 0x9de0
	lda $c4	; 0x9de3
	and #$03	; 0x9de5
	pha	; 0x9de7
	lda $c5	; 0x9de8
	pha	; 0x9dea
	jsr $9df5	; 0x9deb
	pla	; 0x9dee
	sta $ca	; 0x9def
	pla	; 0x9df1
	sta $cb	; 0x9df2
	rts	; 0x9df4
	ldx #$11	; 0x9df5
	lda $1045,x	; 0x9df7
	ldy $bc,x	; 0x9dfa
	sta $bc,x	; 0x9dfc
	tya	; 0x9dfe
	sta $1045,x	; 0x9dff
	dex	; 0x9e02
	bpl $9df7	; 0x9e03
	rts	; 0x9e05
	jsr mmc_set_7475	; 0x9e06
	lda #$00	; 0x9e09
	sta $be	; 0x9e0b
	sta $c2	; 0x9e0d
move_file_loop	lda $c6	; 0x9e0f
	tay	; 0x9e11
	cmp $10d1	; 0x9e12
	lda filename_param	; 0x9e15
	sbc #$00	; 0x9e17
	bcc $9e1e	; 0x9e19
	ldy $10d1	; 0x9e1b
	sty $c3	; 0x9e1e
	lda $c8	; 0x9e20
	sta $c5	; 0x9e22
	lda $c9	; 0x9e24
	sta $c4	; 0x9e26
	lda $10d0	; 0x9e28
	sta $bf	; 0x9e2b
	lda $10d2	; 0x9e2d
	sta cur_drv	; 0x9e30
	jsr $9c38	; 0x9e32
	jsr mmc_set_fdc_drv	; 0x9e35
	jsr $87c6	; 0x9e38
	lda $10d3	; 0x9e3b
	sta cur_drv	; 0x9e3e
	bit $a8	; 0x9e40
	bpl $9e4b	; 0x9e42
	jsr $9db7	; 0x9e44
	lda #$00	; 0x9e47
	sta $a8	; 0x9e49
	lda $ca	; 0x9e4b
	sta $c5	; 0x9e4d
	lda $cb	; 0x9e4f
	sta $c4	; 0x9e51
	lda $10d0	; 0x9e53
	sta $bf	; 0x9e56
	jsr $9c43	; 0x9e58
	jsr mmc_set_fdc_drv	; 0x9e5b
	jsr $878f	; 0x9e5e
	lda $c3	; 0x9e61
	clc	; 0x9e63
	adc $ca	; 0x9e64
	sta $ca	; 0x9e66
	bcc $9e6c	; 0x9e68
	inc $cb	; 0x9e6a
	lda $c3	; 0x9e6c
	clc	; 0x9e6e
	adc $c8	; 0x9e6f
	sta $c8	; 0x9e71
	bcc $9e77	; 0x9e73
	inc $c9	; 0x9e75
	sec	; 0x9e77
	lda $c6	; 0x9e78
	sbc $c3	; 0x9e7a
	sta $c6	; 0x9e7c
	bcs $9e82	; 0x9e7e
	dec filename_param	; 0x9e80
	ora filename_param	; 0x9e82
	bne move_file_loop	; 0x9e84
	rts	; 0x9e86
	jsr ltrim	; 0x9e87
	lda #$00	; 0x9e8a
	beq $9e93	; 0x9e8c
	jsr ltrim	; 0x9e8e
	lda #$ff	; 0x9e91
	sta $ab	; 0x9e93
	lda #$c0	; 0x9e95
	jsr OSFIND	; 0x9e97
	tay	; 0x9e9a
	lda #$0d	; 0x9e9b
	cpy #$00	; 0x9e9d
	bne $9ebf	; 0x9e9f
jmp_filenotfound	jmp $8276	; 0x9ea1
	jsr OSBGET	; 0x9ea4
	bcs $9ec7	; 0x9ea7
	cmp #$0a	; 0x9ea9
	beq $9ea4	; 0x9eab
	plp	; 0x9ead
	bne $9eb8	; 0x9eae
	pha	; 0x9eb0
	jsr $9fa2	; 0x9eb1
	jsr prt_spc	; 0x9eb4
	pla	; 0x9eb7
	jsr OSASCI	; 0x9eb8
	bit $ff	; 0x9ebb
	bmi $9ec8	; 0x9ebd
	and $ab	; 0x9ebf
	cmp #$0d	; 0x9ec1
	php	; 0x9ec3
	jmp $9ea4	; 0x9ec4
	plp	; 0x9ec7
	jsr prt_newline	; 0x9ec8
	lda #$00	; 0x9ecb
	jmp OSFIND	; 0x9ecd
	jsr ltrim	; 0x9ed0
	lda #$c0	; 0x9ed3
	jsr OSFIND	; 0x9ed5
	tay	; 0x9ed8
	beq jmp_filenotfound	; 0x9ed9
	ldx $f4	; 0x9edb
	lda $0df0,x	; 0x9edd
	sta $ad	; 0x9ee0
	inc $ad	; 0x9ee2
	bit $ff	; 0x9ee4
	bmi $9ecb	; 0x9ee6
	lda $a9	; 0x9ee8
	jsr prthex	; 0x9eea
	lda $a8	; 0x9eed
	jsr prthex	; 0x9eef
	jsr prt_spc	; 0x9ef2
	lda #$07	; 0x9ef5
	sta $ac	; 0x9ef7
	ldx #$00	; 0x9ef9
	jsr OSBGET	; 0x9efb
	bcs $9f0d	; 0x9efe
	sta ($ac,x)	; 0x9f00
	jsr prthex	; 0x9f02
	jsr prt_spc	; 0x9f05
	dec $ac	; 0x9f08
	bpl $9efb	; 0x9f0a
	clc	; 0x9f0c
	php	; 0x9f0d
	bcc $9f1e	; 0x9f0e
	jsr prtstr	; 0x9f10
	rol	; 0x9f13
	rol	; 0x9f14
	jsr $00a9	; 0x9f15
	sta ($ac,x)	; 0x9f18
	dec $ac	; 0x9f1a
	bpl $9f10	; 0x9f1c
	lda #$07	; 0x9f1e
	sta $ac	; 0x9f20
	lda ($ac,x)	; 0x9f22
	cmp #$7f	; 0x9f24
	bcs $9f2c	; 0x9f26
	cmp #$20	; 0x9f28
	bcs $9f2e	; 0x9f2a
	lda #$2e	; 0x9f2c
	jsr OSASCI	; 0x9f2e
	dec $ac	; 0x9f31
	bpl $9f22	; 0x9f33
	jsr prt_newline	; 0x9f35
	lda #$08	; 0x9f38
	clc	; 0x9f3a
	adc $a8	; 0x9f3b
	sta $a8	; 0x9f3d
	bcc $9f43	; 0x9f3f
	inc $a9	; 0x9f41
	plp	; 0x9f43
	bcc $9ee4	; 0x9f44
	bcs $9ecb	; 0x9f46
	jsr ltrim	; 0x9f48
	lda #$80	; 0x9f4b
	jsr OSFIND	; 0x9f4d
	sta $ab	; 0x9f50
	jsr $9fa2	; 0x9f52
	jsr prt_spc	; 0x9f55
	ldx $f4	; 0x9f58
	ldy $0df0,x	; 0x9f5a
	iny	; 0x9f5d
	sty $ad	; 0x9f5e
	ldx #$ac	; 0x9f60
	ldy #$ff	; 0x9f62
	sty $ae	; 0x9f64
	sty temp	; 0x9f66
	iny	; 0x9f68
	sty $ac	; 0x9f69
	sty $af	; 0x9f6b
	tya	; 0x9f6d
	jsr OSWORD	; 0x9f6e
	php	; 0x9f71
	sty $aa	; 0x9f72
	ldy $ab	; 0x9f74
	ldx #$00	; 0x9f76
	beq $9f81	; 0x9f78
	lda ($ac,x)	; 0x9f7a
	jsr OSBPUT	; 0x9f7c
	inc $ac	; 0x9f7f
	lda $ac	; 0x9f81
	cmp $aa	; 0x9f83
	bne $9f7a	; 0x9f85
	plp	; 0x9f87
	bcs $9f92	; 0x9f88
	lda #$0d	; 0x9f8a
	jsr OSBPUT	; 0x9f8c
	jmp $9f52	; 0x9f8f
	lda #$7e	; 0x9f92
	jsr OSBYTE	; 0x9f94
	jsr $9ecb	; 0x9f97
prt_newline	pha	; 0x9f9a
	lda #$0d	; 0x9f9b
	jsr prtchr	; 0x9f9d
	pla	; 0x9fa0
	rts	; 0x9fa1
	sed	; 0x9fa2
	clc	; 0x9fa3
	lda $a8	; 0x9fa4
	adc #$01	; 0x9fa6
	sta $a8	; 0x9fa8
	lda $a9	; 0x9faa
	adc #$00	; 0x9fac
	sta $a9	; 0x9fae
	cld	; 0x9fb0
	clc	; 0x9fb1
	jsr $9fb7	; 0x9fb2
	lda $a8	; 0x9fb5
	pha	; 0x9fb7
	php	; 0x9fb8
	jsr lsr4	; 0x9fb9
	plp	; 0x9fbc
	jsr $9fc1	; 0x9fbd
	pla	; 0x9fc0
	tax	; 0x9fc1
	bcs $9fc6	; 0x9fc2
	beq prt_spc	; 0x9fc4
	jsr prthex_ln	; 0x9fc6
	sec	; 0x9fc9
	rts	; 0x9fca
prt_2spc	jsr prt_spc	; 0x9fcb
prt_spc	pha	; 0x9fce
	lda #$20	; 0x9fcf
	jsr prtchr	; 0x9fd1
	pla	; 0x9fd4
	clc	; 0x9fd5
	rts	; 0x9fd6
ltrim	tsx	; 0x9fd7
	lda #$00	; 0x9fd8
	sta $0107,x	; 0x9fda
	dey	; 0x9fdd
-	iny	; 0x9fde
	lda (txt_ptr),y	; 0x9fdf
	cmp #$20	; 0x9fe1
	beq -	; 0x9fe3
	cmp #$0d	; 0x9fe5
	bne +	; 0x9fe7
	jmp $9a06	; 0x9fe9
+	lda #$00	; 0x9fec
	sta $a8	; 0x9fee
	sta $a9	; 0x9ff0
	pha	; 0x9ff2
	tya	; 0x9ff3
	clc	; 0x9ff4
	adc txt_ptr	; 0x9ff5
	tax	; 0x9ff7
	lda $f3	; 0x9ff8
	adc #$00	; 0x9ffa
	tay	; 0x9ffc
	pla	; 0x9ffd
	rts	; 0x9ffe
	!byte $6d
report_error	jsr reset_leds	; 0xa000
	pla	; 0xa003
	sta err_ptr	; 0xa004
	pla	; 0xa006
	sta err_ptr+1	; 0xa007
	jsr report_str	; 0xa009
	jmp $0100	; 0xa00c
report_str	ldy #$00	; 0xa00f
	sty $0100	; 0xa011
-	iny	; 0xa014
	beq +	; 0xa015
	lda (err_ptr),y	; 0xa017
	sta $0100,y	; 0xa019
	bne -	; 0xa01c
+	rts	; 0xa01e
report_mmc_errors	ldx #$ff	; 0xa01f
	bne +	; 0xa021
report_mmc_error	ldx #$00	; 0xa023
+	ldy #$ff	; 0xa025
	sty cur_drv_cat	; 0xa027
	sta temp	; 0xa02a
	stx temp+1	; 0xa02c
	sta mmc_status	; 0xa02e
	jsr reset_leds	; 0xa031
	pla	; 0xa034
	sta err_ptr	; 0xa035
	pla	; 0xa037
	sta err_ptr+1	; 0xa038
	jsr report_str	; 0xa03a
	lda temp	; 0xa03d
	jsr prt_hex	; 0xa03f
	lda temp+1	; 0xa042
	beq +	; 0xa044
	lda #$2f	; 0xa046
	sta $0100,y	; 0xa048
	iny	; 0xa04b
	ldx cur_seq	; 0xa04c
	lda par1,x	; 0xa04f
	jsr prt_hex	; 0xa052
	lda par1+1,x	; 0xa055
	jsr prt_hex	; 0xa058
	lda par1+2,x	; 0xa05b
	jsr prt_hex	; 0xa05e
+	lda #$00	; 0xa061
	sta $0100,y	; 0xa063
	jmp $0100	; 0xa066
prt_hex	pha	; 0xa069
	lsr	; 0xa06a
	lsr	; 0xa06b
	lsr	; 0xa06c
	lsr	; 0xa06d
	jsr +	; 0xa06e
	pla	; 0xa071
	and #$0f	; 0xa072
+	clc	; 0xa074
	adc #$30	; 0xa075
	cmp #$3a	; 0xa077
	bcc +	; 0xa079
	adc #$06	; 0xa07b
+	sta $0100,y	; 0xa07d
	iny	; 0xa080
	rts	; 0xa081
err_escape	jsr report_error	; 0xa082
	!text $11, "Escape", $00
mmc_set_7475	pha	; 0xa08d
	lda #$ff	; 0xa08e
	sta $1074	; 0xa090
	sta $1075	; 0xa093
	pla	; 0xa096
	rts	; 0xa097
check_if_to_tube	pha	; 0xa098
	lda $be	; 0xa099
	sta $1072	; 0xa09b
	lda $bf	; 0xa09e
	sta $1073	; 0xa0a0
	lda $1074	; 0xa0a3
	and $1075	; 0xa0a6
	ora tube_present_if_zero	; 0xa0a9
	eor #$ff	; 0xa0ac
	sta tube_txf	; 0xa0ae
	sec	; 0xa0b1
	beq $a0c1	; 0xa0b2
	jsr $a0c3	; 0xa0b4
	ldx #$72	; 0xa0b7
	ldy #$10	; 0xa0b9
	pla	; 0xa0bb
	pha	; 0xa0bc
	jsr $0406	; 0xa0bd
	clc	; 0xa0c0
	pla	; 0xa0c1
	rts	; 0xa0c2
	pha	; 0xa0c3
	lda #$c1	; 0xa0c4
	jsr $0406	; 0xa0c6
	bcc $a0c4	; 0xa0c9
	pla	; 0xa0cb
	rts	; 0xa0cc
	lda tube_txf	; 0xa0cd
	beq $a0d7	; 0xa0d0
	lda #$81	; 0xa0d2
	jsr $0406	; 0xa0d4
	rts	; 0xa0d7
mmc_gbpb1	sta $0105,x	; 0xa0d8
	jsr $95e4	; 0xa0db
	php	; 0xa0de
	lda $1081	; 0xa0df
	beq $a0e9	; 0xa0e2
	lda #$81	; 0xa0e4
	jsr $0406	; 0xa0e6
	plp	; 0xa0e9
	rts	; 0xa0ea
mmc_gbpb2	beq $a0f3	; 0xa0eb
	jsr $a0c3	; 0xa0ed
	clc	; 0xa0f0
	lda #$ff	; 0xa0f1
	jmp $9617	; 0xa0f3
mmc_service	cmp #$fe	; 0xa0f6
	bcc $a154	; 0xa0f8
	bne $a117	; 0xa0fa
	cpy #$00	; 0xa0fc
	beq $a154	; 0xa0fe
	ldx #$06	; 0xa100
	lda #$14	; 0xa102
	jsr OSBYTE	; 0xa104
	bit TUBE_R0	; 0xa107
	bpl $a107	; 0xa10a
	lda TUBE_R1	; 0xa10c
	beq $a152	; 0xa10f
	jsr OSWRCH	; 0xa111
	jmp $a107	; 0xa114
	lda #$ad	; 0xa117
	sta $0220	; 0xa119
	lda #$06	; 0xa11c
	sta $0221	; 0xa11e
	lda #$16	; 0xa121
	sta $0202	; 0xa123
	ldy #$00	; 0xa126
	sty $0203	; 0xa128
	lda #$8e	; 0xa12b
	sta TUBE_R0	; 0xa12d
	lda $8b03,y	; 0xa130
	sta $0400,y	; 0xa133
	lda $8c03,y	; 0xa136
	sta $0500,y	; 0xa139
	lda $8d03,y	; 0xa13c
	sta $0600,y	; 0xa13f
	dey	; 0xa142
	bne $a130	; 0xa143
	jsr $0421	; 0xa145
	ldx #$40	; 0xa148
	lda $8ac2,x	; 0xa14a
	sta $16,x	; 0xa14d
	dex	; 0xa14f
	bpl $a14a	; 0xa150
	lda #$00	; 0xa152
	rts	; 0xa154
mmc_cmd_disk	lda #$ff	; 0xa155
	sta start_opts	; 0xa157
	pha	; 0xa15a
	jmp $933b	; 0xa15b
mmc_set_ptr_to_ext	lda $1114,y	; 0xa15e
	sta $1110,y	; 0xa161
	lda $1115,y	; 0xa164
	sta $1111,y	; 0xa167
	lda $1116,y	; 0xa16a
	sta $1112,y	; 0xa16d
	rts	; 0xa170
set_leds	ldx #$06	; 0xa171
	stx SV_IOB	; 0xa173
	inx	; 0xa176
	stx SV_IOB	; 0xa177
	rts	; 0xa17a
reset_leds	lda #$76	; 0xa17b
	jmp OSBYTE	; 0xa17d
	ldx #$01	; 0xa180

print_splash	jsr prtstr
	!text "MakeStuff UDFS", $0d, $0d
	nop
	rts

mmc_check	pha
	lda #'A'
	jsr OSWRCH
	pla
	rts
mmc_do_read16	pha
	lda #'B'
	jsr OSWRCH
	pla
	rts
mmc_read_block	pha
	txa
	pha
	tya
	pha
	lda #'C'
	jsr OSWRCH

	; Setup parameter block
	lda sector+1
	sta zp+block_data+1
	lda sector+0
	sta zp+block_data+0
	lda sector_count
	ldx bytes_last_sector
	stx zp+block_data+2
	beq +
	sec
	sbc #1
+	sta zp+block_data+3

	; Setup command block
	lda #0
	sta zp+channel
	sta zp+param1
	sta zp+param2
	sta zp+send_length+1
	lda #1
	sta zp+command
	lda #4
	sta zp+send_length
	lda #>(zp+block_data)
	sta zp+send_addr+1
	lda #<(zp+block_data)
	sta zp+send_addr
	lda data_ptr+1
	sta zp+recv_addr+1
	lda data_ptr
	sta zp+recv_addr
	jsr send_msg
	
	;lda #' '
	;jsr OSWRCH
	;ldx sector+1
	;jsr print_num
	;ldx sector+0
	;jsr print_num
	;lda #' '
	;jsr OSWRCH
	;lda sector_count
	;sec
	;sbc #1
	;tax
	;jsr print_num
	;ldx bytes_last_sector
	;jsr print_num
	;lda #' '
	;jsr OSWRCH
	;ldx data_ptr+1
	;jsr print_num
	;ldx data_ptr+0
	;jsr print_num
	;jsr OSNEWL

	pla
	tay
	pla
	tax
	pla
	rts

mmc_read_cat	pha
	txa
	pha
	tya
	pha

	lda #'D'
	jsr OSWRCH
	

;	jsr OSNEWL
;	lda #'D'
;	jsr OSWRCH
;	ldx sector+2
;	jsr print_num
;	ldx sector+1
;	jsr print_num
;	ldx sector+0
;	jsr print_num
;	ldy #0
;-	tya
;	and #$0f
;	bne +
;	jsr OSNEWL
;+	ldx $0100,y
;	jsr print_num
;	lda #' '
;	jsr OSWRCH
;	iny
;	bne -
;	jsr OSNEWL
;	tsx
;	jsr print_num
;	jsr OSNEWL
;	txa
;	clc
;	adc #3
;	tay
;	ldx $0102,y
;	jsr print_num
;	ldx $0101,y
;	jsr print_num
;	jsr OSRDCH
;	ldy #0
;-	lda cat_sec,y
;	sta (data_ptr),y
;	iny
;	bne -
;	inc data_ptr+1
;-	lda cat_sec+256,y
;	sta (data_ptr),y
;	iny
;	bne -

	lda #0
	sta $e00
	sta $e01
	sta $e02
	sta zp+channel
	sta zp+param1
	sta zp+param2
	sta zp+send_length+1
	sta zp+send_addr
	sta zp+recv_addr
	lda #1
	sta zp+command
	lda #2
	sta $e03
	lda #4
	sta zp+send_length
	lda #$0e
	sta zp+send_addr+1
	sta zp+recv_addr+1
	jsr send_msg

	pla
	tay
	pla
	tax
	pla
	rts
mmc_setup_read16	pha
	lda #'E'
	jsr OSWRCH
	pla
-	rts
mmc_start_opts	lda #$7a
	jsr OSBYTE
	txa
	bmi ++
	cmp #$65 ; M
	beq +
	cmp #$42 ; X
	bne -
+	lda #$78
	jsr OSBYTE
++	stx start_opts
	jmp $9320 ; AUTOBOOT
;	pha
;	lda #'F'
;	jsr OSWRCH
;	pla
;	rts
mmc_write_block	pha
	lda #'G'
	jsr OSWRCH
	pla
	rts
mmc_write_cat	pha
	lda #'H'
	jsr OSWRCH
	pla
	rts

; On entry:
;   $70       - Channel
;   $71       - Command
;   $72       - 1st parameter
;   $73       - 2nd parameter
;   $74 & $75 - Send length
;   $76 & $77 - Send address
;   $78 & $79 - Receive address
;
; On exit:
;   $70       - Status
;   $74 & $75 - Receive length
;
send_msg	lda pcr
	pha
	lda acr
	pha
	lda #0
	sta acr
	lda zp+send_addr
	sta data_ptr
	lda zp+send_addr+1
	sta data_ptr+1
	lda #$00
	sta ddrb	; Reading from AVR.
	lda #$C0
	sta pcr	; Drive CB2 low.
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
-	lda zp,y
	jsr send_byte
	iny
	cpy #6
	bne -
	ldy zp+send_length+1	; Get length high byte
	beq send_final_page
	ldy #$00
-	lda (data_ptr),y
	jsr send_byte
	iny
	bne -
	inc data_ptr+1
	dec zp+send_length+1
	bne -
	beq send_final_page
-	lda (data_ptr),y
	jsr send_byte
	iny
send_final_page	cpy zp+send_length
	bne -
	lda zp+recv_addr
	sta data_ptr
	lda zp+recv_addr+1
	sta data_ptr+1
	ldy #$00
	sty ddrb	; Reading from AVR.
	jsr send_byte	; Tell AVR to send.
	jsr send_byte	; Get AVR's status byte.
	ldx drb	; Load it into X.
	stx zp+channel	; Save status byte.
	jsr send_byte	; Get AVR's length low byte.
	ldx drb	; Load it into X.
	stx zp+param1	; Save it.
	stx zp+send_length	; ...and in the counter.
	jsr send_byte	; Get AVR's length high byte.
	ldx drb	; Load it into X.
	stx zp+param2	; Save it first in out param block...
	stx zp+send_length+1	; ...and in the counter.
	beq recv_final_page
-	jsr send_byte
	lda drb
	sta (data_ptr),y
	iny
	bne -
	inc data_ptr+1	; Inc addr high byte.
	dec zp+param2	; Dec count high byte.
	bne -
	beq recv_final_page

-	jsr send_byte
	lda drb
	sta (data_ptr),y
	iny
recv_final_page	cpy zp+param1	; Compare with count low byte.
	bne -
	jsr send_byte	; Tell AVR to drop bus.
	pla
	sta acr
	pla
	sta pcr
	rts

send_byte	sta drb	; Send byte to AVR and strobe CB2.
-	lda ifr	; Load the interrupt flag register.
	and #$10	; Test bit CB1 (AVR acknowledge).
	beq -	; Loop until CB1 set.
	rts

print_num	pha
	txa
	pha
	tya
	pha
	txa
	lsr
	lsr
	lsr
	lsr
	tay
	lda digits,y
	jsr OSWRCH
	txa
	and #$0f
	tay
	lda digits,y
	jsr OSWRCH
	pla
	tay
	pla
	tax
	pla
	rts
digits	!byte '0', '1', '2', '3', '4', '5', '6', '7'
	!byte '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'

	* = $a817
check_sector0	lda $0d05	; 0xa817
	cmp #$54	; 0xa81a
	bne $a835	; 0xa81c
	lda $0d06	; 0xa81e
	eor $0d09	; 0xa821
	eor $0d07	; 0xa824
	eor $0d0a	; 0xa827
	eor $0d08	; 0xa82a
	eor $0d0b	; 0xa82d
	cmp #$ff	; 0xa830
	bne $a835	; 0xa832
	rts	; 0xa834
	ldx #$08	; 0xa835
	lda $a1,x	; 0xa837
	pha	; 0xa839
	dex	; 0xa83a
	bne $a837	; 0xa83b
	lda #$00	; 0xa83d
	sta sector	; 0xa83f
	sta sector+1	; 0xa841
	sta sector+2	; 0xa843
	jsr mmc_read_cat	; 0xa845
	lda #$dd	; 0xa848
	sta cur_drv_cat	; 0xa84a
	jsr $a86b	; 0xa84d
	beq $a87b	; 0xa850
	lda #$00	; 0xa852
	sta $0d06	; 0xa854
	sta $0d07	; 0xa857
	sta $0d08	; 0xa85a
	lda #$ff	; 0xa85d
	sta $0d09	; 0xa85f
	sta $0d0a	; 0xa862
	sta $0d0b	; 0xa865
	jmp $a999	; 0xa868
	lda $0ffe	; 0xa86b
	cmp #$55	; 0xa86e
	bne $a877	; 0xa870
	lda $0fff	; 0xa872
	cmp #$aa	; 0xa875
	rts	; 0xa877
	jmp err_unrecognised_format	; 0xa878
	lda $0fc6	; 0xa87b
	asl	; 0xa87e
	sta sector	; 0xa87f
	lda $0fc7	; 0xa881
	rol	; 0xa884
	sta sector+1	; 0xa885
	lda $0fc8	; 0xa887
	rol	; 0xa88a
	bcs $a878	; 0xa88b
	sta sector+2	; 0xa88d
	lda $0fc9	; 0xa88f
	bne $a878	; 0xa892
	jsr mmc_read_cat	; 0xa894
	jsr $a86b	; 0xa897
	bne $a878	; 0xa89a
	lda $0e0b	; 0xa89c
	bne $a878	; 0xa89f
	lda $0e0c	; 0xa8a1
	cmp #$02	; 0xa8a4
	bne $a878	; 0xa8a6
	lda $0e11	; 0xa8a8
	sta sector_count	; 0xa8ab
	lda $0e12	; 0xa8ad
	lsr	; 0xa8b0
	ror sector_count	; 0xa8b1
	lsr	; 0xa8b3
	ror sector_count	; 0xa8b4
	lsr	; 0xa8b6
	ror sector_count	; 0xa8b7
	sta attempts	; 0xa8b9
	lda $0e0d	; 0xa8bb
	sta bytes_last_sector	; 0xa8be
	lda $0e0e	; 0xa8c0
	asl	; 0xa8c3
	rol $0e0f	; 0xa8c4
	bcs $a878	; 0xa8c7
	adc sector	; 0xa8c9
	sta sector	; 0xa8cb
	lda $0e0f	; 0xa8cd
	adc sector+1	; 0xa8d0
	sta sector+1	; 0xa8d2
	bcc $a8d8	; 0xa8d4
	inc sector+2	; 0xa8d6
	asl $0e16	; 0xa8d8
	rol $0e17	; 0xa8db
	bcs $a878	; 0xa8de
	ldx $0e10	; 0xa8e0
	clc	; 0xa8e3
	lda sector	; 0xa8e4
	adc $0e16	; 0xa8e6
	sta sector	; 0xa8e9
	lda sector+1	; 0xa8eb
	adc $0e17	; 0xa8ed
	sta sector+1	; 0xa8f0
	bcc $a8f6	; 0xa8f2
	inc sector+2	; 0xa8f4
	dex	; 0xa8f6
	bne $a8e3	; 0xa8f7
	jsr mmc_read_cat	; 0xa8f9
	lda #$00	; 0xa8fc
	sta $a8	; 0xa8fe
	lda #$0e	; 0xa900
	sta $a9	; 0xa902
	ldy #$0b	; 0xa904
	lda ($a8),y	; 0xa906
	and #$0f	; 0xa908
	bne $a91c	; 0xa90a
	ldy #$00	; 0xa90c
	lda ($a8),y	; 0xa90e
	cmp mmb,y	; 0xa910
	bne $a91c	; 0xa913
	iny	; 0xa915
	cpy #$0b	; 0xa916
	beq $a93a	; 0xa918
	bne $a90e	; 0xa91a
	clc	; 0xa91c
	lda $a8	; 0xa91d
	adc #$20	; 0xa91f
	sta $a8	; 0xa921
	bne $a904	; 0xa923
	jsr report_error	; 0xa925
	!text $ff, "Image not found!", $00
	clc	; 0xa93a
	lda sector	; 0xa93b
	adc sector_count	; 0xa93d
	sta sector	; 0xa93f
	lda sector+1	; 0xa941
	adc attempts	; 0xa943
	sta sector+1	; 0xa945
	bcc $a94b	; 0xa947
	inc sector+2	; 0xa949
	ldy #$1b	; 0xa94b
	lda ($a8),y	; 0xa94d
	pha	; 0xa94f
	dey	; 0xa950
	lda ($a8),y	; 0xa951
	sec	; 0xa953
	sbc #$02	; 0xa954
	sta $a8	; 0xa956
	pla	; 0xa958
	sbc #$00	; 0xa959
	sta $a9	; 0xa95b
	ora $a8	; 0xa95d
	beq $a97b	; 0xa95f
	asl $a8	; 0xa961
	rol $a9	; 0xa963
	ldx bytes_last_sector	; 0xa965
	clc	; 0xa967
	lda sector	; 0xa968
	adc $a8	; 0xa96a
	sta sector	; 0xa96c
	lda sector+1	; 0xa96e
	adc $a9	; 0xa970
	sta sector+1	; 0xa972
	bcc $a978	; 0xa974
	inc sector+2	; 0xa976
	dex	; 0xa978
	bne $a967	; 0xa979
	lda sector	; 0xa97b
	sta $0d06	; 0xa97d
	eor #$ff	; 0xa980
	sta $0d09	; 0xa982
	lda sector+1	; 0xa985
	sta $0d07	; 0xa987
	eor #$ff	; 0xa98a
	sta $0d0a	; 0xa98c
	lda sector+2	; 0xa98f
	sta $0d08	; 0xa991
	eor #$ff	; 0xa994
	sta $0d0b	; 0xa996
	lda #$54	; 0xa999
	sta $0d05	; 0xa99b
	ldx #$00	; 0xa99e
	pla	; 0xa9a0
	sta sector,x	; 0xa9a1
	inx	; 0xa9a3
	cpx #$08	; 0xa9a4
	bne $a9a0	; 0xa9a6
	rts	; 0xa9a8
err_unrecognised_format	jsr report_error	; 0xa9a9
	!text $ff, "Unrecognised format!", $00
mmb	!text "BEEB    MMB"
bin2bcd	php	; 0xa9cd
	tax	; 0xa9ce
	jsr $aa02	; 0xa9cf
	sta $b2	; 0xa9d2
	pha	; 0xa9d4
	jsr $aa1e	; 0xa9d5
	txa	; 0xa9d8
	sbc temp	; 0xa9d9
	tax	; 0xa9db
	pla	; 0xa9dc
	jsr $aa02	; 0xa9dd
	pha	; 0xa9e0
	jsr $aa1e	; 0xa9e1
	lda $b2	; 0xa9e4
	sbc temp	; 0xa9e6
	asl	; 0xa9e8
	asl	; 0xa9e9
	asl	; 0xa9ea
	asl	; 0xa9eb
	sta $b2	; 0xa9ec
	txa	; 0xa9ee
	ora $b2	; 0xa9ef
	tax	; 0xa9f1
	pla	; 0xa9f2
	plp	; 0xa9f3
	bcc $aa01	; 0xa9f4
	pha	; 0xa9f6
	txa	; 0xa9f7
	sed	; 0xa9f8
	clc	; 0xa9f9
	adc #$56	; 0xa9fa
	tax	; 0xa9fc
	pla	; 0xa9fd
	adc #$02	; 0xa9fe
	cld	; 0xaa00
	rts	; 0xaa01
	ldy #$00	; 0xaa02
	sty temp+1	; 0xaa04
	ldy #data_ptr	; 0xaa06
	sty temp	; 0xaa08
	ldy #$05	; 0xaa0a
	cmp temp	; 0xaa0c
	bcc $aa14	; 0xaa0e
	sec	; 0xaa10
	sbc temp	; 0xaa11
	sec	; 0xaa13
	rol temp+1	; 0xaa14
	lsr temp	; 0xaa16
	dey	; 0xaa18
	bne $aa0c	; 0xaa19
	lda temp+1	; 0xaa1b
	rts	; 0xaa1d
	pha	; 0xaa1e
	asl	; 0xaa1f
	asl	; 0xaa20
	asl	; 0xaa21
	sta temp	; 0xaa22
	pla	; 0xaa24
	asl	; 0xaa25
	clc	; 0xaa26
	adc temp	; 0xaa27
	sta temp	; 0xaa29
	sec	; 0xaa2b
	rts	; 0xaa2c
	cpx #$ff	; 0xaa2d
	beq $aa66	; 0xaa2f
	lda $0d10,x	; 0xaa31
	bmi $aa66	; 0xaa34
	eor #$ff	; 0xaa36
	cmp $0d18,x	; 0xaa38
	bne $aa61	; 0xaa3b
	lda $0d0c,x	; 0xaa3d
	eor #$ff	; 0xaa40
	cmp $0d14,x	; 0xaa42
	bne $aa61	; 0xaa45
	lda $0d1c,x	; 0xaa47
	cmp #$54	; 0xaa4a
	beq $aa77	; 0xaa4c
	jsr report_error	; 0xaa4e
	!text $c9, "Disk read only", $00
	lda #$ff	; 0xaa61
	sta $0d10,x	; 0xaa63
	jsr report_error	; 0xaa66
	!text $c7, "No disk", $00
	lda #$54	; 0xaa72
	sta $0d1c,x	; 0xaa74
	rts	; 0xaa77
	lda #$00	; 0xaa78
	sta $0d1c,x	; 0xaa7a
	rts	; 0xaa7d
	lda $0d10,x	; 0xaa7e
	bmi $aa66	; 0xaa81
	ror	; 0xaa83
	lda $0d0c,x	; 0xaa84
	php	; 0xaa87
	tax	; 0xaa88
	lda #$00	; 0xaa89
	sta sector	; 0xaa8b
	rol	; 0xaa8d
	pha	; 0xaa8e
	sta sector+2	; 0xaa8f
	txa	; 0xaa91
	asl	; 0xaa92
	rol sector+2	; 0xaa93
	sta sector+1	; 0xaa95
	txa	; 0xaa97
	adc sector+1	; 0xaa98
	sta sector+1	; 0xaa9a
	pla	; 0xaa9c
	adc #$00	; 0xaa9d
	adc sector+2	; 0xaa9f
	sta sector+2	; 0xaaa1
	ror sector	; 0xaaa3
	txa	; 0xaaa5
	plp	; 0xaaa6
	ror	; 0xaaa7
	ror sector	; 0xaaa8
	lsr	; 0xaaaa
	ror sector	; 0xaaab
	lsr	; 0xaaad
	ror sector	; 0xaaae
	adc sector+1	; 0xaab0
	sta sector+1	; 0xaab2
	lda sector+2	; 0xaab4
	adc #$00	; 0xaab6
	sta sector+2	; 0xaab8

	; No sector offset for catalog
	;jsr check_sector0	; 0xaaba
	;sec	; 0xaabd
	;lda sector	; 0xaabe
	;ora #$1f	; 0xaac0
	;adc $0d06	; 0xaac2
	;sta sector	; 0xaac5
	;lda sector+1	; 0xaac7
	;adc $0d07	; 0xaac9
	;sta sector+1	; 0xaacc
	;lda sector+2	; 0xaace
	;adc $0d08	; 0xaad0
	;sta sector+2	; 0xaad3
	rts	; 0xaad5

	* = $aad6
	lda $be	; 0xaad6
	sta data_ptr	; 0xaad8
	lda $bf	; 0xaada
	sta $a1	; 0xaadc
	ldx cur_drv	; 0xaade
	jsr $aa7e	; 0xaae0
	clc	; 0xaae3
	lda $c5	; 0xaae4
	adc sector	; 0xaae6
	sta sector	; 0xaae8
	lda $c4	; 0xaaea
	and #$03	; 0xaaec
	pha	; 0xaaee
	adc sector+1	; 0xaaef
	sta sector+1	; 0xaaf1
	bcc $aaf7	; 0xaaf3
	inc sector+2	; 0xaaf5
	lda $c3	; 0xaaf7
	sta sector_count	; 0xaaf9
	lda $c4	; 0xaafb
	lsr	; 0xaafd
	lsr	; 0xaafe
	lsr	; 0xaaff
	lsr	; 0xab00
	and #$03	; 0xab01
	bne $ab23	; 0xab03
	lda $c2	; 0xab05
	sta bytes_last_sector	; 0xab07
	beq $ab0f	; 0xab09
	inc sector_count	; 0xab0b
	beq $ab23	; 0xab0d
	clc	; 0xab0f
	lda $c5	; 0xab10
	adc sector_count	; 0xab12
	tax	; 0xab14
	pla	; 0xab15
	adc #$00	; 0xab16
	cmp #$03	; 0xab18
	bcc $ab22	; 0xab1a
	bne $ab35	; 0xab1c
	cpx #$21	; 0xab1e
	bcs $ab35	; 0xab20
	rts	; 0xab22
	jsr report_error	; 0xab23
	!text $ff, "Block too big", $00
	jsr report_error	; 0xab35
	!text $ff, "Disk overflow", $00
mmc_load_cur_drv_cat2	jsr $834d	; 0xab47
	jsr $8358	; 0xab4a
mmc_load_cur_drv_cat	jsr mmc_check	; 0xab4d
	ldx cur_drv	; 0xab50
	stx $0d20	; 0xab52
	jsr $aa7e	; 0xab55
	jsr mmc_read_cat	; 0xab58
	lda cur_drv	; 0xab5b
	sta cur_drv_cat	; 0xab5d
	rts	; 0xab60
mmc_save_cur_drv_cat	jsr mmc_check	; 0xab61
	ldx cur_drv	; 0xab64
	jsr $aa2d	; 0xab66
	jsr $aa7e	; 0xab69
	jmp mmc_write_cat	; 0xab6c
	php	; 0xab6f
	pha	; 0xab70
	ldy #$ff	; 0xab71
	sty cur_drv_cat	; 0xab73
	iny	; 0xab76
	tya	; 0xab77
	sta buf,y	; 0xab78
	sta $0f00,y	; 0xab7b
	iny	; 0xab7e
	bne $ab78	; 0xab7f
	lda #$03	; 0xab81
	sta $0f06	; 0xab83
	lda #$20	; 0xab86
	sta $0f07	; 0xab88
	jsr mmc_check	; 0xab8b
	pla	; 0xab8e
	plp	; 0xab8f
	jsr $aa87	; 0xab90
	jmp mmc_write_cat	; 0xab93
mmc_load_mem_block	jsr mmc_check	; 0xab96
	jsr $aad6	; 0xab99
	jsr mmc_read_block	; 0xab9c
	jsr $a0cd	; 0xab9f
	lda #$01	; 0xaba2
	rts	; 0xaba4
mmc_save_mem_block	jsr mmc_check	; 0xaba5
	jsr $aad6	; 0xaba8
	ldx cur_drv	; 0xabab
	jsr $aa2d	; 0xabad
	jsr mmc_write_block	; 0xabb0
	jsr $a0cd	; 0xabb3
	lda #$01	; 0xabb6
	rts	; 0xabb8
	tay	; 0xabb9
	iny	; 0xabba
	tya	; 0xabbb
	bne $abbf	; 0xabbc
	sec	; 0xabbe
	rol	; 0xabbf
	rol	; 0xabc0
	rol	; 0xabc1
	rol	; 0xabc2
	rol	; 0xabc3
	pha	; 0xabc4
	and #$1f	; 0xabc5
	tay	; 0xabc7
	pla	; 0xabc8
	ora #$1f	; 0xabc9
	ror	; 0xabcb
	rts	; 0xabcc
	jsr $abb9	; 0xabcd
	pha	; 0xabd0
	txa	; 0xabd1
	pha	; 0xabd2
	tya	; 0xabd3
	pha	; 0xabd4
	jsr $ac98	; 0xabd5
	pla	; 0xabd8
	ror	; 0xabd9
	pla	; 0xabda
	tax	; 0xabdb
	pla	; 0xabdc
	tay	; 0xabdd
	bcs $abe4	; 0xabde
	lda buf,y	; 0xabe0
	rts	; 0xabe3
	lda $0f00,y	; 0xabe4
	rts	; 0xabe7
	php	; 0xabe8
	pha	; 0xabe9
	sta $0d5f	; 0xabea
	lda #$00	; 0xabed
	rol	; 0xabef
	sta $0d60	; 0xabf0
	stx $0d61	; 0xabf3
	ldx #$03	; 0xabf6
	cpx $0d61	; 0xabf8
	beq $ac12	; 0xabfb
	lda $0d0c,x	; 0xabfd
	cmp $0d5f	; 0xac00
	bne $ac12	; 0xac03
	lda $0d10,x	; 0xac05
	cmp $0d60	; 0xac08
	bne $ac12	; 0xac0b
	lda #$ff	; 0xac0d
	sta $0d10,x	; 0xac0f
	dex	; 0xac12
	bpl $abf8	; 0xac13
	ldx $0d61	; 0xac15
	pla	; 0xac18
	plp	; 0xac19
	rts	; 0xac1a
loaddisk	php	; 0xac1b
	pha	; 0xac1c
	sta $0d0c,x	; 0xac1d
	eor #$ff	; 0xac20
	sta $0d14,x	; 0xac22
	lda #$00	; 0xac25
	rol	; 0xac27
	sta $0d10,x	; 0xac28
	eor #$ff	; 0xac2b
	sta $0d18,x	; 0xac2d
	pla	; 0xac30
	plp	; 0xac31
	jsr $abe8	; 0xac32
	jsr $abcd	; 0xac35
	bmi $ac42	; 0xac38
	beq $ac3f	; 0xac3a
	jmp $aa72	; 0xac3c
	jmp $aa78	; 0xac3f
	tay	; 0xac42
	lda #$ff	; 0xac43
	sta $0d10,x	; 0xac45
	iny	; 0xac48
	bne $ac65	; 0xac49
	jsr report_error	; 0xac4b
	!text $c7, "Disk number not valid", $00
	jsr report_error	; 0xac65
	!text $c7, "Disk not formatted", $00
	and #$7e	; 0xac7c
	pha	; 0xac7e
	jsr check_sector0	; 0xac7f
	clc	; 0xac82
	pla	; 0xac83
	adc $0d06	; 0xac84
	sta sector	; 0xac87
	lda $0d07	; 0xac89
	adc #$00	; 0xac8c
	sta sector+1	; 0xac8e
	lda $0d08	; 0xac90
	adc #$00	; 0xac93
	sta sector+2	; 0xac95
	rts	; 0xac97
	and #$fe	; 0xac98
	ora #$80	; 0xac9a
	cmp cur_drv_cat	; 0xac9c
	beq $ac97	; 0xac9f
	sta cur_drv_cat	; 0xaca1
	pha	; 0xaca4
	jsr mmc_check	; 0xaca5
	pla	; 0xaca8
	jsr $ac7c	; 0xaca9
	jmp mmc_read_cat	; 0xacac
	sta cur_drv_cat	; 0xacaf
	jsr $ac7c	; 0xacb2
	jmp mmc_read_cat	; 0xacb5
	jsr mmc_check	; 0xacb8
	lda cur_drv_cat	; 0xacbb
	jsr $ac7c	; 0xacbe
	jmp mmc_write_cat	; 0xacc1
	lda cur_drv_cat	; 0xacc4
	jsr $ac7c	; 0xacc7
	jmp mmc_write_cat	; 0xacca
	jsr $acb8	; 0xaccd
	ldx #$03	; 0xacd0
	jsr $acd9	; 0xacd2
	dex	; 0xacd5
	bpl $acd2	; 0xacd6
	rts	; 0xacd8
	lda $0d10,x	; 0xacd9
	bmi $ad09	; 0xacdc
	eor #$ff	; 0xacde
	cmp $0d18,x	; 0xace0
	bne $acfd	; 0xace3
	lda $0d0c,x	; 0xace5
	eor #$ff	; 0xace8
	cmp $0d14,x	; 0xacea
	bne $acfd	; 0xaced
	lda $0d10,x	; 0xacef
	ror	; 0xacf2
	lda $0d0c,x	; 0xacf3
	jsr $abcd	; 0xacf6
	beq $ad06	; 0xacf9
	bpl $ad04	; 0xacfb
	lda #$ff	; 0xacfd
	sta $0d10,x	; 0xacff
	bne $ad06	; 0xad02
	lda #$54	; 0xad04
	sta $0d1c,x	; 0xad06
	rts	; 0xad09
mmc_initialise	lda #$ff	; 0xad0a
	ldx #$1f	; 0xad0c
	sta $0d20,x	; 0xad0e
	dex	; 0xad11
	bne $ad0e	; 0xad12
	stx mmc_first_mode	; 0xad14
	lda #$00	; 0xad17
	sta mmc_status	; 0xad19
	sta $0d05	; 0xad1c
	sta $0d20	; 0xad1f
	lda #$80	; 0xad22
	jsr $aca1	; 0xad24
	ldx #$00	; 0xad27
	lda start_opts	; 0xad29
	cmp #$42	; 0xad2c
	beq $ad46	; 0xad2e
	lda $0d10,x	; 0xad30
	bmi $ad78	; 0xad33
	eor #$ff	; 0xad35
	cmp $0d18,x	; 0xad37
	bne $ad46	; 0xad3a
	lda $0d0c,x	; 0xad3c
	eor #$ff	; 0xad3f
	cmp $0d14,x	; 0xad41
	beq $ad5c	; 0xad44
	lda buf,x	; 0xad46
	sta $0d0c,x	; 0xad49
	eor #$ff	; 0xad4c
	sta $0d14,x	; 0xad4e
	lda $0e04,x	; 0xad51
	sta $0d10,x	; 0xad54
	eor #$ff	; 0xad57
	sta $0d18,x	; 0xad59
	txa	; 0xad5c
	beq $ad7d	; 0xad5d
	tay	; 0xad5f
	dey	; 0xad60
	lda $0d10,x	; 0xad61
	bmi $ad7d	; 0xad64
	cmp $0d10,y	; 0xad66
	bne $ad73	; 0xad69
	lda $0d0c,x	; 0xad6b
	cmp $0d0c,y	; 0xad6e
	beq $ad78	; 0xad71
	dey	; 0xad73
	bpl $ad61	; 0xad74
	bmi $ad7d	; 0xad76
	lda #$ff	; 0xad78
	sta $0d10,x	; 0xad7a
	inx	; 0xad7d
	cpx #$04	; 0xad7e
	bne $ad29	; 0xad80
	jmp $acd0	; 0xad82
	php	; 0xad85
	pha	; 0xad86
	sta $0d53	; 0xad87
	lda #$00	; 0xad8a
	rol	; 0xad8c
	sta $0d54	; 0xad8d
	pla	; 0xad90
	plp	; 0xad91
	php	; 0xad92
	pha	; 0xad93
	jsr bin2bcd	; 0xad94
	stx $0d55	; 0xad97
	sta $0d56	; 0xad9a
	pla	; 0xad9d
	plp	; 0xad9e
	jsr $abb9	; 0xad9f
	and #$f0	; 0xada2
	sta txt_ptr	; 0xada4
	tya	; 0xada6
	and #$01	; 0xada7
	ora #$0e	; 0xada9
	sta $f3	; 0xadab
	tya	; 0xadad
	and #$fe	; 0xadae
	ora #$80	; 0xadb0
	sta start_opts	; 0xadb2
	jsr $ac9c	; 0xadb5
	jmp $ae19	; 0xadb8
	lda #$00	; 0xadbb
	sta $0d55	; 0xadbd
	sta $0d56	; 0xadc0
	sta $0d53	; 0xadc3
	sta $0d54	; 0xadc6
	lda #$10	; 0xadc9
	sta txt_ptr	; 0xadcb
	lda #$0e	; 0xadcd
	sta $f3	; 0xadcf
	lda #$80	; 0xadd1
	sta start_opts	; 0xadd3
	jsr $ac9c	; 0xadd6
	jmp $ae19	; 0xadd9
	cmp #$ff	; 0xaddc
	beq $ae21	; 0xadde
	clc	; 0xade0
	lda txt_ptr	; 0xade1
	adc #$10	; 0xade3
	sta txt_ptr	; 0xade5
	bne $ae01	; 0xade7
	lda $f3	; 0xade9
	eor #$01	; 0xadeb
	sta $f3	; 0xaded
	ror	; 0xadef
	bcs $ae01	; 0xadf0
	lda start_opts	; 0xadf2
	adc #$02	; 0xadf5
	cmp #data_ptr	; 0xadf7
	beq $ae21	; 0xadf9
	sta start_opts	; 0xadfb
	jsr $ac9c	; 0xadfe
	inc $0d53	; 0xae01
	bne $ae09	; 0xae04
	inc $0d54	; 0xae06
	sed	; 0xae09
	clc	; 0xae0a
	lda $0d55	; 0xae0b
	adc #$01	; 0xae0e
	sta $0d55	; 0xae10
	bcc $ae18	; 0xae13
	inc $0d56	; 0xae15
	cld	; 0xae18
	ldy #$0f	; 0xae19
	lda (txt_ptr),y	; 0xae1b
	bmi $addc	; 0xae1d
	clc	; 0xae1f
	rts	; 0xae20
	lda #$ff	; 0xae21
	sta $0d54	; 0xae23
	sec	; 0xae26
	rts	; 0xae27
	jsr mmc_check	; 0xae28
	lda #$80	; 0xae2b
	sta start_opts	; 0xae2d
	jsr $acaf	; 0xae30
	lda #$10	; 0xae33
	sta txt_ptr	; 0xae35
	lda #$0e	; 0xae37
	sta $f3	; 0xae39
	jsr check_sector0	; 0xae3b
	clc	; 0xae3e
	lda $0d06	; 0xae3f
	adc #$20	; 0xae42
	sta sector	; 0xae44
	lda $0d07	; 0xae46
	adc #$00	; 0xae49
	sta sector+1	; 0xae4b
	lda $0d08	; 0xae4d
	adc #$00	; 0xae50
	sta sector+2	; 0xae52
	jsr mmc_setup_read16	; 0xae54
	ldy #$0f	; 0xae57
	lda (txt_ptr),y	; 0xae59
	cmp #$ff	; 0xae5b
	beq $ae98	; 0xae5d
	jsr mmc_do_read16	; 0xae5f
	ldy #$0b	; 0xae62
	lda $0d5f,y	; 0xae64
	sta (txt_ptr),y	; 0xae67
	dey	; 0xae69
	bpl $ae64	; 0xae6a
	clc	; 0xae6c
	lda txt_ptr	; 0xae6d
	adc #$10	; 0xae6f
	sta txt_ptr	; 0xae71
	bne $ae57	; 0xae73
	lda $f3	; 0xae75
	eor #$01	; 0xae77
	sta $f3	; 0xae79
	ror	; 0xae7b
	bcs $ae57	; 0xae7c
	jsr $acc4	; 0xae7e
	clc	; 0xae81
	lda start_opts	; 0xae82
	adc #$02	; 0xae85
	cmp #data_ptr	; 0xae87
	beq $aea3	; 0xae89
	sta start_opts	; 0xae8b
	bit $ff	; 0xae8e
	bmi $aea4	; 0xae90
	jsr $acaf	; 0xae92
	jmp $ae57	; 0xae95
	lda txt_ptr	; 0xae98
	bne $aea0	; 0xae9a
	ror $f3	; 0xae9c
	bcc $aea3	; 0xae9e
	jsr $acc4	; 0xaea0
	rts	; 0xaea3
	jmp err_escape	; 0xaea4
	ldx #$0b	; 0xaea7
	lda #$00	; 0xaea9
	jsr $88c6	; 0xaeab
	sta $0d5f,x	; 0xaeae
	dex	; 0xaeb1
	bpl $aeab	; 0xaeb2
	inx	; 0xaeb4
	jsr GSREAD	; 0xaeb5
	bcs $aec4	; 0xaeb8
	jsr $88c6	; 0xaeba
	sta $0d5f,x	; 0xaebd
	cpx #$0b	; 0xaec0
	bcc $aeb4	; 0xaec2
	jsr $8ab4	; 0xaec4
	ldx cur_drv_cat	; 0xaec7
	lda $0d10,x	; 0xaeca
	ror	; 0xaecd
	lda $0d0c,x	; 0xaece
	jsr $abb9	; 0xaed1
	and #$f0	; 0xaed4
	pha	; 0xaed6
	tya	; 0xaed7
	pha	; 0xaed8
	and #$fe	; 0xaed9
	ora #$80	; 0xaedb
	jsr $aca1	; 0xaedd
	pla	; 0xaee0
	clc	; 0xaee1
	and #$01	; 0xaee2
	adc #$0e	; 0xaee4
	sta $f3	; 0xaee6
	pla	; 0xaee8
	sta txt_ptr	; 0xaee9
	ldy #$0b	; 0xaeeb
	lda $0d5f,y	; 0xaeed
	sta (txt_ptr),y	; 0xaef0
	dey	; 0xaef2
	bpl $aeed	; 0xaef3
	jmp $acb8	; 0xaef5
cmd_table	!text "DIN", $b3, $c0, $12, "DBOOT", $b3, $b5, $02, "DCAT", $b3, $c6, $04, "DDISKS", $b5, "v", $01, "DLOCK", $b5, $bc, $02, "DUNLOCK", $b5, $c0, $02, "DFREE", $b4, $b0, $00, "DKILL", $b5, $e3, $03, "DRESTORE", $b6, "&", $03, "DNEW", $b6, "{", $01, "DFORM", $b6, $1e, $03, "DONBOOT", $b7, "IRDRECAT", $ae, "'", $00, "DROM", $b7, $b0, $86, "DMODE", $b7, "d", $07, "DSWAP", $b7, $9a, $00, "DABOUT", $af, $fa, $00, $87, $d6, $00, "DUTILS", $af, $cb, $00, $af, $bd, $00
mmc_dhelp	ldx #data_ptr	; 0xaf94
	lda (txt_ptr),y	; 0xaf96
	cmp #$0d	; 0xaf98
	bne $afb2	; 0xaf9a
	tya	; 0xaf9c
	inx	; 0xaf9d
	ldy #$02	; 0xaf9e
	jsr $99cb	; 0xafa0
	jsr $b1ff	; 0xafa3
	!text "  DUTILS", $00
	jmp OSNEWL	; 0xafaf
	tya	; 0xafb2
	pha	; 0xafb3
	jsr $8671	; 0xafb4
	pla	; 0xafb7
	tay	; 0xafb8
	ldx #$8d	; 0xafb9
	jmp $b029	; 0xafbb
	iny	; 0xafbe
	lda (txt_ptr),y	; 0xafbf
	cmp #$0d	; 0xafc1
	beq $afcb	; 0xafc3
	cmp #$20	; 0xafc5
	beq $afb9	; 0xafc7
	bne $afbe	; 0xafc9
	rts	; 0xafcb
	jsr OSNEWL	; 0xafcc
	jsr $b1ff	; 0xafcf
	!text "DFS 0.90", $00
	jsr OSNEWL	; 0xafdb
	ldx #$00	; 0xafde
	lda #$0e	; 0xafe0
	stx $b5	; 0xafe2
	sta $bf	; 0xafe4
	ldx #$00	; 0xafe6
	lda #$20	; 0xafe8
	jsr OSWRCH	; 0xafea
	jsr OSWRCH	; 0xafed
	jsr $b2c3	; 0xaff0
	jsr OSNEWL	; 0xaff3
	dec $bf	; 0xaff6
	bne $afe8	; 0xaff8
	rts	; 0xaffa
	jsr $b1ff	; 0xaffb
	!text "DUTILS by Martin Mather (19 Nov 2008)", $00
	jmp OSNEWL	; 0xb024
	ldx #$fd	; 0xb027
	tya	; 0xb029
	pha	; 0xb02a
	inx	; 0xb02b
	inx	; 0xb02c
	pla	; 0xb02d
	pha	; 0xb02e
	tay	; 0xb02f
	jsr $b06b	; 0xb030
	inx	; 0xb033
	lda cmd_table,x	; 0xb034
	bmi $b061	; 0xb037
	stx $b5	; 0xb039
	dex	; 0xb03b
	dey	; 0xb03c
	inx	; 0xb03d
	iny	; 0xb03e
	lda cmd_table,x	; 0xb03f
	bmi $b05a	; 0xb042
	eor (txt_ptr),y	; 0xb044
	and #$5f	; 0xb046
	beq $b03d	; 0xb048
	dex	; 0xb04a
	inx	; 0xb04b
	lda cmd_table,x	; 0xb04c
	bpl $b04b	; 0xb04f
	lda (txt_ptr),y	; 0xb051
	cmp #$2e	; 0xb053
	bne $b02b	; 0xb055
	iny	; 0xb057
	bcs $b061	; 0xb058
	lda (txt_ptr),y	; 0xb05a
	jsr $82ee	; 0xb05c
	bcc $b02b	; 0xb05f
	pla	; 0xb061
	lda cmd_table,x	; 0xb062
	pha	; 0xb065
	lda $aef9,x	; 0xb066
	pha	; 0xb069
	rts	; 0xb06a
	lda (txt_ptr),y	; 0xb06b
	cmp #$0d	; 0xb06d
	beq $b079	; 0xb06f
	iny	; 0xb071
	beq $b07b	; 0xb072
	cmp #$20	; 0xb074
	beq $b06b	; 0xb076
	clc	; 0xb078
	dey	; 0xb079
	rts	; 0xb07a
	jmp syntax	; 0xb07b
	tya	; 0xb07e
	pha	; 0xb07f
	lda #$00	; 0xb080
	sta $0d55	; 0xb082
	sta $0d56	; 0xb085
	jsr $b06b	; 0xb088
	bcs $b0ef	; 0xb08b
	lda (txt_ptr),y	; 0xb08d
	cmp #$0d	; 0xb08f
	beq $b0ef	; 0xb091
	sec	; 0xb093
	sbc #$30	; 0xb094
	bmi $b0ef	; 0xb096
	cmp #$0a	; 0xb098
	bcs $b0ef	; 0xb09a
	pha	; 0xb09c
	lda $0d55	; 0xb09d
	asl	; 0xb0a0
	pha	; 0xb0a1
	rol $0d56	; 0xb0a2
	ldx $0d56	; 0xb0a5
	asl	; 0xb0a8
	rol $0d56	; 0xb0a9
	asl	; 0xb0ac
	rol $0d56	; 0xb0ad
	sta $0d55	; 0xb0b0
	pla	; 0xb0b3
	adc $0d55	; 0xb0b4
	sta $0d55	; 0xb0b7
	txa	; 0xb0ba
	adc $0d56	; 0xb0bb
	tax	; 0xb0be
	pla	; 0xb0bf
	adc $0d55	; 0xb0c0
	sta $0d55	; 0xb0c3
	txa	; 0xb0c6
	adc #$00	; 0xb0c7
	sta $0d56	; 0xb0c9
	cmp #$02	; 0xb0cc
	bcs $b0ef	; 0xb0ce
	iny	; 0xb0d0
	beq $b0ef	; 0xb0d1
	lda (txt_ptr),y	; 0xb0d3
	cmp #$0d	; 0xb0d5
	beq $b0dd	; 0xb0d7
	cmp #$20	; 0xb0d9
	bne $b093	; 0xb0db
	ldx $0d55	; 0xb0dd
	lda $0d56	; 0xb0e0
	beq $b0e9	; 0xb0e3
	inx	; 0xb0e5
	beq $b0ef	; 0xb0e6
	dex	; 0xb0e8
	pla	; 0xb0e9
	lda $0d56	; 0xb0ea
	clc	; 0xb0ed
	rts	; 0xb0ee
	pla	; 0xb0ef
	tay	; 0xb0f0
	lda #$00	; 0xb0f1
	tax	; 0xb0f3
	sec	; 0xb0f4
	rts	; 0xb0f5
	lda #$0d	; 0xb0f6
	sta $0d5d	; 0xb0f8
	ldx #$00	; 0xb0fb
	stx $0d5e	; 0xb0fd
	jsr $b06b	; 0xb100
	bcs $b14e	; 0xb103
	cmp #$22	; 0xb105
	bne $b10d	; 0xb107
	iny	; 0xb109
	sta $0d5d	; 0xb10a
	lda (txt_ptr),y	; 0xb10d
	cmp #$0d	; 0xb10f
	beq $b13f	; 0xb111
	cmp #$20	; 0xb113
	bne $b122	; 0xb115
	bcc $b16b	; 0xb117
	lda $0d5d	; 0xb119
	cmp #$22	; 0xb11c
	bne $b148	; 0xb11e
	lda #$20	; 0xb120
	cmp #$22	; 0xb122
	beq $b13f	; 0xb124
	cmp #$2a	; 0xb126
	beq $b15b	; 0xb128
	cmp #$61	; 0xb12a
	bcc $b134	; 0xb12c
	cmp #$7b	; 0xb12e
	bcs $b134	; 0xb130
	eor #$20	; 0xb132
	sta $0d5f,x	; 0xb134
	iny	; 0xb137
	inx	; 0xb138
	cpx #$0c	; 0xb139
	bne $b10d	; 0xb13b
	lda (txt_ptr),y	; 0xb13d
	cmp $0d5d	; 0xb13f
	bne $b16b	; 0xb142
	cmp #$0d	; 0xb144
	beq $b14e	; 0xb146
	iny	; 0xb148
	jsr $b06b	; 0xb149
	bcc $b16b	; 0xb14c
	stx $0d5c	; 0xb14e
	cpx #$0c	; 0xb151
	beq $b15a	; 0xb153
	lda #$00	; 0xb155
	sta $0d5f,x	; 0xb157
	rts	; 0xb15a
	sta $0d5e	; 0xb15b
	lda $0d5d	; 0xb15e
	cmp #$0d	; 0xb161
	beq $b148	; 0xb163
	iny	; 0xb165
	lda (txt_ptr),y	; 0xb166
	jmp $b13f	; 0xb168
	jmp syntax	; 0xb16b
	ldy #$00	; 0xb16e
	ldx $0d5c	; 0xb170
	beq $b18c	; 0xb173
	lda (txt_ptr),y	; 0xb175
	beq $b19e	; 0xb177
	cmp #$61	; 0xb179
	bcc $b183	; 0xb17b
	cmp #$7b	; 0xb17d
	bcs $b183	; 0xb17f
	eor #$20	; 0xb181
	cmp $0d5f,y	; 0xb183
	bne $b19e	; 0xb186
	iny	; 0xb188
	dex	; 0xb189
	bne $b175	; 0xb18a
	lda (txt_ptr),y	; 0xb18c
	beq $b19c	; 0xb18e
	lda $0d5c	; 0xb190
	cmp #$0c	; 0xb193
	beq $b19c	; 0xb195
	lda $0d5e	; 0xb197
	beq $b19e	; 0xb19a
	clc	; 0xb19c
	rts	; 0xb19d
	sec	; 0xb19e
	rts	; 0xb19f
	bcs $b1a7	; 0xb1a0
	lda #$20	; 0xb1a2
	jsr OSWRCH	; 0xb1a4
	ldx #$20	; 0xb1a7
	ldy #$04	; 0xb1a9
	lda $0d56	; 0xb1ab
	jsr $b1e1	; 0xb1ae
	lda $0d55	; 0xb1b1
	jsr $b1e1	; 0xb1b4
	lda #$20	; 0xb1b7
	jsr OSWRCH	; 0xb1b9
	ldy #$00	; 0xb1bc
	lda (txt_ptr),y	; 0xb1be
	beq $b1ca	; 0xb1c0
	jsr OSWRCH	; 0xb1c2
	iny	; 0xb1c5
	cpy #$0c	; 0xb1c6
	bne $b1be	; 0xb1c8
	lda #$20	; 0xb1ca
	jsr OSWRCH	; 0xb1cc
	iny	; 0xb1cf
	cpy #$0d	; 0xb1d0
	bne $b1cc	; 0xb1d2
	tax	; 0xb1d4
	ldy #$0f	; 0xb1d5
	lda (txt_ptr),y	; 0xb1d7
	bne $b1dd	; 0xb1d9
	ldx #$50	; 0xb1db
	txa	; 0xb1dd
	jmp OSWRCH	; 0xb1de
	pha	; 0xb1e1
	lsr	; 0xb1e2
	lsr	; 0xb1e3
	lsr	; 0xb1e4
	lsr	; 0xb1e5
	jsr $b1ea	; 0xb1e6
	pla	; 0xb1e9
	and #$0f	; 0xb1ea
	beq $b1f6	; 0xb1ec
	ldx #$30	; 0xb1ee
	clc	; 0xb1f0
	adc #$30	; 0xb1f1
	jmp OSWRCH	; 0xb1f3
	dey	; 0xb1f6
	bne $b1fb	; 0xb1f7
	ldx #$30	; 0xb1f9
	txa	; 0xb1fb
	jmp OSWRCH	; 0xb1fc
	ldx #$00	; 0xb1ff
	pla	; 0xb201
	sta data_ptr	; 0xb202
	pla	; 0xb204
	sta $a1	; 0xb205
	ldy #$00	; 0xb207
	beq $b212	; 0xb209
	lda (data_ptr),y	; 0xb20b
	beq $b21a	; 0xb20d
	jsr $b221	; 0xb20f
	inc data_ptr	; 0xb212
	bne $b20b	; 0xb214
	inc $a1	; 0xb216
	bne $b20b	; 0xb218
	lda $a1	; 0xb21a
	pha	; 0xb21c
	lda data_ptr	; 0xb21d
	pha	; 0xb21f
	rts	; 0xb220
	cpx #$00	; 0xb221
	bne $b228	; 0xb223
	jmp OSWRCH	; 0xb225
	sta $0100,x	; 0xb228
	inx	; 0xb22b
	rts	; 0xb22c
	!byte $08, $10, $1c, $22, $43, $49, $4f, $58
	!text "(<drv>)", $00, "<dno>/<dsp>", $00, "<dno>", $00, "((<from dno>) <to dno>) (<adsp>)", $00, "<drv>", $00, "<fsp>", $00, "(<mode>)", $00, "(<rom>)", $00
print_param	pha	; 0xb28d
	lsr	; 0xb28e
	lsr	; 0xb28f
	lsr	; 0xb290
	lsr	; 0xb291
	jsr $b298	; 0xb292
	pla	; 0xb295
	and #$0f	; 0xb296
	tay	; 0xb298
	beq $b2af	; 0xb299
	lda #$20	; 0xb29b
	jsr $b221	; 0xb29d
	lda $b22c,y	; 0xb2a0
	tay	; 0xb2a3
	lda $b22d,y	; 0xb2a4
	beq $b2af	; 0xb2a7
	jsr $b221	; 0xb2a9
	iny	; 0xb2ac
	bne $b2a4	; 0xb2ad
	rts	; 0xb2af
syntax	ldx #$00	; 0xb2b0
	stx $0100	; 0xb2b2
	inx	; 0xb2b5
	jsr $b201	; 0xb2b6
	!text $1a, "Syntax: ", $00
	ldy $b5	; 0xb2c3
	lda cmd_table,y	; 0xb2c5
	bmi $b2d0	; 0xb2c8
	jsr $b221	; 0xb2ca
	iny	; 0xb2cd
	bne $b2c5	; 0xb2ce
	iny	; 0xb2d0
	iny	; 0xb2d1
	lda cmd_table,y	; 0xb2d2
	iny	; 0xb2d5
	sty $b5	; 0xb2d6
	jsr print_param	; 0xb2d8
	cpx #$00	; 0xb2db
	beq $b2e7	; 0xb2dd
	lda #$00	; 0xb2df
	sta $0100,x	; 0xb2e1
	jmp $0100	; 0xb2e4
	rts	; 0xb2e7
	jmp syntax	; 0xb2e8
	jsr $b06b	; 0xb2eb
	bcs $b307	; 0xb2ee
	jsr $b07e	; 0xb2f0
	bcs syntax	; 0xb2f3
	pha	; 0xb2f5
	jsr $b06b	; 0xb2f6
	pla	; 0xb2f9
	bcc syntax	; 0xb2fa
	bne $b324	; 0xb2fc
	txa	; 0xb2fe
	sta $0d5b	; 0xb2ff
	cmp #$04	; 0xb302
	bcs $b324	; 0xb304
	rts	; 0xb306
	lda cur_drv	; 0xb307
	rts	; 0xb309
	jsr $b06b	; 0xb30a
	bcs syntax	; 0xb30d
	jsr $b07e	; 0xb30f
	bcs syntax	; 0xb312
	pha	; 0xb314
	jsr $b06b	; 0xb315
	pla	; 0xb318
	bcc syntax	; 0xb319
	rts	; 0xb31b
	jsr $b06b	; 0xb31c
	bcs syntax	; 0xb31f
	jmp $b375	; 0xb321
	jsr report_error	; 0xb324
	!text $cd, "Bad drive", $00
	jsr report_error	; 0xb332
	!text $d6, "Disk not found", $00
	jsr $b06b	; 0xb345
	bcs $b2e8	; 0xb348
	lda #$ff	; 0xb34a
	jsr $b35d	; 0xb34c
	php	; 0xb34f
	cpx #$04	; 0xb350
	bcs $b387	; 0xb352
	plp	; 0xb354
	rts	; 0xb355
	jsr $b06b	; 0xb356
	bcs $b2e8	; 0xb359
	lda cur_drv	; 0xb35b
	sta $0d5b	; 0xb35d
	jsr $b07e	; 0xb360
	bcs $b38b	; 0xb363
	pha	; 0xb365
	jsr $b06b	; 0xb366
	bcs $b380	; 0xb369
	pla	; 0xb36b
	bne $b324	; 0xb36c
	cpx #$04	; 0xb36e
	bcs $b324	; 0xb370
	stx $0d5b	; 0xb372
	jsr $b07e	; 0xb375
	bcs $b38b	; 0xb378
	pha	; 0xb37a
	jsr $b06b	; 0xb37b
	bcc $b387	; 0xb37e
	pla	; 0xb380
	ror	; 0xb381
	txa	; 0xb382
	ldx $0d5b	; 0xb383
	rts	; 0xb386
	pla	; 0xb387
	jmp syntax	; 0xb388
	jsr $b0f6	; 0xb38b
	jsr $adbb	; 0xb38e
	lda $0d5c	; 0xb391
	beq $b388	; 0xb394
	lda $0d5e	; 0xb396
	bne $b388	; 0xb399
	lda $0d54	; 0xb39b
	bmi $b332	; 0xb39e
	jsr $b16e	; 0xb3a0
	bcc $b3ab	; 0xb3a3
	jsr $ade0	; 0xb3a5
	jmp $b39b	; 0xb3a8
	lda $0d54	; 0xb3ab
	ror	; 0xb3ae
	lda $0d53	; 0xb3af
	ldx $0d5b	; 0xb3b2
	rts	; 0xb3b5
	jsr $b31c	; 0xb3b6
	ldx cur_drv	; 0xb3b9
	jsr $ac1b	; 0xb3bb
	jmp $9407	; 0xb3be
	jsr $b356	; 0xb3c1
	jmp $ac1b	; 0xb3c4
	lda #$00	; 0xb3c7
	sta $0d57	; 0xb3c9
	sta $0d58	; 0xb3cc
	jsr $b07e	; 0xb3cf
	bcs $b401	; 0xb3d2
	stx $0d59	; 0xb3d4
	stx $0d53	; 0xb3d7
	sta $0d5a	; 0xb3da
	sta $0d54	; 0xb3dd
	jsr $b07e	; 0xb3e0
	bcs $b40a	; 0xb3e3
	stx $0d59	; 0xb3e5
	sta $0d5a	; 0xb3e8
	cpx $0d53	; 0xb3eb
	sbc $0d54	; 0xb3ee
	bpl $b412	; 0xb3f1
	jsr report_error	; 0xb3f3
	!text $ff, "Bad range", $00
	ldx #$fe	; 0xb401
	stx $0d59	; 0xb403
	inx	; 0xb406
	stx $0d5a	; 0xb407
	lda #$00	; 0xb40a
	sta $0d53	; 0xb40c
	sta $0d54	; 0xb40f
	inc $0d59	; 0xb412
	bne $b41a	; 0xb415
	inc $0d5a	; 0xb417
	jsr $b0f6	; 0xb41a
	lda $0d54	; 0xb41d
	ror	; 0xb420
	lda $0d53	; 0xb421
	jsr $ad85	; 0xb424
	ldx #$00	; 0xb427
	lda $0d5c	; 0xb429
	bne $b432	; 0xb42c
	dex	; 0xb42e
	stx $0d5e	; 0xb42f
	lda $0d54	; 0xb432
	bmi $b46a	; 0xb435
	lda $0d53	; 0xb437
	cmp $0d59	; 0xb43a
	lda $0d54	; 0xb43d
	sbc $0d5a	; 0xb440
	bcs $b46a	; 0xb443
	jsr $b16e	; 0xb445
	bcs $b460	; 0xb448
	jsr $b1a0	; 0xb44a
	sed	; 0xb44d
	clc	; 0xb44e
	lda $0d57	; 0xb44f
	adc #$01	; 0xb452
	sta $0d57	; 0xb454
	lda $0d58	; 0xb457
	adc #$00	; 0xb45a
	sta $0d58	; 0xb45c
	cld	; 0xb45f
	bit $ff	; 0xb460
	bmi $b4ab	; 0xb462
	jsr $ade0	; 0xb464
	jmp $b432	; 0xb467
	lda #$86	; 0xb46a
	jsr OSBYTE	; 0xb46c
	cpx #$00	; 0xb46f
	beq $b476	; 0xb471
	jsr OSNEWL	; 0xb473
	lda $0d58	; 0xb476
	ldx #$00	; 0xb479
	ldy #$04	; 0xb47b
	jsr $b1e1	; 0xb47d
	lda $0d57	; 0xb480
	jsr $b1e1	; 0xb483
	jsr $b1ff	; 0xb486
	!text " disk", $00
	lda $0d58	; 0xb48f
	bne $b499	; 0xb492
	dec $0d57	; 0xb494
	beq $b49e	; 0xb497
	lda #$73	; 0xb499
	jsr OSWRCH	; 0xb49b
	jsr $b1ff	; 0xb49e
	!text " found", $00
	jmp OSNEWL	; 0xb4a8
	jmp err_escape	; 0xb4ab
	jmp syntax	; 0xb4ae
	jsr $b06b	; 0xb4b1
	bcc $b4ae	; 0xb4b4
	ldx #$00	; 0xb4b6
	stx $0d57	; 0xb4b8
	stx $0d58	; 0xb4bb
	stx $0d59	; 0xb4be
	stx $0d5a	; 0xb4c1
	lda #$80	; 0xb4c4
	jsr $ac9c	; 0xb4c6
	lda #$10	; 0xb4c9
	sta txt_ptr	; 0xb4cb
	lda #$0e	; 0xb4cd
	sta $f3	; 0xb4cf
	ldy #$0f	; 0xb4d1
	lda (txt_ptr),y	; 0xb4d3
	cmp #$ff	; 0xb4d5
	beq $b51b	; 0xb4d7
	sed	; 0xb4d9
	tay	; 0xb4da
	bpl $b4eb	; 0xb4db
	clc	; 0xb4dd
	lda $0d57	; 0xb4de
	adc #$01	; 0xb4e1
	sta $0d57	; 0xb4e3
	bcc $b4eb	; 0xb4e6
	inc $0d58	; 0xb4e8
	clc	; 0xb4eb
	lda $0d59	; 0xb4ec
	adc #$01	; 0xb4ef
	sta $0d59	; 0xb4f1
	bcc $b4f9	; 0xb4f4
	inc $0d5a	; 0xb4f6
	cld	; 0xb4f9
	clc	; 0xb4fa
	lda txt_ptr	; 0xb4fb
	adc #$10	; 0xb4fd
	sta txt_ptr	; 0xb4ff
	bne $b4d1	; 0xb501
	lda $f3	; 0xb503
	eor #$01	; 0xb505
	sta $f3	; 0xb507
	ror	; 0xb509
	bcs $b4d1	; 0xb50a
	lda cur_drv_cat	; 0xb50c
	adc #$02	; 0xb50f
	cmp #data_ptr	; 0xb511
	beq $b51b	; 0xb513
	jsr $ac9c	; 0xb515
	jmp $b4d1	; 0xb518
	ldy #$04	; 0xb51b
	ldx #$00	; 0xb51d
	lda $0d58	; 0xb51f
	jsr $b1e1	; 0xb522
	lda $0d57	; 0xb525
	jsr $b1e1	; 0xb528
	jsr $b1ff	; 0xb52b
	!text " of ", $00
	ldx #$00	; 0xb533
	ldy #$04	; 0xb535
	lda $0d5a	; 0xb537
	jsr $b1e1	; 0xb53a
	lda $0d59	; 0xb53d
	jsr $b1e1	; 0xb540
	jsr $b1ff	; 0xb543
	!text " disk"
	brk	; 0xb54b
	lda $0d5a	; 0xb54c
	bne $b558	; 0xb54f
	lda $0d59	; 0xb551
	cmp #$01	; 0xb554
	beq $b55d	; 0xb556
	lda #$73	; 0xb558
	jsr OSWRCH	; 0xb55a
	jsr $b1ff	; 0xb55d
	!text " free (unformatted)", $00
	jmp OSNEWL	; 0xb574
	jsr $b2eb	; 0xb577
	ldx #$04	; 0xb57a
	stx $0d5b	; 0xb57c
	ldx #$00	; 0xb57f
	bcs $b589	; 0xb581
	tax	; 0xb583
	inx	; 0xb584
	stx $0d5b	; 0xb585
	dex	; 0xb588
	txa	; 0xb589
	pha	; 0xb58a
	ldx #$20	; 0xb58b
	ldy #$02	; 0xb58d
	jsr $b1e1	; 0xb58f
	lda #$3a	; 0xb592
	jsr OSWRCH	; 0xb594
	pla	; 0xb597
	tax	; 0xb598
	pha	; 0xb599
	lda $0d10,x	; 0xb59a
	bmi $b5ae	; 0xb59d
	ror	; 0xb59f
	lda $0d0c,x	; 0xb5a0
	jsr $ad85	; 0xb5a3
	cmp #$ff	; 0xb5a6
	beq $b5ae	; 0xb5a8
	sec	; 0xb5aa
	jsr $b1a0	; 0xb5ab
	jsr OSNEWL	; 0xb5ae
	pla	; 0xb5b1
	tax	; 0xb5b2
	inx	; 0xb5b3
	cpx $0d5b	; 0xb5b4
	bcc $b589	; 0xb5b7
	rts	; 0xb5b9
	jmp syntax	; 0xb5ba
	lda #$00	; 0xb5bd
	beq $b5c3	; 0xb5bf
	lda #$0f	; 0xb5c1
	pha	; 0xb5c3
	jsr $b31c	; 0xb5c4
	jsr $abcd	; 0xb5c7
	bmi $b5da	; 0xb5ca
	pla	; 0xb5cc
	bcs $b5d4	; 0xb5cd
	sta buf,y	; 0xb5cf
	bcc $b5d7	; 0xb5d2
	sta $0f00,y	; 0xb5d4
	jmp $accd	; 0xb5d7
	cmp #$ff	; 0xb5da
	beq $b5e1	; 0xb5dc
	jmp $ac65	; 0xb5de
	jmp $ac4b	; 0xb5e1
	jsr $9bbd	; 0xb5e4
	jsr $b30a	; 0xb5e7
	ror	; 0xb5ea
	php	; 0xb5eb
	txa	; 0xb5ec
	pha	; 0xb5ed
	jsr $abcd	; 0xb5ee
	bmi $b5da	; 0xb5f1
	pla	; 0xb5f3
	plp	; 0xb5f4
	jsr $ad85	; 0xb5f5
	jsr $b1ff	; 0xb5f8
	!text "Kill", $00
	sec	; 0xb600
	jsr $b1a0	; 0xb601
	jsr $b1ff	; 0xb604
	!text " : ", $00
	jsr $9c9e	; 0xb60b
	php	; 0xb60e
	jsr OSNEWL	; 0xb60f
	plp	; 0xb612
	bne $b61e	; 0xb613
	ldy #$0f	; 0xb615
	lda #$f0	; 0xb617
	sta (txt_ptr),y	; 0xb619
	jmp $accd	; 0xb61b
	rts	; 0xb61e
	lda #$00	; 0xb61f
	jsr $b629	; 0xb621
	jmp $ab6f	; 0xb624
	lda #$01	; 0xb627
	sta $0d5f	; 0xb629
	jsr $b30a	; 0xb62c
	ror	; 0xb62f
	php	; 0xb630
	txa	; 0xb631
	pha	; 0xb632
	jsr $abcd	; 0xb633
	bpl $b65e	; 0xb636
	tax	; 0xb638
	inx	; 0xb639
	beq $b679	; 0xb63a
	tya	; 0xb63c
	and #$f0	; 0xb63d
	sta txt_ptr	; 0xb63f
	ldy #$0e	; 0xb641
	bcc $b646	; 0xb643
	iny	; 0xb645
	sty $f3	; 0xb646
	ldy #$0f	; 0xb648
	tya	; 0xb64a
	sta (txt_ptr),y	; 0xb64b
	lda $0d5f	; 0xb64d
	bne $b658	; 0xb650
	dey	; 0xb652
	sta (txt_ptr),y	; 0xb653
	dey	; 0xb655
	bpl $b653	; 0xb656
	jsr $accd	; 0xb658
	pla	; 0xb65b
	plp	; 0xb65c
	rts	; 0xb65d
	jsr report_error	; 0xb65e
	!text $ff, "Disk already formatted", $00
	jmp $ac4b	; 0xb679
	jsr $b2eb	; 0xb67c
	sta $0d5b	; 0xb67f
	jsr $b6e0	; 0xb682
	php	; 0xb685
	pha	; 0xb686
	lda #$0f	; 0xb687
	sta (txt_ptr),y	; 0xb689
	dey	; 0xb68b
	lda #$00	; 0xb68c
	sta (txt_ptr),y	; 0xb68e
	dey	; 0xb690
	bpl $b68e	; 0xb691
	jsr $acb8	; 0xb693
	pla	; 0xb696
	plp	; 0xb697
	php	; 0xb698
	pha	; 0xb699
	jsr $ab6f	; 0xb69a
	pla	; 0xb69d
	plp	; 0xb69e
	php	; 0xb69f
	pha	; 0xb6a0
	ldx $0d5b	; 0xb6a1
	jsr $ac1b	; 0xb6a4
	jsr $b1ff	; 0xb6a7
	!text "Disk ", $00
	pla	; 0xb6b0
	plp	; 0xb6b1
	jsr bin2bcd	; 0xb6b2
	stx $0d55	; 0xb6b5
	ldx #$00	; 0xb6b8
	ldy #$04	; 0xb6ba
	jsr $b1e1	; 0xb6bc
	lda $0d55	; 0xb6bf
	jsr $b1e1	; 0xb6c2
	jsr $b1ff	; 0xb6c5
	!text " in drive ", $00
	lda $0d5b	; 0xb6d3
	ldx #$00	; 0xb6d6
	ldy #$02	; 0xb6d8
	jsr $b1e1	; 0xb6da
	jmp OSNEWL	; 0xb6dd
	lda #$10	; 0xb6e0
	sta txt_ptr	; 0xb6e2
	lda #$0e	; 0xb6e4
	sta $f3	; 0xb6e6
	lda #$80	; 0xb6e8
	sta start_opts	; 0xb6ea
	jsr $aca1	; 0xb6ed
	lda #$00	; 0xb6f0
	sta $0d53	; 0xb6f2
	sta $0d54	; 0xb6f5
	ldy #$0f	; 0xb6f8
	lda (txt_ptr),y	; 0xb6fa
	bpl $b70a	; 0xb6fc
	cmp #$ff	; 0xb6fe
	beq $b738	; 0xb700
	lda $0d54	; 0xb702
	ror	; 0xb705
	lda $0d53	; 0xb706
	rts	; 0xb709
	inc $0d53	; 0xb70a
	bne $b712	; 0xb70d
	inc $0d54	; 0xb70f
	clc	; 0xb712
	lda txt_ptr	; 0xb713
	adc #$10	; 0xb715
	sta txt_ptr	; 0xb717
	bne $b6fa	; 0xb719
	lda $f3	; 0xb71b
	eor #$01	; 0xb71d
	sta $f3	; 0xb71f
	and #$01	; 0xb721
	bne $b6fa	; 0xb723
	clc	; 0xb725
	lda start_opts	; 0xb726
	adc #$02	; 0xb729
	cmp #data_ptr	; 0xb72b
	beq $b738	; 0xb72d
	sta start_opts	; 0xb72f
	jsr $aca1	; 0xb732
	jmp $b6f8	; 0xb735
	jsr report_error	; 0xb738
	!text $ff, "No free disks", $00
	jsr $b345	; 0xb74a
	php	; 0xb74d
	pha	; 0xb74e
	txa	; 0xb74f
	pha	; 0xb750
	lda #$80	; 0xb751
	jsr $aca1	; 0xb753
	pla	; 0xb756
	tax	; 0xb757
	pla	; 0xb758
	sta buf,x	; 0xb759
	pla	; 0xb75c
	and #$01	; 0xb75d
	sta $0e04,x	; 0xb75f
	jmp $acb8	; 0xb762
	jsr $b06b	; 0xb765
	ldx #$00	; 0xb768
	bcs $b777	; 0xb76a
	jsr $b07e	; 0xb76c
	bcs $b787	; 0xb76f
	cmp #$00	; 0xb771
	beq $b777	; 0xb773
	ldx #$01	; 0xb775
	stx mmc_first_mode	; 0xb777
	jsr fscv6_shutdown_filesys	; 0xb77a
	ldx #$ff	; 0xb77d
	lda #$61	; 0xb77f
	sta start_opts	; 0xb781
	jmp $ad17	; 0xb784
	jsr report_error	; 0xb787
	!text $ff, "Bad driver mode", $00
	ldx #$1e	; 0xb79b
	ldy mmc_status,x	; 0xb79d
	lda $0d21,x	; 0xb7a0
	sta mmc_status,x	; 0xb7a3
	tya	; 0xb7a6
	sta $0d21,x	; 0xb7a7
	dex	; 0xb7aa
	bpl $b79d	; 0xb7ab
	stx cur_drv_cat	; 0xb7ad
	rts	; 0xb7b0
drom	lda #$00	; 0xb7b1
	sta attempts	; 0xb7b3
	jsr GSINIT	; 0xb7b5
	beq $b825	; 0xb7b8
	lda (txt_ptr),y	; 0xb7ba
	iny	; 0xb7bc
	cmp #$20	; 0xb7bd
	beq $b7ba	; 0xb7bf
	lda (txt_ptr),y	; 0xb7c1
	dey	; 0xb7c3
	cmp #$20	; 0xb7c4
	bne $b7eb	; 0xb7c6
	lda (txt_ptr),y	; 0xb7c8
	sec	; 0xb7ca
	sbc #$30	; 0xb7cb
	bmi $b7eb	; 0xb7cd
	cmp #$0a	; 0xb7cf
	bcc $b7e7	; 0xb7d1
	sbc #$07	; 0xb7d3
	cmp #$0a	; 0xb7d5
	bcc $b7eb	; 0xb7d7
	cmp #$10	; 0xb7d9
	bcc $b7e7	; 0xb7db
	sbc #$20	; 0xb7dd
	cmp #$0a	; 0xb7df
	bcc $b7eb	; 0xb7e1
	cmp #$10	; 0xb7e3
	bcs $b7eb	; 0xb7e5
	iny	; 0xb7e7
	iny	; 0xb7e8
	sta attempts	; 0xb7e9
	lda $f4	; 0xb7eb
	sta bytes_last_sector	; 0xb7ed
	tya	; 0xb7ef
	pha	; 0xb7f0
	ldy #$24	; 0xb7f1
	lda $b8e7,y	; 0xb7f3
	sta start_opts,y	; 0xb7f6
	dey	; 0xb7f9
	bpl $b7f3	; 0xb7fa
	ldx #$0f	; 0xb7fc
	jsr start_opts	; 0xb7fe
	pla	; 0xb801
	tay	; 0xb802
	stx attempts	; 0xb803
	txa	; 0xb805
	bpl $b81c	; 0xb806
	jsr report_error	; 0xb808
	!text $ff, "No Sideways RAM", $00
	jsr $8262	; 0xb81c
	clc	; 0xb81f
	jsr GSINIT	; 0xb820
	bne $b828	; 0xb823
	jmp syntax	; 0xb825
	jsr $80fe	; 0xb828
	tya	; 0xb82b
	jsr $8271	; 0xb82c
	lda $0f0e,y	; 0xb82f
	pha	; 0xb832
	and #$03	; 0xb833
	sta $a1	; 0xb835
	lda $0f0f,y	; 0xb837
	sta data_ptr	; 0xb83a
	pla	; 0xb83c
	lsr	; 0xb83d
	lsr	; 0xb83e
	and #$03	; 0xb83f
	beq $b847	; 0xb841
	eor #$03	; 0xb843
	bne $b85d	; 0xb845
	lda $0f0c,y	; 0xb847
	bne $b85d	; 0xb84a
	lda $0f0d,y	; 0xb84c
	bmi $b85d	; 0xb84f
	sta sector_count	; 0xb851
	ldx #$05	; 0xb853
	cmp #$40	; 0xb855
	beq $b86e	; 0xb857
	asl	; 0xb859
	dex	; 0xb85a
	bne $b855	; 0xb85b
	jsr report_error	; 0xb85d
	!text $ff, "Bad ROM size", $00
	lsr sector_count	; 0xb86e
	ldx cur_drv	; 0xb870
	jsr $aa7e	; 0xb872
	clc	; 0xb875
	lda sector	; 0xb876
	adc data_ptr	; 0xb878
	sta sector	; 0xb87a
	lda sector+1	; 0xb87c
	adc $a1	; 0xb87e
	sta sector+1	; 0xb880
	lda #$00	; 0xb882
	adc sector+2	; 0xb884
	sta sector+2	; 0xb886
	ldy #$1c	; 0xb888
	lda $b8cb,y	; 0xb88a
	sta start_opts,y	; 0xb88d
	dey	; 0xb890
	bpl $b88a	; 0xb891
	lda attempts	; 0xb893
	sta $0d53	; 0xb895
	lda bytes_last_sector	; 0xb898
	sta $0d69	; 0xb89a
	jsr mmc_check	; 0xb89d
	lda #$ff	; 0xb8a0
	sta cur_drv_cat	; 0xb8a2
	jsr mmc_read_cat	; 0xb8a5
	jsr start_opts	; 0xb8a8
	clc	; 0xb8ab
	lda sector	; 0xb8ac
	adc #$02	; 0xb8ae
	sta sector	; 0xb8b0
	bcc $b8ba	; 0xb8b2
	inc sector+1	; 0xb8b4
	bne $b8ba	; 0xb8b6
	inc sector+1	; 0xb8b8
	inc $0d5e	; 0xb8ba
	inc $0d5e	; 0xb8bd
	inc $0d64	; 0xb8c0
	inc $0d64	; 0xb8c3
	dec sector_count	; 0xb8c6
	bne $b8a5	; 0xb8c8
	rts	; 0xb8ca
	lda #$00	; 0xb8cb
	sta ROM_PAGE	; 0xb8cd
	ldy #$00	; 0xb8d0
	lda buf,y	; 0xb8d2
	sta lang_entry,y	; 0xb8d5
	lda $0f00,y	; 0xb8d8
	sta $8100,y	; 0xb8db
	dey	; 0xb8de
	bne $b8d2	; 0xb8df
	lda #$00	; 0xb8e1
	sta ROM_PAGE	; 0xb8e3
	rts	; 0xb8e6
	stx ROM_PAGE	; 0xb8e7
	lda $bfff	; 0xb8ea
	tay	; 0xb8ed
	eor #$ff	; 0xb8ee
	sta $bfff	; 0xb8f0
	tya	; 0xb8f3
	eor $bfff	; 0xb8f4
	sty $bfff	; 0xb8f7
	cmp #$ff	; 0xb8fa
	bne $b902	; 0xb8fc
	dec attempts	; 0xb8fe
	bmi $b905	; 0xb900
	dex	; 0xb902
	bpl $b8e7	; 0xb903
	lda bytes_last_sector	; 0xb905
	sta ROM_PAGE	; 0xb907
	rts	; 0xb90a
mmc_set_fdc_drv	pha	; 0xb90b
	lda cur_drv	; 0xb90c
	sta $0d20	; 0xb90e
	pla	; 0xb911
	rts	; 0xb912
mmc_osword_7f	ldy #$00	; 0xb913
	lda (temp),y	; 0xb915
	bmi $b920	; 0xb917
	and #$03	; 0xb919
	sta cur_drv	; 0xb91b
	sta $0d20	; 0xb91d
	ldy #$05	; 0xb920
	lda (temp),y	; 0xb922
	clc	; 0xb924
	adc #$07	; 0xb925
	sta $be	; 0xb927
	jsr $b937	; 0xb929
	ldy $be	; 0xb92c
	bcs $b932	; 0xb92e
	lda #$00	; 0xb930
	sta (temp),y	; 0xb932
	lda #$00	; 0xb934
	rts	; 0xb936
	iny	; 0xb937
	lda (temp),y	; 0xb938
	tax	; 0xb93a
	and #$3f	; 0xb93b
	sta $bf	; 0xb93d
	cmp #$3a	; 0xb93f
	bne $b96e	; 0xb941
	lda $be	; 0xb943
	cmp #$09	; 0xb945
	bne $b95c	; 0xb947
	iny	; 0xb949
	lda (temp),y	; 0xb94a
	cmp #$23	; 0xb94c
	bne $b95c	; 0xb94e
	iny	; 0xb950
	lda (temp),y	; 0xb951
	and #$20	; 0xb953
	beq $b959	; 0xb955
	lda #$02	; 0xb957
	sta $0d20	; 0xb959
	clc	; 0xb95c
	rts	; 0xb95d
	lda #$1e	; 0xb95e
	sec	; 0xb960
	rts	; 0xb961
	lda #$10	; 0xb962
	sec	; 0xb964
	rts	; 0xb965
	lda #$12	; 0xb966
	sec	; 0xb968
	rts	; 0xb969
	lda #$ff	; 0xb96a
	sec	; 0xb96c
	rts	; 0xb96d
	lda cur_drv	; 0xb96e
	ror	; 0xb970
	txa	; 0xb971
	bcc $b976	; 0xb972
	eor #$c0	; 0xb974
	rol	; 0xb976
	bcc $b985	; 0xb977
	rol	; 0xb979
	bcs $b95e	; 0xb97a
	lda $0d20	; 0xb97c
	and #$02	; 0xb97f
	ora #$01	; 0xb981
	bne $b98d	; 0xb983
	rol	; 0xb985
	bcc $b962	; 0xb986
	lda $0d20	; 0xb988
	and #$02	; 0xb98b
	sta $0d20	; 0xb98d
	tax	; 0xb990
	stx $c0	; 0xb991
	lda $0d10,x	; 0xb993
	bmi $b962	; 0xb996
	lda $bf	; 0xb998
	cmp #$13	; 0xb99a
	beq $b9a9	; 0xb99c
	cmp #$0b	; 0xb99e
	bne $b95c	; 0xb9a0
	lda $0d1c,x	; 0xb9a2
	cmp #$54	; 0xb9a5
	bne $b966	; 0xb9a7
	lda $be	; 0xb9a9
	cmp #$0a	; 0xb9ab
	bne $b96a	; 0xb9ad
	jsr mmc_check	; 0xb9af
	lda #$00	; 0xb9b2
	sta $c5	; 0xb9b4
	iny	; 0xb9b6
	lda (temp),y	; 0xb9b7
	cmp #$50	; 0xb9b9
	bcs $b95e	; 0xb9bb
	asl	; 0xb9bd
	sta $c4	; 0xb9be
	asl	; 0xb9c0
	rol $c5	; 0xb9c1
	asl	; 0xb9c3
	rol $c5	; 0xb9c4
	adc $c4	; 0xb9c6
	sta $c4	; 0xb9c8
	bcc $b9ce	; 0xb9ca
	inc $c5	; 0xb9cc
	iny	; 0xb9ce
	lda (temp),y	; 0xb9cf
	cmp #$0a	; 0xb9d1
	bcs $ba37	; 0xb9d3
	clc	; 0xb9d5
	adc $c4	; 0xb9d6
	sta $c4	; 0xb9d8
	bcc $b9de	; 0xb9da
	inc $c5	; 0xb9dc
	iny	; 0xb9de
	lda (temp),y	; 0xb9df
	and #$1f	; 0xb9e1
	sta sector_count	; 0xb9e3
	beq $ba2d	; 0xb9e5
	clc	; 0xb9e7
	adc $c4	; 0xb9e8
	tax	; 0xb9ea
	lda #$00	; 0xb9eb
	adc $c5	; 0xb9ed
	cmp #$03	; 0xb9ef
	bcc $b9f9	; 0xb9f1
	bne $ba37	; 0xb9f3
	cpx #$21	; 0xb9f5
	bcs $ba37	; 0xb9f7
	ldx $c0	; 0xb9f9
	lda $0d10,x	; 0xb9fb
	ror	; 0xb9fe
	lda $0d0c,x	; 0xb9ff
	jsr $aa87	; 0xba02
	clc	; 0xba05
	lda sector	; 0xba06
	adc $c4	; 0xba08
	sta sector	; 0xba0a
	lda sector+1	; 0xba0c
	adc $c5	; 0xba0e
	sta sector+1	; 0xba10
	bcc $ba16	; 0xba12
	inc sector+2	; 0xba14
	ldy #$00	; 0xba16
	sty bytes_last_sector	; 0xba18
	iny	; 0xba1a
	lda (temp),y	; 0xba1b
	sta data_ptr	; 0xba1d
	iny	; 0xba1f
	lda (temp),y	; 0xba20
	sta $a1	; 0xba22
	lda $bf	; 0xba24
	cmp #$13	; 0xba26
	beq $ba2f	; 0xba28
	jsr $abab	; 0xba2a
	clc	; 0xba2d
	rts	; 0xba2e
	jsr mmc_read_block	; 0xba2f
	jsr $a0cd	; 0xba32
	clc	; 0xba35
	rts	; 0xba36
	lda #$1e	; 0xba37
	sec	; 0xba39
	rts	; 0xba3a
	!text "TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TESS TE"
