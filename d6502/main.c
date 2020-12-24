/* 
 * Copyright (C) 2012 Chris McClelland
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *  
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <makestuff/common.h>
#include <makestuff/libbuffer.h>

struct Context {
	const uint8 *data;
	uint16 index;
	const uint16 orgAddr;
	const char *symbols[65536];
	char map[16384];
};

void loadSymbols(struct Context *cxt) {  //, const char *fileName) {
	cxt->symbols[0x0070] = "zp70";
	cxt->symbols[0x0072] = "zp72";
	cxt->symbols[0x00c7] = "filename_param";
	cxt->symbols[0x00ce] = "directory_param";
	cxt->symbols[0x00cf] = "cur_drv";
	cxt->symbols[0x1082] = "cur_drv_cat";
	cxt->symbols[0xffe3] = "OSASCI";
	cxt->symbols[0xffc5] = "GSREAD";
	cxt->symbols[0xffee] = "OSWRCH";
	cxt->symbols[0xffc2] = "GSINIT";
	cxt->symbols[0xffce] = "OSFIND";
	cxt->symbols[0xffd4] = "OSBPUT";
	cxt->symbols[0xffd7] = "OSBGET";
	cxt->symbols[0xffe0] = "OSRDCH";
	cxt->symbols[0xffe7] = "OSNEWL";
	cxt->symbols[0xfff1] = "OSWORD";
	cxt->symbols[0xfff4] = "OSBYTE";
	cxt->symbols[0xfff7] = "OSCLI";
	cxt->symbols[0x021e] = "FSCV";
	cxt->symbols[0x8000] = "lang_entry";
	cxt->symbols[0x8003] = "serv_entry";
	cxt->symbols[0x8033] = "brk100_errno";
	cxt->symbols[0x8022] = "err_bad";
	cxt->symbols[0x802b] = "err_file";
	cxt->symbols[0x805b] = "brk100_noerrno";
	cxt->symbols[0x83da] = "inc_word_ae";
	cxt->symbols[0x8065] = "prtstr";
	cxt->symbols[0x8074] = "prtstr_loop";
	cxt->symbols[0x8083] = "ptrstr_return";
	cxt->symbols[0x809c] = "prtchr";
	cxt->symbols[0x808a] = "prtstr_brk";
	cxt->symbols[0x80b8] = "prtchr_add100";
	cxt->symbols[0x83e1] = "remember_axy";
	cxt->symbols[0x991c] = "osbyte_ec";
	cxt->symbols[0x9917] = "osbyte_03a";
	cxt->symbols[0x9918] = "osbyte_03x";
	cxt->symbols[0x81c0] = "prt_filename";
	cxt->symbols[0x81fb] = "lsr6_and3";
	cxt->symbols[0x81fc] = "lsr5_and3";
	cxt->symbols[0x81fd] = "lsr4_and3";
	cxt->symbols[0x81fe] = "lsr3_and3";
	cxt->symbols[0x81ff] = "lsr2_and3";
	cxt->symbols[0x8200] = "lsr1_and3";
	cxt->symbols[0x8204] = "lsr5";
	cxt->symbols[0x8205] = "lsr4";
	cxt->symbols[0x8206] = "lsr3";
	cxt->symbols[0x8207] = "lsr2";
	cxt->symbols[0x8208] = "lsr1";
	cxt->symbols[0x80c2] = "prthex";
	cxt->symbols[0x80ca] = "prthex_ln";
	cxt->symbols[0x80d3] = "+";
	cxt->symbols[0x80f8] = "-";
	cxt->symbols[0x80fd] = "fsp_exit";
	cxt->symbols[0x8119] = "fsp_cont";
	cxt->symbols[0x812a] = "+";
	cxt->symbols[0x8177] = "fsp_cont3";
	//cxt->symbols[0x80] = "";
	cxt->symbols[0x8347] = "ld_cur_drv_cat";
	cxt->symbols[0x84e4] = "pc12";
	cxt->symbols[0x8501] = "pc14";
	cxt->symbols[0x856f] = "diskoptions_table";
	cxt->symbols[0x857f] = "get_next_block";
	cxt->symbols[0x859e] = "get_first_block";
	cxt->symbols[0x85b8] = "cmdtxt_access";
	cxt->symbols[0x85c1] = "cmdtxt_backup";
	cxt->symbols[0x85ca] = "cmdtxt_compact";
	cxt->symbols[0x85d4] = "cmdtxt_copy";
	cxt->symbols[0x85db] = "cmdtxt_delete";
	cxt->symbols[0x85e4] = "cmdtxt_destroy";
	cxt->symbols[0x85ee] = "cmdtxt_dir";
	cxt->symbols[0x85f4] = "cmdtxt_drive";
	cxt->symbols[0x85fc] = "cmdtxt_enable";
	cxt->symbols[0x8605] = "cmdtxt_info";
	cxt->symbols[0x860c] = "cmdtxt_lib";
	cxt->symbols[0x8612] = "cmdtxt_rename";
	cxt->symbols[0x861b] = "cmdtxt_title";
	cxt->symbols[0x8623] = "cmdtxt_wipe";
	cxt->symbols[0x862d] = "cmdtxt_build";
	cxt->symbols[0x8635] = "cmdtxt_disc";
	cxt->symbols[0x863c] = "cmdtxt_dump";
	cxt->symbols[0x8643] = "cmdtxt_list";
	cxt->symbols[0x864a] = "cmdtxt_type";
	cxt->symbols[0x8651] = "cmdtxt_disk";
	cxt->symbols[0x865b] = "hlptxt_dfs";
	cxt->symbols[0x8661] = "hlptxt_utils";
	cxt->symbols[0x866c] = "fscv3_unrecognised_cmd";
	cxt->symbols[0x86c3] = "cmd_wipe";
	cxt->symbols[0x86fe] = "cmd_delete";
	cxt->symbols[0x8710] = "cmd_destroy";
	cxt->symbols[0x8775] = "cmd_drive";
	cxt->symbols[0x884e] = "cmd_dir";
	cxt->symbols[0x8852] = "cmd_lib";
	cxt->symbols[0x88a3] = "cmd_title";
	cxt->symbols[0x88d2] = "cmd_access";
	cxt->symbols[0x8a39] = "cmd_enable";
	cxt->symbols[0x8a6d] = "cmd_rename";
	cxt->symbols[0x9455] = "serv_claim_absworkspace";
	cxt->symbols[0x9f9a] = "prt_newline";
	cxt->symbols[0x9a01] = "init_param";
	cxt->symbols[0x835d] = "get_drv_num";
	cxt->symbols[0x818e] = "bad_filename";
	cxt->symbols[0x82a0] = "get_cat_nextentry2";
	cxt->symbols[0x82cb] = "get_cat_nomatch_loop";
	cxt->symbols[0x8558] = "pc15";
	cxt->symbols[0x8678] = "unrecognised_loop";
	cxt->symbols[0x86ae] = "go_cmd_code";
	cxt->symbols[0x87b3] = "load_copyfileinfo_loop";
	cxt->symbols[0x880a] = "runfile_found";
	cxt->symbols[0x8876] = "-";
	cxt->symbols[0x888b] = "bad_directory";
	cxt->symbols[0x88a0] = "good_directory";
	cxt->symbols[0x88c3] = "goto_save_cat";
	cxt->symbols[0x88ec] = "file_found";
	cxt->symbols[0x89d7] = "createfile_endofdisk";
	cxt->symbols[0x8ddd] = "fscv7_handle_range";
	cxt->symbols[0x8de2] = "fscv6_shutdown_filesys";
	cxt->symbols[0x8e05] = "update_catnfile";
	cxt->symbols[0x8e55] = "setup_save_to_media2";
	cxt->symbols[0x8e58] = "setup_save_to_media";
	cxt->symbols[0x8e83] = "set_file_drv";
	cxt->symbols[0x8eea] = "err_too_many_files_open";
	cxt->symbols[0x8f02] = "err_file_open";
	cxt->symbols[0x8ff2] = "argsv_all_files_to_media2";
	cxt->symbols[0x9007] = "argsv_entry";
	cxt->symbols[0x902e] = "argsv_rdseqptr_or_filelen";
	cxt->symbols[0x9051] = "is_handle_in_use";
	cxt->symbols[0x90ad] = "err_channel";
	cxt->symbols[0x90b9] = "err_eof";
	cxt->symbols[0x90c1] = "bgetv_entry";
	cxt->symbols[0x914b] = "file_to_media_y";
	cxt->symbols[0x9196] = "err_file_readonly";
	cxt->symbols[0x91aa] = "bputv_entry";
	cxt->symbols[0x9211] = "err_cannot_extend";
	cxt->symbols[0x932b] = "dfs_name";
	cxt->symbols[0x9427] = "err_file_not_found";
	cxt->symbols[0x947e] = "serv_autoboot";
	cxt->symbols[0x949b] = "serv_unrecognised_cmd";
	cxt->symbols[0x94a7] = "serv_help";
	cxt->symbols[0x9841] = "err_locked";
	cxt->symbols[0x99c6] = "cmd_dfs";
	cxt->symbols[0x99ee] = "cmd_utils";
	cxt->symbols[0x99f5] = "cmd_nothelptbl";
	cxt->symbols[0x9a5b] = "parameter_table";
	cxt->symbols[0x9ac0] = "cmd_compact";
	cxt->symbols[0x9fcb] = "prt_2spc";
	cxt->symbols[0x9fce] = "prt_spc";
	cxt->symbols[0x9fd7] = "ltrim";
	cxt->symbols[0x9fec] = "+";
	cxt->symbols[0x9fde] = "-";
	cxt->symbols[0x9338] = "cmd_disk";
	cxt->symbols[0x94bd] = "serv_claim_stat_workspace";
	cxt->symbols[0x94ea] = "serv_unrecognised_osword";
	cxt->symbols[0x957b] = "filev_entry";
	cxt->symbols[0x95aa] = "fscv_entry";
	cxt->symbols[0x95d0] = "gbpbv_entry";
	cxt->symbols[0x8958] = "err_disk_full";
	cxt->symbols[0x92a6] = "rts_92a6";
	cxt->symbols[0x9cb8] = "err_disk_full2";
	cxt->symbols[0x9e0f] = "move_file_loop";
	cxt->symbols[0x9ea1] = "jmp_filenotfound";
	cxt->symbols[0xb7b1] = "drom";
	cxt->symbols[0xa64b] = "read_block";
	cxt->symbols[0xa641] = "read_block_exit";
	cxt->symbols[0xa098] = "check_if_to_tube";
	cxt->symbols[0xa65d] = "+";
	cxt->symbols[0xa79b] = "mmc_setup_read16";
	cxt->symbols[0xa7b2] = "mmc_do_read16";
/*
	cxt->symbols[0x8b37] = "";
	cxt->symbols[0x8b85] = "";
	cxt->symbols[0x8b9b] = "";
	cxt->symbols[0x8bc3] = "";
	cxt->symbols[0x8cff] = "";
	cxt->symbols[0x8d39] = "";
	cxt->symbols[0x8dbf] = "";
	cxt->symbols[0x8e50] = "";
	cxt->symbols[0x8f02] = "";
	cxt->symbols[0x8f6e] = "";
	cxt->symbols[0x8fdd] = "";
	cxt->symbols[0x902d] = "";
	cxt->symbols[0x9255] = "";
	cxt->symbols[0x9259] = "";
	cxt->symbols[0x930f] = "";
	cxt->symbols[0x943b] = "";
	cxt->symbols[0x9452] = "";
	cxt->symbols[0x95a9] = "";
	cxt->symbols[0x9b97] = "";
	cxt->symbols[0x9c4a] = "";
	cxt->symbols[0x9cb4] = "";
	cxt->symbols[0x9cb8] = "";
	cxt->symbols[0x9d49] = "";
	cxt->symbols[0x9ecb] = "";
	cxt->symbols[0xa154] = "";
	cxt->symbols[0xa416] = "";
	cxt->symbols[0xa641] = "";
	cxt->symbols[0xa683] = "";
	cxt->symbols[0xa6a5] = "";
	cxt->symbols[0xa6ee] = "";
	cxt->symbols[0xa7b1] = "";
	cxt->symbols[0xa835] = "";
	cxt->symbols[0xa91c] = "";
	cxt->symbols[0xaa61] = "";
	cxt->symbols[0xab23] = "";
	cxt->symbols[0xab35] = "";
	cxt->symbols[0xacfd] = "";
	cxt->symbols[0xad06] = "";
	cxt->symbols[0xad46] = "";
	cxt->symbols[0xad78] = "";
	cxt->symbols[0xae01] = "";
	cxt->symbols[0xae21] = "";
	cxt->symbols[0xae57] = "";
	cxt->symbols[0xaea3] = "";
	cxt->symbols[0xb02b] = "";
	cxt->symbols[0xb061] = "";
	cxt->symbols[0xb10d] = "";
	cxt->symbols[0xb134] = "";
	cxt->symbols[0xb13f] = "";
	cxt->symbols[0xb148] = "";
	cxt->symbols[0xb14e] = "";
	cxt->symbols[0xb183] = "";
	cxt->symbols[0xb19c] = "";
	cxt->symbols[0xb20b] = "";
	cxt->symbols[0xb2af] = "";
	cxt->symbols[0xb2e8] = "";
	cxt->symbols[0xb387] = "";
	cxt->symbols[0xb388] = "";
	cxt->symbols[0xb38b] = "";
	cxt->symbols[0xb46a] = "";
	cxt->symbols[0xb4d1] = "";
	cxt->symbols[0xb4eb] = "";
	cxt->symbols[0xb51b] = "";
	cxt->symbols[0xb589] = "";
	cxt->symbols[0xb5ae] = "";
	cxt->symbols[0xb5da] = "";
	cxt->symbols[0xb6fa] = "";
	cxt->symbols[0xb738] = "";
	cxt->symbols[0xb777] = "";
	cxt->symbols[0xb7e7] = "";
	cxt->symbols[0xb8ba] = "";
	cxt->symbols[0xb95e] = "";
	cxt->symbols[0xb962] = "";
	cxt->symbols[0x8148] = "";
	cxt->symbols[0x8374] = "";
	cxt->symbols[0x8e90] = "";
	cxt->symbols[0x92a6] = "";
	cxt->symbols[0x97d9] = "";
	cxt->symbols[0x9878] = "";
	cxt->symbols[0x9936] = "";
	cxt->symbols[0xa580] = "";
	cxt->symbols[0xa752] = "";
	cxt->symbols[0xaa66] = "";
	cxt->symbols[0xac12] = "";
	cxt->symbols[0xad7d] = "";
	cxt->symbols[0xb16b] = "";
	cxt->symbols[0xb19e] = "";
	cxt->symbols[0xb85d] = "";
	cxt->symbols[0xb95c] = "";
	cxt->symbols[0xba37] = "";
	cxt->symbols[0x81a0] = "";
	cxt->symbols[0x9932] = "";
	cxt->symbols[0x9a5a] = "";
	cxt->symbols[0xb324] = "";
	cxt->symbols[0xb7eb] = "";
	cxt->symbols[0xb2b0] = "";
	cxt->symbols[0xa878] = "";
	cxt->symbols[0xb0ef] = "";
*/

	cxt->symbols[0xab61] = "mmc_save_cur_drv_cat";
	cxt->symbols[0xa7f7] = "mmc_start_opts";
	cxt->symbols[0xab4d] = "mmc_load_cur_drv_cat";
	cxt->symbols[0xab47] = "mmc_load_cur_drv_cat2";
	cxt->symbols[0xaba5] = "mmc_save_mem_block";
	cxt->symbols[0xab96] = "mmc_load_mem_block";
	cxt->symbols[0xb90b] = "mmc_set_fdc_drv";
	cxt->symbols[0xa08d] = "mmc_set_7475";
	cxt->symbols[0xa15e] = "mmc_set_ptr_to_ext";
	cxt->symbols[0xa155] = "mmc_cmd_disk";
	cxt->symbols[0xad0a] = "mmc_initialise";
	cxt->symbols[0xaf94] = "mmc_dhelp";
	cxt->symbols[0xb913] = "mmc_osword_7f";
	cxt->symbols[0xa0f6] = "mmc_service";
	cxt->symbols[0xa0d8] = "mmc_gbpb1";
	cxt->symbols[0xa0eb] = "mmc_gbpb2";

	cxt->symbols[0xfe60] = "UV_IOB";
	cxt->symbols[0xfe62] = "UV_DDRB";
	cxt->symbols[0xfe6a] = "UV_SR";
	cxt->symbols[0xfe6b] = "UV_ACR";
	cxt->symbols[0xfe6e] = "UV_IER";
	cxt->symbols[0xfe18] = "MM_REG";
	cxt->symbols[0xfee0] = "TUBE_R0";
	cxt->symbols[0xfee1] = "TUBE_R1";
	cxt->symbols[0xfee2] = "TUBE_R2";
	cxt->symbols[0xfee3] = "TUBE_R3";
	cxt->symbols[0xfee5] = "TUBE_DAT";
	cxt->symbols[0xfe30] = "ROM_PAGE";
	cxt->symbols[0xfe40] = "SV_IOB";

	cxt->symbols[0xa000] = "report_error";
	cxt->symbols[0xa17b] = "reset_leds";
	cxt->symbols[0xa171] = "set_leds";
	cxt->symbols[0xa4bb] = "claim_nmi";
	cxt->symbols[0x10c9] = "nmi_status";
	cxt->symbols[0xa4d1] = "+";
	cxt->symbols[0x0d01] = "nmi_prev";
	cxt->symbols[0xa4d4] = "init_via";
	cxt->symbols[0xa495] = "mmc_set_cmd";
	cxt->symbols[0xa477] = "mmc_write_buf";
	cxt->symbols[0xa488] = "mmc_write_buf_mm";
	cxt->symbols[0xa47c] = "mmc_write_buf_up";
	cxt->symbols[0xb8] = "err_ptr";
	cxt->symbols[0xb9] = "err_ptr+1";
	cxt->symbols[0xb0] = "temp";
	cxt->symbols[0xb1] = "temp+1";
	cxt->symbols[0x0d02] = "mmc_status";
	cxt->symbols[0x0d03] = "mmc_mode";
	cxt->symbols[0xa00f] = "report_str";
	cxt->symbols[0xa01e] = "+";
	cxt->symbols[0xa014] = "-";
	cxt->symbols[0xa01f] = "report_mmc_errors";
	cxt->symbols[0xa025] = "+";
	cxt->symbols[0xa023] = "report_mmc_error";
	cxt->symbols[0xa069] = "prt_hex";
	cxt->symbols[0xa061] = "+";
	cxt->symbols[0x0d40] = "mmc_flags";
	cxt->symbols[0x0d41] = "cur_seq";
	cxt->symbols[0x0d42] = "cmd_seq";
	cxt->symbols[0x0d43] = "cmd_seq+1";
	cxt->symbols[0x0d44] = "par1";
	cxt->symbols[0x0d45] = "par1+1";
	cxt->symbols[0x0d46] = "par1+2";
	cxt->symbols[0x0d47] = "cmd_seq+5";
	cxt->symbols[0x0d48] = "cmd_seq+6";
	cxt->symbols[0x0d49] = "cmd_seq+7";
	cxt->symbols[0x0d4a] = "cmd_seq+8";
	cxt->symbols[0x0d4b] = "cmd_seq+9";
	cxt->symbols[0x0d4c] = "par2";
	cxt->symbols[0x0d4d] = "par2+1";
	cxt->symbols[0x0d4e] = "par2+2";
	cxt->symbols[0xa47e] = "-";
	cxt->symbols[0xa48a] = "-";
	cxt->symbols[0xa074] = "+";
	cxt->symbols[0xa07d] = "+";
	cxt->symbols[0xa082] = "err_escape";
	cxt->symbols[0xa1b8] = "up_write";
	cxt->symbols[0xa210] = "mmc_clocks";
	cxt->symbols[0xa24d] = "mmc_clocks_mm";
	cxt->symbols[0xa219] = "-";
	cxt->symbols[0xa215] = "mmc_clocks_up";
	cxt->symbols[0xa24f] = "-";
	cxt->symbols[0xa259] = "mmc_docmd";
	cxt->symbols[0xa294] = "mmc_docmd_mm";
	cxt->symbols[0xa263] = "-";
	cxt->symbols[0xa25e] = "mmc_docmd_up";
	cxt->symbols[0xa273] = "wait_response_up";
	cxt->symbols[0xa18a] = "up_read7";
	cxt->symbols[0xa28e] = "timeout_error_up";
	cxt->symbols[0xa279] = "-";
	cxt->symbols[0xa291] = "timeout_error";
	cxt->symbols[0xa299] = "-";
	cxt->symbols[0xa258] = "do_nothing";
	cxt->symbols[0xa293] = "dcmdex";
	cxt->symbols[0xa2a8] = "-";
	cxt->symbols[0xa2b6] = "mmc_waitdata";
	cxt->symbols[0xa2c5] = "mmc_waitdata_mm";
	cxt->symbols[0xa2bb] = "mmc_waitdata_up";
	cxt->symbols[0xa182] = "up_readX";
	cxt->symbols[0xa2bd] = "-";
	cxt->symbols[0xa2c7] = "-";
	cxt->symbols[0xa2d5] = "mmc_read_256";
	cxt->symbols[0xa2ef] = "mmc_read_256_mm";
	cxt->symbols[0xa2da] = "mmc_read_256_up";
	cxt->symbols[0xa2ea] = "+";
	cxt->symbols[0xa2e1] = "-";
	cxt->symbols[0x10d6] = "tube_txf";
	cxt->symbols[0xa0] = "data_ptr";
	cxt->symbols[0xa32d] = "rdub2t2";
	cxt->symbols[0xa30f] = "+";
	cxt->symbols[0xa2fc] = "-";
	cxt->symbols[0xa337] = "mmc_readbls_mm";
	cxt->symbols[0xa358] = "rdlt1";
	cxt->symbols[0xa345] = "-";
	cxt->symbols[0xa352] = "+";
	cxt->symbols[0xa7] = "bytes_last_sector";
	cxt->symbols[0xa320] = "-";
	cxt->symbols[0xa35a] = "rdlt2";
	cxt->symbols[0xa314] = "mmc_readbls";
	cxt->symbols[0xa319] = "mmc_readbls_up";
	cxt->symbols[0xa32b] = "+";
	cxt->symbols[0xa377] = "+";
	cxt->symbols[0xa35d] = "-";
	cxt->symbols[0xa37e] = "mmc_read_buf";
	cxt->symbols[0xa391] = "mmc_read_buf_mm";
	cxt->symbols[0xa383] = "mmc_read_buf_up";
	cxt->symbols[0x0e00] = "buf";
	cxt->symbols[0xa387] = "-";
	cxt->symbols[0xa39b] = "-";
	cxt->symbols[0xa3b0] = "mmc_send_data";
	cxt->symbols[0x10d7] = "tube_present_if_zero";
	cxt->symbols[0xa4d2] = "mode_table";
	cxt->symbols[0xa817] = "check_sector0";
	cxt->symbols[0xa9a9] = "err_unrecognised_format";
	cxt->symbols[0xa9c2] = "mmb";
	cxt->symbols[0xa9cd] = "bin2bcd";
	cxt->symbols[0xaef8] = "cmd_table";
	cxt->symbols[0xf2] = "txt_ptr";
	cxt->symbols[0xb2b0] = "syntax";
	cxt->symbols[0xb28d] = "print_param";
	cxt->symbols[0xa4ec] = "mmc_check";
	cxt->symbols[0xa4f7] = "+";
	cxt->symbols[0xa4f6] = "-";
	cxt->symbols[0xa506] = "card_init";
	cxt->symbols[0xa6] = "attempts";
	cxt->symbols[0x0d04] = "mmc_first_mode";
	cxt->symbols[0xa58c] = "iexit";
	cxt->symbols[0xa580] = "ifail";
	cxt->symbols[0xa54b] = "-";
	cxt->symbols[0xa592] = "err_blocklen";
	cxt->symbols[0xa52b] = "il3";
	cxt->symbols[0xa532] = "il2";
	cxt->symbols[0xa5ab] = "mmc_setup_read";
	cxt->symbols[0xa5ad] = "mmc_setup_write";
	cxt->symbols[0xa2] = "sector";
	cxt->symbols[0xa3] = "sector+1";
	cxt->symbols[0xa4] = "sector+2";
	cxt->symbols[0xa5c2] = "mmc_start_read";
	cxt->symbols[0xa5c4] = "mmc_start_readX";
	cxt->symbols[0xa5cd] = "err_read_fault";
	cxt->symbols[0xa5e1] = "mmc_start_write";
	cxt->symbols[0xa5eb] = "err_write_fault";
	cxt->symbols[0xa3d2] = "mmc_end_write";
	cxt->symbols[0xa435] = "mmc_write_256";
	cxt->symbols[0xa43f] = "-";
	cxt->symbols[0xa600] = "setup_cat_rw";
	cxt->symbols[0xa60f] = "mmc_read_cat";
	cxt->symbols[0xa628] = "mmc_write_cat";
	cxt->symbols[0xa642] = "mmc_read_block";
	cxt->symbols[0xa5] = "sector_count";
	cxt->symbols[0xa6ef] = "mmc_write_block";

	*((uint16*)&cxt->orgAddr) = 0x8000;
}

