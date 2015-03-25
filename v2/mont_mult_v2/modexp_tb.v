`include "_parameter.v"
`timescale 1 ns / 1 ns

module modexp_tb();
	reg clk;
	reg reset;
	reg [`DATA_WIDTH - 1 : 0] m_buf;
	reg [`DATA_WIDTH - 1 : 0] e_buf;
	reg [`DATA_WIDTH - 1 : 0] n_buf;
	reg [`DATA_WIDTH - 1 : 0] r_buf;
	reg [`DATA_WIDTH - 1 : 0] t_buf;
	reg nprime0_buf;
	reg startInput;
	reg startCompute;
	reg getResult;
	wire [`DATA_WIDTH - 1 : 0] res_out;
	wire [4 : 0] exp_state;
	wire [3 : 0] state;
	
	modexp modexp0(
		.clk(clk), .reset(reset), .m_buf(m_buf), .e_buf(e_buf),
		.n_buf(n_buf), .r_buf(r_buf), .t_buf(t_buf), .nprime0_buf(nprime0_buf),
		.startInput(startInput), .startCompute(startCompute), .getResult(getResult), 
		.exp_state(exp_state), .state(state), .res_out(res_out)
	);
	
	initial begin
		clk = 0;
		reset = 0;
		startInput = 0;
		startCompute = 0;
		getResult = 0;
		m_buf = 64'h0000000000000000;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h0000000000000000;
		r_buf = 64'h0000000000000000;
		t_buf = 64'h0000000000000000;
		nprime0_buf = 1'b0;
		#100 startInput = 1;	

		#10
		m_buf = 64'h95d1805142cb6d1d;
		e_buf = 64'h0000000000000005;
		n_buf = 64'h1622bd795fec898f;
		t_buf = 64'h73053f82acaa289e;
		r_buf = 64'he9dd4286a0137671;
		#10
		m_buf = 64'h2aa50f4ec6f00933;
		e_buf = 64'h0000000000000000;
		n_buf = 64'ha9ec0806705fca16;
		r_buf = 64'h5613f7f98fa035e9;
		t_buf = 64'h490666572b90f2c5;
		#10
		m_buf = 64'h31234efe6e648043;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h1ba1621582283d15;
		r_buf = 64'he45e9dea7dd7c2ea;
		t_buf = 64'h41d7011500400a06;
		#10
		m_buf = 64'h1d7173e55bc7fdeb;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h29e821a4c74803e3;
		r_buf = 64'hd617de5b38b7fc1c;
		t_buf = 64'h4255b841d1a34bdb;
		#10
		m_buf = 64'hd26d53961058fe8c;
		e_buf = 64'h0000000000000000;
		n_buf = 64'hd707107e855c3844;
		r_buf = 64'h28f8ef817aa3c7bb;
		t_buf = 64'h0d21bcdfdf4473e0;
		#10
		m_buf = 64'hda54f267dd138266;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h5eda92d864ac5db9;
		r_buf = 64'ha1256d279b53a246;
		t_buf = 64'hef79ce5f386efa55;
		#10
		m_buf = 64'h07120911b3b68b57;
		e_buf = 64'h0000000000000000;
		n_buf = 64'hbb968a437d5c8dfc;
		r_buf = 64'h446975bc82a37203;
		t_buf = 64'ha401baa22b888c2e;
		#10
		m_buf = 64'h869bdbd2e72bb5b7;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h78255d6807923986;
		r_buf = 64'h87daa297f86dc679;
		t_buf = 64'h432c1e910135f001;
		#10
		m_buf = 64'hc09fcd8f739cd488;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h4efbc8d60b21fbac;
		r_buf = 64'hb1043729f4de0453;
		t_buf = 64'h192d6bf19f25d484;
		#10
		m_buf = 64'h33a1d1c2ad4ab155;
		e_buf = 64'h0000000000000000;
		n_buf = 64'hd92a4aa2b410d93c;
		r_buf = 64'h26d5b55d4bef26c3;
		t_buf = 64'hd4b94bc352c949d7;
		#10
		m_buf = 64'h7f411fed1e70e799;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h9d643c25fbb230bb;
		r_buf = 64'h629bc3da044dcf44;
		t_buf = 64'h5e12a9a96f7d7742;
		#10
		m_buf = 64'h41a8a6e165e04993;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h9403560d97dae38d;
		r_buf = 64'h6bfca9f268251c72;
		t_buf = 64'hdc64dc90e98f4afe;
		#10
		m_buf = 64'ha41865bf350d278d;
		e_buf = 64'h0000000000000000;
		n_buf = 64'ha5ac06d864c2f2e3;
		r_buf = 64'h5a53f9279b3d0d1c;
		t_buf = 64'h2b94c7ae4af92d64;
		#10
		m_buf = 64'hff3e0ba10ac728b4;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h2b28fef02b9c014e;
		r_buf = 64'hd4d7010fd463feb1;
		t_buf = 64'h17df090edd741e9f;
		#10
		m_buf = 64'hcc249558f2ad985f;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h3a1890c78092b4d4;
		r_buf = 64'hc5e76f387f6d4b2b;
		t_buf = 64'hcb06c0a97843a5f8;
		#10
		m_buf = 64'h9f9821883744da64;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h0326324dfb695ffb;
		r_buf = 64'hfcd9cdb20496a004;
		t_buf = 64'he4e415995f80cfb6;
		#10
		m_buf = 64'h1ac902ee25777cf0;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h33138131c541013d;
		r_buf = 64'hccec7ece3abefec2;
		t_buf = 64'ha0a34b0f89fd1237;
		#10
		m_buf = 64'h755a3ac132ae2a20;
		e_buf = 64'h0000000000000000;
		n_buf = 64'heb8ac8ce8a245e6b;
		r_buf = 64'h1475373175dba194;
		t_buf = 64'hfb05f6b41fca9bc4;
		#10
		m_buf = 64'h5c94938160c6b3ed;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h8c5fe8f8dc3bf364;
		r_buf = 64'h73a0170723c40c9b;
		t_buf = 64'hae264f5fc010a19e;
		#10
		m_buf = 64'hd3b564b08be04c3e;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h678a5aa33b6fe507;
		r_buf = 64'h9875a55cc4901af8;
		t_buf = 64'hd1aeed41c012e824;
		#10
		m_buf = 64'h1ad0a6f226bdd974;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h5804f92283868a29;
		r_buf = 64'ha7fb06dd7c7975d6;
		t_buf = 64'hf2bb3810c6183272;
		#10
		m_buf = 64'h98a33736fd1ac7ce;
		e_buf = 64'h0000000000000000;
		n_buf = 64'hd8f33418f3d4e711;
		r_buf = 64'h270ccbe70c2b18ee;
		t_buf = 64'hd8e7aee5bebbc2b0;
		#10
		m_buf = 64'h7ce71b48fba52e59;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h5a702cfa93ea5c4e;
		r_buf = 64'ha58fd3056c15a3b1;
		t_buf = 64'h3bf4e86e41840ab5;
		#10
		m_buf = 64'h905c053b25fdacbe;
		e_buf = 64'h0000000000000000;
		n_buf = 64'he8e5b4617589a82b;
		r_buf = 64'h171a4b9e8a7657d4;
		t_buf = 64'h79c730582a57f521;
		#10
		m_buf = 64'ha36bcb0167e98363;
		e_buf = 64'h0000000000000000;
		n_buf = 64'ha8c24d4244ef7feb;
		r_buf = 64'h573db2bdbb108014;
		t_buf = 64'h71a5acdaa14ea7d5;
		#10
		m_buf = 64'h6c596216ae0fdbc8;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h9be3cecb8c497c68;
		r_buf = 64'h641c313473b68397;
		t_buf = 64'he2276688a89b7b2a;
		#10
		m_buf = 64'h856f3d95e0ae1a1b;
		e_buf = 64'h0000000000000000;
		n_buf = 64'hbab9f87ff5059285;
		r_buf = 64'h454607800afa6d7a;
		t_buf = 64'h4e1fd46c8dac7c5e;
		#10
		m_buf = 64'hade7cef37ed2ec2f;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h62397bc701762741;
		r_buf = 64'h9dc68438fe89d8be;
		t_buf = 64'h7acdff93e6b10035;
		#10
		m_buf = 64'he345ac72eac39204;
		e_buf = 64'h0000000000000000;
		n_buf = 64'hdb610487c89da11b;
		r_buf = 64'h249efb7837625ee4;
		t_buf = 64'h35605d6ab7d595c7;
		#10
		m_buf = 64'hd5627386528cc241;
		e_buf = 64'h0000000000000000;
		n_buf = 64'hf463b337d20b5d59;
		r_buf = 64'h0b9c4cc82df4a2a6;
		t_buf = 64'h11a738951c5836fd;
		#10
		m_buf = 64'hff88ec827f99d273;
		e_buf = 64'h0000000000000000;
		n_buf = 64'hf03edca7e2dcaa37;
		r_buf = 64'h0fc123581d2355c8;
		t_buf = 64'h06cdb515499fa607;
		#10
		m_buf = 64'ha2939b3b7fa74d8a;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h83333218bd91a1b7;
		r_buf = 64'h7ccccde7426e5e48;
		t_buf = 64'hae06fdfb77efa45d;
		#10
		m_buf = 64'hdfec4623ab899605;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h21167d8fcf23cae8;
		r_buf = 64'hdee9827030dc3517;
		t_buf = 64'hc79891833b715d01;
		#10
		m_buf = 64'h8af5890333b5b3ce;
		e_buf = 64'h0000000000000000;
		n_buf = 64'hc703806984c81999;
		r_buf = 64'h38fc7f967b37e666;
		t_buf = 64'hfc9227224374a351;
		#10
		m_buf = 64'hee6a8e2f9c19ed34;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h349aae908fb5262c;
		r_buf = 64'hcb65516f704ad9d3;
		t_buf = 64'hd7c2368322eec88a;
		#10}
		m_buf = 64'h027c013f38018399;
		e_buf = 64'h0000000000000000;
		n_buf = 64'hf320cd576d14475b;
		r_buf = 64'h0cdf32a892ebb8a4;
		t_buf = 64'he28601753d3988ef;
		#10
		m_buf = 64'hb4a1ca795718ada2;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h7b297d0b0e5e18ba;
		r_buf = 64'h84d682f4f1a1e745;
		t_buf = 64'h6f39db9920e96cfc;
		#10
		m_buf = 64'hbf3df0bbf66ac168;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h5d5f576cdeb8fc4c;
		r_buf = 64'ha2a0a893214703b3;
		t_buf = 64'h67329a416f1cd4b7;
		#10
		m_buf = 64'h51797350e6256403;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h8ded3c9691eb79fa;
		r_buf = 64'h7212c3696e148605;
		t_buf = 64'hbc768610a3668dd1;
		#10
		m_buf = 64'h52631db9d17034ce;
		e_buf = 64'h0000000000000000;
		n_buf = 64'hf0e642f43328ad08;
		r_buf = 64'h0f19bd0bccd752f7;
		t_buf = 64'h9409db1237b42777;
		#10
		m_buf = 64'h866d7002091472ad;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h69d495dd81355c53;
		r_buf = 64'h962b6a227ecaa3ac;
		t_buf = 64'h565a3bcbc8747603;
		#10}
		m_buf = 64'hdfde228125fb5f3d;
		e_buf = 64'h0000000000000000;
		n_buf = 64'hd037cdff7c240d49;
		r_buf = 64'h2fc8320083dbf2b6;
		t_buf = 64'h713bc2b69544b8f0;
		#10
		m_buf = 64'h9a431f7a41c30359;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h6a17b9af5b569643;
		r_buf = 64'h95e84650a4a969bc;
		t_buf = 64'hfb94efe911f499d4;
		#10
		m_buf = 64'h27e969e2c8bf23fb;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h0067dba858989008;
		r_buf = 64'hff982457a7676ff7;
		t_buf = 64'h3c4a088ffc15c724;
		#10
		m_buf = 64'h61067a8cd7a3283c;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h8a449ebe89d9bf02;
		r_buf = 64'h75bb6141762640fd;
		t_buf = 64'hebafa21eb031aa15;
		#10
		m_buf = 64'h4b5ca436953c178e;
		e_buf = 64'h0000000000000000;
		n_buf = 64'hc9546b439f9d0129;
		r_buf = 64'h36ab94bc6062fed6;
		t_buf = 64'h578e46c026e95b17;
		#10}
		m_buf = 64'hb4d4dfccb7d779cc;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h54c56c9a9cc9af4e;
		r_buf = 64'hab3a9365633650b1;
		t_buf = 64'hc95f516a94fb9120;
		#10
		m_buf = 64'h786e30efce9b2e70;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h99901c0475491bc3;
		r_buf = 64'h666fe3fb8ab6e43c;
		t_buf = 64'h3a9a9a285a43a743;
		#10
		m_buf = 64'hccc93ff710fce97d;
		e_buf = 64'h0000000000000000;
		n_buf = 64'hcdf8440407295e42;
		r_buf = 64'h3207bbfbf8d6a1bd;
		t_buf = 64'h958f626f4a113152;
		#10
		m_buf = 64'h843b2a7d15ab2c21;
		e_buf = 64'h0000000000000000;
		n_buf = 64'ha2a7ae1f3ac7652c;
		r_buf = 64'h5d5851e0c5389ad3;
		t_buf = 64'h7d90a87cd03fbbc4;
		#10
		m_buf = 64'hea5f24b6de6fec4b;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h8cfe5cd12d5db79b;
		r_buf = 64'h7301a32ed2a24864;
		t_buf = 64'hde0ae73aa48bb1b9;
		#10
		m_buf = 64'h10fc9eee0a1727f7;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h2e47dc0e959f3a51;
		r_buf = 64'hd1b823f16a60c5ae;
		t_buf = 64'h1b9e6229191b68a6;
		#10
		m_buf = 64'h21681081399f8a8f;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h1773308cdc6b13ab;
		r_buf = 64'he88ccf732394ec54;
		t_buf = 64'h17f328b41c901b92;
		#10
		m_buf = 64'h4cea2df00a66dc4e;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h8d103ed3cc667e97;
		r_buf = 64'h72efc12c33998168;
		t_buf = 64'h6482cd53c788fa69;
		#10
		m_buf = 64'hc2472fd603e9ba02;
		e_buf = 64'h0000000000000000;
		n_buf = 64'hd9ed17e3cc0e95ee;
		r_buf = 64'h2612e81c33f16a11;
		t_buf = 64'h1b98a5e684eecd0d;
		#10
		m_buf = 64'h72d6bc20d80d6a1c;
		e_buf = 64'h0000000000000000;
		n_buf = 64'hee52bdb6d1020a15;
		r_buf = 64'h11ad42492efdf5ea;
		t_buf = 64'h6748cb70d58c588c;
		#10
		m_buf = 64'hdca5b35354a1d505;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h084f3dd6415af341;
		r_buf = 64'hf7b0c229bea50cbe;
		t_buf = 64'h9518ae092a7c394a;
		#10
		m_buf = 64'hccf719ab2922fbd8;
		e_buf = 64'h0000000000000000;
		n_buf = 64'hf18dd1eed77c96c0;
		r_buf = 64'h0e722e112883693f;
		t_buf = 64'h3ef4b1440a12b8ef;
		#10
		m_buf = 64'hde62d43f261908b9;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h12093d26ac512b01;
		r_buf = 64'hedf6c2d953aed4fe;
		t_buf = 64'h6e6637fa3ca95da4;
		#10
		m_buf = 64'h75f2bc20a7f5195c;
		e_buf = 64'h0000000000000000;
		n_buf = 64'hde3a5db5154ed512;
		r_buf = 64'h21c5a24aeab12aed;
		t_buf = 64'h07c9917922a964a8;
		#10
		m_buf = 64'h5f0ef320f7f60e7f;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h73f7ba8e0445d656;
		r_buf = 64'h8c084571fbba29a9;
		t_buf = 64'hf2066470f135295f;
		#10}
		m_buf = 64'h61d9fe398147a8f4;
		e_buf = 64'h0000000000000000;
		n_buf = 64'hc10faa4003ba33db;
		r_buf = 64'h3ef055bffc45cc24;
		t_buf = 64'h9d89062bd8eda4fd;
		#10
		m_buf = 64'h87a1798fe6addd9e;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h47fc816ac16e2284;
		r_buf = 64'hb8037e953e91dd7b;
		t_buf = 64'h718523dad5f58f40;
		#10
		m_buf = 64'h044d9850809f2923;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h84c5b4763fe31d03;
		r_buf = 64'h7b3a4b89c01ce2fc;
		t_buf = 64'h149c1965ad98fa46;

		startCompute = 1;
		
		#1000
		getResult = 1;
		#100
		startCompute = 1;


		#10000000
		reset = 1;
		startInput = 0;
		#100
		reset = 0;
		#100 
		startInput = 1;	

				#10
		m_buf = 64'h95d1805142cb6d1d;
		e_buf = 64'h0000000000000005;
		n_buf = 64'h1622bd795fec898f;
		t_buf = 64'h73053f82acaa289e;
		r_buf = 64'he9dd4286a0137671;
		#10
		m_buf = 64'h2aa50f4ec6f00933;
		e_buf = 64'h0000000000000000;
		n_buf = 64'ha9ec0806705fca16;
		r_buf = 64'h5613f7f98fa035e9;
		t_buf = 64'h490666572b90f2c5;
		#10
		m_buf = 64'h31234efe6e648043;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h1ba1621582283d15;
		r_buf = 64'he45e9dea7dd7c2ea;
		t_buf = 64'h41d7011500400a06;
		#10
		m_buf = 64'h1d7173e55bc7fdeb;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h29e821a4c74803e3;
		r_buf = 64'hd617de5b38b7fc1c;
		t_buf = 64'h4255b841d1a34bdb;
		#10
		m_buf = 64'hd26d53961058fe8c;
		e_buf = 64'h0000000000000000;
		n_buf = 64'hd707107e855c3844;
		r_buf = 64'h28f8ef817aa3c7bb;
		t_buf = 64'h0d21bcdfdf4473e0;
		#10
		m_buf = 64'hda54f267dd138266;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h5eda92d864ac5db9;
		r_buf = 64'ha1256d279b53a246;
		t_buf = 64'hef79ce5f386efa55;
		#10
		m_buf = 64'h07120911b3b68b57;
		e_buf = 64'h0000000000000000;
		n_buf = 64'hbb968a437d5c8dfc;
		r_buf = 64'h446975bc82a37203;
		t_buf = 64'ha401baa22b888c2e;
		#10
		m_buf = 64'h869bdbd2e72bb5b7;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h78255d6807923986;
		r_buf = 64'h87daa297f86dc679;
		t_buf = 64'h432c1e910135f001;
		#10
		m_buf = 64'hc09fcd8f739cd488;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h4efbc8d60b21fbac;
		r_buf = 64'hb1043729f4de0453;
		t_buf = 64'h192d6bf19f25d484;
		#10
		m_buf = 64'h33a1d1c2ad4ab155;
		e_buf = 64'h0000000000000000;
		n_buf = 64'hd92a4aa2b410d93c;
		r_buf = 64'h26d5b55d4bef26c3;
		t_buf = 64'hd4b94bc352c949d7;
		#10
		m_buf = 64'h7f411fed1e70e799;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h9d643c25fbb230bb;
		r_buf = 64'h629bc3da044dcf44;
		t_buf = 64'h5e12a9a96f7d7742;
		#10
		m_buf = 64'h41a8a6e165e04993;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h9403560d97dae38d;
		r_buf = 64'h6bfca9f268251c72;
		t_buf = 64'hdc64dc90e98f4afe;
		#10
		m_buf = 64'ha41865bf350d278d;
		e_buf = 64'h0000000000000000;
		n_buf = 64'ha5ac06d864c2f2e3;
		r_buf = 64'h5a53f9279b3d0d1c;
		t_buf = 64'h2b94c7ae4af92d64;
		#10
		m_buf = 64'hff3e0ba10ac728b4;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h2b28fef02b9c014e;
		r_buf = 64'hd4d7010fd463feb1;
		t_buf = 64'h17df090edd741e9f;
		#10
		m_buf = 64'hcc249558f2ad985f;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h3a1890c78092b4d4;
		r_buf = 64'hc5e76f387f6d4b2b;
		t_buf = 64'hcb06c0a97843a5f8;
		#10
		m_buf = 64'h9f9821883744da64;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h0326324dfb695ffb;
		r_buf = 64'hfcd9cdb20496a004;
		t_buf = 64'he4e415995f80cfb6;
		#10
		m_buf = 64'h1ac902ee25777cf0;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h33138131c541013d;
		r_buf = 64'hccec7ece3abefec2;
		t_buf = 64'ha0a34b0f89fd1237;
		#10
		m_buf = 64'h755a3ac132ae2a20;
		e_buf = 64'h0000000000000000;
		n_buf = 64'heb8ac8ce8a245e6b;
		r_buf = 64'h1475373175dba194;
		t_buf = 64'hfb05f6b41fca9bc4;
		#10
		m_buf = 64'h5c94938160c6b3ed;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h8c5fe8f8dc3bf364;
		r_buf = 64'h73a0170723c40c9b;
		t_buf = 64'hae264f5fc010a19e;
		#10
		m_buf = 64'hd3b564b08be04c3e;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h678a5aa33b6fe507;
		r_buf = 64'h9875a55cc4901af8;
		t_buf = 64'hd1aeed41c012e824;
		#10
		m_buf = 64'h1ad0a6f226bdd974;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h5804f92283868a29;
		r_buf = 64'ha7fb06dd7c7975d6;
		t_buf = 64'hf2bb3810c6183272;
		#10
		m_buf = 64'h98a33736fd1ac7ce;
		e_buf = 64'h0000000000000000;
		n_buf = 64'hd8f33418f3d4e711;
		r_buf = 64'h270ccbe70c2b18ee;
		t_buf = 64'hd8e7aee5bebbc2b0;
		#10
		m_buf = 64'h7ce71b48fba52e59;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h5a702cfa93ea5c4e;
		r_buf = 64'ha58fd3056c15a3b1;
		t_buf = 64'h3bf4e86e41840ab5;
		#10
		m_buf = 64'h905c053b25fdacbe;
		e_buf = 64'h0000000000000000;
		n_buf = 64'he8e5b4617589a82b;
		r_buf = 64'h171a4b9e8a7657d4;
		t_buf = 64'h79c730582a57f521;
		#10
		m_buf = 64'ha36bcb0167e98363;
		e_buf = 64'h0000000000000000;
		n_buf = 64'ha8c24d4244ef7feb;
		r_buf = 64'h573db2bdbb108014;
		t_buf = 64'h71a5acdaa14ea7d5;
		#10
		m_buf = 64'h6c596216ae0fdbc8;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h9be3cecb8c497c68;
		r_buf = 64'h641c313473b68397;
		t_buf = 64'he2276688a89b7b2a;
		#10
		m_buf = 64'h856f3d95e0ae1a1b;
		e_buf = 64'h0000000000000000;
		n_buf = 64'hbab9f87ff5059285;
		r_buf = 64'h454607800afa6d7a;
		t_buf = 64'h4e1fd46c8dac7c5e;
		#10
		m_buf = 64'hade7cef37ed2ec2f;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h62397bc701762741;
		r_buf = 64'h9dc68438fe89d8be;
		t_buf = 64'h7acdff93e6b10035;
		#10
		m_buf = 64'he345ac72eac39204;
		e_buf = 64'h0000000000000000;
		n_buf = 64'hdb610487c89da11b;
		r_buf = 64'h249efb7837625ee4;
		t_buf = 64'h35605d6ab7d595c7;
		#10
		m_buf = 64'hd5627386528cc241;
		e_buf = 64'h0000000000000000;
		n_buf = 64'hf463b337d20b5d59;
		r_buf = 64'h0b9c4cc82df4a2a6;
		t_buf = 64'h11a738951c5836fd;
		#10
		m_buf = 64'hff88ec827f99d273;
		e_buf = 64'h0000000000000000;
		n_buf = 64'hf03edca7e2dcaa37;
		r_buf = 64'h0fc123581d2355c8;
		t_buf = 64'h06cdb515499fa607;
		#10
		m_buf = 64'ha2939b3b7fa74d8a;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h83333218bd91a1b7;
		r_buf = 64'h7ccccde7426e5e48;
		t_buf = 64'hae06fdfb77efa45d;
		#10
		m_buf = 64'hdfec4623ab899605;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h21167d8fcf23cae8;
		r_buf = 64'hdee9827030dc3517;
		t_buf = 64'hc79891833b715d01;
		#10
		m_buf = 64'h8af5890333b5b3ce;
		e_buf = 64'h0000000000000000;
		n_buf = 64'hc703806984c81999;
		r_buf = 64'h38fc7f967b37e666;
		t_buf = 64'hfc9227224374a351;
		#10
		m_buf = 64'hee6a8e2f9c19ed34;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h349aae908fb5262c;
		r_buf = 64'hcb65516f704ad9d3;
		t_buf = 64'hd7c2368322eec88a;
		#10}
		m_buf = 64'h027c013f38018399;
		e_buf = 64'h0000000000000000;
		n_buf = 64'hf320cd576d14475b;
		r_buf = 64'h0cdf32a892ebb8a4;
		t_buf = 64'he28601753d3988ef;
		#10
		m_buf = 64'hb4a1ca795718ada2;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h7b297d0b0e5e18ba;
		r_buf = 64'h84d682f4f1a1e745;
		t_buf = 64'h6f39db9920e96cfc;
		#10
		m_buf = 64'hbf3df0bbf66ac168;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h5d5f576cdeb8fc4c;
		r_buf = 64'ha2a0a893214703b3;
		t_buf = 64'h67329a416f1cd4b7;
		#10
		m_buf = 64'h51797350e6256403;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h8ded3c9691eb79fa;
		r_buf = 64'h7212c3696e148605;
		t_buf = 64'hbc768610a3668dd1;
		#10
		m_buf = 64'h52631db9d17034ce;
		e_buf = 64'h0000000000000000;
		n_buf = 64'hf0e642f43328ad08;
		r_buf = 64'h0f19bd0bccd752f7;
		t_buf = 64'h9409db1237b42777;
		#10
		m_buf = 64'h866d7002091472ad;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h69d495dd81355c53;
		r_buf = 64'h962b6a227ecaa3ac;
		t_buf = 64'h565a3bcbc8747603;
		#10}
		m_buf = 64'hdfde228125fb5f3d;
		e_buf = 64'h0000000000000000;
		n_buf = 64'hd037cdff7c240d49;
		r_buf = 64'h2fc8320083dbf2b6;
		t_buf = 64'h713bc2b69544b8f0;
		#10
		m_buf = 64'h9a431f7a41c30359;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h6a17b9af5b569643;
		r_buf = 64'h95e84650a4a969bc;
		t_buf = 64'hfb94efe911f499d4;
		#10
		m_buf = 64'h27e969e2c8bf23fb;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h0067dba858989008;
		r_buf = 64'hff982457a7676ff7;
		t_buf = 64'h3c4a088ffc15c724;
		#10
		m_buf = 64'h61067a8cd7a3283c;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h8a449ebe89d9bf02;
		r_buf = 64'h75bb6141762640fd;
		t_buf = 64'hebafa21eb031aa15;
		#10
		m_buf = 64'h4b5ca436953c178e;
		e_buf = 64'h0000000000000000;
		n_buf = 64'hc9546b439f9d0129;
		r_buf = 64'h36ab94bc6062fed6;
		t_buf = 64'h578e46c026e95b17;
		#10}
		m_buf = 64'hb4d4dfccb7d779cc;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h54c56c9a9cc9af4e;
		r_buf = 64'hab3a9365633650b1;
		t_buf = 64'hc95f516a94fb9120;
		#10
		m_buf = 64'h786e30efce9b2e70;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h99901c0475491bc3;
		r_buf = 64'h666fe3fb8ab6e43c;
		t_buf = 64'h3a9a9a285a43a743;
		#10
		m_buf = 64'hccc93ff710fce97d;
		e_buf = 64'h0000000000000000;
		n_buf = 64'hcdf8440407295e42;
		r_buf = 64'h3207bbfbf8d6a1bd;
		t_buf = 64'h958f626f4a113152;
		#10
		m_buf = 64'h843b2a7d15ab2c21;
		e_buf = 64'h0000000000000000;
		n_buf = 64'ha2a7ae1f3ac7652c;
		r_buf = 64'h5d5851e0c5389ad3;
		t_buf = 64'h7d90a87cd03fbbc4;
		#10
		m_buf = 64'hea5f24b6de6fec4b;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h8cfe5cd12d5db79b;
		r_buf = 64'h7301a32ed2a24864;
		t_buf = 64'hde0ae73aa48bb1b9;
		#10
		m_buf = 64'h10fc9eee0a1727f7;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h2e47dc0e959f3a51;
		r_buf = 64'hd1b823f16a60c5ae;
		t_buf = 64'h1b9e6229191b68a6;
		#10
		m_buf = 64'h21681081399f8a8f;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h1773308cdc6b13ab;
		r_buf = 64'he88ccf732394ec54;
		t_buf = 64'h17f328b41c901b92;
		#10
		m_buf = 64'h4cea2df00a66dc4e;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h8d103ed3cc667e97;
		r_buf = 64'h72efc12c33998168;
		t_buf = 64'h6482cd53c788fa69;
		#10
		m_buf = 64'hc2472fd603e9ba02;
		e_buf = 64'h0000000000000000;
		n_buf = 64'hd9ed17e3cc0e95ee;
		r_buf = 64'h2612e81c33f16a11;
		t_buf = 64'h1b98a5e684eecd0d;
		#10
		m_buf = 64'h72d6bc20d80d6a1c;
		e_buf = 64'h0000000000000000;
		n_buf = 64'hee52bdb6d1020a15;
		r_buf = 64'h11ad42492efdf5ea;
		t_buf = 64'h6748cb70d58c588c;
		#10
		m_buf = 64'hdca5b35354a1d505;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h084f3dd6415af341;
		r_buf = 64'hf7b0c229bea50cbe;
		t_buf = 64'h9518ae092a7c394a;
		#10
		m_buf = 64'hccf719ab2922fbd8;
		e_buf = 64'h0000000000000000;
		n_buf = 64'hf18dd1eed77c96c0;
		r_buf = 64'h0e722e112883693f;
		t_buf = 64'h3ef4b1440a12b8ef;
		#10
		m_buf = 64'hde62d43f261908b9;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h12093d26ac512b01;
		r_buf = 64'hedf6c2d953aed4fe;
		t_buf = 64'h6e6637fa3ca95da4;
		#10
		m_buf = 64'h75f2bc20a7f5195c;
		e_buf = 64'h0000000000000000;
		n_buf = 64'hde3a5db5154ed512;
		r_buf = 64'h21c5a24aeab12aed;
		t_buf = 64'h07c9917922a964a8;
		#10
		m_buf = 64'h5f0ef320f7f60e7f;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h73f7ba8e0445d656;
		r_buf = 64'h8c084571fbba29a9;
		t_buf = 64'hf2066470f135295f;
		#10}
		m_buf = 64'h61d9fe398147a8f4;
		e_buf = 64'h0000000000000000;
		n_buf = 64'hc10faa4003ba33db;
		r_buf = 64'h3ef055bffc45cc24;
		t_buf = 64'h9d89062bd8eda4fd;
		#10
		m_buf = 64'h87a1798fe6addd9e;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h47fc816ac16e2284;
		r_buf = 64'hb8037e953e91dd7b;
		t_buf = 64'h718523dad5f58f40;
		#10
		m_buf = 64'h044d9850809f2923;
		e_buf = 64'h0000000000000000;
		n_buf = 64'h84c5b4763fe31d03;
		r_buf = 64'h7b3a4b89c01ce2fc;
		t_buf = 64'h149c1965ad98fa46;

		#10000000	
		startCompute = 0;
		getResult = 1;

	end
	
	always begin
		#5 clk = ~clk;
	end
	
endmodule
