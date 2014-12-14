all: 
	make clean
	vcs -full64 +v2k -o aes *.v
	./aes

aes:
	vcs -full64 +v2k -o aespipe aespipe.v add_roundkey.v first_round.v flipflop.v key_expansion.v last_round.v mix_columns.v mult_by2.v mult_by3.v pipereg.v register.v rotword.v sbox.v shift_rows.v std_round.v sub_bytes.v gen_key1.v gen_key2.v gen_key3.v gen_key4.v gen_key5.v gen_key6.v  gen_key7.v gen_key8.v gen_key9.v gen_key10.v

inv:
	vcs -full64 +v2k -o inv_aes inv_aespipe.v inv_first_round.v inv_last_round.v inv_std_round.v inv_mix_columns.v inv_sbox.v inv_shift_rows.v inv_sub_bytes.v key_expansion.v register.v pipereg.v flipflop.v rotword.v mult_by9.v mult_by11.v mult_by13.v mult_by14.v gen_key1.v gen_key2.v gen_key3.v gen_key4.v gen_key5.v gen_key6.v  gen_key7.v gen_key8.v gen_key9.v gen_key10.v sbox.v add_roundkey.v

leda:
	leda -full64 +v2k -top aes_core *.v

clean:
	rm -rf csrc *.key *.log *.dump dumpfiles/* simv* crypto aes crypto.daidir *.daidir aespipe inv_aes aestester.dump