void initMap(struct Context *cxt) {
	char *p = cxt->map;
	int i;
	p[6] = 'b';
	p[7] = 'b';
	p[8] = 'b';
	for ( i = 0x0009; i < 0x0015; i++ ) { p[i] = 't'; }
	for ( i = 0x001b; i < 0x0020; i++ ) { p[i] = 't'; }
	for ( i = 0x0025; i < 0x0029; i++ ) { p[i] = 't'; }
	for ( i = 0x002e; i < 0x0033; i++ ) { p[i] = 't'; }
	for ( i = 0x0191; i < 0x019b; i++ ) { p[i] = 't'; }
	for ( i = 0x01b2; i < 0x01c0; i++ ) { p[i] = 't'; }
	for ( i = 0x0279; i < 0x0284; i++ ) { p[i] = 't'; }
	p[0x440] = p[0x441] = 't';
	for ( i = 0x044b; i < 0x0453; i++ ) { p[i] = 't'; }
	for ( i = 0x0460; i < 0x0467; i++ ) { p[i] = 't'; }
	p[0x473] = p[0x474] = 't';
	for ( i = 0x0487; i < 0x0494; i++ ) { p[i] = 't'; }
	for ( i = 0x04ab; i < 0x04b4; i++ ) { p[i] = 't'; }
	for ( i = 0x056f; i < 0x057f; i++ ) { p[i] = 't'; }
	for ( i = 0x05b8; i < 0x066c; i++ ) { p[i] = 't'; }
	for ( i = 0x06d7; i < 0x06da; i++ ) { p[i] = 't'; }
	for ( i = 0x072f; i < 0x073f; i++ ) { p[i] = 't'; }
	for ( i = 0x088e; i < 0x0899; i++ ) { p[i] = 't'; }
	for ( i = 0x0911; i < 0x091c; i++ ) { p[i] = 't'; }
	for ( i = 0x092b; i < 0x0933; i++ ) { p[i] = 't'; }
	for ( i = 0x095b; i < 0x0961; i++ ) { p[i] = 't'; }
	for ( i = 0x0a9c; i < 0x0aa4; i++ ) { p[i] = 't'; }
	for ( i = 0x0a07; i < 0x0a17; i++ ) { p[i] = 't'; }
	for ( i = 0x0aff; i < 0x0ddd; i++ ) { p[i] = 't'; }  // !!
	for ( i = 0x0eed; i < 0x0f02; i++ ) { p[i] = 't'; }
	for ( i = 0x0f05; i < 0x0f0b; i++ ) { p[i] = 't'; }
	for ( i = 0x10b0; i < 0x10b9; i++ ) { p[i] = 't'; }
	for ( i = 0x10bc; i < 0x10c1; i++ ) { p[i] = 't'; }
	for ( i = 0x1199; i < 0x11a4; i++ ) { p[i] = 't'; }
	for ( i = 0x1214; i < 0x1222; i++ ) { p[i] = 't'; }
	for ( i = 0x132b; i < 0x1336; i++ ) { p[i] = 't'; }
	for ( i = 0x1429; i < 0x143b; i++ ) { p[i] = 't'; }
	p[0x148a] = p[0x148b] = 'b';
	for ( i = 0x1844; i < 0x184c; i++ ) { p[i] = 't'; }
	for ( i = 0x1939; i < 0x1949; i++ ) { p[i] = 't'; }
	for ( i = 0x1949; i < 0x19c6; i++ ) { p[i] = 'b'; }
	for ( i = 0x19cf; i < 0x19d9; i++ ) { p[i] = 't'; }
	for ( i = 0x1a09; i < 0x1a12; i++ ) { p[i] = 't'; }
	for ( i = 0x1a5b; i < 0x1ac0; i++ ) { p[i] = 't'; }
	for ( i = 0x1ac6; i < 0x1ad7; i++ ) { p[i] = 't'; }
	for ( i = 0x1b07; i < 0x1b16; i++ ) { p[i] = 't'; }
	for ( i = 0x1b2f; i < 0x1b3d; i++ ) { p[i] = 't'; }
	for ( i = 0x1bc5; i < 0x1bd2; i++ ) { p[i] = 't'; }
	for ( i = 0x1c05; i < 0x1c18; i++ ) { p[i] = 't'; }
	for ( i = 0x1c21; i < 0x1c2b; i++ ) { p[i] = 't'; }
	for ( i = 0x1c56; i < 0x1c5d; i++ ) { p[i] = 't'; }
	for ( i = 0x1c65; i < 0x1c6b; i++ ) { p[i] = 't'; }
	for ( i = 0x1c70; i < 0x1c7b; i++ ) { p[i] = 't'; }
	for ( i = 0x1c7f; i < 0x1c92; i++ ) { p[i] = 't'; }
	p[0x1fff] = 'b';
	for ( i = 0x2085; i < 0x208d; i++ ) { p[i] = 't'; }
	for ( i = 0x241a; i < 0x2435; i++ ) { p[i] = 't'; }
	p[0x24d2] = p[0x24d3] = 'b';
	for ( i = 0x24ff; i < 0x2506; i++ ) { p[i] = 't'; }
	for ( i = 0x2595; i < 0x25ab; i++ ) { p[i] = 't'; }
	for ( i = 0x25d0; i < 0x25e1; i++ ) { p[i] = 't'; }
	for ( i = 0x25ee; i < 0x2600; i++ ) { p[i] = 't'; }
	for ( i = 0x2928; i < 0x293a; i++ ) { p[i] = 't'; }
	for ( i = 0x29ac; i < 0x29cd; i++ ) { p[i] = 't'; }
	for ( i = 0x2a51; i < 0x2a61; i++ ) { p[i] = 't'; }
	for ( i = 0x2a69; i < 0x2a72; i++ ) { p[i] = 't'; }
	for ( i = 0x2b26; i < 0x2b35; i++ ) { p[i] = 't'; }
	for ( i = 0x2b38; i < 0x2b47; i++ ) { p[i] = 't'; }
	for ( i = 0x2c4e; i < 0x2c65; i++ ) { p[i] = 't'; }
	for ( i = 0x2c68; i < 0x2c7c; i++ ) { p[i] = 't'; }
	for ( i = 0x2ef8; i < 0x2f94; i++ ) { p[i] = 't'; }
	for ( i = 0x2fa6; i < 0x2faf; i++ ) { p[i] = 't'; }
	for ( i = 0x2fd2; i < 0x2fdb; i++ ) { p[i] = 't'; }
	for ( i = 0x2ffe; i < 0x3024; i++ ) { p[i] = 't'; }
	for ( i = 0x322d; i < 0x3235; i++ ) { p[i] = 'b'; }
	for ( i = 0x3235; i < 0x328d; i++ ) { p[i] = 't'; }
	for ( i = 0x32b9; i < 0x32c3; i++ ) { p[i] = 't'; }
	for ( i = 0x3327; i < 0x3332; i++ ) { p[i] = 't'; }
	for ( i = 0x3335; i < 0x3345; i++ ) { p[i] = 't'; }
	for ( i = 0x33f6; i < 0x3401; i++ ) { p[i] = 't'; }
	for ( i = 0x3489; i < 0x348f; i++ ) { p[i] = 't'; }
	for ( i = 0x34a1; i < 0x34a8; i++ ) { p[i] = 't'; }
	for ( i = 0x352e; i < 0x3533; i++ ) { p[i] = 't'; }
	for ( i = 0x3546; i < 0x354b; i++ ) { p[i] = 't'; }
	for ( i = 0x3560; i < 0x3574; i++ ) { p[i] = 't'; }
	for ( i = 0x35fb; i < 0x3600; i++ ) { p[i] = 't'; }
	for ( i = 0x3607; i < 0x360b; i++ ) { p[i] = 't'; }
	for ( i = 0x3661; i < 0x3679; i++ ) { p[i] = 't'; }
	for ( i = 0x36aa; i < 0x36b0; i++ ) { p[i] = 't'; }
	for ( i = 0x36c8; i < 0x36d3; i++ ) { p[i] = 't'; }
	for ( i = 0x373b; i < 0x374a; i++ ) { p[i] = 't'; }
	for ( i = 0x378a; i < 0x379b; i++ ) { p[i] = 't'; }
	for ( i = 0x380b; i < 0x381c; i++ ) { p[i] = 't'; }
	for ( i = 0x3860; i < 0x386e; i++ ) { p[i] = 't'; }



	for ( i = 0x3a3b; i < 0x4000; i++ ) { p[i] = 't'; }
}

enum AddrMode {
	ILL,   // Illegal
	IMP,   // Implied       e.g rts
	ACC,   // Accumulator   e.g asl a
	IMM,   // Immediate     e.g lda #10
	ABS,   // Absolute      e.g cmp $1900
	ZP,    // ZeroPage      e.g cpy $70
	IND,   // Indirect      e.g jmp ($1900)
	ABSX,  // Absolute,X    e.g lda $1900,x
	ABSY,  // Absolute,Y    e.g lda $1900,y
	INDX,  // (Indirect,X)  e.g lda ($70,x)
	INDY,  // (Indirect),Y  e.g lda ($70),y
	ZPX,   // ZeroPage,x    e.g lda $70,x
	ZPY,   // ZeroPage,y    e.g ldx $70,y
	REL    // Relative      e.g bne loop
};

struct Opcode {
	const char *mnemonic;
	enum AddrMode addrMode;
};

const struct Opcode opcodes[] = {
	{"brk",  IMP}, {"ora", INDX}, {"ill",  ILL}, {"ill",  ILL},  // 00 - 03
	{"ill",  ILL}, {"ora",   ZP}, {"asl",   ZP}, {"ill",  ILL},  // 04 - 07
	{"php",  IMP}, {"ora",  IMM}, {"asl",  ACC}, {"ill",  ILL},  // 08 - 0B
	{"ill",  ILL}, {"ora",  ABS}, {"asl",  ABS}, {"ill",  ILL},  // 0C - 0F
	{"bpl",  REL}, {"ora", INDY}, {"ora",  IND}, {"ill",  ILL},  // 10 - 13
	{"ill",  ILL}, {"ora",  ZPX}, {"asl",  ZPX}, {"ill",  ILL},  // 14 - 17
	{"clc",  IMP}, {"ora", ABSY}, {"inc",  ACC}, {"ill",  ILL},  // 18 - 1B
	{"ill",  ILL}, {"ora", ABSX}, {"asl", ABSX}, {"ill",  ILL},  // 1C - 1F

	{"jsr",  ABS}, {"and", INDX}, {"ill",  ILL}, {"ill",  ILL},  // 20 - 23
	{"bit",   ZP}, {"and",   ZP}, {"rol",   ZP}, {"ill",  ILL},  // 24 - 27
	{"plp",  IMP}, {"and",  IMM}, {"rol",  ACC}, {"ill",  ILL},  // 28 - 2B
	{"bit",  ABS}, {"and",  ABS}, {"rol",  ABS}, {"ill",  ILL},  // 2C - 2F
	{"bmi",  REL}, {"and", INDY}, {"and",  IND}, {"ill",  ILL},  // 30 - 33
	{"bit",  ZPX}, {"and",  ZPX}, {"rol",  ZPX}, {"ill",  ILL},  // 34 - 37
	{"sec",  IMP}, {"and", ABSY}, {"dec", ACC},  {"ill",  ILL},  // 38 - 3B
	{"bit", ABSX}, {"and", ABSX}, {"rol", ABSX}, {"ill",  ILL},  // 3C - 3F

	{"rti",  IMP}, {"eor", INDX}, {"ill",  ILL}, {"ill",  ILL},  // 40 - 43
	{"ill",  ILL}, {"eor",   ZP}, {"lsr",   ZP}, {"ill",  ILL},  // 44 - 47
	{"pha",  IMP}, {"eor",  IMM}, {"lsr",  ACC}, {"ill",  ILL},  // 48 - 4B
	{"jmp",  ABS}, {"eor", ABS},  {"lsr",  ABS}, {"ill",  ILL},  // 4C - 4F
	{"bvc",  REL}, {"eor", INDY}, {"eor",  IND}, {"ill",  ILL},  // 50 - 53
	{"ill",  ILL}, {"eor",  ZPX}, {"lsr",  ZPX}, {"ill",  ILL},  // 54 - 57
	{"cli",  IMP}, {"eor", ABSY}, {"ill",  ILL}, {"ill",  ILL},  // 58 - 5B
	{"ill",  ILL}, {"eor", ABSX}, {"lsr", ABSX}, {"ill",  ILL},  // 5C - 5F

	{"rts",  IMP}, {"adc", INDX}, {"ill",  ILL}, {"ill",  ILL},  // 60 - 63
	{"ill",  ILL}, {"adc",   ZP}, {"ror",   ZP}, {"ill",  ILL},  // 64 - 67
	{"pla",  IMP}, {"adc",  IMM}, {"ror",  ACC}, {"ill",  ILL},  // 68 - 6B
	{"jmp",  IND}, {"adc",  ABS}, {"ror",  ABS}, {"ill",  ILL},  // 6C - 6F
	{"bvs",  REL}, {"adc", INDY}, {"adc",  IND}, {"ill",  ILL},  // 70 - 73
	{"ill",  ILL}, {"adc",  ZPX}, {"ror",  ZPX}, {"ill",  ILL},  // 74 - 77
	{"sei",  IMP}, {"adc", ABSY}, {"ill",  ILL}, {"ill",  ILL},  // 78 - 7B
	{"jmp", ABSX}, {"adc", ABSX}, {"ror", ABSX}, {"ill",  ILL},  // 7C - 7F

	{"ill",  ILL}, {"sta", INDX}, {"ill",  ILL}, {"ill",  ILL},  // 80 - 83
	{"sty",   ZP}, {"sta",   ZP}, {"stx",   ZP}, {"ill",  ILL},  // 84 - 87
	{"dey",  IMP}, {"bit",  IMM}, {"txa",  IMP}, {"ill",  ILL},  // 88 - 8B
	{"sty",  ABS}, {"sta",  ABS}, {"stx",  ABS}, {"ill",  ILL},  // 8C - 8F
	{"bcc",  REL}, {"sta", INDY}, {"sta",  IND}, {"ill",  ILL},  // 90 - 93
	{"sty",  ZPX}, {"sta",  ZPX}, {"stx",  ZPY}, {"ill",  ILL},  // 94 - 97
	{"tya",  IMP}, {"sta", ABSY}, {"txs",  IMP}, {"ill",  ILL},  // 98 - 9B
	{"ill",  ILL}, {"sta", ABSX}, {"ill",  ILL}, {"ill",  ILL},  // 9C - 9F

 	{"ldy",  IMM}, {"lda", INDX}, {"ldx",  IMM}, {"ill",  ILL},  // A0 - A3
	{"ldy",   ZP}, {"lda",   ZP}, {"ldx",   ZP}, {"ill",  ILL},  // A4 - A7
	{"tay",  IMP}, {"lda",  IMM}, {"tax",  IMP}, {"ill",  ILL},  // A8 - AB
	{"ldy",  ABS}, {"lda",  ABS}, {"ldx",  ABS}, {"ill",  ILL},  // AC - AF
	{"bcs",  REL}, {"lda", INDY}, {"lda",  IND}, {"ill",  ILL},  // B0 - B3
	{"ldy",  ZPX}, {"lda",  ZPX}, {"ldx",  ZPY}, {"ill",  ILL},  // B4 - B7
	{"clv",  IMP}, {"lda", ABSY}, {"tsx",  IMP}, {"ill",  ILL},  // B8 - BB
	{"ldy", ABSX}, {"lda", ABSX}, {"ldx", ABSY}, {"ill",  ILL},  // BC - BF

	{"cpy",  IMM}, {"cmp", INDX}, {"ill",  ILL}, {"ill",  ILL},  // C0 - C3
	{"cpy",   ZP}, {"cmp",   ZP}, {"dec",   ZP}, {"ill",  ILL},  // C4 - C7
	{"iny",  IMP}, {"cmp",  IMM}, {"dex",  IMP}, {"ill",  ILL},  // C8 - CB
	{"cpy",  ABS}, {"cmp",  ABS}, {"dec",  ABS}, {"ill",  ILL},  // CC - CF
	{"bne",  REL}, {"cmp", INDY}, {"cmp",  IND}, {"ill",  ILL},  // D0 - D3
	{"ill",  ILL}, {"cmp",  ZPX}, {"dec",  ZPX}, {"ill",  ILL},  // D4 - D7
	{"cld",  IMP}, {"cmp", ABSY}, {"ill",  ILL}, {"ill",  ILL},  // D8 - DB
	{"ill",  ILL}, {"cmp", ABSX}, {"dec", ABSX}, {"ill",  ILL},  // DC - DF

	{"cpx",  IMM}, {"sbc", INDX}, {"ill",  ILL}, {"ill",  ILL},  // E0 - E3
	{"cpx",   ZP}, {"sbc",   ZP}, {"inc",   ZP}, {"ill",  ILL},  // E4 - E7
	{"inx",  IMP}, {"sbc",  IMM}, {"nop",  IMP}, {"ill",  ILL},  // E8 - EB
	{"cpx",  ABS}, {"sbc",  ABS}, {"inc",  ABS}, {"ill",  ILL},  // EC - EF
	{"beq",  REL}, {"sbc", INDY}, {"sbc",  IND}, {"ill",  ILL},  // F0 - F3
	{"ill",  ILL}, {"sbc",  ZPX}, {"inc",  ZPX}, {"ill",  ILL},  // F4 - F7
	{"sed",  IMP}, {"sbc", ABSY}, {"ill",  ILL}, {"ill",  ILL},  // F8 - FB
	{"ill",  ILL}, {"sbc", ABSX}, {"inc", ABSX}, {"ill",  ILL}   // FC - FF
};

uint8 getByte(struct Context *cxt) {
	return cxt->data[cxt->index++];
}

void doACC(void) {
	//printf("a");
}
void doIMM(struct Context *cxt) {
	const uint8 operand = getByte(cxt);
	const char *label = cxt->symbols[operand];
	if ( label ) {
		printf(" #%s", label);
	} else {
		printf(" #$%02x", operand);
	}
}
void doABS(struct Context *cxt) {
	const uint16 operand = getByte(cxt) + (getByte(cxt) << 8);
	const char *label = cxt->symbols[operand];
	if ( label ) {
		printf(" %s", label);
	} else {
		printf(" $%04x", operand);
		//printf(" $%04x\t; TODO: add label for $%04x!\n", operand, operand);
	}
}
void doZP(struct Context *cxt) {
	const uint8 operand = getByte(cxt);
	const char *label = cxt->symbols[operand];
	if ( label ) {
		printf(" %s", label);
	} else {
		printf(" $%02x", operand);
		//printf(" $%02x\t; TODO: add label for $%02x!\n", operand, operand);
	}
}
void doIND(struct Context *cxt) {
	const uint16 operand = getByte(cxt) + (getByte(cxt) << 8);
	const char *label = cxt->symbols[operand];
	if ( label ) {
		printf(" (%s)", label);
	} else {
		printf(" ($%04x)", operand);
		//printf(" ($%04x)\t; TODO: add label for $%04x!\n", operand, operand);
	}
}
void doABSX(struct Context *cxt) {
	const uint16 operand = getByte(cxt) + (getByte(cxt) << 8);
	const char *label = cxt->symbols[operand];
	if ( label ) {
		printf(" %s,x", label);
	} else {
		printf(" $%04x,x", operand);
		//printf(" $%04x,x\t; TODO: add label for $%04x!\n", operand, operand);
	}
}
void doABSY(struct Context *cxt) {
	const uint16 operand = getByte(cxt) + (getByte(cxt) << 8);
	const char *label = cxt->symbols[operand];
	if ( label ) {
		printf(" %s,y", label);
	} else {
		printf(" $%04x,y", operand);
		//printf(" $%04x,y\t; TODO: add label for $%04x!\n", operand, operand);
	}
}
void doINDX(struct Context *cxt) {
	const uint8 operand = getByte(cxt);
	const char *label = cxt->symbols[operand];
	if ( label ) {
		printf(" (%s,x)", label);
	} else {
		printf(" ($%02x,x)", operand);
		//printf(" ($%02x,x)\t; TODO: add label for $%02x!\n", operand, operand);
	}
}
void doINDY(struct Context *cxt) {
	const uint8 operand = getByte(cxt);
	const char *label = cxt->symbols[operand];
	if ( label ) {
		printf(" (%s),y", label);
	} else {
		printf(" ($%02x),y", operand);
		//printf(" ($%02x),y\t; TODO: add label for $%02x!\n", operand, operand);
	}
}
void doZPX(struct Context *cxt) {
	const uint8 operand = getByte(cxt);
	const char *label = cxt->symbols[operand];
	if ( label ) {
		printf(" %s,x", label);
	} else {
		printf(" $%02x,x", operand);
		//printf(" $%02x,x\t; TODO: add label for $%02x!\n", operand, operand);
	}
}
void doZPY(struct Context *cxt) {
	const uint8 operand = getByte(cxt);
	const char *label = cxt->symbols[operand];
	if ( label ) {
		printf(" %s,y", label);
	} else {
		printf(" $%02x,y", operand);
		//printf(" $%02x,y\t; TODO: add label for $%02x!\n", operand, operand);
	}
}
void doREL(struct Context *cxt) {
	const char operand = (char)getByte(cxt);
	const uint16 addr = cxt->orgAddr + cxt->index + operand;
	const char *label = cxt->symbols[addr];
	if ( label ) {
		printf(" %s", label);
	} else {
		printf(" $%04x", addr);
		//printf(" $%04x\t; TODO: add label for $%04x!\n", addr, addr);
	}
}

const char *getLabel(struct Context *cxt) {
	const uint16 addr = cxt->orgAddr + cxt->index;
	return cxt->symbols[addr];
}

void d6502(struct Context *cxt) {
	const char *label = getLabel(cxt);
	if ( label ) {
		printf("%s", label);
	}
	if ( cxt->map[cxt->index] == 'b' ) {
		printf("\t!byte $%02x", getByte(cxt));
		while ( cxt->map[cxt->index] == 'b' ) {
			label = getLabel(cxt);
			if ( label ) {
				printf("\n%s\t$%02x", label, getByte(cxt));
			} else {
				printf(", $%02x", getByte(cxt));
			}
		}
		printf("\n");
	} else if ( cxt->map[cxt->index] == 't' ) {
		uint8 byte = getByte(cxt);
		bool inQuotes = false;
		bool needComma = true;
		printf("\t!text ");
		if ( byte >= 32 && byte < 127 ) {
			printf("\"%c", byte);
			inQuotes = true;
		} else {
			printf("$%02x", byte);
		}
		while ( cxt->map[cxt->index] == 't' ) {
			label = getLabel(cxt);
			if ( label ) {
				needComma = false;
				if ( inQuotes ) {
					printf("\"\n%s\t!text ", label);
				} else {
					printf("\n%s\t!text ", label);
				}
			}
			byte = getByte(cxt);
			if ( byte >= 32 && byte < 127 ) {
				if ( inQuotes ) {
					if ( needComma ) {
						printf("%c", byte);
					} else {
						printf("\"%c", byte);
						needComma = true;
					}
				} else {
					if ( needComma ) {
						printf(", \"%c", byte);
					} else {
						printf("\"%c", byte);
						needComma = true;
					}
					inQuotes = true;
				}
			} else {
				if ( inQuotes ) {
					if ( needComma ) {
						printf("\", $%02x", byte);
					} else {
						printf("$%02x", byte);
						needComma = true;
					}
					inQuotes = false;
				} else {
					if ( needComma ) {
						printf(", $%02x", byte);
					} else {
						printf("$%02x", byte);
						needComma = true;
					}
				}
			}
		}
		if ( inQuotes ) {
			printf("\"\n");
		} else {
			printf("\n");
		}
	} else {
		const struct Opcode *oc;
		const uint16 addr = cxt->orgAddr + cxt->index;
		oc = &opcodes[getByte(cxt)];
		printf("\t%s", oc->mnemonic);
		switch ( oc->addrMode ) {
		case ILL:   // Illegal
		case IMP:   // Implied       e.g rts
			break;
		case ACC:   // Accumulator   e.g asl a
			doACC();
			break;
		case IMM:   // Immediate     e.g lda #10
			doIMM(cxt);
			break;
		case ABS:   // Absolute      e.g cmp $1900
			doABS(cxt);
			break;
		case ZP:    // ZeroPage      e.g cpy $70
			doZP(cxt);
			break;
		case IND:   // Indirect      e.g jmp ($1900)
			doIND(cxt);
			break;
		case ABSX:  // Absolute,X    e.g lda $1900,x
			doABSX(cxt);
			break;
		case ABSY:  // Absolute,Y    e.g lda $1900,y
			doABSY(cxt);
			break;
		case INDX:  // (Indirect,X)  e.g lda ($70,x)
			doINDX(cxt);
			break;
		case INDY:  // (Indirect),Y  e.g lda ($70),y
			doINDY(cxt);
			break;
		case ZPX:   // ZeroPage,x    e.g lda $70,x
			doZPX(cxt);
			break;
		case ZPY:   // ZeroPage,y    e.g ldx $70,y
			doZPY(cxt);
			break;
		case REL:    // Relative      e.g bne loop
			doREL(cxt);
			break;
		}
		printf("\t; 0x%04x\n", addr);
	}
}

void dumpSymbols(struct Context *cxt) {
	int i = 0;
	printf("\t* = $%04x\n", cxt->orgAddr);
	for ( i = 0; i < 256; i++ ) {
		if ( cxt->symbols[i] ) {
			if ( !strchr(cxt->symbols[i], '+') ) {
				printf("\t%s = $%02x\n", cxt->symbols[i], i);
			}
		}
	}
	for ( i = 256; i < 0x8000; i++ ) {
		if ( cxt->symbols[i] ) {
			if ( !strchr(cxt->symbols[i], '+') ) {
				printf("\t%s = $%04x\n", cxt->symbols[i], i);
			}
		}
	}
	for ( i = 0xC000; i < 0x10000; i++ ) {
		if ( cxt->symbols[i] ) {
			printf("\t%s = $%04x\n", cxt->symbols[i], i);
		}
	}
	printf("\n");
}

uint8* loadFile(const char *name) {
	FILE *file;
	uint8 *buffer;
	size_t fileLen;

	file = fopen(name, "rb");
	if ( !file ) {
		return NULL;
	}

	fseek(file, 0, SEEK_END);
	fileLen = ftell(file);
	fseek(file, 0, SEEK_SET);

	// Allocate enough space for an extra byte for a null terminator
	buffer = (uint8 *)malloc(fileLen + 1);
	if ( !buffer ) {
		fclose(file);
		return NULL;
	}
	fread(buffer, 1, fileLen, file);
	buffer[fileLen] = 0x00;
	fclose(file);
	return buffer;
}

void freeFile(uint8 *buffer) {
	free((void*)buffer);
}

int main(void) {
  const uint8 *data = loadFile("SUPERMMC.rom");
  struct Context cxt = {data, 0, 0, {0,}, {0,}};
  if (!data) {
    fprintf(stderr, "Cannot find SUPERMMC.rom!\n");
    return 1;
  }
  loadSymbols(&cxt); //, "foo.sym");
  printf("\t!to \"foo.o\", plain\t; set output file and format\n\n");
  dumpSymbols(&cxt);
  initMap(&cxt);
  while ( cxt.index < 0x4000 ) {
    d6502(&cxt);
  }
  return 0;
}

/*
char* loadFile(const char *name) {
	FILE *file;
	char *buffer;
	size_t fileLen;
	size_t returnCode;

	file = fopen(name, "rb");
	if ( !file ) {
		return NULL;
	}

	fseek(file, 0, SEEK_END);
	fileLen = ftell(file);
	fseek(file, 0, SEEK_SET);

	// Allocate enough space for an extra byte for a null terminator
	buffer = (char *)malloc(fileLen + 1);
	if ( !buffer ) {
		fclose(file);
		return NULL;
	}
	fread(buffer, 1, fileLen, file);
	buffer[fileLen] = 0x00;
	fclose(file);
	return buffer;
}

void freeFile(char *buffer) {
	free((void*)buffer);
}

uint16 loadSymbols(struct Context *cxt, const char *fileName) {
	char *symFile = loadFile(fileName);
	char *ptr = symFile;
	const char *symbol;
	uint16 startAddr, thisAddr;
	if ( *ptr != '*' ) {
		exit(1);
	}
	while ( *++ptr == ' ' );
	if ( *++ptr != '=' ) {
		exit(2);
	}
	while ( *++ptr == ' ' );
	startAddr = (uint16)strtoul(ptr, &ptr, 16);
	if ( *ptr != 0x0a && *ptr != 0x00 ) {
		exit(2);
	}
	while ( *ptr != 0x00 ) {
		symbol = ptr;
		while ( *ptr != ' ' && *ptr != '=' ) {
			ptr++;
		}
		
		*ptr++ = 0x00;
		if ( *ptr == 0x0a ) {
			ptr++;
		} else if ( *ptr != 0x00 ) {
			exit(2);
		}
	}
	return startAddr;
}
*/
