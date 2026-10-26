*
*
*
*                       LINUX           Thu Oct 22 22:51:13 2026
*
*
*
*  PROGRAM  advgen
*
*  Name           : advgen - Quantus - (64-bit)
*  Version        : 23.1.2-p001
*  Build Date     : Fri Jan 9 20:05:08 PST 2026
*
*  HSPICE LIBRARY
*
*  OPERATING_TEMPERATURE 25
*  QRC_TECH_DIR /opt/pdk/sky130_release_0.1.0/quantus/extraction/typical 
*
*
*

*
.SUBCKT cdac_8b ctl<0> ctl<1> ctl<2> ctl<3> ctl<4> ctl<5> ctl<6> ctl<7> ctl_dum
+ sample vdda vin vout vref vssa
*
*
*  caps2d version: 10
*
*
*       TRANSISTOR CARDS
*
*
MXI8/MNM0	vbottom<7>#5	ctl<7>#3	vssa#18	vssa#1
+ nfet_01v8	L=1.5e-07	W=4.2e-07
MXI7/MNM0	vbottom<6>#5	ctl<6>#3	vssa#22	vssa#1
+ nfet_01v8	L=1.5e-07	W=4.2e-07
MXI6/MNM0	vbottom<5>#5	ctl<5>#3	vssa#26	vssa#1
+ nfet_01v8	L=1.5e-07	W=4.2e-07
MXI4/MNM0	vbottom<3>#5	ctl<3>#3	vssa#30	vssa#1
+ nfet_01v8	L=1.5e-07	W=4.2e-07
MXI1/MNM0	vbottom<0>#5	ctl<0>#3	vssa#34	vssa#1
+ nfet_01v8	L=1.5e-07	W=4.2e-07
MXI2/MNM0	vbottom<1>#5	ctl<1>#3	vssa#38	vssa#1
+ nfet_01v8	L=1.5e-07	W=4.2e-07
MXI3/MNM0	vbottom<2>#5	ctl<2>#3	vssa#42	vssa#1
+ nfet_01v8	L=1.5e-07	W=4.2e-07
MXI9/MNM0	net3#5	ctl_dum#3	vssa#46	vssa#1	nfet_01v8
+ L=1.5e-07	W=4.2e-07
MXI5/MNM0	vbottom<4>#5	ctl<4>#3	vssa#50	vssa#1
+ nfet_01v8	L=1.5e-07	W=4.2e-07
MXI8/MPM0	vbottom<7>	ctl<7>#1	vref#39	vref
+ pfet_01v8	L=1.5e-07	W=5.5e-07
MXI7/MPM0	vbottom<6>	ctl<6>#1	vref#42	vref
+ pfet_01v8	L=1.5e-07	W=5.5e-07
MXI6/MPM0	vbottom<5>	ctl<5>#1	vref#45	vref
+ pfet_01v8	L=1.5e-07	W=5.5e-07
MXI4/MPM0	vbottom<3>	ctl<3>#1	vref#48	vref
+ pfet_01v8	L=1.5e-07	W=5.5e-07
MXI1/MPM0	vbottom<0>#3	ctl<0>#1	vref#49	vref
+ pfet_01v8	L=1.5e-07	W=5.5e-07
MXI2/MPM0	vbottom<1>	ctl<1>#1	vref#54	vref
+ pfet_01v8	L=1.5e-07	W=5.5e-07
MXI3/MPM0	vbottom<2>#3	ctl<2>#1	vref#55	vref
+ pfet_01v8	L=1.5e-07	W=5.5e-07
MXI9/MPM0	net3#3	ctl_dum#1	vref#58	vref	pfet_01v8
+ L=1.5e-07	W=5.5e-07
MXI5/MPM0	vbottom<4>#3	ctl<4>#1	vref#61	vref
+ pfet_01v8	L=1.5e-07	W=5.5e-07
MXI10/Xinv_lvt0/MPM0	XI10/enb#23	sample#1	vdda#7	vdda
+ pfet_01v8_lvt	L=3.5e-07	W=5.5e-07
MXI10/MM4	XI10/net2#23	XI10/enb	XI10/vbsh#2	XI10/vbsh
+ pfet_01v8_lvt	L=4e-07	W=1e-06
MXI10/MM3	vdda#14	XI10/net2	XI10/vbsh#5	XI10/vbsh
+ pfet_01v8_lvt	L=4e-07	W=1e-06
MXI10/MMs	vout#1	XI10/net2#3	vin#2	vssa#1	nfet_01v8_lvt	L=5e-07
+ W=1e-06
MXI10/MMs2	vssa#13	XI10/enb#5	XI10/net30#2	vssa#1
+ nfet_01v8_lvt	L=4e-07	W=1e-06
MXI10/MM1	XI10/vbsl#2	XI10/net2#5	vin#6	vssa#1	nfet_01v8_lvt
+ L=4e-07	W=1e-06
MXI10/MM2	XI10/vbsl#5	XI10/enb#3	vssa#9	vssa#1	nfet_01v8_lvt
+ L=4e-07	W=1e-06
MXI10/MMs1	XI10/net30#5	vdda#1	XI10/net2#27	vssa#1	nfet_01v8_lvt
+ L=4e-07	W=1e-06
MXI10/Xinv_lvt0/MNM0	XI10/enb#17	sample#3	vssa#6	vssa#1
+ nfet_01v8_lvt	L=1.5e-07	W=4.2e-07
*
*
*       RESISTOR AND CAP/DIODE CARDS
*
Rg2	sample#3	sample#9	154.183411	$poly	$W=1.5e-07
Rg3	XI10/net2#13	XI10/net2#3	99.093826	$poly	$W=4.65e-07
Rg5	XI10/net2#14	XI10/net2#5	116.461678	$poly	$W=3.8e-07
Rg8	XI10/enb#3	XI10/enb#13	125.886208	$poly	$W=4e-07
Rg10	sample#1	sample#10	82.628571	$poly	$W=3.5e-07
Rg11	XI10/enb#14	XI10/enb	99.412498	$poly	$W=4e-07
Rg13	XI10/net2#15	XI10/net2	99.412498	$poly	$W=4e-07
Rg16	XI10/enb#5	XI10/enb#15	103.143257	$poly	$W=3.8e-07
Rg17	vdda#5	vdda#1	99.412498	$poly	$W=4e-07
Rg20	ctl<7>#3	ctl<7>#7	184.528366	$poly	$W=1.5e-07
Rg21	ctl<7>#7	ctl<7>#1	205.415039	$poly	$W=1.5e-07
Rg23	ctl<7>#7	ctl<7>#8	237.742096	$poly	$W=1.5e-07
Rg25	ctl<6>#3	ctl<6>#7	184.528366	$poly	$W=1.5e-07
Rg26	ctl<6>#7	ctl<6>#1	205.415039	$poly	$W=1.5e-07
Rg28	ctl<6>#7	ctl<6>#8	237.742096	$poly	$W=1.5e-07
Rg30	ctl<5>#3	ctl<5>#7	184.528366	$poly	$W=1.5e-07
Rg31	ctl<5>#7	ctl<5>#1	205.415039	$poly	$W=1.5e-07
Rg33	ctl<5>#7	ctl<5>#8	237.742096	$poly	$W=1.5e-07
Rg35	ctl<3>#3	ctl<3>#7	184.528366	$poly	$W=1.5e-07
Rg36	ctl<3>#7	ctl<3>#1	205.415039	$poly	$W=1.5e-07
Rg38	ctl<3>#7	ctl<3>#8	237.742096	$poly	$W=1.5e-07
Rg40	ctl<0>#3	ctl<0>#7	184.528366	$poly	$W=1.5e-07
Rg41	ctl<0>#7	ctl<0>#1	205.415039	$poly	$W=1.5e-07
Rg43	ctl<0>#7	ctl<0>#8	237.742096	$poly	$W=1.5e-07
Rg45	ctl<1>#3	ctl<1>#7	184.528366	$poly	$W=1.5e-07
Rg46	ctl<1>#7	ctl<1>#1	205.415039	$poly	$W=1.5e-07
Rg48	ctl<1>#7	ctl<1>#8	237.742096	$poly	$W=1.5e-07
Rg50	ctl<2>#3	ctl<2>#7	184.528366	$poly	$W=1.5e-07
Rg51	ctl<2>#7	ctl<2>#1	205.415039	$poly	$W=1.5e-07
Rg53	ctl<2>#7	ctl<2>#8	237.742096	$poly	$W=1.5e-07
Rg55	ctl_dum#3	ctl_dum#7	184.528366	$poly	$W=1.5e-07
Rg56	ctl_dum#7	ctl_dum#1	205.415039	$poly	$W=1.5e-07
Rg58	ctl_dum#7	ctl_dum#8	237.742096	$poly	$W=1.5e-07
Rg60	ctl<4>#3	ctl<4>#7	184.528366	$poly	$W=1.5e-07
Rg61	ctl<4>#7	ctl<4>#1	205.415039	$poly	$W=1.5e-07
Rg63	ctl<4>#7	ctl<4>#8	237.742096	$poly	$W=1.5e-07
Rf1	vssa#1	vssa#3	7.500000	$li	$W=5.1e-07
Rf4	sample#9	sample#12	15.000000	$li	$W=2.3e-07
Rf7	vssa#6	vssa#7	15.000000	$li	$W=1.7e-07
Rf10	XI10/enb#17	XI10/enb#16	15.000000	$li	$W=1.7e-07
Rf11	vout#1	vout#3	7.500000	$li	$W=5.1e-07
Rf16	vin#2	vin#3	7.500000	$li	$W=5.1e-07
Rf19	vin#6	vin#7	7.500000	$li	$W=5.1e-07
Rf20	vssa#9	vssa#11	7.500000	$li	$W=5.1e-07
Rf23	sample#10	sample#14	15.000000	$li	$W=2.3e-07
Rf24	XI10/net2#13	XI10/net2#17	167.000000	$li	$W=1.7e-07
Rf25	XI10/net2#14	XI10/net2#19	15.000000	$li	$W=1.7e-07
Rf27	XI10/vbsl#3	XI10/vbsl#4	76.000000	$li	$W=5.1e-07
Rf28	XI10/vbsl#2	XI10/vbsl#3	7.500000	$li	$W=5.1e-07
Rf29	XI10/enb#13	XI10/enb#21	15.000000	$li	$W=1.7e-07
Rf30	XI10/vbsl#5	XI10/vbsl#7	7.500000	$li	$W=5.1e-07
Rf35	XI10/enb#23	XI10/enb#24	15.000000	$li	$W=1.7e-07
Rf38	vdda#7	vdda#6	15.000000	$li	$W=1.7e-07
Rf42	XI10/vbsh	XI10/vbsh#3	7.500000	$li	$W=5.1e-07
Rf43	XI10/vbsh#3	XI10/vbsh#4	76.000000	$li	$W=5.1e-07
Rf44	XI10/vbsh#2	XI10/vbsh#3	7.500000	$li	$W=5.1e-07
Rf45	XI10/vbsh#5	XI10/vbsh#7	7.500000	$li	$W=5.1e-07
Rf48	XI10/enb#15	XI10/enb#27	15.000000	$li	$W=1.7e-07
Rf49	XI10/enb#14	XI10/enb#29	15.000000	$li	$W=2.3e-07
Rf50	XI10/net2#15	XI10/net2#21	15.000000	$li	$W=2.3e-07
Rf52	XI10/net2#24	XI10/net2#25	76.000000	$li	$W=5.1e-07
Rf53	XI10/net2#23	XI10/net2#24	7.500000	$li	$W=5.1e-07
Rf57	vdda#14	vdda#16	7.500000	$li	$W=5.1e-07
Rf63	vssa#13	vssa#15	7.500000	$li	$W=5.1e-07
Rf64	vssa#15	vssa#16	76.000000	$li	$W=5.1e-07
Rf67	XI10/net30#3	XI10/net30	76.000000	$li	$W=5.1e-07
Rf68	XI10/net30#2	XI10/net30#3	7.500000	$li	$W=5.1e-07
Rf69	XI10/net30#5	XI10/net30#7	7.500000	$li	$W=5.1e-07
Rf70	XI10/net30#7	XI10/net30#8	76.000000	$li	$W=5.1e-07
Rf73	XI10/net2#28	XI10/net2#29	76.000000	$li	$W=5.1e-07
Rf74	XI10/net2#27	XI10/net2#28	7.500000	$li	$W=5.1e-07
Rf75	vdda#5	vdda#19	15.000000	$li	$W=2.3e-07
Rf104	vref#38	vref#39	15.000000	$li	$W=1.7e-07
Rf105	vbottom<7>	vbottom<7>#2	15.000000	$li	$W=1.7e-07
Rf108	vref#41	vref#42	15.000000	$li	$W=1.7e-07
Rf109	vbottom<6>	vbottom<6>#2	15.000000	$li	$W=1.7e-07
Rf112	vref#44	vref#45	15.000000	$li	$W=1.7e-07
Rf113	vbottom<5>	vbottom<5>#2	15.000000	$li	$W=1.7e-07
Rf116	vref#47	vref#48	15.000000	$li	$W=1.7e-07
Rf117	vbottom<3>	vbottom<3>#2	15.000000	$li	$W=1.7e-07
Rf120	vbottom<0>#2	vbottom<0>#3	15.000000	$li	$W=1.7e-07
Rf121	vref#49	vref#50	15.000000	$li	$W=1.7e-07
Rf124	vref#53	vref#54	15.000000	$li	$W=1.7e-07
Rf125	vbottom<1>	vbottom<1>#2	15.000000	$li	$W=1.7e-07
Rf128	vbottom<2>#2	vbottom<2>#3	15.000000	$li	$W=1.7e-07
Rf129	vref#55	vref#56	15.000000	$li	$W=1.7e-07
Rf132	net3#2	net3#3	15.000000	$li	$W=1.7e-07
Rf133	vref#58	vref#59	15.000000	$li	$W=1.7e-07
Rf136	vbottom<4>#2	vbottom<4>#3	15.000000	$li	$W=1.7e-07
Rf137	vref#61	vref#62	15.000000	$li	$W=1.7e-07
Rf139	ctl<7>#8	ctl<7>#10	15.000000	$li	$W=1.7e-07
Rf140	ctl<6>#8	ctl<6>#10	15.000000	$li	$W=1.7e-07
Rf141	ctl<5>#8	ctl<5>#10	15.000000	$li	$W=1.7e-07
Rf142	ctl<3>#8	ctl<3>#10	15.000000	$li	$W=1.7e-07
Rf143	ctl<0>#8	ctl<0>#10	15.000000	$li	$W=1.7e-07
Rf144	ctl<1>#8	ctl<1>#10	15.000000	$li	$W=1.7e-07
Rf145	ctl<2>#8	ctl<2>#10	15.000000	$li	$W=1.7e-07
Rf146	ctl_dum#8	ctl_dum#10	15.000000	$li	$W=1.7e-07
Rf147	ctl<4>#8	ctl<4>#10	15.000000	$li	$W=1.7e-07
Rf150	vssa#18	vssa#19	15.000000	$li	$W=1.7e-07
Rf153	vbottom<7>#5	vbottom<7>#4	15.000000	$li	$W=1.7e-07
Rf156	vssa#22	vssa#23	15.000000	$li	$W=1.7e-07
Rf159	vbottom<6>#5	vbottom<6>#4	15.000000	$li	$W=1.7e-07
Rf162	vssa#26	vssa#27	15.000000	$li	$W=1.7e-07
Rf165	vbottom<5>#5	vbottom<5>#4	15.000000	$li	$W=1.7e-07
Rf168	vssa#30	vssa#31	15.000000	$li	$W=1.7e-07
Rf171	vbottom<3>#5	vbottom<3>#4	15.000000	$li	$W=1.7e-07
Rf174	vbottom<0>#5	vbottom<0>#6	15.000000	$li	$W=1.7e-07
Rf177	vssa#34	vssa#33	15.000000	$li	$W=1.7e-07
Rf180	vssa#38	vssa#39	15.000000	$li	$W=1.7e-07
Rf183	vbottom<1>#5	vbottom<1>#4	15.000000	$li	$W=1.7e-07
Rf186	vbottom<2>#5	vbottom<2>#6	15.000000	$li	$W=1.7e-07
Rf189	vssa#42	vssa#41	15.000000	$li	$W=1.7e-07
Rf192	net3#5	net3#6	15.000000	$li	$W=1.7e-07
Rf195	vssa#46	vssa#45	15.000000	$li	$W=1.7e-07
Rf198	vbottom<4>#5	vbottom<4>#6	15.000000	$li	$W=1.7e-07
Rf201	vssa#50	vssa#49	15.000000	$li	$W=1.7e-07
Rf203	vssa#53	vssa#1	15.000000	$li	$W=2.7e-07
Rf205	vssa#1	vssa#57	15.000000	$li	$W=2.7e-07
Rf209	vssa#59	vssa#1	15.000000	$li	$W=2.7e-07
Rf211	vssa#1	vssa#63	15.000000	$li	$W=2.7e-07
Rf215	vssa#65	vssa#1	15.000000	$li	$W=2.7e-07
Rf217	vssa#1	vssa#69	15.000000	$li	$W=2.7e-07
Rf221	vssa#71	vssa#1	15.000000	$li	$W=2.7e-07
Rf223	vssa#1	vssa#75	15.000000	$li	$W=2.7e-07
Rf227	vssa#77	vssa#1	15.000000	$li	$W=2.7e-07
Re1	vin#9	vin	5.089531	$metal1	$W=1.6e-06
Re2	vout#5	vout#3	76.065887	$metal1	$W=1.015e-06
Re3	vin#10	vin#11	0.430234	$metal1	$W=4.2e-07
Re4	vin#11	vin#3	76.226593	$metal1	$W=6.6e-07
Re5	vin#11	vin#7	76.209488	$metal1	$W=4.2e-07
Re6	XI10/enb#30	XI10/enb#31	0.972638	$metal1
+ $W=3.6e-07
Re7	XI10/enb#31	XI10/enb#16	152.917343	$metal1
+ $W=2.35e-07
Re8	XI10/enb#31	XI10/enb#24	152.185944	$metal1
+ $W=3.6e-07
Re9	XI10/enb#34	XI10/enb#21	154.491226	$metal1
+ $W=5.7e-07
Re11	XI10/vbsl#4	XI10/vbsl#11	0.834513	$metal1
+ $W=3.35e-07
Re12	XI10/vbsl#11	XI10/vbsl#7	76.581871	$metal1
+ $W=4.35e-07
Re13	XI10/enb#27	XI10/enb#37	154.784485	$metal1
+ $W=2.9e-07
Re14	XI10/enb#38	XI10/enb#29	159.510223	$metal1
+ $W=2.6e-07
Re16	XI10/vbsh#4	XI10/vbsh#19	0.709097	$metal1
+ $W=2.9e-07
Re17	XI10/vbsh#19	XI10/vbsh#20	0.849130	$metal1
+ $W=4.85e-07
Re18	XI10/vbsh#20	XI10/vbsh#21	0.234787	$metal1
+ $W=4.85e-07
Re19	XI10/vbsh#21	XI10/vbsh#22	0.219456	$metal1
+ $W=4.85e-07
Re22	XI10/vbsh#20	XI10/vbsh#7	76.122620	$metal1
+ $W=1.025e-06
Re25	vssa#16	vssa#82	2.650878	$metal1
+ $W=2.9e-07
Re27	vssa#82	vssa#84	0.264886	$metal1
+ $W=1.525e-06
Re28	vssa#84	vssa#7	152.737137	$metal1	$W=4.2e-07
Re29	vssa#82	vssa#3	76.317535	$metal1	$W=1e-06
Re30	vssa#84	vssa#11	76.862694	$metal1
+ $W=6e-07
Re32	XI10/net30	XI10/net30#8	0.594828	$metal1
+ $W=2.9e-07
Re37	XI10/net2#29	XI10/net2#32	0.394460	$metal1
+ $W=2.95e-07
Re38	XI10/net2#32	XI10/net2#17	3.542489	$metal1
+ $W=2.95e-07
Re39	XI10/net2#17	XI10/net2#19	152.372955	$metal1
+ $W=3.05e-07
Re40	XI10/net2#32	XI10/net2#35	0.608131	$metal1
+ $W=2.95e-07
Re41	XI10/net2#35	XI10/net2#21	153.635468	$metal1
+ $W=2.9e-07
Re42	XI10/net2#35	XI10/net2#25	0.158644	$metal1
+ $W=2.9e-07
Re45	vdda#20	vdda#21	6.224688	$metal1
+ $W=1.8e-06
Re46	vdda#21	vdda#22	2.640313	$metal1
+ $W=4.35e-07
Re47	vdda#22	vdda#6	152.379608	$metal1	$W=3.35e-07
Re48	vdda#21	vdda#24	0.176312	$metal1
+ $W=1.24e-06
Re49	vdda#24	vdda#16	76.217323	$metal1
+ $W=1.005e-06
Re51	vdda#24	vdda#27	0.714368	$metal1
+ $W=1.24e-06
Re52	vdda#27	vdda#19	152.137207	$metal1
+ $W=4.25e-07
Re54	vdda	vdda#30	19.838125	$metal1	$W=1e-06
Re56	vref#65	vref#66	0.598886	$metal1
+ $W=1.4e-07
Re58	vref#65	vref#38	152.623520	$metal1
+ $W=1.4e-07
Re59	vref#66	vref#69	1.099658	$metal1
+ $W=1e-06
Re60	vref#69	vref#70	1.099658	$metal1
+ $W=1e-06
Re61	vref#70	vref#71	1.062158	$metal1
+ $W=1e-06
Re62	vref#71	vref#72	0.578408	$metal1
+ $W=1e-06
Re63	vref#72	vref#73	0.558408	$metal1
+ $W=1e-06
Re64	vref#73	vref#74	0.540908	$metal1
+ $W=1e-06
Re65	vref#74	vref#75	0.974658	$metal1
+ $W=1e-06
Re66	vref#75	vref#76	1.099658	$metal1
+ $W=1e-06
Re67	vref#76	vref	8.499205	$metal1	$W=1e-06
Re68	vref#69	vref#77	0.598886	$metal1
+ $W=1.4e-07
Re70	vref#70	vref#79	0.598886	$metal1
+ $W=1.4e-07
Re72	vref#71	vref#81	0.598886	$metal1
+ $W=1.4e-07
Re74	vref#72	vref#83	0.598886	$metal1
+ $W=1.4e-07
Re76	vref#73	vref#85	0.598886	$metal1
+ $W=1.4e-07
Re78	vref#74	vref#87	0.598886	$metal1
+ $W=1.4e-07
Re80	vref#75	vref#89	0.598886	$metal1
+ $W=1.4e-07
Re82	vref#76	vref#91	0.598886	$metal1
+ $W=1.4e-07
Re84	vref#77	vref#41	152.623520	$metal1
+ $W=1.4e-07
Re85	vref#79	vref#44	152.623520	$metal1
+ $W=1.4e-07
Re86	vref#81	vref#47	152.623520	$metal1
+ $W=1.4e-07
Re87	vref#83	vref#50	152.623520	$metal1
+ $W=1.4e-07
Re88	vref#85	vref#53	152.623520	$metal1
+ $W=1.4e-07
Re89	vref#87	vref#56	152.623520	$metal1
+ $W=1.4e-07
Re90	vref#89	vref#59	152.623520	$metal1
+ $W=1.4e-07
Re91	vref#91	vref#62	152.623520	$metal1
+ $W=1.4e-07
Re92	vbottom<7>#4	vbottom<7>#9	152.471909	$metal1
+ $W=1.4e-07
Re93	vbottom<7>#9	vbottom<7>#2	152.529953	$metal1
+ $W=1.4e-07
Re94	vbottom<7>#9	vbottom<7>#11	1.021158	$metal1
+ $W=1.4e-07
Re95	vbottom<6>#4	vbottom<6>#9	152.471909	$metal1
+ $W=1.4e-07
Re96	vbottom<6>#9	vbottom<6>#2	152.529953	$metal1
+ $W=1.4e-07
Re97	vbottom<6>#9	vbottom<6>#11	0.998836	$metal1
+ $W=1.4e-07
Re98	vbottom<5>#4	vbottom<5>#9	152.471909	$metal1
+ $W=1.4e-07
Re99	vbottom<5>#9	vbottom<5>#2	152.529953	$metal1
+ $W=1.4e-07
Re100	vbottom<5>#9	vbottom<5>#11	1.003300	$metal1
+ $W=1.4e-07
Re101	vbottom<3>#4	vbottom<3>#9	152.471909	$metal1
+ $W=1.4e-07
Re102	vbottom<3>#9	vbottom<3>#2	152.529953	$metal1
+ $W=1.4e-07
Re103	vbottom<3>#9	vbottom<3>#11	0.998836	$metal1
+ $W=1.4e-07
Re104	vbottom<0>#6	vbottom<0>#9	152.471909	$metal1
+ $W=1.4e-07
Re105	vbottom<0>#9	vbottom<0>#2	152.529953	$metal1
+ $W=1.4e-07
Re106	vbottom<0>#9	vbottom<0>#11	0.998836	$metal1
+ $W=1.4e-07
Re107	vbottom<1>#4	vbottom<1>#9	152.471909	$metal1
+ $W=1.4e-07
Re108	vbottom<1>#9	vbottom<1>#2	152.529953	$metal1
+ $W=1.4e-07
Re109	vbottom<1>#9	vbottom<1>#11	0.998836	$metal1
+ $W=1.4e-07
Re110	vbottom<2>#6	vbottom<2>#9	152.471909	$metal1
+ $W=1.4e-07
Re111	vbottom<2>#9	vbottom<2>#2	152.529953	$metal1
+ $W=1.4e-07
Re112	vbottom<2>#9	vbottom<2>#11	0.998836	$metal1
+ $W=1.4e-07
Re113	net3#6	net3#9	152.471909	$metal1	$W=1.4e-07
Re114	net3#9	net3#2	152.529953	$metal1	$W=1.4e-07
Re115	net3#9	net3#11	0.998836	$metal1	$W=1.4e-07
Re116	vbottom<4>#6	vbottom<4>#9	152.471909	$metal1
+ $W=1.4e-07
Re117	vbottom<4>#9	vbottom<4>#2	152.529953	$metal1
+ $W=1.4e-07
Re118	vbottom<4>#9	vbottom<4>#11	0.998836	$metal1
+ $W=1.4e-07
Re119	vssa#88	vssa#89	0.532759	$metal1
+ $W=1.4e-07
Re120	vssa#89	vssa#19	152.574417	$metal1
+ $W=1.4e-07
Re121	vssa#89	vssa#53	152.067368	$metal1
+ $W=2.7e-07
Re122	vssa#92	vssa#93	0.720259	$metal1
+ $W=1.4e-07
Re123	vssa#93	vssa#23	152.574417	$metal1
+ $W=1.4e-07
Re124	vssa#93	vssa#57	152.067368	$metal1
+ $W=2.7e-07
Re125	vssa#96	vssa#97	0.720259	$metal1
+ $W=1.4e-07
Re126	vssa#97	vssa#27	152.574417	$metal1
+ $W=1.4e-07
Re127	vssa#97	vssa#59	152.067368	$metal1
+ $W=2.7e-07
Re128	vssa#100	vssa#101	0.720259	$metal1
+ $W=1.4e-07
Re129	vssa#101	vssa#31	152.574417	$metal1
+ $W=1.4e-07
Re130	vssa#101	vssa#63	152.067368	$metal1
+ $W=2.7e-07
Re131	vssa#104	vssa#105	0.720259	$metal1
+ $W=1.4e-07
Re132	vssa#105	vssa#33	152.574417	$metal1
+ $W=1.4e-07
Re133	vssa#105	vssa#65	152.067368	$metal1
+ $W=2.7e-07
Re134	vssa#108	vssa#109	0.720259	$metal1
+ $W=1.4e-07
Re135	vssa#109	vssa#39	152.574417	$metal1
+ $W=1.4e-07
Re136	vssa#109	vssa#69	152.067368	$metal1
+ $W=2.7e-07
Re137	vssa#112	vssa#113	0.720259	$metal1
+ $W=1.4e-07
Re138	vssa#113	vssa#41	152.574417	$metal1
+ $W=1.4e-07
Re139	vssa#113	vssa#71	152.067368	$metal1
+ $W=2.7e-07
Re140	vssa#116	vssa#117	0.720259	$metal1
+ $W=1.4e-07
Re141	vssa#117	vssa#45	152.574417	$metal1
+ $W=1.4e-07
Re142	vssa#117	vssa#75	152.067368	$metal1
+ $W=2.7e-07
Re143	vssa#120	vssa#121	0.720259	$metal1
+ $W=1.4e-07
Re144	vssa#121	vssa#49	152.574417	$metal1
+ $W=1.4e-07
Re145	vssa#121	vssa#77	152.067368	$metal1
+ $W=2.7e-07
Re146	ctl<7>	ctl<7>#10	156.372864	$metal1	$W=1.5e-07
Re147	ctl<6>	ctl<6>#10	156.372864	$metal1	$W=1.5e-07
Re148	ctl<5>	ctl<5>#10	156.372864	$metal1	$W=1.5e-07
Re149	ctl<3>	ctl<3>#10	156.372864	$metal1	$W=1.5e-07
Re150	ctl<0>	ctl<0>#10	156.322861	$metal1	$W=1.5e-07
Re151	ctl<1>	ctl<1>#10	156.372864	$metal1	$W=1.5e-07
Re152	ctl<2>	ctl<2>#10	156.322861	$metal1	$W=1.5e-07
Re153	ctl_dum	ctl_dum#10	156.322861	$metal1
+ $W=1.5e-07
Re154	ctl<4>	ctl<4>#10	156.322861	$metal1	$W=1.5e-07
Re155	vout	vout#7	7.428515	$metal1	$W=1.6e-06
Re156	vout#7	vout#8	1.314062	$metal1	$W=1.6e-06
Re157	sample	sample#15	27.809185	$metal1	$W=6e-07
Re158	sample#15	sample#12	152.924454	$metal1
+ $W=3.45e-07
Re159	sample#15	sample#14	153.475403	$metal1
+ $W=3.5e-07
Rd1	vin#10	vin#9	11.401065	$metal2	$W=4.2e-07
Rd2	vout#5	vout#8	9.973921	$metal2	$W=6.95e-07
Rd3	XI10/enb#38	XI10/enb#34	0.511555	$metal2
+ $W=5.95e-07
Rd4	XI10/enb#38	XI10/enb#37	5.345588	$metal2
+ $W=5.95e-07
Rd5	XI10/enb#34	XI10/enb#30	4.961134	$metal2
+ $W=5.95e-07
Rd6	XI10/vbsl	XI10/vbsl#11	4.392509	$metal2
+ $W=1.34e-06
Rd7	XI10/vbsh#22	XI10/vbsh#28	6.116758	$metal2
+ $W=9.1e-07
Rd8	vout#7	vout#12	17.699999	$metal2	$W=3e-07
Rd9	vbottom<3>#12	vbottom<3>#13	22.562500	$metal2
+ $W=3e-07
Rd10	vdda#20	vdda#30	4.896875	$metal2
+ $W=1e-06
Rd11	vbottom<5>#11	vbottom<5>#13	10.036663	$metal2
+ $W=3e-07
Rd12	vbottom<5>#13	vbottom<5>#14	23.622667	$metal2
+ $W=3e-07
Rd13	vbottom<5>#13	vbottom<5>#15	18.836662	$metal2
+ $W=3e-07
Rd14	vbottom<7>#11	vbottom<7>#13	10.038467	$metal2
+ $W=3e-07
Rd15	vbottom<7>#13	vbottom<7>#14	8.946492	$metal2
+ $W=3e-07
Rd16	vbottom<7>#13	vbottom<7>#15	4.161384	$metal2
+ $W=3e-07
Rd17	vbottom<6>#11	vbottom<6>#13	10.038965	$metal2
+ $W=3e-07
Rd18	vbottom<6>#13	vbottom<6>#14	16.289122	$metal2
+ $W=3e-07
Rd19	vbottom<6>#13	vbottom<6>#15	11.501466	$metal2
+ $W=3e-07
Rd20	vbottom<4>#11	vbottom<4>#13	10.038965	$metal2
+ $W=3e-07
Rd21	vbottom<4>#13	vbottom<4>#14	23.438965	$metal2
+ $W=3e-07
Rd22	vbottom<4>#14	vbottom<4>#15	7.333333	$metal2
+ $W=3e-07
Rd23	vbottom<4>#13	vbottom<4>	22.941622	$metal2
+ $W=3e-07
Rd24	vbottom<4>	vbottom<4>#17	7.333333	$metal2
+ $W=3e-07
Rd25	vbottom<0>#11	vbottom<0>	39.883335	$metal2
+ $W=3e-07
Rd26	vbottom<1>#11	vbottom<1>#13	41.731251	$metal2
+ $W=3e-07
Rd27	vbottom<1>#13	vbottom<1>#14	1.818750	$metal2
+ $W=3e-07
Rd28	net3#11	net3	43.549999	$metal2	$W=3e-07
Rd29	vbottom<2>#11	vbottom<2>	38.091667	$metal2
+ $W=3e-07
Rd30	vbottom<2>	vbottom<2>#14	12.535000	$metal2
+ $W=3e-07
Rd31	vbottom<3>#11	vbottom<3>#15	13.654166	$metal2
+ $W=3e-07
Rd32	vbottom<3>#15	vbottom<3>#16	22.562500	$metal2
+ $W=3e-07
Rd33	vssa#88	vssa#92	1.287500	$metal2
+ $W=1e-06
Rd34	vssa#92	vssa#96	1.100000	$metal2
+ $W=1e-06
Rd35	vssa#96	vssa#100	1.062500	$metal2
+ $W=1e-06
Rd36	vssa#100	vssa#104	0.527500	$metal2
+ $W=1e-06
Rd37	vssa#104	vssa#108	0.610000	$metal2
+ $W=1e-06
Rd38	vssa#108	vssa#112	0.490000	$metal2
+ $W=1e-06
Rd39	vssa#112	vssa#116	0.975000	$metal2
+ $W=1e-06
Rd40	vssa#116	vssa#120	1.100000	$metal2
+ $W=1e-06
Rd41	vssa#120	vssa#133	13.043591	$metal2
+ $W=1e-06
Rd42	vssa#133	vssa#134	4.055625	$metal2
+ $W=1e-06
Rd43	vssa#134	vssa#135	3.688750	$metal2
+ $W=1e-06
Rd44	vssa#135	vssa#136	4.182500	$metal2
+ $W=1e-06
Rd45	vssa#136	vssa#137	4.765000	$metal2
+ $W=1e-06
Rd46	vssa#137	vssa	0.768286	$metal2	$W=1e-06
Rd47	vssa	vssa#138	1.079861	$metal2	$W=1.8e-06
Rd48	vssa#138	vssa#139	1.708681	$metal2
+ $W=1.8e-06
Rd49	vssa#139	vssa#140	1.724653	$metal2
+ $W=1.8e-06
Rd50	vssa#140	vssa#141	1.517361	$metal2
+ $W=1.8e-06
Rd51	vssa#141	vssa#142	1.307417	$metal2
+ $W=1.8e-06
Rd52	vssa#142	vssa#143	1.540514	$metal2
+ $W=1.8e-06
Rd53	vssa#143	vssa#144	1.541107	$metal2
+ $W=1.8e-06
Rd54	vssa#144	vssa#82	7.327267	$metal2
+ $W=1.8e-06
Rd55	vssa#144	vssa#146	0.667951	$metal2
+ $W=1e-06
Rd56	vssa#146	vssa#147	0.005294	$metal2
+ $W=3.6595e-05
Rd57	vssa#147	vssa#148	0.007685	$metal2
+ $W=3.6595e-05
Rd58	vssa#148	vssa#149	0.007190	$metal2
+ $W=3.6595e-05
Rd61	vssa#147	vssa#152	0.119316	$metal2
+ $W=3.909e-05
Rd62	vssa#152	vssa#153	0.034336	$metal2
+ $W=3.909e-05
Rd63	vssa#153	vssa#154	0.022704	$metal2
+ $W=3.909e-05
Rd64	vssa#154	vssa#155	0.034744	$metal2
+ $W=3.909e-05
Rd65	vssa#155	vssa#156	0.033576	$metal2
+ $W=3.909e-05
Rd66	vssa#156	vssa#157	0.028140	$metal2
+ $W=3.909e-05
Rd67	vssa#157	vssa#158	0.018179	$metal2
+ $W=3.909e-05
Rd68	vssa#158	vssa#159	0.043817	$metal2
+ $W=3.909e-05
Rd69	vssa#159	vssa#160	0.115399	$metal2
+ $W=3.909e-05
Rd72	vssa#160	vssa#163	0.006795	$metal2
+ $W=3.909e-05
Rd73	vssa#163	vssa#164	0.007195	$metal2
+ $W=3.909e-05
Rd74	vssa#164	vssa#165	0.004957	$metal2
+ $W=3.909e-05
Rd75	vssa#165	vssa#166	0.461573	$metal2
+ $W=1e-06
Rd76	vssa#152	vssa#167	0.432526	$metal2
+ $W=1e-06
Rd77	vssa#154	vssa#142	0.392685	$metal2
+ $W=9.53e-06
Rd78	vssa#155	vssa#168	0.503915	$metal2
+ $W=1e-06
Rd79	vssa#158	vssa#169	1.390985	$metal2
+ $W=1e-06
Rd80	vssa#159	vssa#170	0.372189	$metal2
+ $W=1e-06
Rd81	vssa#160	vssa#171	0.255321	$metal2
+ $W=1e-06
Rd82	vssa#163	vssa#172	0.189672	$metal2
+ $W=3.1505e-05
Rd83	vssa#172	vssa#173	0.529618	$metal2
+ $W=1e-06
Rd84	vssa#166	vssa#137	0.464596	$metal2
+ $W=1e-06
Rd85	vssa#167	vssa#143	0.283331	$metal2
+ $W=1e-06
Rd86	vssa#168	vssa#141	0.283331	$metal2
+ $W=1e-06
Rd87	vssa#169	vssa#140	0.283331	$metal2
+ $W=1e-06
Rd88	vssa#170	vssa#139	0.283331	$metal2
+ $W=1e-06
Rd89	vssa#171	vssa#138	0.283331	$metal2
+ $W=1e-06
Rd90	vssa#172	vssa#174	0.133362	$metal2
+ $W=3.346e-05
Rd91	vssa#173	vssa#136	0.464596	$metal2
+ $W=1e-06
Rd92	vssa#174	vssa#159	0.228855	$metal2
+ $W=2.4835e-05
Rd93	vssa#174	vssa#175	0.051190	$metal2
+ $W=3.346e-05
Rd94	vssa#175	vssa#158	2.007523	$metal2
+ $W=2.57e-06
Rd95	vssa#175	vssa#176	0.021444	$metal2
+ $W=3.346e-05
Rd96	vssa#176	vssa#157	0.309013	$metal2
+ $W=8.8e-06
Rd97	vssa#176	vssa#177	0.033337	$metal2
+ $W=3.346e-05
Rd98	vssa#176	vssa#178	0.294548	$metal2
+ $W=8.8e-06
Rd99	vssa#178	vssa#179	0.097885	$metal2
+ $W=2.951e-05
Rd100	vssa#179	vssa#180	0.059837	$metal2
+ $W=2.951e-05
Rd101	vssa#180	vssa#181	0.151020	$metal2
+ $W=2.951e-05
Rd102	vssa#181	vssa#182	0.539224	$metal2
+ $W=1e-06
Rd103	vssa#177	vssa#156	0.333999	$metal2
+ $W=8.8e-06
Rd104	vssa#177	vssa#183	0.065764	$metal2
+ $W=4.1015e-05
Rd107	vssa#179	vssa#175	1.531372	$metal2
+ $W=2.57e-06
Rd108	vssa#180	vssa#174	0.158471	$metal2
+ $W=2.4835e-05
Rd109	vssa#181	vssa#172	0.124921	$metal2
+ $W=3.1505e-05
Rd110	vssa#181	vssa#186	0.060526	$metal2
+ $W=3.1505e-05
Rd111	vssa#186	vssa#187	2.369558	$metal2
+ $W=1e-06
Rd112	vssa#182	vssa#135	0.464596	$metal2
+ $W=1e-06
Rd113	vssa#183	vssa#155	0.952046	$metal2
+ $W=1.22e-05
Rd114	vssa#183	vssa#188	0.073244	$metal2
+ $W=8.5015e-05
Rd116	vssa#186	vssa#190	3.521250	$metal2
+ $W=1e-06
Rd117	vssa#187	vssa#134	0.464596	$metal2
+ $W=1e-06
Rd118	vssa#188	vssa#154	2.040883	$metal2
+ $W=9.53e-06
Rd119	vssa#188	vssa#191	0.025201	$metal2
+ $W=8.5015e-05
Rd121	vssa#190	vssa#180	0.076782	$metal2
+ $W=2.4835e-05
Rd122	vssa#190	vssa#193	1.601453	$metal2
+ $W=1e-06
Rd123	vssa#191	vssa#153	1.234482	$metal2
+ $W=4.67e-06
Rd124	vssa#191	vssa#194	0.028009	$metal2
+ $W=0.000117735
Rd126	vssa#193	vssa#179	0.741975	$metal2
+ $W=2.57e-06
Rd127	vssa#193	vssa#196	0.270336	$metal2
+ $W=2.57e-06
Rd128	vssa#196	vssa#197	0.084041	$metal2
+ $W=5.3765e-05
Rd131	vssa#197	vssa#200	0.004917	$metal2
+ $W=5.3765e-05
Rd132	vssa#200	vssa#201	0.005231	$metal2
+ $W=5.3765e-05
Rd133	vssa#201	vssa#202	0.463553	$metal2
+ $W=1e-06
Rd134	vssa#194	vssa#152	1.666659	$metal2
+ $W=1.6805e-05
Rd135	vssa#194	vssa#203	0.055333	$metal2
+ $W=0.000117735
Rd137	vssa#196	vssa#190	0.044754	$metal2
+ $W=2.4835e-05
Rd138	vssa#201	vssa#186	0.183701	$metal2
+ $W=3.1505e-05
Rd139	vssa#202	vssa#133	0.464596	$metal2
+ $W=1e-06
Rd140	vssa#203	vssa#149	0.155660	$metal2
+ $W=3.6595e-05
Rd141	vssa#203	vssa#205	0.048151	$metal2
+ $W=7.672e-05
Rd144	vssa#205	vssa#208	0.003169	$metal2
+ $W=7.672e-05
Rd145	vssa#208	vssa#209	0.003666	$metal2
+ $W=7.672e-05
Rd146	vssa#209	vssa#210	0.002525	$metal2
+ $W=7.672e-05
Rc1	vssa#211	vssa#146	3.410000	$metal3
+ $W=6e-07
Rc2	vssa#213	vssa#160	3.410000	$metal3
+ $W=6e-07
Rc3	vssa#215	vssa#149	3.410000	$metal3
+ $W=6e-07
Rc4	vssa#217	vssa#165	3.410000	$metal3
+ $W=6e-07
Rc5	vbottom<2>#14	vbottom<2>#16	0.260842	$metal3
+ $W=3e-07
Rc6	vbottom<2>#16	vbottom<2>#17	0.122200	$metal3
+ $W=6e-07
Rc7	vbottom<2>#17	vbottom<2>#18	0.289725	$metal3
+ $W=3e-07
Rc8	vbottom<2>#18	vbottom<2>#19	0.289725	$metal3
+ $W=2.55e-06
Rc9	vbottom<2>#19	vbottom<2>#20	0.464996	$metal3
+ $W=6e-07
Rc10	vbottom<2>#20	vbottom<2>#18	0.025931	$metal3
+ $W=4.2e-06
Rc11	vbottom<2>#20	vbottom<2>#21	0.665112	$metal3
+ $W=3e-07
Rc12	vbottom<2>#21	vbottom<2>#22	0.556646	$metal3
+ $W=6e-07
Rc13	vbottom<2>#22	vbottom<2>#23	0.556646	$metal3
+ $W=6e-07
Rc14	vbottom<2>#23	vbottom<2>#24	0.025931	$metal3
+ $W=4.2e-06
Rc15	vbottom<2>#20	vbottom<2>#16	0.337791	$metal3
+ $W=3e-07
Rc16	vbottom<2>#18	vbottom<2>#19	0.048273	$metal3
+ $W=2.25e-06
Rc17	vbottom<2>#18	vbottom<2>#17	0.048273	$metal3
+ $W=2.25e-06
Rc18	vbottom<2>#24	vbottom<2>#21	0.025931	$metal3
+ $W=4.2e-06
Rc19	vbottom<2>#24	vbottom<2>#22	0.025931	$metal3
+ $W=4.2e-06
Rc20	vbottom<2>#24	vbottom<2>#25	0.025931	$metal3
+ $W=4.2e-06
Rc21	vbottom<2>#25	vbottom<2>#26	0.226767	$metal3
+ $W=6e-07
Rc22	vbottom<2>#26	vbottom<2>#27	0.200533	$metal3
+ $W=3e-07
Rc23	vbottom<2>#25	vbottom<2>#28	0.337203	$metal3
+ $W=3e-07
Rc24	vbottom<2>#26	vbottom<2>#21	0.337203	$metal3
+ $W=3e-07
Rc25	vbottom<2>#27	vbottom<2>#14	0.206408	$metal3
+ $W=3e-07
Rc26	vbottom<2>#28	vbottom<2>#23	0.215025	$metal3
+ $W=6e-07
Rc27	XI10/vbsh#29	XI10/vbsh#28	1.136667	$metal3
+ $W=1e-06
Rc28	XI10/vbsl#15	XI10/vbsl#16	0.040442	$metal3
+ $W=6.88e-06
Rc29	XI10/vbsl#16	XI10/vbsl#17	0.040442	$metal3
+ $W=6.88e-06
Rc30	XI10/vbsl#17	XI10/vbsl	0.009564	$metal3
+ $W=6.88e-06
Rc31	XI10/vbsl	XI10/vbsl#19	0.030878	$metal3
+ $W=6.88e-06
Rc32	vbottom<1>#14	vbottom<1>#16	3.646698	$metal3
+ $W=3e-07
Rc33	vbottom<1>#16	vbottom<1>#17	0.206802	$metal3
+ $W=3e-07
Rc34	vbottom<1>#17	vbottom<1>#18	0.464996	$metal3
+ $W=6e-07
Rc35	vbottom<1>#18	vbottom<1>#19	0.403896	$metal3
+ $W=6e-07
Rc36	vbottom<1>#19	vbottom<1>#20	0.060015	$metal3
+ $W=4.8e-06
Rc37	vbottom<1>#20	vbottom<1>#17	0.048273	$metal3
+ $W=2.25e-06
Rc38	vbottom<1>#20	vbottom<1>#18	0.025931	$metal3
+ $W=4.2e-06
Rc39	vbottom<1>#20	vbottom<1>#16	0.048683	$metal3
+ $W=2.55e-06
Rc40	vbottom<1>#20	vbottom<1>#21	0.059756	$metal3
+ $W=2.55e-06
Rc41	vbottom<1>#21	vbottom<1>#19	0.206753	$metal3
+ $W=3e-07
Rc42	net3	net3#15	3.646698	$metal3	$W=3e-07
Rc43	net3#15	net3#16	0.206802	$metal3
+ $W=3e-07
Rc44	net3#16	net3#17	0.464996	$metal3
+ $W=6e-07
Rc45	net3#17	net3#18	0.403896	$metal3
+ $W=6e-07
Rc46	net3#18	net3#19	0.060015	$metal3
+ $W=4.8e-06
Rc47	net3#19	net3#16	0.048273	$metal3
+ $W=2.25e-06
Rc48	net3#19	net3#17	0.025931	$metal3
+ $W=4.2e-06
Rc49	net3#19	net3#15	0.048683	$metal3
+ $W=2.55e-06
Rc50	net3#19	net3#20	0.059756	$metal3
+ $W=2.55e-06
Rc51	net3#20	net3#18	0.206753	$metal3
+ $W=3e-07
Rc52	vout#13	vout#12	3.410000	$metal3
+ $W=3.3e-07
Rc53	vbottom<0>	vbottom<0>#15	3.673005	$metal3
+ $W=3e-07
Rc54	vbottom<0>#15	vbottom<0>#16	0.059657	$metal3
+ $W=4.8e-06
Rc55	vbottom<0>#16	vbottom<0>#17	0.289725	$metal3
+ $W=2.55e-06
Rc56	vbottom<0>#17	vbottom<0>#18	0.464996	$metal3
+ $W=6e-07
Rc57	vbottom<0>#18	vbottom<0>#19	0.403896	$metal3
+ $W=6e-07
Rc58	vbottom<0>#19	vbottom<0>#16	0.060015	$metal3
+ $W=4.8e-06
Rc59	vbottom<0>#19	vbottom<0>#15	0.206802	$metal3
+ $W=3e-07
Rc60	vbottom<0>#16	vbottom<0>#17	0.048273	$metal3
+ $W=2.25e-06
Rc61	vbottom<0>#16	vbottom<0>#18	0.025931	$metal3
+ $W=4.2e-06
Rc62	vbottom<1>#22	vbottom<1>#23	0.289725	$metal3
+ $W=2.55e-06
Rc63	vbottom<1>#23	vbottom<1>#22	0.060015	$metal3
+ $W=4.8e-06
Rc64	vbottom<1>#22	vbottom<1>#24	0.060015	$metal3
+ $W=2.25e-06
Rc65	vbottom<1>#24	vbottom<1>#25	0.206941	$metal3
+ $W=3e-07
Rc66	vbottom<1>#24	vbottom<1>#26	0.464996	$metal3
+ $W=6e-07
Rc67	vbottom<1>#25	vbottom<1>#22	0.059704	$metal3
+ $W=4.8e-06
Rc68	vbottom<1>#25	vbottom<1>#13	3.819787	$metal3
+ $W=3e-07
Rc69	vbottom<1>#26	vbottom<1>#28	0.337203	$metal3
+ $W=3e-07
Rc70	vbottom<1>#26	vbottom<1>#22	0.025931	$metal3
+ $W=4.2e-06
Rc71	vbottom<1>#28	vbottom<1>#23	0.123375	$metal3
+ $W=6e-07
Rc72	vbottom<4>#17	vbottom<4>#19	3.623842	$metal3
+ $W=3e-07
Rc73	vbottom<4>#19	vbottom<4>#20	0.213850	$metal3
+ $W=6e-07
Rc74	vbottom<4>#20	vbottom<4>#21	0.556646	$metal3
+ $W=3e-07
Rc75	vbottom<4>#21	vbottom<4>#22	0.523746	$metal3
+ $W=6e-07
Rc76	vbottom<4>#22	vbottom<4>#23	0.698840	$metal3
+ $W=3e-07
Rc77	vbottom<4>#23	vbottom<4>#24	0.556646	$metal3
+ $W=3e-07
Rc78	vbottom<4>#24	vbottom<4>#25	0.523746	$metal3
+ $W=6e-07
Rc79	vbottom<4>#25	vbottom<4>#26	0.698840	$metal3
+ $W=3e-07
Rc80	vbottom<4>#26	vbottom<4>#27	0.556646	$metal3
+ $W=3e-07
Rc81	vbottom<4>#27	vbottom<4>#28	0.523746	$metal3
+ $W=6e-07
Rc82	vbottom<4>#28	vbottom<4>#29	0.698840	$metal3
+ $W=3e-07
Rc83	vbottom<4>#29	vbottom<4>#30	0.556646	$metal3
+ $W=3e-07
Rc84	vbottom<4>#30	vbottom<4>#31	0.523746	$metal3
+ $W=6e-07
Rc85	vbottom<4>#31	vbottom<4>#32	0.556646	$metal3
+ $W=6e-07
Rc86	vbottom<4>#32	vbottom<4>#33	0.025931	$metal3
+ $W=4.2e-06
Rc87	vbottom<4>#32	vbottom<4>#34	0.665112	$metal3
+ $W=3e-07
Rc88	vbottom<4>#34	vbottom<4>#35	0.556646	$metal3
+ $W=6e-07
Rc89	vbottom<4>#35	vbottom<4>#36	0.556646	$metal3
+ $W=6e-07
Rc90	vbottom<4>#36	vbottom<4>#37	0.025929	$metal3
+ $W=4.2e-06
Rc91	vbottom<4>#33	vbottom<4>#30	0.025931	$metal3
+ $W=4.2e-06
Rc92	vbottom<4>#33	vbottom<4>#31	0.025931	$metal3
+ $W=4.2e-06
Rc93	vbottom<4>#33	vbottom<4>#29	0.025931	$metal3
+ $W=4.2e-06
Rc94	vbottom<4>#37	vbottom<4>#34	0.025931	$metal3
+ $W=4.2e-06
Rc95	vbottom<4>#37	vbottom<4>#35	0.025931	$metal3
+ $W=4.2e-06
Rc96	vbottom<4>#37	vbottom<4>#38	0.025931	$metal3
+ $W=4.2e-06
Rc97	vbottom<4>#38	vbottom<4>#39	0.226767	$metal3
+ $W=6e-07
Rc98	vbottom<4>#39	vbottom<4>#40	0.661227	$metal3
+ $W=3e-07
Rc99	vbottom<4>#38	vbottom<4>#41	0.182125	$metal3
+ $W=6e-07
Rc100	vbottom<4>#39	vbottom<4>#34	0.337203	$metal3
+ $W=3e-07
Rc101	vbottom<4>#40	vbottom<4>#29	0.345935	$metal3
+ $W=3e-07
Rc102	vbottom<4>#40	vbottom<4>#32	0.345935	$metal3
+ $W=3e-07
Rc103	vbottom<4>#40	vbottom<4>#42	0.672969	$metal3
+ $W=3e-07
Rc104	vbottom<4>#41	vbottom<4>#36	0.337203	$metal3
+ $W=3e-07
Rc105	vbottom<4>#41	vbottom<4>#43	0.672483	$metal3
+ $W=3e-07
Rc106	vbottom<4>#43	vbottom<4>#44	0.337791	$metal3
+ $W=3e-07
Rc107	vbottom<4>#44	vbottom<4>#45	0.603392	$metal3
+ $W=3e-07
Rc108	vbottom<4>#42	vbottom<4>#28	0.337203	$metal3
+ $W=3e-07
Rc109	vbottom<4>#42	vbottom<4>#46	0.215025	$metal3
+ $W=6e-07
Rc110	vbottom<4>#46	vbottom<4>#47	0.025931	$metal3
+ $W=4.2e-06
Rc111	vbottom<4>#44	vbottom<4>#48	0.556646	$metal3
+ $W=6e-07
Rc112	vbottom<4>#48	vbottom<4>#49	0.556646	$metal3
+ $W=6e-07
Rc113	vbottom<4>#49	vbottom<4>#50	0.025929	$metal3
+ $W=4.2e-06
Rc114	vbottom<4>#45	vbottom<4>#36	0.058337	$metal3
+ $W=3.1e-07
Rc115	vbottom<4>#46	vbottom<4>#51	0.193867	$metal3
+ $W=6e-07
Rc116	vbottom<4>#47	vbottom<4>#27	0.025931	$metal3
+ $W=4.2e-06
Rc117	vbottom<4>#47	vbottom<4>#28	0.025931	$metal3
+ $W=4.2e-06
Rc118	vbottom<4>#47	vbottom<4>#26	0.025931	$metal3
+ $W=4.2e-06
Rc119	vbottom<4>#50	vbottom<4>#44	0.025929	$metal3
+ $W=4.2e-06
Rc120	vbottom<4>#50	vbottom<4>#48	0.025931	$metal3
+ $W=4.2e-06
Rc121	vbottom<4>#50	vbottom<4>#52	0.025931	$metal3
+ $W=4.2e-06
Rc122	vbottom<4>#51	vbottom<4>#26	0.337203	$metal3
+ $W=3e-07
Rc123	vbottom<4>#51	vbottom<4>#53	0.685401	$metal3
+ $W=3e-07
Rc124	vbottom<4>#52	vbottom<4>#43	0.225592	$metal3
+ $W=6e-07
Rc125	vbottom<4>#52	vbottom<4>#54	0.182125	$metal3
+ $W=6e-07
Rc126	vbottom<4>#53	vbottom<4>#25	0.337203	$metal3
+ $W=3e-07
Rc127	vbottom<4>#53	vbottom<4>#55	0.215025	$metal3
+ $W=6e-07
Rc128	vbottom<4>#55	vbottom<4>#56	0.025931	$metal3
+ $W=4.2e-06
Rc129	vbottom<4>#54	vbottom<4>#49	0.337203	$metal3
+ $W=3e-07
Rc130	vbottom<4>#54	vbottom<4>#57	0.672483	$metal3
+ $W=3e-07
Rc131	vbottom<4>#57	vbottom<4>#58	0.337791	$metal3
+ $W=3e-07
Rc132	vbottom<4>#58	vbottom<4>#59	0.603392	$metal3
+ $W=3e-07
Rc133	vbottom<4>#55	vbottom<4>#60	0.193867	$metal3
+ $W=6e-07
Rc134	vbottom<4>#56	vbottom<4>#24	0.025931	$metal3
+ $W=4.2e-06
Rc135	vbottom<4>#56	vbottom<4>#25	0.025931	$metal3
+ $W=4.2e-06
Rc136	vbottom<4>#56	vbottom<4>#23	0.025931	$metal3
+ $W=4.2e-06
Rc137	vbottom<4>#58	vbottom<4>#61	0.556646	$metal3
+ $W=6e-07
Rc138	vbottom<4>#61	vbottom<4>#62	0.556646	$metal3
+ $W=6e-07
Rc139	vbottom<4>#62	vbottom<4>#63	0.025931	$metal3
+ $W=4.2e-06
Rc140	vbottom<4>#59	vbottom<4>#49	0.058337	$metal3
+ $W=3.1e-07
Rc141	vbottom<4>#60	vbottom<4>#23	0.337203	$metal3
+ $W=3e-07
Rc142	vbottom<4>#60	vbottom<4>#64	0.685401	$metal3
+ $W=3e-07
Rc143	vbottom<4>#63	vbottom<4>#58	0.025929	$metal3
+ $W=4.2e-06
Rc144	vbottom<4>#63	vbottom<4>#61	0.025931	$metal3
+ $W=4.2e-06
Rc145	vbottom<4>#63	vbottom<4>#65	0.025931	$metal3
+ $W=4.2e-06
Rc146	vbottom<4>#64	vbottom<4>#22	0.337203	$metal3
+ $W=3e-07
Rc147	vbottom<4>#64	vbottom<4>#66	0.215025	$metal3
+ $W=6e-07
Rc148	vbottom<4>#66	vbottom<4>#67	0.025931	$metal3
+ $W=4.2e-06
Rc149	vbottom<4>#65	vbottom<4>#57	0.225592	$metal3
+ $W=6e-07
Rc150	vbottom<4>#65	vbottom<4>#68	0.182125	$metal3
+ $W=6e-07
Rc151	vbottom<4>#66	vbottom<4>#15	3.835403	$metal3
+ $W=3e-07
Rc152	vbottom<4>#66	vbottom<4>#19	0.337791	$metal3
+ $W=3e-07
Rc153	vbottom<4>#67	vbottom<4>#21	0.025931	$metal3
+ $W=4.2e-06
Rc154	vbottom<4>#67	vbottom<4>#22	0.025931	$metal3
+ $W=4.2e-06
Rc155	vbottom<4>#67	vbottom<4>#20	0.025931	$metal3
+ $W=4.2e-06
Rc156	vbottom<4>#68	vbottom<4>#62	0.337203	$metal3
+ $W=3e-07
Rc157	vbottom<4>#68	vbottom<4>#70	0.672483	$metal3
+ $W=3e-07
Rc158	vbottom<4>#70	vbottom<4>#71	0.337791	$metal3
+ $W=3e-07
Rc159	vbottom<4>#71	vbottom<4>#72	0.315692	$metal3
+ $W=3e-07
Rc160	vbottom<4>#71	vbottom<4>#73	0.556646	$metal3
+ $W=6e-07
Rc161	vbottom<4>#73	vbottom<4>#74	0.556646	$metal3
+ $W=6e-07
Rc162	vbottom<4>#74	vbottom<4>#75	0.025931	$metal3
+ $W=4.2e-06
Rc163	vbottom<4>#72	vbottom<4>#62	0.349420	$metal3
+ $W=3e-07
Rc164	vbottom<4>#75	vbottom<4>#71	0.025931	$metal3
+ $W=4.2e-06
Rc165	vbottom<4>#75	vbottom<4>#73	0.025931	$metal3
+ $W=4.2e-06
Rc166	vbottom<4>#75	vbottom<4>#76	0.025931	$metal3
+ $W=4.2e-06
Rc167	vbottom<4>#76	vbottom<4>#70	0.225592	$metal3
+ $W=6e-07
Rc168	vbottom<4>#76	vbottom<4>#77	0.337203	$metal3
+ $W=3e-07
Rc169	vbottom<4>#77	vbottom<4>#74	0.215025	$metal3
+ $W=6e-07
Rc170	vbottom<3>#16	vbottom<3>#18	3.612100	$metal3
+ $W=3e-07
Rc171	vbottom<3>#18	vbottom<3>#19	0.337791	$metal3
+ $W=3e-07
Rc172	vbottom<3>#19	vbottom<3>#20	0.226767	$metal3
+ $W=6e-07
Rc173	vbottom<3>#20	vbottom<3>#21	0.685401	$metal3
+ $W=3e-07
Rc174	vbottom<3>#21	vbottom<3>#22	0.215025	$metal3
+ $W=6e-07
Rc175	vbottom<3>#22	vbottom<3>#23	0.193867	$metal3
+ $W=6e-07
Rc176	vbottom<3>#23	vbottom<3>#24	0.685401	$metal3
+ $W=3e-07
Rc177	vbottom<3>#24	vbottom<3>#25	0.215025	$metal3
+ $W=6e-07
Rc178	vbottom<3>#25	vbottom<3>#26	0.193867	$metal3
+ $W=6e-07
Rc179	vbottom<3>#26	vbottom<3>#27	0.685401	$metal3
+ $W=3e-07
Rc180	vbottom<3>#27	vbottom<3>#28	0.215025	$metal3
+ $W=6e-07
Rc181	vbottom<3>#28	vbottom<3>#29	0.523746	$metal3
+ $W=6e-07
Rc182	vbottom<3>#29	vbottom<3>#30	0.556646	$metal3
+ $W=6e-07
Rc183	vbottom<3>#30	vbottom<3>#31	0.025931	$metal3
+ $W=4.2e-06
Rc184	vbottom<3>#31	vbottom<3>#28	0.025931	$metal3
+ $W=4.2e-06
Rc185	vbottom<3>#31	vbottom<3>#29	0.025931	$metal3
+ $W=4.2e-06
Rc186	vbottom<3>#31	vbottom<3>#32	0.025931	$metal3
+ $W=4.2e-06
Rc187	vbottom<3>#32	vbottom<3>#27	0.337203	$metal3
+ $W=3e-07
Rc188	vbottom<3>#32	vbottom<3>#33	0.337203	$metal3
+ $W=3e-07
Rc189	vbottom<3>#32	vbottom<3>#34	0.698840	$metal3
+ $W=3e-07
Rc190	vbottom<3>#33	vbottom<3>#30	0.215025	$metal3
+ $W=6e-07
Rc191	vbottom<3>#34	vbottom<3>#26	0.337203	$metal3
+ $W=3e-07
Rc192	vbottom<3>#34	vbottom<3>#35	0.556646	$metal3
+ $W=6e-07
Rc193	vbottom<3>#35	vbottom<3>#36	0.025931	$metal3
+ $W=4.2e-06
Rc194	vbottom<3>#36	vbottom<3>#25	0.025931	$metal3
+ $W=4.2e-06
Rc195	vbottom<3>#36	vbottom<3>#34	0.025931	$metal3
+ $W=4.2e-06
Rc196	vbottom<3>#36	vbottom<3>#37	0.025931	$metal3
+ $W=4.2e-06
Rc197	vbottom<3>#37	vbottom<3>#24	0.337203	$metal3
+ $W=3e-07
Rc198	vbottom<3>#37	vbottom<3>#38	0.337203	$metal3
+ $W=3e-07
Rc199	vbottom<3>#37	vbottom<3>#39	0.698840	$metal3
+ $W=3e-07
Rc200	vbottom<3>#38	vbottom<3>#35	0.215025	$metal3
+ $W=6e-07
Rc201	vbottom<3>#39	vbottom<3>#23	0.337203	$metal3
+ $W=3e-07
Rc202	vbottom<3>#39	vbottom<3>#40	0.556646	$metal3
+ $W=6e-07
Rc203	vbottom<3>#40	vbottom<3>#41	0.025931	$metal3
+ $W=4.2e-06
Rc204	vbottom<3>#41	vbottom<3>#22	0.025931	$metal3
+ $W=4.2e-06
Rc205	vbottom<3>#41	vbottom<3>#39	0.025931	$metal3
+ $W=4.2e-06
Rc206	vbottom<3>#41	vbottom<3>#42	0.025931	$metal3
+ $W=4.2e-06
Rc207	vbottom<3>#42	vbottom<3>#21	0.337203	$metal3
+ $W=3e-07
Rc208	vbottom<3>#42	vbottom<3>#43	0.337203	$metal3
+ $W=3e-07
Rc209	vbottom<3>#42	vbottom<3>#44	0.698840	$metal3
+ $W=3e-07
Rc210	vbottom<3>#43	vbottom<3>#40	0.215025	$metal3
+ $W=6e-07
Rc211	vbottom<3>#44	vbottom<3>#20	0.337203	$metal3
+ $W=3e-07
Rc212	vbottom<3>#44	vbottom<3>#45	0.556646	$metal3
+ $W=6e-07
Rc213	vbottom<3>#45	vbottom<3>#46	0.025931	$metal3
+ $W=4.2e-06
Rc214	vbottom<3>#46	vbottom<3>#19	0.025931	$metal3
+ $W=4.2e-06
Rc215	vbottom<3>#46	vbottom<3>#44	0.025931	$metal3
+ $W=4.2e-06
Rc216	vbottom<3>#46	vbottom<3>#47	0.025931	$metal3
+ $W=4.2e-06
Rc217	vbottom<3>#47	vbottom<3>#18	0.225592	$metal3
+ $W=6e-07
Rc218	vbottom<3>#47	vbottom<3>#48	0.337203	$metal3
+ $W=3e-07
Rc219	vbottom<3>#48	vbottom<3>#45	0.215025	$metal3
+ $W=6e-07
Rc220	vbottom<2>#29	vbottom<2>#30	0.025931	$metal3
+ $W=4.2e-06
Rc221	vbottom<2>#30	vbottom<2>#31	0.655882	$metal3
+ $W=3e-07
Rc222	vbottom<2>#31	vbottom<2>#32	0.131538	$metal3
+ $W=2.55e-06
Rc223	vbottom<2>#32	vbottom<2>#33	0.133942	$metal3
+ $W=6e-07
Rc224	vbottom<2>#33	vbottom<2>#34	0.393476	$metal3
+ $W=3e-07
Rc225	vbottom<2>#31	vbottom<2>#35	0.131538	$metal3
+ $W=2.55e-06
Rc226	vbottom<2>#32	vbottom<2>#31	0.373510	$metal3
+ $W=4.8e-06
Rc227	vbottom<2>#33	vbottom<2>#31	0.061628	$metal3
+ $W=4.8e-06
Rc228	vbottom<2>#34	vbottom<2>#36	0.406942	$metal3
+ $W=3e-07
Rc229	vbottom<2>#36	vbottom<2>#37	0.226767	$metal3
+ $W=6e-07
Rc230	vbottom<2>#37	vbottom<2>#38	0.523746	$metal3
+ $W=6e-07
Rc231	vbottom<2>#35	vbottom<2>#31	0.373510	$metal3
+ $W=4.8e-06
Rc232	vbottom<2>#35	vbottom<2>#39	0.048208	$metal3
+ $W=6e-07
Rc233	vbottom<2>#36	vbottom<2>#30	0.337203	$metal3
+ $W=3e-07
Rc234	vbottom<2>#37	vbottom<2>#29	0.025931	$metal3
+ $W=4.2e-06
Rc235	vbottom<2>#38	vbottom<2>#29	0.025931	$metal3
+ $W=4.2e-06
Rc236	vbottom<2>#38	vbottom<2>#40	0.556646	$metal3
+ $W=6e-07
Rc237	vbottom<2>#39	vbottom<2>#31	0.065516	$metal3
+ $W=4.8e-06
Rc238	vbottom<2>#40	vbottom<2>#41	0.337203	$metal3
+ $W=3e-07
Rc239	vbottom<2>#40	vbottom<2>#29	0.025931	$metal3
+ $W=4.2e-06
Rc240	vbottom<2>#41	vbottom<2>#30	0.215025	$metal3
+ $W=6e-07
Rc241	vbottom<3>#13	vbottom<3>#50	3.670842	$metal3
+ $W=3e-07
Rc242	vbottom<3>#50	vbottom<3>#51	0.213850	$metal3
+ $W=6e-07
Rc243	vbottom<3>#51	vbottom<3>#52	0.556646	$metal3
+ $W=3e-07
Rc244	vbottom<3>#52	vbottom<3>#53	0.523746	$metal3
+ $W=6e-07
Rc245	vbottom<3>#53	vbottom<3>#54	0.698840	$metal3
+ $W=3e-07
Rc246	vbottom<3>#54	vbottom<3>#55	0.556646	$metal3
+ $W=3e-07
Rc247	vbottom<3>#55	vbottom<3>#56	0.523746	$metal3
+ $W=6e-07
Rc248	vbottom<3>#56	vbottom<3>#57	0.698840	$metal3
+ $W=3e-07
Rc249	vbottom<3>#57	vbottom<3>#58	0.556646	$metal3
+ $W=3e-07
Rc250	vbottom<3>#58	vbottom<3>#59	0.523746	$metal3
+ $W=6e-07
Rc251	vbottom<3>#59	vbottom<3>#60	0.698840	$metal3
+ $W=3e-07
Rc252	vbottom<3>#60	vbottom<3>#61	0.556646	$metal3
+ $W=3e-07
Rc253	vbottom<3>#61	vbottom<3>#62	0.523746	$metal3
+ $W=6e-07
Rc254	vbottom<3>#62	vbottom<3>#63	0.556646	$metal3
+ $W=6e-07
Rc255	vbottom<3>#63	vbottom<3>#64	0.025931	$metal3
+ $W=4.2e-06
Rc256	vbottom<3>#63	vbottom<3>#65	0.226767	$metal3
+ $W=6e-07
Rc257	vbottom<3>#64	vbottom<3>#61	0.025931	$metal3
+ $W=4.2e-06
Rc258	vbottom<3>#64	vbottom<3>#62	0.025931	$metal3
+ $W=4.2e-06
Rc259	vbottom<3>#64	vbottom<3>#60	0.025931	$metal3
+ $W=4.2e-06
Rc260	vbottom<3>#65	vbottom<3>#60	0.337203	$metal3
+ $W=3e-07
Rc261	vbottom<3>#65	vbottom<3>#66	0.685401	$metal3
+ $W=3e-07
Rc262	vbottom<3>#66	vbottom<3>#59	0.337203	$metal3
+ $W=3e-07
Rc263	vbottom<3>#66	vbottom<3>#67	0.215025	$metal3
+ $W=6e-07
Rc264	vbottom<3>#67	vbottom<3>#68	0.025931	$metal3
+ $W=4.2e-06
Rc265	vbottom<3>#67	vbottom<3>#69	0.193867	$metal3
+ $W=6e-07
Rc266	vbottom<3>#68	vbottom<3>#58	0.025931	$metal3
+ $W=4.2e-06
Rc267	vbottom<3>#68	vbottom<3>#59	0.025931	$metal3
+ $W=4.2e-06
Rc268	vbottom<3>#68	vbottom<3>#57	0.025931	$metal3
+ $W=4.2e-06
Rc269	vbottom<3>#69	vbottom<3>#57	0.337203	$metal3
+ $W=3e-07
Rc270	vbottom<3>#69	vbottom<3>#70	0.685401	$metal3
+ $W=3e-07
Rc271	vbottom<3>#70	vbottom<3>#56	0.337203	$metal3
+ $W=3e-07
Rc272	vbottom<3>#70	vbottom<3>#71	0.215025	$metal3
+ $W=6e-07
Rc273	vbottom<3>#71	vbottom<3>#72	0.025931	$metal3
+ $W=4.2e-06
Rc274	vbottom<3>#71	vbottom<3>#73	0.193867	$metal3
+ $W=6e-07
Rc275	vbottom<3>#72	vbottom<3>#55	0.025931	$metal3
+ $W=4.2e-06
Rc276	vbottom<3>#72	vbottom<3>#56	0.025931	$metal3
+ $W=4.2e-06
Rc277	vbottom<3>#72	vbottom<3>#54	0.025931	$metal3
+ $W=4.2e-06
Rc278	vbottom<3>#73	vbottom<3>#54	0.337203	$metal3
+ $W=3e-07
Rc279	vbottom<3>#73	vbottom<3>#74	0.685401	$metal3
+ $W=3e-07
Rc280	vbottom<3>#74	vbottom<3>#53	0.337203	$metal3
+ $W=3e-07
Rc281	vbottom<3>#74	vbottom<3>#75	0.215025	$metal3
+ $W=6e-07
Rc282	vbottom<3>#75	vbottom<3>#76	0.025931	$metal3
+ $W=4.2e-06
Rc283	vbottom<3>#75	vbottom<3>#50	0.337791	$metal3
+ $W=3e-07
Rc284	vbottom<3>#76	vbottom<3>#52	0.025931	$metal3
+ $W=4.2e-06
Rc285	vbottom<3>#76	vbottom<3>#53	0.025931	$metal3
+ $W=4.2e-06
Rc286	vbottom<3>#76	vbottom<3>#51	0.025931	$metal3
+ $W=4.2e-06
Rc287	vbottom<4>	vbottom<4>#79	3.862766	$metal3
+ $W=3e-07
Rc288	vbottom<4>#79	vbottom<4>#80	0.337791	$metal3
+ $W=3e-07
Rc289	vbottom<4>#80	vbottom<4>#81	0.556646	$metal3
+ $W=6e-07
Rc290	vbottom<4>#81	vbottom<4>#82	0.213850	$metal3
+ $W=6e-07
Rc291	vbottom<4>#82	vbottom<4>#83	0.671308	$metal3
+ $W=3e-07
Rc292	vbottom<4>#83	vbottom<4>#84	0.225592	$metal3
+ $W=6e-07
Rc293	vbottom<4>#84	vbottom<4>#85	0.180950	$metal3
+ $W=6e-07
Rc294	vbottom<4>#85	vbottom<4>#86	0.671308	$metal3
+ $W=3e-07
Rc295	vbottom<4>#86	vbottom<4>#87	0.225592	$metal3
+ $W=6e-07
Rc296	vbottom<4>#87	vbottom<4>#88	0.180950	$metal3
+ $W=6e-07
Rc297	vbottom<4>#88	vbottom<4>#89	0.671308	$metal3
+ $W=3e-07
Rc298	vbottom<4>#89	vbottom<4>#90	0.225592	$metal3
+ $W=6e-07
Rc299	vbottom<4>#90	vbottom<4>#91	0.180950	$metal3
+ $W=6e-07
Rc300	vbottom<4>#91	vbottom<4>#92	0.671793	$metal3
+ $W=3e-07
Rc301	vbottom<4>#92	vbottom<4>#93	0.672969	$metal3
+ $W=3e-07
Rc302	vbottom<4>#93	vbottom<4>#94	0.215025	$metal3
+ $W=6e-07
Rc303	vbottom<4>#94	vbottom<4>#95	0.193867	$metal3
+ $W=6e-07
Rc304	vbottom<4>#95	vbottom<4>#96	0.685401	$metal3
+ $W=3e-07
Rc305	vbottom<4>#96	vbottom<4>#97	0.215025	$metal3
+ $W=6e-07
Rc306	vbottom<4>#97	vbottom<4>#98	0.193867	$metal3
+ $W=6e-07
Rc307	vbottom<4>#98	vbottom<4>#99	0.685401	$metal3
+ $W=3e-07
Rc308	vbottom<4>#99	vbottom<4>#100	0.215025	$metal3
+ $W=6e-07
Rc309	vbottom<4>#100	vbottom<4>#101	0.523746	$metal3
+ $W=6e-07
Rc310	vbottom<4>#101	vbottom<4>#102	0.556646	$metal3
+ $W=6e-07
Rc311	vbottom<4>#102	vbottom<4>#103	0.025931	$metal3
+ $W=4.2e-06
Rc312	vbottom<4>#80	vbottom<4>#14	3.645009	$metal3
+ $W=3e-07
Rc313	vbottom<4>#103	vbottom<4>#100	0.025931	$metal3
+ $W=4.2e-06
Rc314	vbottom<4>#103	vbottom<4>#101	0.025931	$metal3
+ $W=4.2e-06
Rc315	vbottom<4>#103	vbottom<4>#105	0.025931	$metal3
+ $W=4.2e-06
Rc316	vbottom<4>#105	vbottom<4>#99	0.337203	$metal3
+ $W=3e-07
Rc317	vbottom<4>#105	vbottom<4>#106	0.337203	$metal3
+ $W=3e-07
Rc318	vbottom<4>#105	vbottom<4>#107	0.698840	$metal3
+ $W=3e-07
Rc319	vbottom<4>#106	vbottom<4>#102	0.215025	$metal3
+ $W=6e-07
Rc320	vbottom<4>#107	vbottom<4>#98	0.337203	$metal3
+ $W=3e-07
Rc321	vbottom<4>#107	vbottom<4>#108	0.556646	$metal3
+ $W=6e-07
Rc322	vbottom<4>#108	vbottom<4>#109	0.025931	$metal3
+ $W=4.2e-06
Rc323	vbottom<4>#109	vbottom<4>#97	0.025931	$metal3
+ $W=4.2e-06
Rc324	vbottom<4>#109	vbottom<4>#107	0.025931	$metal3
+ $W=4.2e-06
Rc325	vbottom<4>#109	vbottom<4>#110	0.025931	$metal3
+ $W=4.2e-06
Rc326	vbottom<4>#110	vbottom<4>#96	0.337203	$metal3
+ $W=3e-07
Rc327	vbottom<4>#110	vbottom<4>#111	0.337203	$metal3
+ $W=3e-07
Rc328	vbottom<4>#110	vbottom<4>#112	0.698840	$metal3
+ $W=3e-07
Rc329	vbottom<4>#111	vbottom<4>#108	0.215025	$metal3
+ $W=6e-07
Rc330	vbottom<4>#112	vbottom<4>#95	0.337203	$metal3
+ $W=3e-07
Rc331	vbottom<4>#112	vbottom<4>#113	0.556646	$metal3
+ $W=6e-07
Rc332	vbottom<4>#113	vbottom<4>#114	0.025931	$metal3
+ $W=4.2e-06
Rc333	vbottom<4>#114	vbottom<4>#94	0.025931	$metal3
+ $W=4.2e-06
Rc334	vbottom<4>#114	vbottom<4>#112	0.025931	$metal3
+ $W=4.2e-06
Rc335	vbottom<4>#114	vbottom<4>#115	0.025931	$metal3
+ $W=4.2e-06
Rc336	vbottom<4>#115	vbottom<4>#93	0.337203	$metal3
+ $W=3e-07
Rc337	vbottom<4>#115	vbottom<4>#116	0.337203	$metal3
+ $W=3e-07
Rc338	vbottom<4>#115	vbottom<4>#117	0.698840	$metal3
+ $W=3e-07
Rc339	vbottom<4>#116	vbottom<4>#113	0.215025	$metal3
+ $W=6e-07
Rc340	vbottom<4>#117	vbottom<4>#92	0.345935	$metal3
+ $W=3e-07
Rc341	vbottom<4>#117	vbottom<4>#118	0.556646	$metal3
+ $W=6e-07
Rc342	vbottom<4>#118	vbottom<4>#119	0.025931	$metal3
+ $W=4.2e-06
Rc343	vbottom<4>#119	vbottom<4>#120	0.025931	$metal3
+ $W=4.2e-06
Rc344	vbottom<4>#120	vbottom<4>#121	0.665112	$metal3
+ $W=3e-07
Rc345	vbottom<4>#121	vbottom<4>#122	0.025931	$metal3
+ $W=4.2e-06
Rc346	vbottom<4>#122	vbottom<4>#123	0.025931	$metal3
+ $W=4.2e-06
Rc347	vbottom<4>#123	vbottom<4>#124	0.665112	$metal3
+ $W=3e-07
Rc348	vbottom<4>#124	vbottom<4>#125	0.025931	$metal3
+ $W=4.2e-06
Rc349	vbottom<4>#125	vbottom<4>#126	0.025931	$metal3
+ $W=4.2e-06
Rc350	vbottom<4>#126	vbottom<4>#127	0.665112	$metal3
+ $W=3e-07
Rc351	vbottom<4>#127	vbottom<4>#128	0.025931	$metal3
+ $W=4.2e-06
Rc352	vbottom<4>#128	vbottom<4>#129	0.025931	$metal3
+ $W=4.2e-06
Rc353	vbottom<4>#129	vbottom<4>#130	0.665112	$metal3
+ $W=3e-07
Rc354	vbottom<4>#130	vbottom<4>#131	0.025931	$metal3
+ $W=4.2e-06
Rc355	vbottom<4>#119	vbottom<4>#117	0.025931	$metal3
+ $W=4.2e-06
Rc356	vbottom<4>#120	vbottom<4>#92	0.345935	$metal3
+ $W=3e-07
Rc357	vbottom<4>#120	vbottom<4>#132	0.556646	$metal3
+ $W=6e-07
Rc358	vbottom<4>#121	vbottom<4>#91	0.337791	$metal3
+ $W=3e-07
Rc359	vbottom<4>#122	vbottom<4>#90	0.025931	$metal3
+ $W=4.2e-06
Rc360	vbottom<4>#123	vbottom<4>#89	0.337791	$metal3
+ $W=3e-07
Rc361	vbottom<4>#123	vbottom<4>#133	0.556646	$metal3
+ $W=6e-07
Rc362	vbottom<4>#124	vbottom<4>#88	0.337791	$metal3
+ $W=3e-07
Rc363	vbottom<4>#125	vbottom<4>#87	0.025931	$metal3
+ $W=4.2e-06
Rc364	vbottom<4>#126	vbottom<4>#86	0.337791	$metal3
+ $W=3e-07
Rc365	vbottom<4>#126	vbottom<4>#134	0.556646	$metal3
+ $W=6e-07
Rc366	vbottom<4>#127	vbottom<4>#85	0.337791	$metal3
+ $W=3e-07
Rc367	vbottom<4>#128	vbottom<4>#84	0.025931	$metal3
+ $W=4.2e-06
Rc368	vbottom<4>#129	vbottom<4>#83	0.337791	$metal3
+ $W=3e-07
Rc369	vbottom<4>#129	vbottom<4>#135	0.556646	$metal3
+ $W=6e-07
Rc370	vbottom<4>#130	vbottom<4>#82	0.337791	$metal3
+ $W=3e-07
Rc371	vbottom<4>#131	vbottom<4>#80	0.025931	$metal3
+ $W=4.2e-06
Rc372	vbottom<4>#131	vbottom<4>#81	0.025931	$metal3
+ $W=4.2e-06
Rc373	vbottom<4>#131	vbottom<4>#136	0.025931	$metal3
+ $W=4.2e-06
Rc374	vbottom<4>#132	vbottom<4>#119	0.025931	$metal3
+ $W=4.2e-06
Rc375	vbottom<4>#132	vbottom<4>#137	0.337203	$metal3
+ $W=3e-07
Rc376	vbottom<4>#133	vbottom<4>#122	0.025931	$metal3
+ $W=4.2e-06
Rc377	vbottom<4>#133	vbottom<4>#138	0.337203	$metal3
+ $W=3e-07
Rc378	vbottom<4>#134	vbottom<4>#125	0.025931	$metal3
+ $W=4.2e-06
Rc379	vbottom<4>#134	vbottom<4>#139	0.337203	$metal3
+ $W=3e-07
Rc380	vbottom<4>#135	vbottom<4>#128	0.025931	$metal3
+ $W=4.2e-06
Rc381	vbottom<4>#135	vbottom<4>#140	0.337203	$metal3
+ $W=3e-07
Rc382	vbottom<4>#136	vbottom<4>#79	0.225592	$metal3
+ $W=6e-07
Rc383	vbottom<4>#136	vbottom<4>#141	0.337203	$metal3
+ $W=3e-07
Rc384	vbottom<4>#137	vbottom<4>#118	0.215025	$metal3
+ $W=6e-07
Rc385	vbottom<4>#138	vbottom<4>#121	0.215025	$metal3
+ $W=6e-07
Rc386	vbottom<4>#139	vbottom<4>#124	0.215025	$metal3
+ $W=6e-07
Rc387	vbottom<4>#140	vbottom<4>#127	0.215025	$metal3
+ $W=6e-07
Rc388	vbottom<4>#141	vbottom<4>#130	0.215025	$metal3
+ $W=6e-07
Rc389	vbottom<5>#15	vbottom<5>#17	3.659100	$metal3
+ $W=3e-07
Rc390	vbottom<5>#17	vbottom<5>#18	0.337791	$metal3
+ $W=3e-07
Rc391	vbottom<5>#18	vbottom<5>#14	0.438675	$metal3
+ $W=3e-07
Rc392	vbottom<5>#14	vbottom<5>#20	0.221737	$metal3
+ $W=3e-07
Rc393	vbottom<5>#20	vbottom<5>#21	0.025931	$metal3
+ $W=4.2e-06
Rc394	vbottom<5>#21	vbottom<5>#22	0.025931	$metal3
+ $W=4.2e-06
Rc395	vbottom<5>#22	vbottom<5>#23	0.665112	$metal3
+ $W=3e-07
Rc396	vbottom<5>#23	vbottom<5>#24	0.025931	$metal3
+ $W=4.2e-06
Rc397	vbottom<5>#24	vbottom<5>#25	0.025931	$metal3
+ $W=4.2e-06
Rc398	vbottom<5>#25	vbottom<5>#26	0.665112	$metal3
+ $W=3e-07
Rc399	vbottom<5>#26	vbottom<5>#27	0.025931	$metal3
+ $W=4.2e-06
Rc400	vbottom<5>#27	vbottom<5>#28	0.025931	$metal3
+ $W=4.2e-06
Rc401	vbottom<5>#28	vbottom<5>#29	0.665112	$metal3
+ $W=3e-07
Rc402	vbottom<5>#29	vbottom<5>#30	0.025931	$metal3
+ $W=4.2e-06
Rc403	vbottom<5>#30	vbottom<5>#31	0.025931	$metal3
+ $W=4.2e-06
Rc404	vbottom<5>#31	vbottom<5>#32	0.665112	$metal3
+ $W=3e-07
Rc405	vbottom<5>#32	vbottom<5>#33	0.025931	$metal3
+ $W=4.2e-06
Rc406	vbottom<5>#33	vbottom<5>#34	0.025931	$metal3
+ $W=4.2e-06
Rc407	vbottom<5>#34	vbottom<5>#35	0.665112	$metal3
+ $W=3e-07
Rc408	vbottom<5>#35	vbottom<5>#36	0.025931	$metal3
+ $W=4.2e-06
Rc409	vbottom<5>#36	vbottom<5>#37	0.025931	$metal3
+ $W=4.2e-06
Rc410	vbottom<5>#37	vbottom<5>#38	0.556646	$metal3
+ $W=6e-07
Rc411	vbottom<5>#38	vbottom<5>#39	0.698840	$metal3
+ $W=3e-07
Rc412	vbottom<5>#39	vbottom<5>#40	0.556646	$metal3
+ $W=3e-07
Rc413	vbottom<5>#40	vbottom<5>#41	0.523746	$metal3
+ $W=6e-07
Rc414	vbottom<5>#41	vbottom<5>#42	0.698840	$metal3
+ $W=3e-07
Rc415	vbottom<5>#42	vbottom<5>#43	0.556646	$metal3
+ $W=3e-07
Rc416	vbottom<5>#43	vbottom<5>#44	0.523746	$metal3
+ $W=6e-07
Rc417	vbottom<5>#44	vbottom<5>#45	0.698840	$metal3
+ $W=3e-07
Rc418	vbottom<5>#45	vbottom<5>#46	0.556646	$metal3
+ $W=3e-07
Rc419	vbottom<5>#46	vbottom<5>#47	0.523746	$metal3
+ $W=6e-07
Rc420	vbottom<5>#47	vbottom<5>#48	0.698840	$metal3
+ $W=3e-07
Rc421	vbottom<5>#48	vbottom<5>#49	0.556646	$metal3
+ $W=3e-07
Rc422	vbottom<5>#49	vbottom<5>#50	0.523746	$metal3
+ $W=6e-07
Rc423	vbottom<5>#50	vbottom<5>#51	0.698840	$metal3
+ $W=3e-07
Rc424	vbottom<5>#51	vbottom<5>#52	0.556646	$metal3
+ $W=3e-07
Rc425	vbottom<5>#52	vbottom<5>#53	0.523746	$metal3
+ $W=6e-07
Rc426	vbottom<5>#53	vbottom<5>#54	0.698840	$metal3
+ $W=3e-07
Rc427	vbottom<5>#54	vbottom<5>#55	0.556646	$metal3
+ $W=3e-07
Rc428	vbottom<5>#55	vbottom<5>#56	0.523746	$metal3
+ $W=6e-07
Rc429	vbottom<5>#56	vbottom<5>#57	0.698840	$metal3
+ $W=3e-07
Rc430	vbottom<5>#57	vbottom<5>#58	0.556646	$metal3
+ $W=3e-07
Rc431	vbottom<5>#58	vbottom<5>#59	0.523746	$metal3
+ $W=6e-07
Rc432	vbottom<5>#59	vbottom<5>#60	0.556646	$metal3
+ $W=6e-07
Rc433	vbottom<5>#60	vbottom<5>#61	0.025931	$metal3
+ $W=4.2e-06
Rc434	vbottom<5>#22	vbottom<5>#62	0.556646	$metal3
+ $W=6e-07
Rc435	vbottom<5>#25	vbottom<5>#63	0.556646	$metal3
+ $W=6e-07
Rc436	vbottom<5>#28	vbottom<5>#64	0.556646	$metal3
+ $W=6e-07
Rc437	vbottom<5>#31	vbottom<5>#65	0.556646	$metal3
+ $W=6e-07
Rc438	vbottom<5>#34	vbottom<5>#66	0.556646	$metal3
+ $W=6e-07
Rc439	vbottom<5>#37	vbottom<5>#67	0.523746	$metal3
+ $W=6e-07
Rc440	vbottom<5>#38	vbottom<5>#36	0.025931	$metal3
+ $W=4.2e-06
Rc441	vbottom<5>#60	vbottom<5>#68	0.665112	$metal3
+ $W=3e-07
Rc442	vbottom<5>#68	vbottom<5>#69	0.556646	$metal3
+ $W=6e-07
Rc443	vbottom<5>#69	vbottom<5>#70	0.556646	$metal3
+ $W=6e-07
Rc444	vbottom<5>#70	vbottom<5>#71	0.025931	$metal3
+ $W=4.2e-06
Rc445	vbottom<5>#61	vbottom<5>#58	0.025931	$metal3
+ $W=4.2e-06
Rc446	vbottom<5>#61	vbottom<5>#59	0.025931	$metal3
+ $W=4.2e-06
Rc447	vbottom<5>#61	vbottom<5>#57	0.025931	$metal3
+ $W=4.2e-06
Rc448	vbottom<5>#62	vbottom<5>#21	0.025931	$metal3
+ $W=4.2e-06
Rc449	vbottom<5>#62	vbottom<5>#72	0.337203	$metal3
+ $W=3e-07
Rc450	vbottom<5>#63	vbottom<5>#24	0.025931	$metal3
+ $W=4.2e-06
Rc451	vbottom<5>#63	vbottom<5>#73	0.337203	$metal3
+ $W=3e-07
Rc452	vbottom<5>#64	vbottom<5>#27	0.025931	$metal3
+ $W=4.2e-06
Rc453	vbottom<5>#64	vbottom<5>#74	0.337203	$metal3
+ $W=3e-07
Rc454	vbottom<5>#65	vbottom<5>#30	0.025931	$metal3
+ $W=4.2e-06
Rc455	vbottom<5>#65	vbottom<5>#75	0.337203	$metal3
+ $W=3e-07
Rc456	vbottom<5>#66	vbottom<5>#33	0.025931	$metal3
+ $W=4.2e-06
Rc457	vbottom<5>#66	vbottom<5>#76	0.337203	$metal3
+ $W=3e-07
Rc458	vbottom<5>#67	vbottom<5>#36	0.025931	$metal3
+ $W=4.2e-06
Rc459	vbottom<5>#67	vbottom<5>#77	0.337203	$metal3
+ $W=3e-07
Rc460	vbottom<5>#71	vbottom<5>#68	0.025931	$metal3
+ $W=4.2e-06
Rc461	vbottom<5>#71	vbottom<5>#69	0.025931	$metal3
+ $W=4.2e-06
Rc462	vbottom<5>#71	vbottom<5>#78	0.025931	$metal3
+ $W=4.2e-06
Rc463	vbottom<5>#78	vbottom<5>#79	0.226767	$metal3
+ $W=6e-07
Rc464	vbottom<5>#79	vbottom<5>#80	0.661227	$metal3
+ $W=3e-07
Rc465	vbottom<5>#72	vbottom<5>#20	0.215025	$metal3
+ $W=6e-07
Rc466	vbottom<5>#73	vbottom<5>#23	0.215025	$metal3
+ $W=6e-07
Rc467	vbottom<5>#74	vbottom<5>#26	0.215025	$metal3
+ $W=6e-07
Rc468	vbottom<5>#75	vbottom<5>#29	0.215025	$metal3
+ $W=6e-07
Rc469	vbottom<5>#76	vbottom<5>#32	0.215025	$metal3
+ $W=6e-07
Rc470	vbottom<5>#77	vbottom<5>#35	0.215025	$metal3
+ $W=6e-07
Rc471	vbottom<5>#79	vbottom<5>#68	0.337203	$metal3
+ $W=3e-07
Rc472	vbottom<5>#80	vbottom<5>#57	0.345935	$metal3
+ $W=3e-07
Rc473	vbottom<5>#80	vbottom<5>#60	0.345935	$metal3
+ $W=3e-07
Rc474	vbottom<5>#80	vbottom<5>#81	0.672969	$metal3
+ $W=3e-07
Rc475	vbottom<5>#81	vbottom<5>#56	0.337203	$metal3
+ $W=3e-07
Rc476	vbottom<5>#81	vbottom<5>#82	0.215025	$metal3
+ $W=6e-07
Rc477	vbottom<5>#82	vbottom<5>#83	0.025931	$metal3
+ $W=4.2e-06
Rc478	vbottom<5>#82	vbottom<5>#84	0.193867	$metal3
+ $W=6e-07
Rc479	vbottom<5>#83	vbottom<5>#55	0.025931	$metal3
+ $W=4.2e-06
Rc480	vbottom<5>#83	vbottom<5>#56	0.025931	$metal3
+ $W=4.2e-06
Rc481	vbottom<5>#83	vbottom<5>#54	0.025931	$metal3
+ $W=4.2e-06
Rc482	vbottom<5>#84	vbottom<5>#54	0.337203	$metal3
+ $W=3e-07
Rc483	vbottom<5>#84	vbottom<5>#85	0.685401	$metal3
+ $W=3e-07
Rc484	vbottom<5>#85	vbottom<5>#53	0.337203	$metal3
+ $W=3e-07
Rc485	vbottom<5>#85	vbottom<5>#86	0.215025	$metal3
+ $W=6e-07
Rc486	vbottom<5>#86	vbottom<5>#87	0.025931	$metal3
+ $W=4.2e-06
Rc487	vbottom<5>#86	vbottom<5>#88	0.193867	$metal3
+ $W=6e-07
Rc488	vbottom<5>#87	vbottom<5>#52	0.025931	$metal3
+ $W=4.2e-06
Rc489	vbottom<5>#87	vbottom<5>#53	0.025931	$metal3
+ $W=4.2e-06
Rc490	vbottom<5>#87	vbottom<5>#51	0.025931	$metal3
+ $W=4.2e-06
Rc491	vbottom<5>#88	vbottom<5>#51	0.337203	$metal3
+ $W=3e-07
Rc492	vbottom<5>#88	vbottom<5>#89	0.685401	$metal3
+ $W=3e-07
Rc493	vbottom<5>#89	vbottom<5>#50	0.337203	$metal3
+ $W=3e-07
Rc494	vbottom<5>#89	vbottom<5>#90	0.215025	$metal3
+ $W=6e-07
Rc495	vbottom<5>#90	vbottom<5>#91	0.025931	$metal3
+ $W=4.2e-06
Rc496	vbottom<5>#90	vbottom<5>#92	0.193867	$metal3
+ $W=6e-07
Rc497	vbottom<5>#91	vbottom<5>#49	0.025931	$metal3
+ $W=4.2e-06
Rc498	vbottom<5>#91	vbottom<5>#50	0.025931	$metal3
+ $W=4.2e-06
Rc499	vbottom<5>#91	vbottom<5>#48	0.025931	$metal3
+ $W=4.2e-06
Rc500	vbottom<5>#92	vbottom<5>#48	0.337203	$metal3
+ $W=3e-07
Rc501	vbottom<5>#92	vbottom<5>#93	0.685401	$metal3
+ $W=3e-07
Rc502	vbottom<5>#93	vbottom<5>#47	0.337203	$metal3
+ $W=3e-07
Rc503	vbottom<5>#93	vbottom<5>#94	0.215025	$metal3
+ $W=6e-07
Rc504	vbottom<5>#94	vbottom<5>#95	0.025931	$metal3
+ $W=4.2e-06
Rc505	vbottom<5>#94	vbottom<5>#96	0.193867	$metal3
+ $W=6e-07
Rc506	vbottom<5>#95	vbottom<5>#46	0.025931	$metal3
+ $W=4.2e-06
Rc507	vbottom<5>#95	vbottom<5>#47	0.025931	$metal3
+ $W=4.2e-06
Rc508	vbottom<5>#95	vbottom<5>#45	0.025931	$metal3
+ $W=4.2e-06
Rc509	vbottom<5>#96	vbottom<5>#45	0.337203	$metal3
+ $W=3e-07
Rc510	vbottom<5>#96	vbottom<5>#97	0.685401	$metal3
+ $W=3e-07
Rc511	vbottom<5>#97	vbottom<5>#44	0.337203	$metal3
+ $W=3e-07
Rc512	vbottom<5>#97	vbottom<5>#98	0.215025	$metal3
+ $W=6e-07
Rc513	vbottom<5>#98	vbottom<5>#99	0.025931	$metal3
+ $W=4.2e-06
Rc514	vbottom<5>#98	vbottom<5>#100	0.193867	$metal3
+ $W=6e-07
Rc515	vbottom<5>#99	vbottom<5>#43	0.025931	$metal3
+ $W=4.2e-06
Rc516	vbottom<5>#99	vbottom<5>#44	0.025931	$metal3
+ $W=4.2e-06
Rc517	vbottom<5>#99	vbottom<5>#42	0.025931	$metal3
+ $W=4.2e-06
Rc518	vbottom<5>#100	vbottom<5>#42	0.337203	$metal3
+ $W=3e-07
Rc519	vbottom<5>#100	vbottom<5>#101	0.685401	$metal3
+ $W=3e-07
Rc520	vbottom<5>#101	vbottom<5>#41	0.337203	$metal3
+ $W=3e-07
Rc521	vbottom<5>#101	vbottom<5>#102	0.215025	$metal3
+ $W=6e-07
Rc522	vbottom<5>#102	vbottom<5>#103	0.025931	$metal3
+ $W=4.2e-06
Rc523	vbottom<5>#102	vbottom<5>#104	0.193867	$metal3
+ $W=6e-07
Rc524	vbottom<5>#103	vbottom<5>#40	0.025931	$metal3
+ $W=4.2e-06
Rc525	vbottom<5>#103	vbottom<5>#41	0.025931	$metal3
+ $W=4.2e-06
Rc526	vbottom<5>#103	vbottom<5>#39	0.025931	$metal3
+ $W=4.2e-06
Rc527	vbottom<5>#104	vbottom<5>#39	0.337203	$metal3
+ $W=3e-07
Rc528	vbottom<5>#104	vbottom<5>#105	0.672969	$metal3
+ $W=3e-07
Rc529	vbottom<5>#105	vbottom<5>#38	0.345935	$metal3
+ $W=3e-07
Rc530	vbottom<5>#105	vbottom<5>#106	0.661227	$metal3
+ $W=3e-07
Rc531	vbottom<5>#106	vbottom<5>#107	0.226767	$metal3
+ $W=6e-07
Rc532	vbottom<5>#107	vbottom<5>#108	0.698840	$metal3
+ $W=3e-07
Rc533	vbottom<5>#108	vbottom<5>#109	0.556646	$metal3
+ $W=3e-07
Rc534	vbottom<5>#109	vbottom<5>#110	0.523746	$metal3
+ $W=6e-07
Rc535	vbottom<5>#110	vbottom<5>#111	0.698840	$metal3
+ $W=3e-07
Rc536	vbottom<5>#111	vbottom<5>#112	0.556646	$metal3
+ $W=3e-07
Rc537	vbottom<5>#112	vbottom<5>#113	0.523746	$metal3
+ $W=6e-07
Rc538	vbottom<5>#113	vbottom<5>#114	0.556646	$metal3
+ $W=6e-07
Rc539	vbottom<5>#114	vbottom<5>#115	0.025931	$metal3
+ $W=4.2e-06
Rc540	vbottom<5>#105	vbottom<5>#35	0.345935	$metal3
+ $W=3e-07
Rc541	vbottom<5>#106	vbottom<5>#34	0.337203	$metal3
+ $W=3e-07
Rc542	vbottom<5>#107	vbottom<5>#33	0.025931	$metal3
+ $W=4.2e-06
Rc543	vbottom<5>#114	vbottom<5>#116	0.226767	$metal3
+ $W=6e-07
Rc544	vbottom<5>#115	vbottom<5>#112	0.025931	$metal3
+ $W=4.2e-06
Rc545	vbottom<5>#115	vbottom<5>#113	0.025931	$metal3
+ $W=4.2e-06
Rc546	vbottom<5>#115	vbottom<5>#111	0.025931	$metal3
+ $W=4.2e-06
Rc547	vbottom<5>#116	vbottom<5>#111	0.337203	$metal3
+ $W=3e-07
Rc548	vbottom<5>#116	vbottom<5>#117	0.685401	$metal3
+ $W=3e-07
Rc549	vbottom<5>#117	vbottom<5>#110	0.337203	$metal3
+ $W=3e-07
Rc550	vbottom<5>#117	vbottom<5>#118	0.215025	$metal3
+ $W=6e-07
Rc551	vbottom<5>#118	vbottom<5>#119	0.025931	$metal3
+ $W=4.2e-06
Rc552	vbottom<5>#118	vbottom<5>#120	0.193867	$metal3
+ $W=6e-07
Rc553	vbottom<5>#119	vbottom<5>#109	0.025931	$metal3
+ $W=4.2e-06
Rc554	vbottom<5>#119	vbottom<5>#110	0.025931	$metal3
+ $W=4.2e-06
Rc555	vbottom<5>#119	vbottom<5>#108	0.025931	$metal3
+ $W=4.2e-06
Rc556	vbottom<5>#120	vbottom<5>#108	0.337203	$metal3
+ $W=3e-07
Rc557	vbottom<5>#120	vbottom<5>#121	0.672969	$metal3
+ $W=3e-07
Rc558	vbottom<5>#121	vbottom<5>#107	0.345935	$metal3
+ $W=3e-07
Rc559	vbottom<5>#121	vbottom<5>#122	0.661227	$metal3
+ $W=3e-07
Rc560	vbottom<5>#122	vbottom<5>#123	0.226767	$metal3
+ $W=6e-07
Rc561	vbottom<5>#123	vbottom<5>#124	0.182125	$metal3
+ $W=6e-07
Rc562	vbottom<5>#124	vbottom<5>#125	0.673659	$metal3
+ $W=3e-07
Rc563	vbottom<5>#125	vbottom<5>#126	0.226767	$metal3
+ $W=6e-07
Rc564	vbottom<5>#126	vbottom<5>#127	0.182125	$metal3
+ $W=6e-07
Rc565	vbottom<5>#127	vbottom<5>#128	0.673659	$metal3
+ $W=3e-07
Rc566	vbottom<5>#128	vbottom<5>#129	0.226767	$metal3
+ $W=6e-07
Rc567	vbottom<5>#129	vbottom<5>#130	0.182125	$metal3
+ $W=6e-07
Rc568	vbottom<5>#130	vbottom<5>#131	0.673659	$metal3
+ $W=3e-07
Rc569	vbottom<5>#131	vbottom<5>#132	0.226767	$metal3
+ $W=6e-07
Rc570	vbottom<5>#132	vbottom<5>#133	0.182125	$metal3
+ $W=6e-07
Rc571	vbottom<5>#133	vbottom<5>#134	0.673659	$metal3
+ $W=3e-07
Rc572	vbottom<5>#134	vbottom<5>#135	0.226767	$metal3
+ $W=6e-07
Rc573	vbottom<5>#135	vbottom<5>#136	0.180950	$metal3
+ $W=6e-07
Rc574	vbottom<5>#136	vbottom<5>#137	0.671793	$metal3
+ $W=3e-07
Rc575	vbottom<5>#137	vbottom<5>#138	0.672969	$metal3
+ $W=3e-07
Rc576	vbottom<5>#138	vbottom<5>#139	0.215025	$metal3
+ $W=6e-07
Rc577	vbottom<5>#139	vbottom<5>#140	0.193867	$metal3
+ $W=6e-07
Rc578	vbottom<5>#140	vbottom<5>#141	0.685401	$metal3
+ $W=3e-07
Rc579	vbottom<5>#141	vbottom<5>#142	0.215025	$metal3
+ $W=6e-07
Rc580	vbottom<5>#142	vbottom<5>#143	0.193867	$metal3
+ $W=6e-07
Rc581	vbottom<5>#143	vbottom<5>#144	0.685401	$metal3
+ $W=3e-07
Rc582	vbottom<5>#144	vbottom<5>#145	0.215025	$metal3
+ $W=6e-07
Rc583	vbottom<5>#145	vbottom<5>#146	0.193867	$metal3
+ $W=6e-07
Rc584	vbottom<5>#146	vbottom<5>#147	0.685401	$metal3
+ $W=3e-07
Rc585	vbottom<5>#147	vbottom<5>#148	0.215025	$metal3
+ $W=6e-07
Rc586	vbottom<5>#148	vbottom<5>#149	0.193867	$metal3
+ $W=6e-07
Rc587	vbottom<5>#149	vbottom<5>#150	0.685401	$metal3
+ $W=3e-07
Rc588	vbottom<5>#150	vbottom<5>#151	0.215025	$metal3
+ $W=6e-07
Rc589	vbottom<5>#151	vbottom<5>#152	0.193867	$metal3
+ $W=6e-07
Rc590	vbottom<5>#152	vbottom<5>#153	0.685401	$metal3
+ $W=3e-07
Rc591	vbottom<5>#153	vbottom<5>#154	0.215025	$metal3
+ $W=6e-07
Rc592	vbottom<5>#154	vbottom<5>#155	0.193867	$metal3
+ $W=6e-07
Rc593	vbottom<5>#155	vbottom<5>#156	0.672969	$metal3
+ $W=3e-07
Rc594	vbottom<5>#156	vbottom<5>#157	0.671793	$metal3
+ $W=3e-07
Rc595	vbottom<5>#157	vbottom<5>#158	0.213850	$metal3
+ $W=6e-07
Rc596	vbottom<5>#158	vbottom<5>#159	0.345935	$metal3
+ $W=3e-07
Rc597	vbottom<5>#159	vbottom<5>#160	0.671793	$metal3
+ $W=3e-07
Rc598	vbottom<5>#160	vbottom<5>#161	0.213850	$metal3
+ $W=6e-07
Rc599	vbottom<5>#161	vbottom<5>#162	0.192692	$metal3
+ $W=6e-07
Rc600	vbottom<5>#162	vbottom<5>#163	0.671308	$metal3
+ $W=3e-07
Rc601	vbottom<5>#163	vbottom<5>#164	0.213850	$metal3
+ $W=6e-07
Rc602	vbottom<5>#164	vbottom<5>#165	0.192692	$metal3
+ $W=6e-07
Rc603	vbottom<5>#165	vbottom<5>#166	0.671308	$metal3
+ $W=3e-07
Rc604	vbottom<5>#166	vbottom<5>#167	0.213850	$metal3
+ $W=6e-07
Rc605	vbottom<5>#167	vbottom<5>#168	0.192692	$metal3
+ $W=6e-07
Rc606	vbottom<5>#168	vbottom<5>#169	0.671308	$metal3
+ $W=3e-07
Rc607	vbottom<5>#169	vbottom<5>#170	0.213850	$metal3
+ $W=6e-07
Rc608	vbottom<5>#170	vbottom<5>#171	0.192692	$metal3
+ $W=6e-07
Rc609	vbottom<5>#171	vbottom<5>#172	0.672483	$metal3
+ $W=3e-07
Rc610	vbottom<5>#121	vbottom<5>#32	0.345935	$metal3
+ $W=3e-07
Rc611	vbottom<5>#122	vbottom<5>#31	0.337203	$metal3
+ $W=3e-07
Rc612	vbottom<5>#123	vbottom<5>#30	0.025931	$metal3
+ $W=4.2e-06
Rc613	vbottom<5>#124	vbottom<5>#29	0.337203	$metal3
+ $W=3e-07
Rc614	vbottom<5>#125	vbottom<5>#28	0.337203	$metal3
+ $W=3e-07
Rc615	vbottom<5>#126	vbottom<5>#27	0.025931	$metal3
+ $W=4.2e-06
Rc616	vbottom<5>#127	vbottom<5>#26	0.337203	$metal3
+ $W=3e-07
Rc617	vbottom<5>#128	vbottom<5>#25	0.337203	$metal3
+ $W=3e-07
Rc618	vbottom<5>#129	vbottom<5>#24	0.025931	$metal3
+ $W=4.2e-06
Rc619	vbottom<5>#130	vbottom<5>#23	0.337203	$metal3
+ $W=3e-07
Rc620	vbottom<5>#131	vbottom<5>#22	0.337203	$metal3
+ $W=3e-07
Rc621	vbottom<5>#132	vbottom<5>#21	0.025931	$metal3
+ $W=4.2e-06
Rc622	vbottom<5>#133	vbottom<5>#20	0.337203	$metal3
+ $W=3e-07
Rc623	vbottom<5>#134	vbottom<5>#18	0.337203	$metal3
+ $W=3e-07
Rc624	vbottom<5>#159	vbottom<5>#173	0.671793	$metal3
+ $W=3e-07
Rc625	vbottom<5>#173	vbottom<5>#174	0.337791	$metal3
+ $W=3e-07
Rc626	vbottom<5>#174	vbottom<5>#175	0.315692	$metal3
+ $W=3e-07
Rc627	vbottom<5>#171	vbottom<5>#176	0.337791	$metal3
+ $W=3e-07
Rc628	vbottom<5>#176	vbottom<5>#177	0.315692	$metal3
+ $W=3e-07
Rc629	vbottom<5>#172	vbottom<5>#78	0.182125	$metal3
+ $W=6e-07
Rc630	vbottom<5>#172	vbottom<5>#70	0.337203	$metal3
+ $W=3e-07
Rc631	vbottom<5>#174	vbottom<5>#178	0.556646	$metal3
+ $W=6e-07
Rc632	vbottom<5>#178	vbottom<5>#179	0.025931	$metal3
+ $W=4.2e-06
Rc633	vbottom<5>#179	vbottom<5>#180	0.025931	$metal3
+ $W=4.2e-06
Rc634	vbottom<5>#180	vbottom<5>#181	0.193867	$metal3
+ $W=6e-07
Rc635	vbottom<5>#181	vbottom<5>#182	0.337203	$metal3
+ $W=3e-07
Rc636	vbottom<5>#175	vbottom<5>#158	0.349420	$metal3
+ $W=3e-07
Rc637	vbottom<5>#176	vbottom<5>#183	0.556646	$metal3
+ $W=6e-07
Rc638	vbottom<5>#183	vbottom<5>#184	0.556646	$metal3
+ $W=6e-07
Rc639	vbottom<5>#184	vbottom<5>#185	0.025931	$metal3
+ $W=4.2e-06
Rc640	vbottom<5>#177	vbottom<5>#70	0.349420	$metal3
+ $W=3e-07
Rc641	vbottom<5>#179	vbottom<5>#174	0.025931	$metal3
+ $W=4.2e-06
Rc642	vbottom<5>#180	vbottom<5>#173	0.192692	$metal3
+ $W=6e-07
Rc643	vbottom<5>#182	vbottom<5>#179	0.025931	$metal3
+ $W=4.2e-06
Rc644	vbottom<5>#182	vbottom<5>#186	0.337203	$metal3
+ $W=3e-07
Rc645	vbottom<5>#182	vbottom<5>#187	0.698840	$metal3
+ $W=3e-07
Rc646	vbottom<5>#187	vbottom<5>#188	0.337203	$metal3
+ $W=3e-07
Rc647	vbottom<5>#188	vbottom<5>#189	0.330958	$metal3
+ $W=3e-07
Rc648	vbottom<5>#184	vbottom<5>#190	0.665112	$metal3
+ $W=3e-07
Rc649	vbottom<5>#190	vbottom<5>#191	0.556646	$metal3
+ $W=6e-07
Rc650	vbottom<5>#191	vbottom<5>#192	0.556646	$metal3
+ $W=6e-07
Rc651	vbottom<5>#192	vbottom<5>#193	0.025931	$metal3
+ $W=4.2e-06
Rc652	vbottom<5>#184	vbottom<5>#169	0.337791	$metal3
+ $W=3e-07
Rc653	vbottom<5>#185	vbottom<5>#176	0.025931	$metal3
+ $W=4.2e-06
Rc654	vbottom<5>#185	vbottom<5>#183	0.025931	$metal3
+ $W=4.2e-06
Rc655	vbottom<5>#185	vbottom<5>#170	0.025931	$metal3
+ $W=4.2e-06
Rc656	vbottom<5>#186	vbottom<5>#178	0.215025	$metal3
+ $W=6e-07
Rc657	vbottom<5>#188	vbottom<5>#194	0.215025	$metal3
+ $W=6e-07
Rc658	vbottom<5>#194	vbottom<5>#195	0.025931	$metal3
+ $W=4.2e-06
Rc659	vbottom<5>#189	vbottom<5>#181	0.342700	$metal3
+ $W=3e-07
Rc660	vbottom<5>#190	vbottom<5>#168	0.337791	$metal3
+ $W=3e-07
Rc661	vbottom<5>#192	vbottom<5>#196	0.665112	$metal3
+ $W=3e-07
Rc662	vbottom<5>#196	vbottom<5>#197	0.556646	$metal3
+ $W=6e-07
Rc663	vbottom<5>#197	vbottom<5>#198	0.556646	$metal3
+ $W=6e-07
Rc664	vbottom<5>#198	vbottom<5>#199	0.025931	$metal3
+ $W=4.2e-06
Rc665	vbottom<5>#192	vbottom<5>#166	0.337791	$metal3
+ $W=3e-07
Rc666	vbottom<5>#193	vbottom<5>#190	0.025931	$metal3
+ $W=4.2e-06
Rc667	vbottom<5>#193	vbottom<5>#191	0.025931	$metal3
+ $W=4.2e-06
Rc668	vbottom<5>#193	vbottom<5>#167	0.025931	$metal3
+ $W=4.2e-06
Rc669	vbottom<5>#195	vbottom<5>#187	0.025931	$metal3
+ $W=4.2e-06
Rc670	vbottom<5>#195	vbottom<5>#200	0.103652	$metal3
+ $W=4.8e-06
Rc671	vbottom<5>#196	vbottom<5>#165	0.337791	$metal3
+ $W=3e-07
Rc672	vbottom<5>#198	vbottom<5>#201	0.665112	$metal3
+ $W=3e-07
Rc673	vbottom<5>#201	vbottom<5>#202	0.556646	$metal3
+ $W=6e-07
Rc674	vbottom<5>#202	vbottom<5>#203	0.556646	$metal3
+ $W=6e-07
Rc675	vbottom<5>#203	vbottom<5>#204	0.025931	$metal3
+ $W=4.2e-06
Rc676	vbottom<5>#198	vbottom<5>#163	0.337791	$metal3
+ $W=3e-07
Rc677	vbottom<5>#199	vbottom<5>#196	0.025931	$metal3
+ $W=4.2e-06
Rc678	vbottom<5>#199	vbottom<5>#197	0.025931	$metal3
+ $W=4.2e-06
Rc679	vbottom<5>#199	vbottom<5>#164	0.025931	$metal3
+ $W=4.2e-06
Rc680	vbottom<5>#200	vbottom<5>#187	0.213850	$metal3
+ $W=6e-07
Rc681	vbottom<5>#201	vbottom<5>#162	0.337791	$metal3
+ $W=3e-07
Rc682	vbottom<5>#203	vbottom<5>#205	0.665112	$metal3
+ $W=3e-07
Rc683	vbottom<5>#205	vbottom<5>#206	0.556646	$metal3
+ $W=6e-07
Rc684	vbottom<5>#206	vbottom<5>#207	0.556646	$metal3
+ $W=6e-07
Rc685	vbottom<5>#207	vbottom<5>#208	0.025931	$metal3
+ $W=4.2e-06
Rc686	vbottom<5>#203	vbottom<5>#160	0.337791	$metal3
+ $W=3e-07
Rc687	vbottom<5>#204	vbottom<5>#201	0.025931	$metal3
+ $W=4.2e-06
Rc688	vbottom<5>#204	vbottom<5>#202	0.025931	$metal3
+ $W=4.2e-06
Rc689	vbottom<5>#204	vbottom<5>#161	0.025931	$metal3
+ $W=4.2e-06
Rc690	vbottom<5>#205	vbottom<5>#159	0.345935	$metal3
+ $W=3e-07
Rc691	vbottom<5>#207	vbottom<5>#209	0.665112	$metal3
+ $W=3e-07
Rc692	vbottom<5>#209	vbottom<5>#210	0.556646	$metal3
+ $W=6e-07
Rc693	vbottom<5>#210	vbottom<5>#211	0.556646	$metal3
+ $W=6e-07
Rc694	vbottom<5>#211	vbottom<5>#212	0.025931	$metal3
+ $W=4.2e-06
Rc695	vbottom<5>#207	vbottom<5>#157	0.337791	$metal3
+ $W=3e-07
Rc696	vbottom<5>#208	vbottom<5>#205	0.025931	$metal3
+ $W=4.2e-06
Rc697	vbottom<5>#208	vbottom<5>#206	0.025931	$metal3
+ $W=4.2e-06
Rc698	vbottom<5>#208	vbottom<5>#158	0.025931	$metal3
+ $W=4.2e-06
Rc699	vbottom<5>#209	vbottom<5>#156	0.345935	$metal3
+ $W=3e-07
Rc700	vbottom<5>#212	vbottom<5>#209	0.025931	$metal3
+ $W=4.2e-06
Rc701	vbottom<5>#212	vbottom<5>#210	0.025931	$metal3
+ $W=4.2e-06
Rc702	vbottom<5>#212	vbottom<5>#213	0.025931	$metal3
+ $W=4.2e-06
Rc703	vbottom<5>#213	vbottom<5>#156	0.345935	$metal3
+ $W=3e-07
Rc704	vbottom<5>#213	vbottom<5>#214	0.337203	$metal3
+ $W=3e-07
Rc705	vbottom<5>#213	vbottom<5>#215	0.698840	$metal3
+ $W=3e-07
Rc706	vbottom<5>#214	vbottom<5>#211	0.215025	$metal3
+ $W=6e-07
Rc707	vbottom<5>#215	vbottom<5>#155	0.337203	$metal3
+ $W=3e-07
Rc708	vbottom<5>#215	vbottom<5>#216	0.556646	$metal3
+ $W=6e-07
Rc709	vbottom<5>#216	vbottom<5>#217	0.025931	$metal3
+ $W=4.2e-06
Rc710	vbottom<5>#217	vbottom<5>#154	0.025931	$metal3
+ $W=4.2e-06
Rc711	vbottom<5>#217	vbottom<5>#215	0.025931	$metal3
+ $W=4.2e-06
Rc712	vbottom<5>#217	vbottom<5>#218	0.025931	$metal3
+ $W=4.2e-06
Rc713	vbottom<5>#218	vbottom<5>#153	0.337203	$metal3
+ $W=3e-07
Rc714	vbottom<5>#218	vbottom<5>#219	0.337203	$metal3
+ $W=3e-07
Rc715	vbottom<5>#218	vbottom<5>#220	0.698840	$metal3
+ $W=3e-07
Rc716	vbottom<5>#219	vbottom<5>#216	0.215025	$metal3
+ $W=6e-07
Rc717	vbottom<5>#220	vbottom<5>#152	0.337203	$metal3
+ $W=3e-07
Rc718	vbottom<5>#220	vbottom<5>#221	0.556646	$metal3
+ $W=6e-07
Rc719	vbottom<5>#221	vbottom<5>#222	0.025931	$metal3
+ $W=4.2e-06
Rc720	vbottom<5>#222	vbottom<5>#151	0.025931	$metal3
+ $W=4.2e-06
Rc721	vbottom<5>#222	vbottom<5>#220	0.025931	$metal3
+ $W=4.2e-06
Rc722	vbottom<5>#222	vbottom<5>#223	0.025931	$metal3
+ $W=4.2e-06
Rc723	vbottom<5>#223	vbottom<5>#150	0.337203	$metal3
+ $W=3e-07
Rc724	vbottom<5>#223	vbottom<5>#224	0.337203	$metal3
+ $W=3e-07
Rc725	vbottom<5>#223	vbottom<5>#225	0.698840	$metal3
+ $W=3e-07
Rc726	vbottom<5>#224	vbottom<5>#221	0.215025	$metal3
+ $W=6e-07
Rc727	vbottom<5>#225	vbottom<5>#149	0.337203	$metal3
+ $W=3e-07
Rc728	vbottom<5>#225	vbottom<5>#226	0.556646	$metal3
+ $W=6e-07
Rc729	vbottom<5>#226	vbottom<5>#227	0.025931	$metal3
+ $W=4.2e-06
Rc730	vbottom<5>#227	vbottom<5>#148	0.025931	$metal3
+ $W=4.2e-06
Rc731	vbottom<5>#227	vbottom<5>#225	0.025931	$metal3
+ $W=4.2e-06
Rc732	vbottom<5>#227	vbottom<5>#228	0.025931	$metal3
+ $W=4.2e-06
Rc733	vbottom<5>#228	vbottom<5>#147	0.337203	$metal3
+ $W=3e-07
Rc734	vbottom<5>#228	vbottom<5>#229	0.337203	$metal3
+ $W=3e-07
Rc735	vbottom<5>#228	vbottom<5>#230	0.698840	$metal3
+ $W=3e-07
Rc736	vbottom<5>#229	vbottom<5>#226	0.215025	$metal3
+ $W=6e-07
Rc737	vbottom<5>#230	vbottom<5>#146	0.337203	$metal3
+ $W=3e-07
Rc738	vbottom<5>#230	vbottom<5>#231	0.556646	$metal3
+ $W=6e-07
Rc739	vbottom<5>#231	vbottom<5>#232	0.025931	$metal3
+ $W=4.2e-06
Rc740	vbottom<5>#232	vbottom<5>#145	0.025931	$metal3
+ $W=4.2e-06
Rc741	vbottom<5>#232	vbottom<5>#230	0.025931	$metal3
+ $W=4.2e-06
Rc742	vbottom<5>#232	vbottom<5>#233	0.025931	$metal3
+ $W=4.2e-06
Rc743	vbottom<5>#233	vbottom<5>#144	0.337203	$metal3
+ $W=3e-07
Rc744	vbottom<5>#233	vbottom<5>#234	0.337203	$metal3
+ $W=3e-07
Rc745	vbottom<5>#233	vbottom<5>#235	0.698840	$metal3
+ $W=3e-07
Rc746	vbottom<5>#234	vbottom<5>#231	0.215025	$metal3
+ $W=6e-07
Rc747	vbottom<5>#235	vbottom<5>#143	0.337203	$metal3
+ $W=3e-07
Rc748	vbottom<5>#235	vbottom<5>#236	0.556646	$metal3
+ $W=6e-07
Rc749	vbottom<5>#236	vbottom<5>#237	0.025931	$metal3
+ $W=4.2e-06
Rc750	vbottom<5>#237	vbottom<5>#142	0.025931	$metal3
+ $W=4.2e-06
Rc751	vbottom<5>#237	vbottom<5>#235	0.025931	$metal3
+ $W=4.2e-06
Rc752	vbottom<5>#237	vbottom<5>#238	0.025931	$metal3
+ $W=4.2e-06
Rc753	vbottom<5>#238	vbottom<5>#141	0.337203	$metal3
+ $W=3e-07
Rc754	vbottom<5>#238	vbottom<5>#239	0.337203	$metal3
+ $W=3e-07
Rc755	vbottom<5>#238	vbottom<5>#240	0.698840	$metal3
+ $W=3e-07
Rc756	vbottom<5>#239	vbottom<5>#236	0.215025	$metal3
+ $W=6e-07
Rc757	vbottom<5>#240	vbottom<5>#140	0.337203	$metal3
+ $W=3e-07
Rc758	vbottom<5>#240	vbottom<5>#241	0.556646	$metal3
+ $W=6e-07
Rc759	vbottom<5>#241	vbottom<5>#242	0.025931	$metal3
+ $W=4.2e-06
Rc760	vbottom<5>#242	vbottom<5>#139	0.025931	$metal3
+ $W=4.2e-06
Rc761	vbottom<5>#242	vbottom<5>#240	0.025931	$metal3
+ $W=4.2e-06
Rc762	vbottom<5>#242	vbottom<5>#243	0.025931	$metal3
+ $W=4.2e-06
Rc763	vbottom<5>#243	vbottom<5>#138	0.337203	$metal3
+ $W=3e-07
Rc764	vbottom<5>#243	vbottom<5>#244	0.337203	$metal3
+ $W=3e-07
Rc765	vbottom<5>#243	vbottom<5>#245	0.698840	$metal3
+ $W=3e-07
Rc766	vbottom<5>#244	vbottom<5>#241	0.215025	$metal3
+ $W=6e-07
Rc767	vbottom<5>#245	vbottom<5>#137	0.345935	$metal3
+ $W=3e-07
Rc768	vbottom<5>#245	vbottom<5>#246	0.556646	$metal3
+ $W=6e-07
Rc769	vbottom<5>#246	vbottom<5>#247	0.025931	$metal3
+ $W=4.2e-06
Rc770	vbottom<5>#247	vbottom<5>#248	0.025931	$metal3
+ $W=4.2e-06
Rc771	vbottom<5>#248	vbottom<5>#249	0.665112	$metal3
+ $W=3e-07
Rc772	vbottom<5>#249	vbottom<5>#250	0.025931	$metal3
+ $W=4.2e-06
Rc773	vbottom<5>#247	vbottom<5>#245	0.025931	$metal3
+ $W=4.2e-06
Rc774	vbottom<5>#248	vbottom<5>#137	0.345935	$metal3
+ $W=3e-07
Rc775	vbottom<5>#248	vbottom<5>#251	0.556646	$metal3
+ $W=6e-07
Rc776	vbottom<5>#249	vbottom<5>#136	0.337791	$metal3
+ $W=3e-07
Rc777	vbottom<5>#250	vbottom<5>#18	0.025931	$metal3
+ $W=4.2e-06
Rc778	vbottom<5>#250	vbottom<5>#135	0.025931	$metal3
+ $W=4.2e-06
Rc779	vbottom<5>#250	vbottom<5>#252	0.025931	$metal3
+ $W=4.2e-06
Rc780	vbottom<5>#251	vbottom<5>#247	0.025931	$metal3
+ $W=4.2e-06
Rc781	vbottom<5>#251	vbottom<5>#253	0.337203	$metal3
+ $W=3e-07
Rc782	vbottom<5>#252	vbottom<5>#17	0.225592	$metal3
+ $W=6e-07
Rc783	vbottom<5>#252	vbottom<5>#254	0.337203	$metal3
+ $W=3e-07
Rc784	vbottom<5>#253	vbottom<5>#246	0.215025	$metal3
+ $W=6e-07
Rc785	vbottom<5>#254	vbottom<5>#249	0.215025	$metal3
+ $W=6e-07
Rc786	vbottom<6>#15	vbottom<6>#17	3.659100	$metal3
+ $W=3e-07
Rc787	vbottom<6>#17	vbottom<6>#18	0.337791	$metal3
+ $W=3e-07
Rc788	vbottom<6>#18	vbottom<6>#14	0.438675	$metal3
+ $W=3e-07
Rc789	vbottom<6>#14	vbottom<6>#20	0.221737	$metal3
+ $W=3e-07
Rc790	vbottom<6>#20	vbottom<6>#21	0.025931	$metal3
+ $W=4.2e-06
Rc791	vbottom<6>#21	vbottom<6>#22	0.025931	$metal3
+ $W=4.2e-06
Rc792	vbottom<6>#22	vbottom<6>#23	0.665112	$metal3
+ $W=3e-07
Rc793	vbottom<6>#23	vbottom<6>#24	0.025931	$metal3
+ $W=4.2e-06
Rc794	vbottom<6>#24	vbottom<6>#25	0.025931	$metal3
+ $W=4.2e-06
Rc795	vbottom<6>#25	vbottom<6>#26	0.665112	$metal3
+ $W=3e-07
Rc796	vbottom<6>#26	vbottom<6>#27	0.025931	$metal3
+ $W=4.2e-06
Rc797	vbottom<6>#27	vbottom<6>#28	0.025931	$metal3
+ $W=4.2e-06
Rc798	vbottom<6>#28	vbottom<6>#29	0.665112	$metal3
+ $W=3e-07
Rc799	vbottom<6>#29	vbottom<6>#30	0.025931	$metal3
+ $W=4.2e-06
Rc800	vbottom<6>#30	vbottom<6>#31	0.025931	$metal3
+ $W=4.2e-06
Rc801	vbottom<6>#31	vbottom<6>#32	0.665112	$metal3
+ $W=3e-07
Rc802	vbottom<6>#32	vbottom<6>#33	0.025931	$metal3
+ $W=4.2e-06
Rc803	vbottom<6>#33	vbottom<6>#34	0.025931	$metal3
+ $W=4.2e-06
Rc804	vbottom<6>#34	vbottom<6>#35	0.665112	$metal3
+ $W=3e-07
Rc805	vbottom<6>#35	vbottom<6>#36	0.025931	$metal3
+ $W=4.2e-06
Rc806	vbottom<6>#36	vbottom<6>#37	0.025931	$metal3
+ $W=4.2e-06
Rc807	vbottom<6>#37	vbottom<6>#38	0.665112	$metal3
+ $W=3e-07
Rc808	vbottom<6>#38	vbottom<6>#39	0.025931	$metal3
+ $W=4.2e-06
Rc809	vbottom<6>#39	vbottom<6>#40	0.025931	$metal3
+ $W=4.2e-06
Rc810	vbottom<6>#40	vbottom<6>#41	0.665112	$metal3
+ $W=3e-07
Rc811	vbottom<6>#41	vbottom<6>#42	0.025931	$metal3
+ $W=4.2e-06
Rc812	vbottom<6>#42	vbottom<6>#43	0.025931	$metal3
+ $W=4.2e-06
Rc813	vbottom<6>#43	vbottom<6>#44	0.556646	$metal3
+ $W=6e-07
Rc814	vbottom<6>#44	vbottom<6>#45	0.698840	$metal3
+ $W=3e-07
Rc815	vbottom<6>#45	vbottom<6>#46	0.556646	$metal3
+ $W=3e-07
Rc816	vbottom<6>#46	vbottom<6>#47	0.523746	$metal3
+ $W=6e-07
Rc817	vbottom<6>#47	vbottom<6>#48	0.698840	$metal3
+ $W=3e-07
Rc818	vbottom<6>#48	vbottom<6>#49	0.556646	$metal3
+ $W=3e-07
Rc819	vbottom<6>#49	vbottom<6>#50	0.523746	$metal3
+ $W=6e-07
Rc820	vbottom<6>#50	vbottom<6>#51	0.698840	$metal3
+ $W=3e-07
Rc821	vbottom<6>#51	vbottom<6>#52	0.556646	$metal3
+ $W=3e-07
Rc822	vbottom<6>#52	vbottom<6>#53	0.523746	$metal3
+ $W=6e-07
Rc823	vbottom<6>#53	vbottom<6>#54	0.698840	$metal3
+ $W=3e-07
Rc824	vbottom<6>#54	vbottom<6>#55	0.556646	$metal3
+ $W=3e-07
Rc825	vbottom<6>#55	vbottom<6>#56	0.523746	$metal3
+ $W=6e-07
Rc826	vbottom<6>#56	vbottom<6>#57	0.698840	$metal3
+ $W=3e-07
Rc827	vbottom<6>#57	vbottom<6>#58	0.556646	$metal3
+ $W=3e-07
Rc828	vbottom<6>#58	vbottom<6>#59	0.523746	$metal3
+ $W=6e-07
Rc829	vbottom<6>#59	vbottom<6>#60	0.698840	$metal3
+ $W=3e-07
Rc830	vbottom<6>#60	vbottom<6>#61	0.556646	$metal3
+ $W=3e-07
Rc831	vbottom<6>#61	vbottom<6>#62	0.523746	$metal3
+ $W=6e-07
Rc832	vbottom<6>#62	vbottom<6>#63	0.698840	$metal3
+ $W=3e-07
Rc833	vbottom<6>#63	vbottom<6>#64	0.556646	$metal3
+ $W=3e-07
Rc834	vbottom<6>#64	vbottom<6>#65	0.523746	$metal3
+ $W=6e-07
Rc835	vbottom<6>#65	vbottom<6>#66	0.698840	$metal3
+ $W=3e-07
Rc836	vbottom<6>#66	vbottom<6>#67	0.556646	$metal3
+ $W=3e-07
Rc837	vbottom<6>#67	vbottom<6>#68	0.523746	$metal3
+ $W=6e-07
Rc838	vbottom<6>#68	vbottom<6>#69	0.698840	$metal3
+ $W=3e-07
Rc839	vbottom<6>#69	vbottom<6>#70	0.556646	$metal3
+ $W=3e-07
Rc840	vbottom<6>#70	vbottom<6>#71	0.523746	$metal3
+ $W=6e-07
Rc841	vbottom<6>#71	vbottom<6>#72	0.698840	$metal3
+ $W=3e-07
Rc842	vbottom<6>#72	vbottom<6>#73	0.556646	$metal3
+ $W=3e-07
Rc843	vbottom<6>#73	vbottom<6>#74	0.523746	$metal3
+ $W=6e-07
Rc844	vbottom<6>#74	vbottom<6>#75	0.698840	$metal3
+ $W=3e-07
Rc845	vbottom<6>#75	vbottom<6>#76	0.225592	$metal3
+ $W=6e-07
Rc846	vbottom<6>#76	vbottom<6>#77	0.660051	$metal3
+ $W=3e-07
Rc847	vbottom<6>#77	vbottom<6>#78	0.345935	$metal3
+ $W=3e-07
Rc848	vbottom<6>#78	vbottom<6>#79	0.556646	$metal3
+ $W=3e-07
Rc849	vbottom<6>#79	vbottom<6>#80	0.523746	$metal3
+ $W=6e-07
Rc850	vbottom<6>#80	vbottom<6>#81	0.556646	$metal3
+ $W=6e-07
Rc851	vbottom<6>#81	vbottom<6>#82	0.025931	$metal3
+ $W=4.2e-06
Rc852	vbottom<6>#22	vbottom<6>#83	0.556646	$metal3
+ $W=6e-07
Rc853	vbottom<6>#25	vbottom<6>#84	0.556646	$metal3
+ $W=6e-07
Rc854	vbottom<6>#28	vbottom<6>#85	0.556646	$metal3
+ $W=6e-07
Rc855	vbottom<6>#31	vbottom<6>#86	0.556646	$metal3
+ $W=6e-07
Rc856	vbottom<6>#34	vbottom<6>#87	0.556646	$metal3
+ $W=6e-07
Rc857	vbottom<6>#37	vbottom<6>#88	0.556646	$metal3
+ $W=6e-07
Rc858	vbottom<6>#40	vbottom<6>#89	0.556646	$metal3
+ $W=6e-07
Rc859	vbottom<6>#43	vbottom<6>#90	0.523746	$metal3
+ $W=6e-07
Rc860	vbottom<6>#44	vbottom<6>#42	0.025931	$metal3
+ $W=4.2e-06
Rc861	vbottom<6>#78	vbottom<6>#91	0.698840	$metal3
+ $W=3e-07
Rc862	vbottom<6>#91	vbottom<6>#92	0.556646	$metal3
+ $W=3e-07
Rc863	vbottom<6>#92	vbottom<6>#93	0.025931	$metal3
+ $W=4.2e-06
Rc864	vbottom<6>#81	vbottom<6>#94	0.665112	$metal3
+ $W=3e-07
Rc865	vbottom<6>#94	vbottom<6>#95	0.556646	$metal3
+ $W=6e-07
Rc866	vbottom<6>#95	vbottom<6>#96	0.556646	$metal3
+ $W=6e-07
Rc867	vbottom<6>#96	vbottom<6>#97	0.025931	$metal3
+ $W=4.2e-06
Rc868	vbottom<6>#81	vbottom<6>#77	0.345935	$metal3
+ $W=3e-07
Rc869	vbottom<6>#82	vbottom<6>#79	0.025931	$metal3
+ $W=4.2e-06
Rc870	vbottom<6>#82	vbottom<6>#80	0.025931	$metal3
+ $W=4.2e-06
Rc871	vbottom<6>#82	vbottom<6>#78	0.025931	$metal3
+ $W=4.2e-06
Rc872	vbottom<6>#83	vbottom<6>#21	0.025931	$metal3
+ $W=4.2e-06
Rc873	vbottom<6>#83	vbottom<6>#98	0.337203	$metal3
+ $W=3e-07
Rc874	vbottom<6>#84	vbottom<6>#24	0.025931	$metal3
+ $W=4.2e-06
Rc875	vbottom<6>#84	vbottom<6>#99	0.337203	$metal3
+ $W=3e-07
Rc876	vbottom<6>#85	vbottom<6>#27	0.025931	$metal3
+ $W=4.2e-06
Rc877	vbottom<6>#85	vbottom<6>#100	0.337203	$metal3
+ $W=3e-07
Rc878	vbottom<6>#86	vbottom<6>#30	0.025931	$metal3
+ $W=4.2e-06
Rc879	vbottom<6>#86	vbottom<6>#101	0.337203	$metal3
+ $W=3e-07
Rc880	vbottom<6>#87	vbottom<6>#33	0.025931	$metal3
+ $W=4.2e-06
Rc881	vbottom<6>#87	vbottom<6>#102	0.337203	$metal3
+ $W=3e-07
Rc882	vbottom<6>#88	vbottom<6>#36	0.025931	$metal3
+ $W=4.2e-06
Rc883	vbottom<6>#88	vbottom<6>#103	0.337203	$metal3
+ $W=3e-07
Rc884	vbottom<6>#89	vbottom<6>#39	0.025931	$metal3
+ $W=4.2e-06
Rc885	vbottom<6>#89	vbottom<6>#104	0.337203	$metal3
+ $W=3e-07
Rc886	vbottom<6>#90	vbottom<6>#42	0.025931	$metal3
+ $W=4.2e-06
Rc887	vbottom<6>#90	vbottom<6>#105	0.337203	$metal3
+ $W=3e-07
Rc888	vbottom<6>#93	vbottom<6>#91	0.025931	$metal3
+ $W=4.2e-06
Rc889	vbottom<6>#93	vbottom<6>#106	0.025931	$metal3
+ $W=4.2e-06
Rc890	vbottom<6>#106	vbottom<6>#107	0.226767	$metal3
+ $W=6e-07
Rc891	vbottom<6>#94	vbottom<6>#76	0.337791	$metal3
+ $W=3e-07
Rc892	vbottom<6>#96	vbottom<6>#108	0.665112	$metal3
+ $W=3e-07
Rc893	vbottom<6>#108	vbottom<6>#109	0.556646	$metal3
+ $W=6e-07
Rc894	vbottom<6>#109	vbottom<6>#110	0.556646	$metal3
+ $W=6e-07
Rc895	vbottom<6>#110	vbottom<6>#111	0.025931	$metal3
+ $W=4.2e-06
Rc896	vbottom<6>#97	vbottom<6>#94	0.025931	$metal3
+ $W=4.2e-06
Rc897	vbottom<6>#97	vbottom<6>#95	0.025931	$metal3
+ $W=4.2e-06
Rc898	vbottom<6>#97	vbottom<6>#75	0.025931	$metal3
+ $W=4.2e-06
Rc899	vbottom<6>#98	vbottom<6>#20	0.215025	$metal3
+ $W=6e-07
Rc900	vbottom<6>#99	vbottom<6>#23	0.215025	$metal3
+ $W=6e-07
Rc901	vbottom<6>#100	vbottom<6>#26	0.215025	$metal3
+ $W=6e-07
Rc902	vbottom<6>#101	vbottom<6>#29	0.215025	$metal3
+ $W=6e-07
Rc903	vbottom<6>#102	vbottom<6>#32	0.215025	$metal3
+ $W=6e-07
Rc904	vbottom<6>#103	vbottom<6>#35	0.215025	$metal3
+ $W=6e-07
Rc905	vbottom<6>#104	vbottom<6>#38	0.215025	$metal3
+ $W=6e-07
Rc906	vbottom<6>#105	vbottom<6>#41	0.215025	$metal3
+ $W=6e-07
Rc907	vbottom<6>#106	vbottom<6>#112	0.192692	$metal3
+ $W=6e-07
Rc908	vbottom<6>#112	vbottom<6>#113	0.048308	$metal3
+ $W=3e-07
Rc909	vbottom<6>#113	vbottom<6>#114	0.700747	$metal3
+ $W=3e-07
Rc910	vbottom<6>#114	vbottom<6>#115	0.556646	$metal3
+ $W=3e-07
Rc911	vbottom<6>#115	vbottom<6>#116	0.025931	$metal3
+ $W=4.2e-06
Rc912	vbottom<6>#107	vbottom<6>#91	0.337203	$metal3
+ $W=3e-07
Rc913	vbottom<6>#107	vbottom<6>#117	0.330958	$metal3
+ $W=3e-07
Rc914	vbottom<6>#111	vbottom<6>#108	0.025931	$metal3
+ $W=4.2e-06
Rc915	vbottom<6>#111	vbottom<6>#109	0.025931	$metal3
+ $W=4.2e-06
Rc916	vbottom<6>#111	vbottom<6>#118	0.025931	$metal3
+ $W=4.2e-06
Rc917	vbottom<6>#118	vbottom<6>#119	0.226767	$metal3
+ $W=6e-07
Rc918	vbottom<6>#119	vbottom<6>#120	0.661227	$metal3
+ $W=3e-07
Rc919	vbottom<6>#113	vbottom<6>#93	0.022837	$metal3
+ $W=4.8e-06
Rc920	vbottom<6>#116	vbottom<6>#114	0.025931	$metal3
+ $W=4.2e-06
Rc921	vbottom<6>#116	vbottom<6>#121	0.025931	$metal3
+ $W=4.2e-06
Rc922	vbottom<6>#121	vbottom<6>#122	0.226767	$metal3
+ $W=6e-07
Rc923	vbottom<6>#117	vbottom<6>#77	0.330268	$metal3
+ $W=3e-07
Rc924	vbottom<6>#119	vbottom<6>#108	0.337203	$metal3
+ $W=3e-07
Rc925	vbottom<6>#120	vbottom<6>#75	0.345935	$metal3
+ $W=3e-07
Rc926	vbottom<6>#120	vbottom<6>#96	0.345935	$metal3
+ $W=3e-07
Rc927	vbottom<6>#120	vbottom<6>#123	0.672969	$metal3
+ $W=3e-07
Rc928	vbottom<6>#121	vbottom<6>#124	0.192692	$metal3
+ $W=6e-07
Rc929	vbottom<6>#124	vbottom<6>#125	0.048308	$metal3
+ $W=3e-07
Rc930	vbottom<6>#125	vbottom<6>#126	0.700747	$metal3
+ $W=3e-07
Rc931	vbottom<6>#126	vbottom<6>#127	0.556646	$metal3
+ $W=3e-07
Rc932	vbottom<6>#127	vbottom<6>#128	0.025931	$metal3
+ $W=4.2e-06
Rc933	vbottom<6>#122	vbottom<6>#114	0.337203	$metal3
+ $W=3e-07
Rc934	vbottom<6>#122	vbottom<6>#129	0.330958	$metal3
+ $W=3e-07
Rc935	vbottom<6>#123	vbottom<6>#74	0.337203	$metal3
+ $W=3e-07
Rc936	vbottom<6>#123	vbottom<6>#130	0.215025	$metal3
+ $W=6e-07
Rc937	vbottom<6>#130	vbottom<6>#131	0.025931	$metal3
+ $W=4.2e-06
Rc938	vbottom<6>#125	vbottom<6>#116	0.022837	$metal3
+ $W=4.8e-06
Rc939	vbottom<6>#128	vbottom<6>#126	0.025931	$metal3
+ $W=4.2e-06
Rc940	vbottom<6>#128	vbottom<6>#132	0.124229	$metal3
+ $W=4.8e-06
Rc941	vbottom<6>#129	vbottom<6>#112	0.341525	$metal3
+ $W=3e-07
Rc942	vbottom<6>#130	vbottom<6>#133	0.665112	$metal3
+ $W=3e-07
Rc943	vbottom<6>#133	vbottom<6>#134	0.556646	$metal3
+ $W=6e-07
Rc944	vbottom<6>#134	vbottom<6>#135	0.556646	$metal3
+ $W=6e-07
Rc945	vbottom<6>#135	vbottom<6>#136	0.025931	$metal3
+ $W=4.2e-06
Rc946	vbottom<6>#131	vbottom<6>#73	0.025931	$metal3
+ $W=4.2e-06
Rc947	vbottom<6>#131	vbottom<6>#74	0.025931	$metal3
+ $W=4.2e-06
Rc948	vbottom<6>#131	vbottom<6>#72	0.025931	$metal3
+ $W=4.2e-06
Rc949	vbottom<6>#132	vbottom<6>#126	0.337203	$metal3
+ $W=3e-07
Rc950	vbottom<6>#132	vbottom<6>#137	0.330958	$metal3
+ $W=3e-07
Rc951	vbottom<6>#136	vbottom<6>#133	0.025931	$metal3
+ $W=4.2e-06
Rc952	vbottom<6>#136	vbottom<6>#134	0.025931	$metal3
+ $W=4.2e-06
Rc953	vbottom<6>#136	vbottom<6>#138	0.025931	$metal3
+ $W=4.2e-06
Rc954	vbottom<6>#138	vbottom<6>#139	0.226767	$metal3
+ $W=6e-07
Rc955	vbottom<6>#139	vbottom<6>#140	0.661227	$metal3
+ $W=3e-07
Rc956	vbottom<6>#137	vbottom<6>#124	0.341525	$metal3
+ $W=3e-07
Rc957	vbottom<6>#139	vbottom<6>#133	0.337203	$metal3
+ $W=3e-07
Rc958	vbottom<6>#140	vbottom<6>#72	0.345935	$metal3
+ $W=3e-07
Rc959	vbottom<6>#140	vbottom<6>#130	0.345935	$metal3
+ $W=3e-07
Rc960	vbottom<6>#140	vbottom<6>#141	0.672969	$metal3
+ $W=3e-07
Rc961	vbottom<6>#141	vbottom<6>#71	0.337203	$metal3
+ $W=3e-07
Rc962	vbottom<6>#141	vbottom<6>#142	0.215025	$metal3
+ $W=6e-07
Rc963	vbottom<6>#142	vbottom<6>#143	0.025931	$metal3
+ $W=4.2e-06
Rc964	vbottom<6>#142	vbottom<6>#144	0.193867	$metal3
+ $W=6e-07
Rc965	vbottom<6>#143	vbottom<6>#70	0.025931	$metal3
+ $W=4.2e-06
Rc966	vbottom<6>#143	vbottom<6>#71	0.025931	$metal3
+ $W=4.2e-06
Rc967	vbottom<6>#143	vbottom<6>#69	0.025931	$metal3
+ $W=4.2e-06
Rc968	vbottom<6>#144	vbottom<6>#69	0.337203	$metal3
+ $W=3e-07
Rc969	vbottom<6>#144	vbottom<6>#145	0.685401	$metal3
+ $W=3e-07
Rc970	vbottom<6>#145	vbottom<6>#68	0.337203	$metal3
+ $W=3e-07
Rc971	vbottom<6>#145	vbottom<6>#146	0.215025	$metal3
+ $W=6e-07
Rc972	vbottom<6>#146	vbottom<6>#147	0.025931	$metal3
+ $W=4.2e-06
Rc973	vbottom<6>#146	vbottom<6>#148	0.193867	$metal3
+ $W=6e-07
Rc974	vbottom<6>#147	vbottom<6>#67	0.025931	$metal3
+ $W=4.2e-06
Rc975	vbottom<6>#147	vbottom<6>#68	0.025931	$metal3
+ $W=4.2e-06
Rc976	vbottom<6>#147	vbottom<6>#66	0.025931	$metal3
+ $W=4.2e-06
Rc977	vbottom<6>#148	vbottom<6>#66	0.337203	$metal3
+ $W=3e-07
Rc978	vbottom<6>#148	vbottom<6>#149	0.685401	$metal3
+ $W=3e-07
Rc979	vbottom<6>#149	vbottom<6>#65	0.337203	$metal3
+ $W=3e-07
Rc980	vbottom<6>#149	vbottom<6>#150	0.215025	$metal3
+ $W=6e-07
Rc981	vbottom<6>#150	vbottom<6>#151	0.025931	$metal3
+ $W=4.2e-06
Rc982	vbottom<6>#150	vbottom<6>#152	0.193867	$metal3
+ $W=6e-07
Rc983	vbottom<6>#151	vbottom<6>#64	0.025931	$metal3
+ $W=4.2e-06
Rc984	vbottom<6>#151	vbottom<6>#65	0.025931	$metal3
+ $W=4.2e-06
Rc985	vbottom<6>#151	vbottom<6>#63	0.025931	$metal3
+ $W=4.2e-06
Rc986	vbottom<6>#152	vbottom<6>#63	0.337203	$metal3
+ $W=3e-07
Rc987	vbottom<6>#152	vbottom<6>#153	0.685401	$metal3
+ $W=3e-07
Rc988	vbottom<6>#153	vbottom<6>#62	0.337203	$metal3
+ $W=3e-07
Rc989	vbottom<6>#153	vbottom<6>#154	0.215025	$metal3
+ $W=6e-07
Rc990	vbottom<6>#154	vbottom<6>#155	0.025931	$metal3
+ $W=4.2e-06
Rc991	vbottom<6>#154	vbottom<6>#156	0.193867	$metal3
+ $W=6e-07
Rc992	vbottom<6>#155	vbottom<6>#61	0.025931	$metal3
+ $W=4.2e-06
Rc993	vbottom<6>#155	vbottom<6>#62	0.025931	$metal3
+ $W=4.2e-06
Rc994	vbottom<6>#155	vbottom<6>#60	0.025931	$metal3
+ $W=4.2e-06
Rc995	vbottom<6>#156	vbottom<6>#60	0.337203	$metal3
+ $W=3e-07
Rc996	vbottom<6>#156	vbottom<6>#157	0.685401	$metal3
+ $W=3e-07
Rc997	vbottom<6>#157	vbottom<6>#59	0.337203	$metal3
+ $W=3e-07
Rc998	vbottom<6>#157	vbottom<6>#158	0.215025	$metal3
+ $W=6e-07
Rc999	vbottom<6>#158	vbottom<6>#159	0.025931	$metal3
+ $W=4.2e-06
Rc1000	vbottom<6>#158	vbottom<6>#160	0.193867	$metal3
+ $W=6e-07
Rc1001	vbottom<6>#159	vbottom<6>#58	0.025931	$metal3
+ $W=4.2e-06
Rc1002	vbottom<6>#159	vbottom<6>#59	0.025931	$metal3
+ $W=4.2e-06
Rc1003	vbottom<6>#159	vbottom<6>#57	0.025931	$metal3
+ $W=4.2e-06
Rc1004	vbottom<6>#160	vbottom<6>#57	0.337203	$metal3
+ $W=3e-07
Rc1005	vbottom<6>#160	vbottom<6>#161	0.685401	$metal3
+ $W=3e-07
Rc1006	vbottom<6>#161	vbottom<6>#56	0.337203	$metal3
+ $W=3e-07
Rc1007	vbottom<6>#161	vbottom<6>#162	0.215025	$metal3
+ $W=6e-07
Rc1008	vbottom<6>#162	vbottom<6>#163	0.025931	$metal3
+ $W=4.2e-06
Rc1009	vbottom<6>#162	vbottom<6>#164	0.193867	$metal3
+ $W=6e-07
Rc1010	vbottom<6>#163	vbottom<6>#55	0.025931	$metal3
+ $W=4.2e-06
Rc1011	vbottom<6>#163	vbottom<6>#56	0.025931	$metal3
+ $W=4.2e-06
Rc1012	vbottom<6>#163	vbottom<6>#54	0.025931	$metal3
+ $W=4.2e-06
Rc1013	vbottom<6>#164	vbottom<6>#54	0.337203	$metal3
+ $W=3e-07
Rc1014	vbottom<6>#164	vbottom<6>#165	0.685401	$metal3
+ $W=3e-07
Rc1015	vbottom<6>#165	vbottom<6>#53	0.337203	$metal3
+ $W=3e-07
Rc1016	vbottom<6>#165	vbottom<6>#166	0.215025	$metal3
+ $W=6e-07
Rc1017	vbottom<6>#166	vbottom<6>#167	0.025931	$metal3
+ $W=4.2e-06
Rc1018	vbottom<6>#166	vbottom<6>#168	0.193867	$metal3
+ $W=6e-07
Rc1019	vbottom<6>#167	vbottom<6>#52	0.025931	$metal3
+ $W=4.2e-06
Rc1020	vbottom<6>#167	vbottom<6>#53	0.025931	$metal3
+ $W=4.2e-06
Rc1021	vbottom<6>#167	vbottom<6>#51	0.025931	$metal3
+ $W=4.2e-06
Rc1022	vbottom<6>#168	vbottom<6>#51	0.337203	$metal3
+ $W=3e-07
Rc1023	vbottom<6>#168	vbottom<6>#169	0.685401	$metal3
+ $W=3e-07
Rc1024	vbottom<6>#169	vbottom<6>#50	0.337203	$metal3
+ $W=3e-07
Rc1025	vbottom<6>#169	vbottom<6>#170	0.215025	$metal3
+ $W=6e-07
Rc1026	vbottom<6>#170	vbottom<6>#171	0.025931	$metal3
+ $W=4.2e-06
Rc1027	vbottom<6>#170	vbottom<6>#172	0.193867	$metal3
+ $W=6e-07
Rc1028	vbottom<6>#171	vbottom<6>#49	0.025931	$metal3
+ $W=4.2e-06
Rc1029	vbottom<6>#171	vbottom<6>#50	0.025931	$metal3
+ $W=4.2e-06
Rc1030	vbottom<6>#171	vbottom<6>#48	0.025931	$metal3
+ $W=4.2e-06
Rc1031	vbottom<6>#172	vbottom<6>#48	0.337203	$metal3
+ $W=3e-07
Rc1032	vbottom<6>#172	vbottom<6>#173	0.672969	$metal3
+ $W=3e-07
Rc1033	vbottom<6>#173	vbottom<6>#47	0.345935	$metal3
+ $W=3e-07
Rc1034	vbottom<6>#173	vbottom<6>#174	0.660051	$metal3
+ $W=3e-07
Rc1035	vbottom<6>#174	vbottom<6>#175	0.225592	$metal3
+ $W=6e-07
Rc1036	vbottom<6>#175	vbottom<6>#176	0.180950	$metal3
+ $W=6e-07
Rc1037	vbottom<6>#176	vbottom<6>#177	0.671308	$metal3
+ $W=3e-07
Rc1038	vbottom<6>#177	vbottom<6>#178	0.225592	$metal3
+ $W=6e-07
Rc1039	vbottom<6>#178	vbottom<6>#179	0.180950	$metal3
+ $W=6e-07
Rc1040	vbottom<6>#179	vbottom<6>#180	0.671308	$metal3
+ $W=3e-07
Rc1041	vbottom<6>#180	vbottom<6>#181	0.225592	$metal3
+ $W=6e-07
Rc1042	vbottom<6>#181	vbottom<6>#182	0.180950	$metal3
+ $W=6e-07
Rc1043	vbottom<6>#182	vbottom<6>#183	0.671308	$metal3
+ $W=3e-07
Rc1044	vbottom<6>#183	vbottom<6>#184	0.225592	$metal3
+ $W=6e-07
Rc1045	vbottom<6>#184	vbottom<6>#185	0.180950	$metal3
+ $W=6e-07
Rc1046	vbottom<6>#185	vbottom<6>#186	0.671308	$metal3
+ $W=3e-07
Rc1047	vbottom<6>#186	vbottom<6>#187	0.225592	$metal3
+ $W=6e-07
Rc1048	vbottom<6>#187	vbottom<6>#188	0.180950	$metal3
+ $W=6e-07
Rc1049	vbottom<6>#188	vbottom<6>#189	0.671308	$metal3
+ $W=3e-07
Rc1050	vbottom<6>#189	vbottom<6>#190	0.225592	$metal3
+ $W=6e-07
Rc1051	vbottom<6>#190	vbottom<6>#191	0.180950	$metal3
+ $W=6e-07
Rc1052	vbottom<6>#191	vbottom<6>#192	0.671308	$metal3
+ $W=3e-07
Rc1053	vbottom<6>#192	vbottom<6>#193	0.225592	$metal3
+ $W=6e-07
Rc1054	vbottom<6>#193	vbottom<6>#194	0.180950	$metal3
+ $W=6e-07
Rc1055	vbottom<6>#194	vbottom<6>#195	0.671308	$metal3
+ $W=3e-07
Rc1056	vbottom<6>#195	vbottom<6>#196	0.225592	$metal3
+ $W=6e-07
Rc1057	vbottom<6>#196	vbottom<6>#197	0.180950	$metal3
+ $W=6e-07
Rc1058	vbottom<6>#197	vbottom<6>#198	0.671793	$metal3
+ $W=3e-07
Rc1059	vbottom<6>#198	vbottom<6>#199	0.672969	$metal3
+ $W=3e-07
Rc1060	vbottom<6>#199	vbottom<6>#200	0.215025	$metal3
+ $W=6e-07
Rc1061	vbottom<6>#200	vbottom<6>#201	0.193867	$metal3
+ $W=6e-07
Rc1062	vbottom<6>#201	vbottom<6>#202	0.685401	$metal3
+ $W=3e-07
Rc1063	vbottom<6>#202	vbottom<6>#203	0.215025	$metal3
+ $W=6e-07
Rc1064	vbottom<6>#203	vbottom<6>#204	0.192692	$metal3
+ $W=6e-07
Rc1065	vbottom<6>#204	vbottom<6>#205	0.684225	$metal3
+ $W=3e-07
Rc1066	vbottom<6>#205	vbottom<6>#206	0.215025	$metal3
+ $W=6e-07
Rc1067	vbottom<6>#206	vbottom<6>#207	0.193867	$metal3
+ $W=6e-07
Rc1068	vbottom<6>#207	vbottom<6>#208	0.685401	$metal3
+ $W=3e-07
Rc1069	vbottom<6>#208	vbottom<6>#209	0.215025	$metal3
+ $W=6e-07
Rc1070	vbottom<6>#209	vbottom<6>#210	0.193867	$metal3
+ $W=6e-07
Rc1071	vbottom<6>#210	vbottom<6>#211	0.685401	$metal3
+ $W=3e-07
Rc1072	vbottom<6>#211	vbottom<6>#212	0.215025	$metal3
+ $W=6e-07
Rc1073	vbottom<6>#212	vbottom<6>#213	0.193867	$metal3
+ $W=6e-07
Rc1074	vbottom<6>#213	vbottom<6>#214	0.685401	$metal3
+ $W=3e-07
Rc1075	vbottom<6>#214	vbottom<6>#215	0.215025	$metal3
+ $W=6e-07
Rc1076	vbottom<6>#215	vbottom<6>#216	0.193867	$metal3
+ $W=6e-07
Rc1077	vbottom<6>#216	vbottom<6>#217	0.685401	$metal3
+ $W=3e-07
Rc1078	vbottom<6>#217	vbottom<6>#218	0.215025	$metal3
+ $W=6e-07
Rc1079	vbottom<6>#218	vbottom<6>#219	0.193867	$metal3
+ $W=6e-07
Rc1080	vbottom<6>#219	vbottom<6>#220	0.685401	$metal3
+ $W=3e-07
Rc1081	vbottom<6>#220	vbottom<6>#221	0.215025	$metal3
+ $W=6e-07
Rc1082	vbottom<6>#221	vbottom<6>#222	0.193867	$metal3
+ $W=6e-07
Rc1083	vbottom<6>#222	vbottom<6>#223	0.672969	$metal3
+ $W=3e-07
Rc1084	vbottom<6>#223	vbottom<6>#224	0.671793	$metal3
+ $W=3e-07
Rc1085	vbottom<6>#224	vbottom<6>#225	0.213850	$metal3
+ $W=6e-07
Rc1086	vbottom<6>#225	vbottom<6>#226	0.192692	$metal3
+ $W=6e-07
Rc1087	vbottom<6>#226	vbottom<6>#227	0.671308	$metal3
+ $W=3e-07
Rc1088	vbottom<6>#227	vbottom<6>#228	0.213850	$metal3
+ $W=6e-07
Rc1089	vbottom<6>#228	vbottom<6>#229	0.192692	$metal3
+ $W=6e-07
Rc1090	vbottom<6>#229	vbottom<6>#230	0.671308	$metal3
+ $W=3e-07
Rc1091	vbottom<6>#230	vbottom<6>#231	0.213850	$metal3
+ $W=6e-07
Rc1092	vbottom<6>#231	vbottom<6>#232	0.192692	$metal3
+ $W=6e-07
Rc1093	vbottom<6>#232	vbottom<6>#233	0.671308	$metal3
+ $W=3e-07
Rc1094	vbottom<6>#233	vbottom<6>#234	0.213850	$metal3
+ $W=6e-07
Rc1095	vbottom<6>#234	vbottom<6>#235	0.192692	$metal3
+ $W=6e-07
Rc1096	vbottom<6>#235	vbottom<6>#236	0.671308	$metal3
+ $W=3e-07
Rc1097	vbottom<6>#236	vbottom<6>#237	0.213850	$metal3
+ $W=6e-07
Rc1098	vbottom<6>#237	vbottom<6>#238	0.192692	$metal3
+ $W=6e-07
Rc1099	vbottom<6>#238	vbottom<6>#239	0.671308	$metal3
+ $W=3e-07
Rc1100	vbottom<6>#239	vbottom<6>#240	0.213850	$metal3
+ $W=6e-07
Rc1101	vbottom<6>#240	vbottom<6>#241	0.192692	$metal3
+ $W=6e-07
Rc1102	vbottom<6>#241	vbottom<6>#242	0.671308	$metal3
+ $W=3e-07
Rc1103	vbottom<6>#242	vbottom<6>#243	0.213850	$metal3
+ $W=6e-07
Rc1104	vbottom<6>#243	vbottom<6>#244	0.192692	$metal3
+ $W=6e-07
Rc1105	vbottom<6>#244	vbottom<6>#245	0.672483	$metal3
+ $W=3e-07
Rc1106	vbottom<6>#204	vbottom<6>#246	0.337791	$metal3
+ $W=3e-07
Rc1107	vbottom<6>#246	vbottom<6>#247	0.556646	$metal3
+ $W=6e-07
Rc1108	vbottom<6>#247	vbottom<6>#248	0.025931	$metal3
+ $W=4.2e-06
Rc1109	vbottom<6>#244	vbottom<6>#249	0.337791	$metal3
+ $W=3e-07
Rc1110	vbottom<6>#249	vbottom<6>#250	0.315692	$metal3
+ $W=3e-07
Rc1111	vbottom<6>#245	vbottom<6>#138	0.182125	$metal3
+ $W=6e-07
Rc1112	vbottom<6>#245	vbottom<6>#135	0.337203	$metal3
+ $W=3e-07
Rc1113	vbottom<6>#248	vbottom<6>#203	0.025931	$metal3
+ $W=4.2e-06
Rc1114	vbottom<6>#248	vbottom<6>#246	0.025931	$metal3
+ $W=4.2e-06
Rc1115	vbottom<6>#248	vbottom<6>#251	0.025931	$metal3
+ $W=4.2e-06
Rc1116	vbottom<6>#249	vbottom<6>#252	0.556646	$metal3
+ $W=6e-07
Rc1117	vbottom<6>#252	vbottom<6>#253	0.556646	$metal3
+ $W=6e-07
Rc1118	vbottom<6>#253	vbottom<6>#254	0.025931	$metal3
+ $W=4.2e-06
Rc1119	vbottom<6>#250	vbottom<6>#135	0.349420	$metal3
+ $W=3e-07
Rc1120	vbottom<6>#251	vbottom<6>#202	0.337203	$metal3
+ $W=3e-07
Rc1121	vbottom<6>#251	vbottom<6>#255	0.337203	$metal3
+ $W=3e-07
Rc1122	vbottom<6>#251	vbottom<6>#256	0.698840	$metal3
+ $W=3e-07
Rc1123	vbottom<6>#253	vbottom<6>#257	0.665112	$metal3
+ $W=3e-07
Rc1124	vbottom<6>#257	vbottom<6>#258	0.556646	$metal3
+ $W=6e-07
Rc1125	vbottom<6>#258	vbottom<6>#259	0.556646	$metal3
+ $W=6e-07
Rc1126	vbottom<6>#259	vbottom<6>#260	0.025931	$metal3
+ $W=4.2e-06
Rc1127	vbottom<6>#253	vbottom<6>#242	0.337791	$metal3
+ $W=3e-07
Rc1128	vbottom<6>#254	vbottom<6>#249	0.025931	$metal3
+ $W=4.2e-06
Rc1129	vbottom<6>#254	vbottom<6>#252	0.025931	$metal3
+ $W=4.2e-06
Rc1130	vbottom<6>#254	vbottom<6>#243	0.025931	$metal3
+ $W=4.2e-06
Rc1131	vbottom<6>#255	vbottom<6>#247	0.215025	$metal3
+ $W=6e-07
Rc1132	vbottom<6>#256	vbottom<6>#201	0.337203	$metal3
+ $W=3e-07
Rc1133	vbottom<6>#256	vbottom<6>#261	0.556646	$metal3
+ $W=6e-07
Rc1134	vbottom<6>#261	vbottom<6>#262	0.025931	$metal3
+ $W=4.2e-06
Rc1135	vbottom<6>#257	vbottom<6>#241	0.337791	$metal3
+ $W=3e-07
Rc1136	vbottom<6>#259	vbottom<6>#263	0.665112	$metal3
+ $W=3e-07
Rc1137	vbottom<6>#263	vbottom<6>#264	0.556646	$metal3
+ $W=6e-07
Rc1138	vbottom<6>#264	vbottom<6>#265	0.556646	$metal3
+ $W=6e-07
Rc1139	vbottom<6>#265	vbottom<6>#266	0.025931	$metal3
+ $W=4.2e-06
Rc1140	vbottom<6>#259	vbottom<6>#239	0.337791	$metal3
+ $W=3e-07
Rc1141	vbottom<6>#260	vbottom<6>#257	0.025931	$metal3
+ $W=4.2e-06
Rc1142	vbottom<6>#260	vbottom<6>#258	0.025931	$metal3
+ $W=4.2e-06
Rc1143	vbottom<6>#260	vbottom<6>#240	0.025931	$metal3
+ $W=4.2e-06
Rc1144	vbottom<6>#262	vbottom<6>#200	0.025931	$metal3
+ $W=4.2e-06
Rc1145	vbottom<6>#262	vbottom<6>#256	0.025931	$metal3
+ $W=4.2e-06
Rc1146	vbottom<6>#262	vbottom<6>#267	0.025931	$metal3
+ $W=4.2e-06
Rc1147	vbottom<6>#263	vbottom<6>#238	0.337791	$metal3
+ $W=3e-07
Rc1148	vbottom<6>#265	vbottom<6>#268	0.665112	$metal3
+ $W=3e-07
Rc1149	vbottom<6>#268	vbottom<6>#269	0.556646	$metal3
+ $W=6e-07
Rc1150	vbottom<6>#269	vbottom<6>#270	0.556646	$metal3
+ $W=6e-07
Rc1151	vbottom<6>#270	vbottom<6>#271	0.025931	$metal3
+ $W=4.2e-06
Rc1152	vbottom<6>#265	vbottom<6>#236	0.337791	$metal3
+ $W=3e-07
Rc1153	vbottom<6>#266	vbottom<6>#263	0.025931	$metal3
+ $W=4.2e-06
Rc1154	vbottom<6>#266	vbottom<6>#264	0.025931	$metal3
+ $W=4.2e-06
Rc1155	vbottom<6>#266	vbottom<6>#237	0.025931	$metal3
+ $W=4.2e-06
Rc1156	vbottom<6>#267	vbottom<6>#199	0.337203	$metal3
+ $W=3e-07
Rc1157	vbottom<6>#267	vbottom<6>#272	0.337203	$metal3
+ $W=3e-07
Rc1158	vbottom<6>#267	vbottom<6>#273	0.698840	$metal3
+ $W=3e-07
Rc1159	vbottom<6>#268	vbottom<6>#235	0.337791	$metal3
+ $W=3e-07
Rc1160	vbottom<6>#270	vbottom<6>#274	0.665112	$metal3
+ $W=3e-07
Rc1161	vbottom<6>#274	vbottom<6>#275	0.556646	$metal3
+ $W=6e-07
Rc1162	vbottom<6>#275	vbottom<6>#276	0.556646	$metal3
+ $W=6e-07
Rc1163	vbottom<6>#276	vbottom<6>#277	0.025931	$metal3
+ $W=4.2e-06
Rc1164	vbottom<6>#270	vbottom<6>#233	0.337791	$metal3
+ $W=3e-07
Rc1165	vbottom<6>#271	vbottom<6>#268	0.025931	$metal3
+ $W=4.2e-06
Rc1166	vbottom<6>#271	vbottom<6>#269	0.025931	$metal3
+ $W=4.2e-06
Rc1167	vbottom<6>#271	vbottom<6>#234	0.025931	$metal3
+ $W=4.2e-06
Rc1168	vbottom<6>#272	vbottom<6>#261	0.215025	$metal3
+ $W=6e-07
Rc1169	vbottom<6>#273	vbottom<6>#198	0.345935	$metal3
+ $W=3e-07
Rc1170	vbottom<6>#273	vbottom<6>#278	0.556646	$metal3
+ $W=6e-07
Rc1171	vbottom<6>#278	vbottom<6>#279	0.025931	$metal3
+ $W=4.2e-06
Rc1172	vbottom<6>#279	vbottom<6>#280	0.025931	$metal3
+ $W=4.2e-06
Rc1173	vbottom<6>#280	vbottom<6>#281	0.665112	$metal3
+ $W=3e-07
Rc1174	vbottom<6>#281	vbottom<6>#282	0.025931	$metal3
+ $W=4.2e-06
Rc1175	vbottom<6>#282	vbottom<6>#283	0.025931	$metal3
+ $W=4.2e-06
Rc1176	vbottom<6>#283	vbottom<6>#284	0.665112	$metal3
+ $W=3e-07
Rc1177	vbottom<6>#284	vbottom<6>#285	0.025931	$metal3
+ $W=4.2e-06
Rc1178	vbottom<6>#285	vbottom<6>#286	0.025931	$metal3
+ $W=4.2e-06
Rc1179	vbottom<6>#286	vbottom<6>#287	0.665112	$metal3
+ $W=3e-07
Rc1180	vbottom<6>#287	vbottom<6>#288	0.025931	$metal3
+ $W=4.2e-06
Rc1181	vbottom<6>#288	vbottom<6>#289	0.025931	$metal3
+ $W=4.2e-06
Rc1182	vbottom<6>#289	vbottom<6>#290	0.665112	$metal3
+ $W=3e-07
Rc1183	vbottom<6>#290	vbottom<6>#291	0.025931	$metal3
+ $W=4.2e-06
Rc1184	vbottom<6>#291	vbottom<6>#292	0.025931	$metal3
+ $W=4.2e-06
Rc1185	vbottom<6>#292	vbottom<6>#293	0.665112	$metal3
+ $W=3e-07
Rc1186	vbottom<6>#293	vbottom<6>#294	0.025931	$metal3
+ $W=4.2e-06
Rc1187	vbottom<6>#294	vbottom<6>#295	0.025931	$metal3
+ $W=4.2e-06
Rc1188	vbottom<6>#295	vbottom<6>#296	0.665112	$metal3
+ $W=3e-07
Rc1189	vbottom<6>#296	vbottom<6>#297	0.025931	$metal3
+ $W=4.2e-06
Rc1190	vbottom<6>#297	vbottom<6>#298	0.025931	$metal3
+ $W=4.2e-06
Rc1191	vbottom<6>#298	vbottom<6>#299	0.665112	$metal3
+ $W=3e-07
Rc1192	vbottom<6>#299	vbottom<6>#300	0.025931	$metal3
+ $W=4.2e-06
Rc1193	vbottom<6>#300	vbottom<6>#301	0.025931	$metal3
+ $W=4.2e-06
Rc1194	vbottom<6>#301	vbottom<6>#302	0.665112	$metal3
+ $W=3e-07
Rc1195	vbottom<6>#302	vbottom<6>#303	0.025931	$metal3
+ $W=4.2e-06
Rc1196	vbottom<6>#303	vbottom<6>#304	0.025931	$metal3
+ $W=4.2e-06
Rc1197	vbottom<6>#304	vbottom<6>#305	0.665112	$metal3
+ $W=3e-07
Rc1198	vbottom<6>#305	vbottom<6>#306	0.025931	$metal3
+ $W=4.2e-06
Rc1199	vbottom<6>#274	vbottom<6>#232	0.337791	$metal3
+ $W=3e-07
Rc1200	vbottom<6>#276	vbottom<6>#307	0.665112	$metal3
+ $W=3e-07
Rc1201	vbottom<6>#307	vbottom<6>#308	0.556646	$metal3
+ $W=6e-07
Rc1202	vbottom<6>#308	vbottom<6>#309	0.556646	$metal3
+ $W=6e-07
Rc1203	vbottom<6>#309	vbottom<6>#310	0.025931	$metal3
+ $W=4.2e-06
Rc1204	vbottom<6>#276	vbottom<6>#230	0.337791	$metal3
+ $W=3e-07
Rc1205	vbottom<6>#277	vbottom<6>#274	0.025931	$metal3
+ $W=4.2e-06
Rc1206	vbottom<6>#277	vbottom<6>#275	0.025931	$metal3
+ $W=4.2e-06
Rc1207	vbottom<6>#277	vbottom<6>#231	0.025931	$metal3
+ $W=4.2e-06
Rc1208	vbottom<6>#279	vbottom<6>#273	0.025931	$metal3
+ $W=4.2e-06
Rc1209	vbottom<6>#280	vbottom<6>#198	0.345935	$metal3
+ $W=3e-07
Rc1210	vbottom<6>#281	vbottom<6>#197	0.337791	$metal3
+ $W=3e-07
Rc1211	vbottom<6>#282	vbottom<6>#196	0.025931	$metal3
+ $W=4.2e-06
Rc1212	vbottom<6>#283	vbottom<6>#195	0.337791	$metal3
+ $W=3e-07
Rc1213	vbottom<6>#283	vbottom<6>#311	0.556646	$metal3
+ $W=6e-07
Rc1214	vbottom<6>#284	vbottom<6>#194	0.337791	$metal3
+ $W=3e-07
Rc1215	vbottom<6>#285	vbottom<6>#193	0.025931	$metal3
+ $W=4.2e-06
Rc1216	vbottom<6>#286	vbottom<6>#192	0.337791	$metal3
+ $W=3e-07
Rc1217	vbottom<6>#286	vbottom<6>#312	0.556646	$metal3
+ $W=6e-07
Rc1218	vbottom<6>#287	vbottom<6>#191	0.337791	$metal3
+ $W=3e-07
Rc1219	vbottom<6>#288	vbottom<6>#190	0.025931	$metal3
+ $W=4.2e-06
Rc1220	vbottom<6>#289	vbottom<6>#189	0.337791	$metal3
+ $W=3e-07
Rc1221	vbottom<6>#289	vbottom<6>#313	0.556646	$metal3
+ $W=6e-07
Rc1222	vbottom<6>#290	vbottom<6>#188	0.337791	$metal3
+ $W=3e-07
Rc1223	vbottom<6>#291	vbottom<6>#187	0.025931	$metal3
+ $W=4.2e-06
Rc1224	vbottom<6>#292	vbottom<6>#186	0.337791	$metal3
+ $W=3e-07
Rc1225	vbottom<6>#292	vbottom<6>#314	0.556646	$metal3
+ $W=6e-07
Rc1226	vbottom<6>#293	vbottom<6>#185	0.337791	$metal3
+ $W=3e-07
Rc1227	vbottom<6>#294	vbottom<6>#184	0.025931	$metal3
+ $W=4.2e-06
Rc1228	vbottom<6>#295	vbottom<6>#183	0.337791	$metal3
+ $W=3e-07
Rc1229	vbottom<6>#295	vbottom<6>#315	0.556646	$metal3
+ $W=6e-07
Rc1230	vbottom<6>#296	vbottom<6>#182	0.337791	$metal3
+ $W=3e-07
Rc1231	vbottom<6>#297	vbottom<6>#181	0.025931	$metal3
+ $W=4.2e-06
Rc1232	vbottom<6>#298	vbottom<6>#180	0.337791	$metal3
+ $W=3e-07
Rc1233	vbottom<6>#298	vbottom<6>#316	0.556646	$metal3
+ $W=6e-07
Rc1234	vbottom<6>#299	vbottom<6>#179	0.337791	$metal3
+ $W=3e-07
Rc1235	vbottom<6>#300	vbottom<6>#178	0.025931	$metal3
+ $W=4.2e-06
Rc1236	vbottom<6>#301	vbottom<6>#177	0.337791	$metal3
+ $W=3e-07
Rc1237	vbottom<6>#301	vbottom<6>#317	0.556646	$metal3
+ $W=6e-07
Rc1238	vbottom<6>#302	vbottom<6>#176	0.337791	$metal3
+ $W=3e-07
Rc1239	vbottom<6>#303	vbottom<6>#175	0.025931	$metal3
+ $W=4.2e-06
Rc1240	vbottom<6>#304	vbottom<6>#174	0.337791	$metal3
+ $W=3e-07
Rc1241	vbottom<6>#304	vbottom<6>#318	0.556646	$metal3
+ $W=6e-07
Rc1242	vbottom<6>#305	vbottom<6>#173	0.345935	$metal3
+ $W=3e-07
Rc1243	vbottom<6>#305	vbottom<6>#319	0.226767	$metal3
+ $W=6e-07
Rc1244	vbottom<6>#306	vbottom<6>#46	0.025931	$metal3
+ $W=4.2e-06
Rc1245	vbottom<6>#306	vbottom<6>#47	0.025931	$metal3
+ $W=4.2e-06
Rc1246	vbottom<6>#306	vbottom<6>#45	0.025931	$metal3
+ $W=4.2e-06
Rc1247	vbottom<6>#307	vbottom<6>#229	0.337791	$metal3
+ $W=3e-07
Rc1248	vbottom<6>#309	vbottom<6>#320	0.665112	$metal3
+ $W=3e-07
Rc1249	vbottom<6>#320	vbottom<6>#321	0.556646	$metal3
+ $W=6e-07
Rc1250	vbottom<6>#321	vbottom<6>#322	0.556646	$metal3
+ $W=6e-07
Rc1251	vbottom<6>#322	vbottom<6>#323	0.025931	$metal3
+ $W=4.2e-06
Rc1252	vbottom<6>#309	vbottom<6>#227	0.337791	$metal3
+ $W=3e-07
Rc1253	vbottom<6>#310	vbottom<6>#307	0.025931	$metal3
+ $W=4.2e-06
Rc1254	vbottom<6>#310	vbottom<6>#308	0.025931	$metal3
+ $W=4.2e-06
Rc1255	vbottom<6>#310	vbottom<6>#228	0.025931	$metal3
+ $W=4.2e-06
Rc1256	vbottom<6>#311	vbottom<6>#282	0.025931	$metal3
+ $W=4.2e-06
Rc1257	vbottom<6>#311	vbottom<6>#324	0.337203	$metal3
+ $W=3e-07
Rc1258	vbottom<6>#312	vbottom<6>#285	0.025931	$metal3
+ $W=4.2e-06
Rc1259	vbottom<6>#312	vbottom<6>#325	0.337203	$metal3
+ $W=3e-07
Rc1260	vbottom<6>#313	vbottom<6>#288	0.025931	$metal3
+ $W=4.2e-06
Rc1261	vbottom<6>#313	vbottom<6>#326	0.337203	$metal3
+ $W=3e-07
Rc1262	vbottom<6>#314	vbottom<6>#291	0.025931	$metal3
+ $W=4.2e-06
Rc1263	vbottom<6>#314	vbottom<6>#327	0.337203	$metal3
+ $W=3e-07
Rc1264	vbottom<6>#315	vbottom<6>#294	0.025931	$metal3
+ $W=4.2e-06
Rc1265	vbottom<6>#315	vbottom<6>#328	0.337203	$metal3
+ $W=3e-07
Rc1266	vbottom<6>#316	vbottom<6>#297	0.025931	$metal3
+ $W=4.2e-06
Rc1267	vbottom<6>#316	vbottom<6>#329	0.337203	$metal3
+ $W=3e-07
Rc1268	vbottom<6>#317	vbottom<6>#300	0.025931	$metal3
+ $W=4.2e-06
Rc1269	vbottom<6>#317	vbottom<6>#330	0.337203	$metal3
+ $W=3e-07
Rc1270	vbottom<6>#318	vbottom<6>#303	0.025931	$metal3
+ $W=4.2e-06
Rc1271	vbottom<6>#318	vbottom<6>#331	0.337203	$metal3
+ $W=3e-07
Rc1272	vbottom<6>#319	vbottom<6>#45	0.337203	$metal3
+ $W=3e-07
Rc1273	vbottom<6>#319	vbottom<6>#332	0.672969	$metal3
+ $W=3e-07
Rc1274	vbottom<6>#320	vbottom<6>#226	0.337791	$metal3
+ $W=3e-07
Rc1275	vbottom<6>#322	vbottom<6>#333	0.665112	$metal3
+ $W=3e-07
Rc1276	vbottom<6>#333	vbottom<6>#334	0.226767	$metal3
+ $W=6e-07
Rc1277	vbottom<6>#334	vbottom<6>#335	0.672969	$metal3
+ $W=3e-07
Rc1278	vbottom<6>#335	vbottom<6>#336	0.671793	$metal3
+ $W=3e-07
Rc1279	vbottom<6>#336	vbottom<6>#337	0.213850	$metal3
+ $W=6e-07
Rc1280	vbottom<6>#337	vbottom<6>#338	0.192692	$metal3
+ $W=6e-07
Rc1281	vbottom<6>#338	vbottom<6>#339	0.671308	$metal3
+ $W=3e-07
Rc1282	vbottom<6>#339	vbottom<6>#340	0.213850	$metal3
+ $W=6e-07
Rc1283	vbottom<6>#340	vbottom<6>#341	0.192692	$metal3
+ $W=6e-07
Rc1284	vbottom<6>#341	vbottom<6>#342	0.671308	$metal3
+ $W=3e-07
Rc1285	vbottom<6>#342	vbottom<6>#343	0.213850	$metal3
+ $W=6e-07
Rc1286	vbottom<6>#343	vbottom<6>#344	0.192692	$metal3
+ $W=6e-07
Rc1287	vbottom<6>#344	vbottom<6>#345	0.671308	$metal3
+ $W=3e-07
Rc1288	vbottom<6>#345	vbottom<6>#346	0.213850	$metal3
+ $W=6e-07
Rc1289	vbottom<6>#346	vbottom<6>#347	0.192692	$metal3
+ $W=6e-07
Rc1290	vbottom<6>#347	vbottom<6>#348	0.671308	$metal3
+ $W=3e-07
Rc1291	vbottom<6>#348	vbottom<6>#349	0.213850	$metal3
+ $W=6e-07
Rc1292	vbottom<6>#349	vbottom<6>#350	0.192692	$metal3
+ $W=6e-07
Rc1293	vbottom<6>#350	vbottom<6>#351	0.671308	$metal3
+ $W=3e-07
Rc1294	vbottom<6>#351	vbottom<6>#352	0.213850	$metal3
+ $W=6e-07
Rc1295	vbottom<6>#352	vbottom<6>#353	0.192692	$metal3
+ $W=6e-07
Rc1296	vbottom<6>#353	vbottom<6>#354	0.671308	$metal3
+ $W=3e-07
Rc1297	vbottom<6>#354	vbottom<6>#355	0.213850	$metal3
+ $W=6e-07
Rc1298	vbottom<6>#355	vbottom<6>#356	0.192692	$metal3
+ $W=6e-07
Rc1299	vbottom<6>#356	vbottom<6>#357	0.672483	$metal3
+ $W=3e-07
Rc1300	vbottom<6>#322	vbottom<6>#224	0.337791	$metal3
+ $W=3e-07
Rc1301	vbottom<6>#323	vbottom<6>#320	0.025931	$metal3
+ $W=4.2e-06
Rc1302	vbottom<6>#323	vbottom<6>#321	0.025931	$metal3
+ $W=4.2e-06
Rc1303	vbottom<6>#323	vbottom<6>#225	0.025931	$metal3
+ $W=4.2e-06
Rc1304	vbottom<6>#324	vbottom<6>#281	0.215025	$metal3
+ $W=6e-07
Rc1305	vbottom<6>#325	vbottom<6>#284	0.215025	$metal3
+ $W=6e-07
Rc1306	vbottom<6>#326	vbottom<6>#287	0.215025	$metal3
+ $W=6e-07
Rc1307	vbottom<6>#327	vbottom<6>#290	0.215025	$metal3
+ $W=6e-07
Rc1308	vbottom<6>#328	vbottom<6>#293	0.215025	$metal3
+ $W=6e-07
Rc1309	vbottom<6>#329	vbottom<6>#296	0.215025	$metal3
+ $W=6e-07
Rc1310	vbottom<6>#330	vbottom<6>#299	0.215025	$metal3
+ $W=6e-07
Rc1311	vbottom<6>#331	vbottom<6>#302	0.215025	$metal3
+ $W=6e-07
Rc1312	vbottom<6>#332	vbottom<6>#44	0.345935	$metal3
+ $W=3e-07
Rc1313	vbottom<6>#332	vbottom<6>#358	0.661227	$metal3
+ $W=3e-07
Rc1314	vbottom<6>#358	vbottom<6>#359	0.226767	$metal3
+ $W=6e-07
Rc1315	vbottom<6>#359	vbottom<6>#360	0.182125	$metal3
+ $W=6e-07
Rc1316	vbottom<6>#360	vbottom<6>#361	0.673659	$metal3
+ $W=3e-07
Rc1317	vbottom<6>#361	vbottom<6>#362	0.226767	$metal3
+ $W=6e-07
Rc1318	vbottom<6>#362	vbottom<6>#363	0.182125	$metal3
+ $W=6e-07
Rc1319	vbottom<6>#363	vbottom<6>#364	0.673659	$metal3
+ $W=3e-07
Rc1320	vbottom<6>#364	vbottom<6>#365	0.226767	$metal3
+ $W=6e-07
Rc1321	vbottom<6>#365	vbottom<6>#366	0.182125	$metal3
+ $W=6e-07
Rc1322	vbottom<6>#366	vbottom<6>#367	0.673659	$metal3
+ $W=3e-07
Rc1323	vbottom<6>#367	vbottom<6>#368	0.226767	$metal3
+ $W=6e-07
Rc1324	vbottom<6>#368	vbottom<6>#369	0.182125	$metal3
+ $W=6e-07
Rc1325	vbottom<6>#369	vbottom<6>#370	0.673659	$metal3
+ $W=3e-07
Rc1326	vbottom<6>#370	vbottom<6>#371	0.226767	$metal3
+ $W=6e-07
Rc1327	vbottom<6>#371	vbottom<6>#372	0.182125	$metal3
+ $W=6e-07
Rc1328	vbottom<6>#372	vbottom<6>#373	0.673659	$metal3
+ $W=3e-07
Rc1329	vbottom<6>#373	vbottom<6>#374	0.226767	$metal3
+ $W=6e-07
Rc1330	vbottom<6>#374	vbottom<6>#375	0.182125	$metal3
+ $W=6e-07
Rc1331	vbottom<6>#375	vbottom<6>#376	0.673659	$metal3
+ $W=3e-07
Rc1332	vbottom<6>#376	vbottom<6>#377	0.226767	$metal3
+ $W=6e-07
Rc1333	vbottom<6>#377	vbottom<6>#378	0.182125	$metal3
+ $W=6e-07
Rc1334	vbottom<6>#378	vbottom<6>#379	0.673659	$metal3
+ $W=3e-07
Rc1335	vbottom<6>#379	vbottom<6>#380	0.226767	$metal3
+ $W=6e-07
Rc1336	vbottom<6>#380	vbottom<6>#381	0.180950	$metal3
+ $W=6e-07
Rc1337	vbottom<6>#381	vbottom<6>#382	0.671793	$metal3
+ $W=3e-07
Rc1338	vbottom<6>#382	vbottom<6>#383	0.672969	$metal3
+ $W=3e-07
Rc1339	vbottom<6>#383	vbottom<6>#384	0.337203	$metal3
+ $W=3e-07
Rc1340	vbottom<6>#332	vbottom<6>#41	0.345935	$metal3
+ $W=3e-07
Rc1341	vbottom<6>#333	vbottom<6>#223	0.345935	$metal3
+ $W=3e-07
Rc1342	vbottom<6>#356	vbottom<6>#385	0.337791	$metal3
+ $W=3e-07
Rc1343	vbottom<6>#385	vbottom<6>#386	0.315692	$metal3
+ $W=3e-07
Rc1344	vbottom<6>#357	vbottom<6>#118	0.182125	$metal3
+ $W=6e-07
Rc1345	vbottom<6>#357	vbottom<6>#110	0.337203	$metal3
+ $W=3e-07
Rc1346	vbottom<6>#358	vbottom<6>#40	0.337203	$metal3
+ $W=3e-07
Rc1347	vbottom<6>#359	vbottom<6>#39	0.025931	$metal3
+ $W=4.2e-06
Rc1348	vbottom<6>#360	vbottom<6>#38	0.337203	$metal3
+ $W=3e-07
Rc1349	vbottom<6>#361	vbottom<6>#37	0.337203	$metal3
+ $W=3e-07
Rc1350	vbottom<6>#362	vbottom<6>#36	0.025931	$metal3
+ $W=4.2e-06
Rc1351	vbottom<6>#363	vbottom<6>#35	0.337203	$metal3
+ $W=3e-07
Rc1352	vbottom<6>#364	vbottom<6>#34	0.337203	$metal3
+ $W=3e-07
Rc1353	vbottom<6>#365	vbottom<6>#33	0.025931	$metal3
+ $W=4.2e-06
Rc1354	vbottom<6>#366	vbottom<6>#32	0.337203	$metal3
+ $W=3e-07
Rc1355	vbottom<6>#367	vbottom<6>#31	0.337203	$metal3
+ $W=3e-07
Rc1356	vbottom<6>#368	vbottom<6>#30	0.025931	$metal3
+ $W=4.2e-06
Rc1357	vbottom<6>#369	vbottom<6>#29	0.337203	$metal3
+ $W=3e-07
Rc1358	vbottom<6>#370	vbottom<6>#28	0.337203	$metal3
+ $W=3e-07
Rc1359	vbottom<6>#371	vbottom<6>#27	0.025931	$metal3
+ $W=4.2e-06
Rc1360	vbottom<6>#372	vbottom<6>#26	0.337203	$metal3
+ $W=3e-07
Rc1361	vbottom<6>#373	vbottom<6>#25	0.337203	$metal3
+ $W=3e-07
Rc1362	vbottom<6>#374	vbottom<6>#24	0.025931	$metal3
+ $W=4.2e-06
Rc1363	vbottom<6>#375	vbottom<6>#23	0.337203	$metal3
+ $W=3e-07
Rc1364	vbottom<6>#376	vbottom<6>#22	0.337203	$metal3
+ $W=3e-07
Rc1365	vbottom<6>#377	vbottom<6>#21	0.025931	$metal3
+ $W=4.2e-06
Rc1366	vbottom<6>#378	vbottom<6>#20	0.337203	$metal3
+ $W=3e-07
Rc1367	vbottom<6>#379	vbottom<6>#18	0.337203	$metal3
+ $W=3e-07
Rc1368	vbottom<6>#383	vbottom<6>#280	0.215025	$metal3
+ $W=6e-07
Rc1369	vbottom<6>#384	vbottom<6>#279	0.025931	$metal3
+ $W=4.2e-06
Rc1370	vbottom<6>#384	vbottom<6>#387	0.337203	$metal3
+ $W=3e-07
Rc1371	vbottom<6>#384	vbottom<6>#388	0.698840	$metal3
+ $W=3e-07
Rc1372	vbottom<6>#385	vbottom<6>#389	0.556646	$metal3
+ $W=6e-07
Rc1373	vbottom<6>#389	vbottom<6>#390	0.556646	$metal3
+ $W=6e-07
Rc1374	vbottom<6>#390	vbottom<6>#391	0.025931	$metal3
+ $W=4.2e-06
Rc1375	vbottom<6>#386	vbottom<6>#110	0.349420	$metal3
+ $W=3e-07
Rc1376	vbottom<6>#387	vbottom<6>#278	0.215025	$metal3
+ $W=6e-07
Rc1377	vbottom<6>#388	vbottom<6>#382	0.345935	$metal3
+ $W=3e-07
Rc1378	vbottom<6>#388	vbottom<6>#392	0.213850	$metal3
+ $W=6e-07
Rc1379	vbottom<6>#392	vbottom<6>#393	0.671793	$metal3
+ $W=3e-07
Rc1380	vbottom<6>#393	vbottom<6>#394	0.672969	$metal3
+ $W=3e-07
Rc1381	vbottom<6>#394	vbottom<6>#395	0.215025	$metal3
+ $W=6e-07
Rc1382	vbottom<6>#395	vbottom<6>#396	0.193867	$metal3
+ $W=6e-07
Rc1383	vbottom<6>#396	vbottom<6>#397	0.685401	$metal3
+ $W=3e-07
Rc1384	vbottom<6>#397	vbottom<6>#398	0.215025	$metal3
+ $W=6e-07
Rc1385	vbottom<6>#398	vbottom<6>#399	0.193867	$metal3
+ $W=6e-07
Rc1386	vbottom<6>#399	vbottom<6>#400	0.685401	$metal3
+ $W=3e-07
Rc1387	vbottom<6>#400	vbottom<6>#401	0.215025	$metal3
+ $W=6e-07
Rc1388	vbottom<6>#401	vbottom<6>#402	0.523746	$metal3
+ $W=6e-07
Rc1389	vbottom<6>#402	vbottom<6>#403	0.556646	$metal3
+ $W=6e-07
Rc1390	vbottom<6>#403	vbottom<6>#404	0.025931	$metal3
+ $W=4.2e-06
Rc1391	vbottom<6>#390	vbottom<6>#405	0.665112	$metal3
+ $W=3e-07
Rc1392	vbottom<6>#405	vbottom<6>#406	0.556646	$metal3
+ $W=6e-07
Rc1393	vbottom<6>#406	vbottom<6>#407	0.556646	$metal3
+ $W=6e-07
Rc1394	vbottom<6>#407	vbottom<6>#408	0.025931	$metal3
+ $W=4.2e-06
Rc1395	vbottom<6>#390	vbottom<6>#354	0.337791	$metal3
+ $W=3e-07
Rc1396	vbottom<6>#391	vbottom<6>#385	0.025931	$metal3
+ $W=4.2e-06
Rc1397	vbottom<6>#391	vbottom<6>#389	0.025931	$metal3
+ $W=4.2e-06
Rc1398	vbottom<6>#391	vbottom<6>#355	0.025931	$metal3
+ $W=4.2e-06
Rc1399	vbottom<6>#404	vbottom<6>#401	0.025931	$metal3
+ $W=4.2e-06
Rc1400	vbottom<6>#404	vbottom<6>#402	0.025931	$metal3
+ $W=4.2e-06
Rc1401	vbottom<6>#404	vbottom<6>#409	0.025931	$metal3
+ $W=4.2e-06
Rc1402	vbottom<6>#405	vbottom<6>#353	0.337791	$metal3
+ $W=3e-07
Rc1403	vbottom<6>#407	vbottom<6>#410	0.665112	$metal3
+ $W=3e-07
Rc1404	vbottom<6>#410	vbottom<6>#411	0.556646	$metal3
+ $W=6e-07
Rc1405	vbottom<6>#411	vbottom<6>#412	0.556646	$metal3
+ $W=6e-07
Rc1406	vbottom<6>#412	vbottom<6>#413	0.025931	$metal3
+ $W=4.2e-06
Rc1407	vbottom<6>#407	vbottom<6>#351	0.337791	$metal3
+ $W=3e-07
Rc1408	vbottom<6>#408	vbottom<6>#405	0.025931	$metal3
+ $W=4.2e-06
Rc1409	vbottom<6>#408	vbottom<6>#406	0.025931	$metal3
+ $W=4.2e-06
Rc1410	vbottom<6>#408	vbottom<6>#352	0.025931	$metal3
+ $W=4.2e-06
Rc1411	vbottom<6>#409	vbottom<6>#400	0.337203	$metal3
+ $W=3e-07
Rc1412	vbottom<6>#409	vbottom<6>#414	0.337203	$metal3
+ $W=3e-07
Rc1413	vbottom<6>#409	vbottom<6>#415	0.698840	$metal3
+ $W=3e-07
Rc1414	vbottom<6>#410	vbottom<6>#350	0.337791	$metal3
+ $W=3e-07
Rc1415	vbottom<6>#412	vbottom<6>#416	0.665112	$metal3
+ $W=3e-07
Rc1416	vbottom<6>#416	vbottom<6>#417	0.556646	$metal3
+ $W=6e-07
Rc1417	vbottom<6>#417	vbottom<6>#418	0.556646	$metal3
+ $W=6e-07
Rc1418	vbottom<6>#418	vbottom<6>#419	0.025931	$metal3
+ $W=4.2e-06
Rc1419	vbottom<6>#412	vbottom<6>#348	0.337791	$metal3
+ $W=3e-07
Rc1420	vbottom<6>#413	vbottom<6>#410	0.025931	$metal3
+ $W=4.2e-06
Rc1421	vbottom<6>#413	vbottom<6>#411	0.025931	$metal3
+ $W=4.2e-06
Rc1422	vbottom<6>#413	vbottom<6>#349	0.025931	$metal3
+ $W=4.2e-06
Rc1423	vbottom<6>#414	vbottom<6>#403	0.215025	$metal3
+ $W=6e-07
Rc1424	vbottom<6>#415	vbottom<6>#399	0.337203	$metal3
+ $W=3e-07
Rc1425	vbottom<6>#415	vbottom<6>#420	0.556646	$metal3
+ $W=6e-07
Rc1426	vbottom<6>#420	vbottom<6>#421	0.025931	$metal3
+ $W=4.2e-06
Rc1427	vbottom<6>#416	vbottom<6>#347	0.337791	$metal3
+ $W=3e-07
Rc1428	vbottom<6>#418	vbottom<6>#422	0.665112	$metal3
+ $W=3e-07
Rc1429	vbottom<6>#422	vbottom<6>#423	0.556646	$metal3
+ $W=6e-07
Rc1430	vbottom<6>#423	vbottom<6>#424	0.556646	$metal3
+ $W=6e-07
Rc1431	vbottom<6>#424	vbottom<6>#425	0.025931	$metal3
+ $W=4.2e-06
Rc1432	vbottom<6>#418	vbottom<6>#345	0.337791	$metal3
+ $W=3e-07
Rc1433	vbottom<6>#419	vbottom<6>#416	0.025931	$metal3
+ $W=4.2e-06
Rc1434	vbottom<6>#419	vbottom<6>#417	0.025931	$metal3
+ $W=4.2e-06
Rc1435	vbottom<6>#419	vbottom<6>#346	0.025931	$metal3
+ $W=4.2e-06
Rc1436	vbottom<6>#421	vbottom<6>#398	0.025931	$metal3
+ $W=4.2e-06
Rc1437	vbottom<6>#421	vbottom<6>#415	0.025931	$metal3
+ $W=4.2e-06
Rc1438	vbottom<6>#421	vbottom<6>#426	0.025929	$metal3
+ $W=4.2e-06
Rc1439	vbottom<6>#422	vbottom<6>#344	0.337791	$metal3
+ $W=3e-07
Rc1440	vbottom<6>#424	vbottom<6>#427	0.665112	$metal3
+ $W=3e-07
Rc1441	vbottom<6>#427	vbottom<6>#428	0.556646	$metal3
+ $W=6e-07
Rc1442	vbottom<6>#428	vbottom<6>#429	0.556646	$metal3
+ $W=6e-07
Rc1443	vbottom<6>#429	vbottom<6>#430	0.025931	$metal3
+ $W=4.2e-06
Rc1444	vbottom<6>#424	vbottom<6>#342	0.337791	$metal3
+ $W=3e-07
Rc1445	vbottom<6>#425	vbottom<6>#422	0.025931	$metal3
+ $W=4.2e-06
Rc1446	vbottom<6>#425	vbottom<6>#423	0.025931	$metal3
+ $W=4.2e-06
Rc1447	vbottom<6>#425	vbottom<6>#343	0.025931	$metal3
+ $W=4.2e-06
Rc1448	vbottom<6>#426	vbottom<6>#397	0.337203	$metal3
+ $W=3e-07
Rc1449	vbottom<6>#426	vbottom<6>#431	0.337203	$metal3
+ $W=3e-07
Rc1450	vbottom<6>#426	vbottom<6>#432	0.694969	$metal3
+ $W=3e-07
Rc1451	vbottom<6>#427	vbottom<6>#341	0.337791	$metal3
+ $W=3e-07
Rc1452	vbottom<6>#429	vbottom<6>#433	0.665112	$metal3
+ $W=3e-07
Rc1453	vbottom<6>#433	vbottom<6>#434	0.556646	$metal3
+ $W=6e-07
Rc1454	vbottom<6>#434	vbottom<6>#435	0.556646	$metal3
+ $W=6e-07
Rc1455	vbottom<6>#435	vbottom<6>#436	0.025931	$metal3
+ $W=4.2e-06
Rc1456	vbottom<6>#429	vbottom<6>#339	0.337791	$metal3
+ $W=3e-07
Rc1457	vbottom<6>#430	vbottom<6>#427	0.025931	$metal3
+ $W=4.2e-06
Rc1458	vbottom<6>#430	vbottom<6>#428	0.025931	$metal3
+ $W=4.2e-06
Rc1459	vbottom<6>#430	vbottom<6>#340	0.025931	$metal3
+ $W=4.2e-06
Rc1460	vbottom<6>#431	vbottom<6>#420	0.215025	$metal3
+ $W=6e-07
Rc1461	vbottom<6>#432	vbottom<6>#396	0.337203	$metal3
+ $W=3e-07
Rc1462	vbottom<6>#432	vbottom<6>#437	0.556646	$metal3
+ $W=6e-07
Rc1463	vbottom<6>#437	vbottom<6>#438	0.025931	$metal3
+ $W=4.2e-06
Rc1464	vbottom<6>#433	vbottom<6>#338	0.337791	$metal3
+ $W=3e-07
Rc1465	vbottom<6>#435	vbottom<6>#439	0.665112	$metal3
+ $W=3e-07
Rc1466	vbottom<6>#439	vbottom<6>#440	0.556646	$metal3
+ $W=6e-07
Rc1467	vbottom<6>#440	vbottom<6>#441	0.556646	$metal3
+ $W=6e-07
Rc1468	vbottom<6>#441	vbottom<6>#442	0.025931	$metal3
+ $W=4.2e-06
Rc1469	vbottom<6>#435	vbottom<6>#336	0.337791	$metal3
+ $W=3e-07
Rc1470	vbottom<6>#436	vbottom<6>#433	0.025931	$metal3
+ $W=4.2e-06
Rc1471	vbottom<6>#436	vbottom<6>#434	0.025931	$metal3
+ $W=4.2e-06
Rc1472	vbottom<6>#436	vbottom<6>#337	0.025931	$metal3
+ $W=4.2e-06
Rc1473	vbottom<6>#438	vbottom<6>#395	0.025931	$metal3
+ $W=4.2e-06
Rc1474	vbottom<6>#438	vbottom<6>#432	0.025929	$metal3
+ $W=4.2e-06
Rc1475	vbottom<6>#438	vbottom<6>#443	0.025931	$metal3
+ $W=4.2e-06
Rc1476	vbottom<6>#439	vbottom<6>#335	0.345935	$metal3
+ $W=3e-07
Rc1477	vbottom<6>#442	vbottom<6>#439	0.025931	$metal3
+ $W=4.2e-06
Rc1478	vbottom<6>#442	vbottom<6>#440	0.025931	$metal3
+ $W=4.2e-06
Rc1479	vbottom<6>#442	vbottom<6>#444	0.025931	$metal3
+ $W=4.2e-06
Rc1480	vbottom<6>#443	vbottom<6>#394	0.337203	$metal3
+ $W=3e-07
Rc1481	vbottom<6>#443	vbottom<6>#445	0.337203	$metal3
+ $W=3e-07
Rc1482	vbottom<6>#443	vbottom<6>#446	0.698840	$metal3
+ $W=3e-07
Rc1483	vbottom<6>#444	vbottom<6>#335	0.345935	$metal3
+ $W=3e-07
Rc1484	vbottom<6>#444	vbottom<6>#447	0.337203	$metal3
+ $W=3e-07
Rc1485	vbottom<6>#444	vbottom<6>#448	0.698840	$metal3
+ $W=3e-07
Rc1486	vbottom<6>#445	vbottom<6>#437	0.215025	$metal3
+ $W=6e-07
Rc1487	vbottom<6>#446	vbottom<6>#393	0.345935	$metal3
+ $W=3e-07
Rc1488	vbottom<6>#446	vbottom<6>#449	0.556646	$metal3
+ $W=6e-07
Rc1489	vbottom<6>#449	vbottom<6>#450	0.025931	$metal3
+ $W=4.2e-06
Rc1490	vbottom<6>#450	vbottom<6>#451	0.025931	$metal3
+ $W=4.2e-06
Rc1491	vbottom<6>#451	vbottom<6>#452	0.665112	$metal3
+ $W=3e-07
Rc1492	vbottom<6>#452	vbottom<6>#453	0.025931	$metal3
+ $W=4.2e-06
Rc1493	vbottom<6>#453	vbottom<6>#454	0.025931	$metal3
+ $W=4.2e-06
Rc1494	vbottom<6>#454	vbottom<6>#455	0.665112	$metal3
+ $W=3e-07
Rc1495	vbottom<6>#455	vbottom<6>#456	0.025931	$metal3
+ $W=4.2e-06
Rc1496	vbottom<6>#447	vbottom<6>#441	0.215025	$metal3
+ $W=6e-07
Rc1497	vbottom<6>#448	vbottom<6>#334	0.337203	$metal3
+ $W=3e-07
Rc1498	vbottom<6>#448	vbottom<6>#457	0.556646	$metal3
+ $W=6e-07
Rc1499	vbottom<6>#457	vbottom<6>#458	0.025931	$metal3
+ $W=4.2e-06
Rc1500	vbottom<6>#450	vbottom<6>#446	0.025931	$metal3
+ $W=4.2e-06
Rc1501	vbottom<6>#451	vbottom<6>#393	0.345935	$metal3
+ $W=3e-07
Rc1502	vbottom<6>#451	vbottom<6>#459	0.556646	$metal3
+ $W=6e-07
Rc1503	vbottom<6>#452	vbottom<6>#392	0.337791	$metal3
+ $W=3e-07
Rc1504	vbottom<6>#453	vbottom<6>#388	0.025931	$metal3
+ $W=4.2e-06
Rc1505	vbottom<6>#454	vbottom<6>#382	0.345935	$metal3
+ $W=3e-07
Rc1506	vbottom<6>#454	vbottom<6>#460	0.556646	$metal3
+ $W=6e-07
Rc1507	vbottom<6>#455	vbottom<6>#381	0.337791	$metal3
+ $W=3e-07
Rc1508	vbottom<6>#456	vbottom<6>#18	0.025931	$metal3
+ $W=4.2e-06
Rc1509	vbottom<6>#456	vbottom<6>#380	0.025931	$metal3
+ $W=4.2e-06
Rc1510	vbottom<6>#456	vbottom<6>#461	0.025931	$metal3
+ $W=4.2e-06
Rc1511	vbottom<6>#458	vbottom<6>#333	0.025931	$metal3
+ $W=4.2e-06
Rc1512	vbottom<6>#458	vbottom<6>#448	0.025931	$metal3
+ $W=4.2e-06
Rc1513	vbottom<6>#458	vbottom<6>#462	0.025931	$metal3
+ $W=4.2e-06
Rc1514	vbottom<6>#459	vbottom<6>#450	0.025931	$metal3
+ $W=4.2e-06
Rc1515	vbottom<6>#459	vbottom<6>#463	0.337203	$metal3
+ $W=3e-07
Rc1516	vbottom<6>#460	vbottom<6>#453	0.025931	$metal3
+ $W=4.2e-06
Rc1517	vbottom<6>#460	vbottom<6>#464	0.337203	$metal3
+ $W=3e-07
Rc1518	vbottom<6>#461	vbottom<6>#17	0.225592	$metal3
+ $W=6e-07
Rc1519	vbottom<6>#461	vbottom<6>#465	0.337203	$metal3
+ $W=3e-07
Rc1520	vbottom<6>#462	vbottom<6>#223	0.345935	$metal3
+ $W=3e-07
Rc1521	vbottom<6>#462	vbottom<6>#466	0.337203	$metal3
+ $W=3e-07
Rc1522	vbottom<6>#462	vbottom<6>#467	0.698840	$metal3
+ $W=3e-07
Rc1523	vbottom<6>#463	vbottom<6>#449	0.215025	$metal3
+ $W=6e-07
Rc1524	vbottom<6>#464	vbottom<6>#452	0.215025	$metal3
+ $W=6e-07
Rc1525	vbottom<6>#465	vbottom<6>#455	0.215025	$metal3
+ $W=6e-07
Rc1526	vbottom<6>#466	vbottom<6>#457	0.215025	$metal3
+ $W=6e-07
Rc1527	vbottom<6>#467	vbottom<6>#222	0.337203	$metal3
+ $W=3e-07
Rc1528	vbottom<6>#467	vbottom<6>#468	0.556646	$metal3
+ $W=6e-07
Rc1529	vbottom<6>#468	vbottom<6>#469	0.025931	$metal3
+ $W=4.2e-06
Rc1530	vbottom<6>#469	vbottom<6>#221	0.025931	$metal3
+ $W=4.2e-06
Rc1531	vbottom<6>#469	vbottom<6>#467	0.025931	$metal3
+ $W=4.2e-06
Rc1532	vbottom<6>#469	vbottom<6>#470	0.025931	$metal3
+ $W=4.2e-06
Rc1533	vbottom<6>#470	vbottom<6>#220	0.337203	$metal3
+ $W=3e-07
Rc1534	vbottom<6>#470	vbottom<6>#471	0.337203	$metal3
+ $W=3e-07
Rc1535	vbottom<6>#470	vbottom<6>#472	0.698840	$metal3
+ $W=3e-07
Rc1536	vbottom<6>#471	vbottom<6>#468	0.215025	$metal3
+ $W=6e-07
Rc1537	vbottom<6>#472	vbottom<6>#219	0.337203	$metal3
+ $W=3e-07
Rc1538	vbottom<6>#472	vbottom<6>#473	0.556646	$metal3
+ $W=6e-07
Rc1539	vbottom<6>#473	vbottom<6>#474	0.025931	$metal3
+ $W=4.2e-06
Rc1540	vbottom<6>#474	vbottom<6>#218	0.025931	$metal3
+ $W=4.2e-06
Rc1541	vbottom<6>#474	vbottom<6>#472	0.025931	$metal3
+ $W=4.2e-06
Rc1542	vbottom<6>#474	vbottom<6>#475	0.025931	$metal3
+ $W=4.2e-06
Rc1543	vbottom<6>#475	vbottom<6>#217	0.337203	$metal3
+ $W=3e-07
Rc1544	vbottom<6>#475	vbottom<6>#476	0.337203	$metal3
+ $W=3e-07
Rc1545	vbottom<6>#475	vbottom<6>#477	0.698840	$metal3
+ $W=3e-07
Rc1546	vbottom<6>#476	vbottom<6>#473	0.215025	$metal3
+ $W=6e-07
Rc1547	vbottom<6>#477	vbottom<6>#216	0.337203	$metal3
+ $W=3e-07
Rc1548	vbottom<6>#477	vbottom<6>#478	0.556646	$metal3
+ $W=6e-07
Rc1549	vbottom<6>#478	vbottom<6>#479	0.025931	$metal3
+ $W=4.2e-06
Rc1550	vbottom<6>#479	vbottom<6>#215	0.025931	$metal3
+ $W=4.2e-06
Rc1551	vbottom<6>#479	vbottom<6>#477	0.025931	$metal3
+ $W=4.2e-06
Rc1552	vbottom<6>#479	vbottom<6>#480	0.025931	$metal3
+ $W=4.2e-06
Rc1553	vbottom<6>#480	vbottom<6>#214	0.337203	$metal3
+ $W=3e-07
Rc1554	vbottom<6>#480	vbottom<6>#481	0.337203	$metal3
+ $W=3e-07
Rc1555	vbottom<6>#480	vbottom<6>#482	0.698840	$metal3
+ $W=3e-07
Rc1556	vbottom<6>#481	vbottom<6>#478	0.215025	$metal3
+ $W=6e-07
Rc1557	vbottom<6>#482	vbottom<6>#213	0.337203	$metal3
+ $W=3e-07
Rc1558	vbottom<6>#482	vbottom<6>#483	0.556646	$metal3
+ $W=6e-07
Rc1559	vbottom<6>#483	vbottom<6>#484	0.025931	$metal3
+ $W=4.2e-06
Rc1560	vbottom<6>#484	vbottom<6>#212	0.025931	$metal3
+ $W=4.2e-06
Rc1561	vbottom<6>#484	vbottom<6>#482	0.025931	$metal3
+ $W=4.2e-06
Rc1562	vbottom<6>#484	vbottom<6>#485	0.025931	$metal3
+ $W=4.2e-06
Rc1563	vbottom<6>#485	vbottom<6>#211	0.337203	$metal3
+ $W=3e-07
Rc1564	vbottom<6>#485	vbottom<6>#486	0.337203	$metal3
+ $W=3e-07
Rc1565	vbottom<6>#485	vbottom<6>#487	0.698840	$metal3
+ $W=3e-07
Rc1566	vbottom<6>#486	vbottom<6>#483	0.215025	$metal3
+ $W=6e-07
Rc1567	vbottom<6>#487	vbottom<6>#210	0.337203	$metal3
+ $W=3e-07
Rc1568	vbottom<6>#487	vbottom<6>#488	0.556646	$metal3
+ $W=6e-07
Rc1569	vbottom<6>#488	vbottom<6>#489	0.025931	$metal3
+ $W=4.2e-06
Rc1570	vbottom<6>#489	vbottom<6>#209	0.025931	$metal3
+ $W=4.2e-06
Rc1571	vbottom<6>#489	vbottom<6>#487	0.025931	$metal3
+ $W=4.2e-06
Rc1572	vbottom<6>#489	vbottom<6>#490	0.025931	$metal3
+ $W=4.2e-06
Rc1573	vbottom<6>#490	vbottom<6>#208	0.337203	$metal3
+ $W=3e-07
Rc1574	vbottom<6>#490	vbottom<6>#491	0.337203	$metal3
+ $W=3e-07
Rc1575	vbottom<6>#490	vbottom<6>#492	0.698840	$metal3
+ $W=3e-07
Rc1576	vbottom<6>#491	vbottom<6>#488	0.215025	$metal3
+ $W=6e-07
Rc1577	vbottom<6>#492	vbottom<6>#207	0.337203	$metal3
+ $W=3e-07
Rc1578	vbottom<6>#492	vbottom<6>#493	0.556646	$metal3
+ $W=6e-07
Rc1579	vbottom<6>#493	vbottom<6>#494	0.025931	$metal3
+ $W=4.2e-06
Rc1580	vbottom<6>#494	vbottom<6>#206	0.025931	$metal3
+ $W=4.2e-06
Rc1581	vbottom<6>#494	vbottom<6>#492	0.025931	$metal3
+ $W=4.2e-06
Rc1582	vbottom<6>#494	vbottom<6>#495	0.025931	$metal3
+ $W=4.2e-06
Rc1583	vbottom<6>#495	vbottom<6>#205	0.337203	$metal3
+ $W=3e-07
Rc1584	vbottom<6>#495	vbottom<6>#496	0.337203	$metal3
+ $W=3e-07
Rc1585	vbottom<6>#496	vbottom<6>#493	0.215025	$metal3
+ $W=6e-07
Rc1586	vbottom<7>#15	vbottom<7>#17	3.659100	$metal3
+ $W=3e-07
Rc1587	vbottom<7>#17	vbottom<7>#18	0.337791	$metal3
+ $W=3e-07
Rc1588	vbottom<7>#18	vbottom<7>#14	0.438675	$metal3
+ $W=3e-07
Rc1589	vbottom<7>#14	vbottom<7>#20	0.221737	$metal3
+ $W=3e-07
Rc1590	vbottom<7>#20	vbottom<7>#21	0.025931	$metal3
+ $W=4.2e-06
Rc1591	vbottom<7>#21	vbottom<7>#22	0.025931	$metal3
+ $W=4.2e-06
Rc1592	vbottom<7>#22	vbottom<7>#23	0.665112	$metal3
+ $W=3e-07
Rc1593	vbottom<7>#23	vbottom<7>#24	0.025931	$metal3
+ $W=4.2e-06
Rc1594	vbottom<7>#24	vbottom<7>#25	0.025931	$metal3
+ $W=4.2e-06
Rc1595	vbottom<7>#25	vbottom<7>#26	0.665112	$metal3
+ $W=3e-07
Rc1596	vbottom<7>#26	vbottom<7>#27	0.025931	$metal3
+ $W=4.2e-06
Rc1597	vbottom<7>#27	vbottom<7>#28	0.025931	$metal3
+ $W=4.2e-06
Rc1598	vbottom<7>#28	vbottom<7>#29	0.665112	$metal3
+ $W=3e-07
Rc1599	vbottom<7>#29	vbottom<7>#30	0.025931	$metal3
+ $W=4.2e-06
Rc1600	vbottom<7>#30	vbottom<7>#31	0.025931	$metal3
+ $W=4.2e-06
Rc1601	vbottom<7>#31	vbottom<7>#32	0.665112	$metal3
+ $W=3e-07
Rc1602	vbottom<7>#32	vbottom<7>#33	0.025931	$metal3
+ $W=4.2e-06
Rc1603	vbottom<7>#33	vbottom<7>#34	0.025931	$metal3
+ $W=4.2e-06
Rc1604	vbottom<7>#34	vbottom<7>#35	0.665112	$metal3
+ $W=3e-07
Rc1605	vbottom<7>#35	vbottom<7>#36	0.025931	$metal3
+ $W=4.2e-06
Rc1606	vbottom<7>#36	vbottom<7>#37	0.025931	$metal3
+ $W=4.2e-06
Rc1607	vbottom<7>#37	vbottom<7>#38	0.665112	$metal3
+ $W=3e-07
Rc1608	vbottom<7>#38	vbottom<7>#39	0.025931	$metal3
+ $W=4.2e-06
Rc1609	vbottom<7>#39	vbottom<7>#40	0.025931	$metal3
+ $W=4.2e-06
Rc1610	vbottom<7>#40	vbottom<7>#41	0.665112	$metal3
+ $W=3e-07
Rc1611	vbottom<7>#41	vbottom<7>#42	0.025931	$metal3
+ $W=4.2e-06
Rc1612	vbottom<7>#42	vbottom<7>#43	0.025931	$metal3
+ $W=4.2e-06
Rc1613	vbottom<7>#43	vbottom<7>#44	0.665112	$metal3
+ $W=3e-07
Rc1614	vbottom<7>#44	vbottom<7>#45	0.025931	$metal3
+ $W=4.2e-06
Rc1615	vbottom<7>#45	vbottom<7>#46	0.025931	$metal3
+ $W=4.2e-06
Rc1616	vbottom<7>#46	vbottom<7>#47	0.665112	$metal3
+ $W=3e-07
Rc1617	vbottom<7>#47	vbottom<7>#48	0.025931	$metal3
+ $W=4.2e-06
Rc1618	vbottom<7>#48	vbottom<7>#49	0.025931	$metal3
+ $W=4.2e-06
Rc1619	vbottom<7>#49	vbottom<7>#50	0.665112	$metal3
+ $W=3e-07
Rc1620	vbottom<7>#50	vbottom<7>#51	0.025931	$metal3
+ $W=4.2e-06
Rc1621	vbottom<7>#51	vbottom<7>#52	0.025931	$metal3
+ $W=4.2e-06
Rc1622	vbottom<7>#52	vbottom<7>#53	0.665112	$metal3
+ $W=3e-07
Rc1623	vbottom<7>#53	vbottom<7>#54	0.025931	$metal3
+ $W=4.2e-06
Rc1624	vbottom<7>#54	vbottom<7>#55	0.025931	$metal3
+ $W=4.2e-06
Rc1625	vbottom<7>#55	vbottom<7>#56	0.556646	$metal3
+ $W=6e-07
Rc1626	vbottom<7>#56	vbottom<7>#57	0.664836	$metal3
+ $W=3e-07
Rc1627	vbottom<7>#57	vbottom<7>#58	0.556646	$metal3
+ $W=3e-07
Rc1628	vbottom<7>#58	vbottom<7>#59	0.523746	$metal3
+ $W=6e-07
Rc1629	vbottom<7>#59	vbottom<7>#60	0.698840	$metal3
+ $W=3e-07
Rc1630	vbottom<7>#60	vbottom<7>#61	0.556646	$metal3
+ $W=3e-07
Rc1631	vbottom<7>#61	vbottom<7>#62	0.523746	$metal3
+ $W=6e-07
Rc1632	vbottom<7>#62	vbottom<7>#63	0.698840	$metal3
+ $W=3e-07
Rc1633	vbottom<7>#63	vbottom<7>#64	0.556646	$metal3
+ $W=3e-07
Rc1634	vbottom<7>#64	vbottom<7>#65	0.523746	$metal3
+ $W=6e-07
Rc1635	vbottom<7>#65	vbottom<7>#66	0.698840	$metal3
+ $W=3e-07
Rc1636	vbottom<7>#66	vbottom<7>#67	0.556646	$metal3
+ $W=3e-07
Rc1637	vbottom<7>#67	vbottom<7>#68	0.523746	$metal3
+ $W=6e-07
Rc1638	vbottom<7>#68	vbottom<7>#69	0.698840	$metal3
+ $W=3e-07
Rc1639	vbottom<7>#69	vbottom<7>#70	0.556646	$metal3
+ $W=3e-07
Rc1640	vbottom<7>#70	vbottom<7>#71	0.523746	$metal3
+ $W=6e-07
Rc1641	vbottom<7>#71	vbottom<7>#72	0.698840	$metal3
+ $W=3e-07
Rc1642	vbottom<7>#72	vbottom<7>#73	0.556646	$metal3
+ $W=3e-07
Rc1643	vbottom<7>#73	vbottom<7>#74	0.523746	$metal3
+ $W=6e-07
Rc1644	vbottom<7>#74	vbottom<7>#75	0.698840	$metal3
+ $W=3e-07
Rc1645	vbottom<7>#75	vbottom<7>#76	0.556646	$metal3
+ $W=3e-07
Rc1646	vbottom<7>#76	vbottom<7>#77	0.523746	$metal3
+ $W=6e-07
Rc1647	vbottom<7>#77	vbottom<7>#78	0.698840	$metal3
+ $W=3e-07
Rc1648	vbottom<7>#78	vbottom<7>#79	0.556646	$metal3
+ $W=3e-07
Rc1649	vbottom<7>#79	vbottom<7>#80	0.523746	$metal3
+ $W=6e-07
Rc1650	vbottom<7>#80	vbottom<7>#81	0.698840	$metal3
+ $W=3e-07
Rc1651	vbottom<7>#81	vbottom<7>#82	0.556646	$metal3
+ $W=3e-07
Rc1652	vbottom<7>#82	vbottom<7>#83	0.523746	$metal3
+ $W=6e-07
Rc1653	vbottom<7>#83	vbottom<7>#84	0.698840	$metal3
+ $W=3e-07
Rc1654	vbottom<7>#84	vbottom<7>#85	0.556646	$metal3
+ $W=3e-07
Rc1655	vbottom<7>#85	vbottom<7>#86	0.523746	$metal3
+ $W=6e-07
Rc1656	vbottom<7>#86	vbottom<7>#87	0.698840	$metal3
+ $W=3e-07
Rc1657	vbottom<7>#87	vbottom<7>#88	0.556646	$metal3
+ $W=3e-07
Rc1658	vbottom<7>#88	vbottom<7>#89	0.523746	$metal3
+ $W=6e-07
Rc1659	vbottom<7>#89	vbottom<7>#90	0.698840	$metal3
+ $W=3e-07
Rc1660	vbottom<7>#90	vbottom<7>#91	0.556646	$metal3
+ $W=3e-07
Rc1661	vbottom<7>#91	vbottom<7>#92	0.523746	$metal3
+ $W=6e-07
Rc1662	vbottom<7>#92	vbottom<7>#93	0.698840	$metal3
+ $W=3e-07
Rc1663	vbottom<7>#93	vbottom<7>#94	0.556646	$metal3
+ $W=3e-07
Rc1664	vbottom<7>#94	vbottom<7>#95	0.523746	$metal3
+ $W=6e-07
Rc1665	vbottom<7>#95	vbottom<7>#96	0.698840	$metal3
+ $W=3e-07
Rc1666	vbottom<7>#96	vbottom<7>#97	0.556646	$metal3
+ $W=3e-07
Rc1667	vbottom<7>#97	vbottom<7>#98	0.523746	$metal3
+ $W=6e-07
Rc1668	vbottom<7>#98	vbottom<7>#99	0.698840	$metal3
+ $W=3e-07
Rc1669	vbottom<7>#99	vbottom<7>#100	0.556646	$metal3
+ $W=3e-07
Rc1670	vbottom<7>#100	vbottom<7>#101	0.523746	$metal3
+ $W=6e-07
Rc1671	vbottom<7>#101	vbottom<7>#102	0.556646	$metal3
+ $W=6e-07
Rc1672	vbottom<7>#102	vbottom<7>#103	0.025931	$metal3
+ $W=4.2e-06
Rc1673	vbottom<7>#22	vbottom<7>#104	0.556646	$metal3
+ $W=6e-07
Rc1674	vbottom<7>#25	vbottom<7>#105	0.556646	$metal3
+ $W=6e-07
Rc1675	vbottom<7>#28	vbottom<7>#106	0.556646	$metal3
+ $W=6e-07
Rc1676	vbottom<7>#31	vbottom<7>#107	0.556646	$metal3
+ $W=6e-07
Rc1677	vbottom<7>#34	vbottom<7>#108	0.556646	$metal3
+ $W=6e-07
Rc1678	vbottom<7>#37	vbottom<7>#109	0.556646	$metal3
+ $W=6e-07
Rc1679	vbottom<7>#40	vbottom<7>#110	0.556646	$metal3
+ $W=6e-07
Rc1680	vbottom<7>#43	vbottom<7>#111	0.556646	$metal3
+ $W=6e-07
Rc1681	vbottom<7>#46	vbottom<7>#112	0.556646	$metal3
+ $W=6e-07
Rc1682	vbottom<7>#49	vbottom<7>#113	0.556646	$metal3
+ $W=6e-07
Rc1683	vbottom<7>#52	vbottom<7>#114	0.556646	$metal3
+ $W=6e-07
Rc1684	vbottom<7>#55	vbottom<7>#115	0.523746	$metal3
+ $W=6e-07
Rc1685	vbottom<7>#56	vbottom<7>#54	0.025894	$metal3
+ $W=4.2e-06
Rc1686	vbottom<7>#102	vbottom<7>#116	0.665112	$metal3
+ $W=3e-07
Rc1687	vbottom<7>#116	vbottom<7>#117	0.556646	$metal3
+ $W=6e-07
Rc1688	vbottom<7>#117	vbottom<7>#118	0.556646	$metal3
+ $W=6e-07
Rc1689	vbottom<7>#118	vbottom<7>#119	0.025931	$metal3
+ $W=4.2e-06
Rc1690	vbottom<7>#103	vbottom<7>#100	0.025931	$metal3
+ $W=4.2e-06
Rc1691	vbottom<7>#103	vbottom<7>#101	0.025931	$metal3
+ $W=4.2e-06
Rc1692	vbottom<7>#103	vbottom<7>#99	0.025931	$metal3
+ $W=4.2e-06
Rc1693	vbottom<7>#104	vbottom<7>#21	0.025931	$metal3
+ $W=4.2e-06
Rc1694	vbottom<7>#104	vbottom<7>#120	0.337203	$metal3
+ $W=3e-07
Rc1695	vbottom<7>#105	vbottom<7>#24	0.025931	$metal3
+ $W=4.2e-06
Rc1696	vbottom<7>#105	vbottom<7>#121	0.337203	$metal3
+ $W=3e-07
Rc1697	vbottom<7>#106	vbottom<7>#27	0.025931	$metal3
+ $W=4.2e-06
Rc1698	vbottom<7>#106	vbottom<7>#122	0.337203	$metal3
+ $W=3e-07
Rc1699	vbottom<7>#107	vbottom<7>#30	0.025931	$metal3
+ $W=4.2e-06
Rc1700	vbottom<7>#107	vbottom<7>#123	0.337203	$metal3
+ $W=3e-07
Rc1701	vbottom<7>#108	vbottom<7>#33	0.025931	$metal3
+ $W=4.2e-06
Rc1702	vbottom<7>#108	vbottom<7>#124	0.337203	$metal3
+ $W=3e-07
Rc1703	vbottom<7>#109	vbottom<7>#36	0.025931	$metal3
+ $W=4.2e-06
Rc1704	vbottom<7>#109	vbottom<7>#125	0.337203	$metal3
+ $W=3e-07
Rc1705	vbottom<7>#110	vbottom<7>#39	0.025931	$metal3
+ $W=4.2e-06
Rc1706	vbottom<7>#110	vbottom<7>#126	0.337203	$metal3
+ $W=3e-07
Rc1707	vbottom<7>#111	vbottom<7>#42	0.025931	$metal3
+ $W=4.2e-06
Rc1708	vbottom<7>#111	vbottom<7>#127	0.337203	$metal3
+ $W=3e-07
Rc1709	vbottom<7>#112	vbottom<7>#45	0.025931	$metal3
+ $W=4.2e-06
Rc1710	vbottom<7>#112	vbottom<7>#128	0.337203	$metal3
+ $W=3e-07
Rc1711	vbottom<7>#113	vbottom<7>#48	0.025931	$metal3
+ $W=4.2e-06
Rc1712	vbottom<7>#113	vbottom<7>#129	0.337203	$metal3
+ $W=3e-07
Rc1713	vbottom<7>#114	vbottom<7>#51	0.025931	$metal3
+ $W=4.2e-06
Rc1714	vbottom<7>#114	vbottom<7>#130	0.337203	$metal3
+ $W=3e-07
Rc1715	vbottom<7>#115	vbottom<7>#54	0.025931	$metal3
+ $W=4.2e-06
Rc1716	vbottom<7>#115	vbottom<7>#131	0.337203	$metal3
+ $W=3e-07
Rc1717	vbottom<7>#119	vbottom<7>#116	0.025931	$metal3
+ $W=4.2e-06
Rc1718	vbottom<7>#119	vbottom<7>#117	0.025931	$metal3
+ $W=4.2e-06
Rc1719	vbottom<7>#119	vbottom<7>#132	0.025894	$metal3
+ $W=4.2e-06
Rc1720	vbottom<7>#132	vbottom<7>#133	0.226767	$metal3
+ $W=6e-07
Rc1721	vbottom<7>#133	vbottom<7>#134	0.661227	$metal3
+ $W=3e-07
Rc1722	vbottom<7>#120	vbottom<7>#20	0.215025	$metal3
+ $W=6e-07
Rc1723	vbottom<7>#121	vbottom<7>#23	0.215025	$metal3
+ $W=6e-07
Rc1724	vbottom<7>#122	vbottom<7>#26	0.215025	$metal3
+ $W=6e-07
Rc1725	vbottom<7>#123	vbottom<7>#29	0.215025	$metal3
+ $W=6e-07
Rc1726	vbottom<7>#124	vbottom<7>#32	0.215025	$metal3
+ $W=6e-07
Rc1727	vbottom<7>#125	vbottom<7>#35	0.215025	$metal3
+ $W=6e-07
Rc1728	vbottom<7>#126	vbottom<7>#38	0.215025	$metal3
+ $W=6e-07
Rc1729	vbottom<7>#127	vbottom<7>#41	0.215025	$metal3
+ $W=6e-07
Rc1730	vbottom<7>#128	vbottom<7>#44	0.215025	$metal3
+ $W=6e-07
Rc1731	vbottom<7>#129	vbottom<7>#47	0.215025	$metal3
+ $W=6e-07
Rc1732	vbottom<7>#130	vbottom<7>#50	0.215025	$metal3
+ $W=6e-07
Rc1733	vbottom<7>#131	vbottom<7>#53	0.215025	$metal3
+ $W=6e-07
Rc1734	vbottom<7>#133	vbottom<7>#116	0.337203	$metal3
+ $W=3e-07
Rc1735	vbottom<7>#134	vbottom<7>#99	0.345935	$metal3
+ $W=3e-07
Rc1736	vbottom<7>#134	vbottom<7>#102	0.345935	$metal3
+ $W=3e-07
Rc1737	vbottom<7>#134	vbottom<7>#135	0.672969	$metal3
+ $W=3e-07
Rc1738	vbottom<7>#135	vbottom<7>#98	0.337203	$metal3
+ $W=3e-07
Rc1739	vbottom<7>#135	vbottom<7>#136	0.215025	$metal3
+ $W=6e-07
Rc1740	vbottom<7>#136	vbottom<7>#137	0.025931	$metal3
+ $W=4.2e-06
Rc1741	vbottom<7>#136	vbottom<7>#138	0.665112	$metal3
+ $W=3e-07
Rc1742	vbottom<7>#138	vbottom<7>#139	0.556646	$metal3
+ $W=6e-07
Rc1743	vbottom<7>#139	vbottom<7>#140	0.618108	$metal3
+ $W=3e-07
Rc1744	vbottom<7>#137	vbottom<7>#97	0.025931	$metal3
+ $W=4.2e-06
Rc1745	vbottom<7>#137	vbottom<7>#98	0.025931	$metal3
+ $W=4.2e-06
Rc1746	vbottom<7>#137	vbottom<7>#96	0.025931	$metal3
+ $W=4.2e-06
Rc1747	vbottom<7>#139	vbottom<7>#141	0.337203	$metal3
+ $W=3e-07
Rc1748	vbottom<7>#141	vbottom<7>#142	0.672969	$metal3
+ $W=3e-07
Rc1749	vbottom<7>#140	vbottom<7>#132	0.046728	$metal3
+ $W=4.35e-07
Rc1750	vbottom<7>#142	vbottom<7>#132	0.345935	$metal3
+ $W=3e-07
Rc1751	vbottom<7>#142	vbottom<7>#118	0.345935	$metal3
+ $W=3e-07
Rc1752	vbottom<7>#142	vbottom<7>#143	0.660051	$metal3
+ $W=3e-07
Rc1753	vbottom<7>#143	vbottom<7>#144	0.337791	$metal3
+ $W=3e-07
Rc1754	vbottom<7>#144	vbottom<7>#145	0.315692	$metal3
+ $W=3e-07
Rc1755	vbottom<7>#144	vbottom<7>#146	0.556646	$metal3
+ $W=6e-07
Rc1756	vbottom<7>#146	vbottom<7>#147	0.556646	$metal3
+ $W=6e-07
Rc1757	vbottom<7>#147	vbottom<7>#148	0.025931	$metal3
+ $W=4.2e-06
Rc1758	vbottom<7>#145	vbottom<7>#118	0.349420	$metal3
+ $W=3e-07
Rc1759	vbottom<7>#148	vbottom<7>#144	0.025931	$metal3
+ $W=4.2e-06
Rc1760	vbottom<7>#148	vbottom<7>#146	0.025931	$metal3
+ $W=4.2e-06
Rc1761	vbottom<7>#148	vbottom<7>#149	0.025931	$metal3
+ $W=4.2e-06
Rc1762	vbottom<7>#149	vbottom<7>#143	0.225592	$metal3
+ $W=6e-07
Rc1763	vbottom<7>#149	vbottom<7>#150	0.182125	$metal3
+ $W=6e-07
Rc1764	vbottom<7>#150	vbottom<7>#147	0.337203	$metal3
+ $W=3e-07
Rc1765	vbottom<7>#150	vbottom<7>#151	0.672483	$metal3
+ $W=3e-07
Rc1766	vbottom<7>#151	vbottom<7>#152	0.337791	$metal3
+ $W=3e-07
Rc1767	vbottom<7>#152	vbottom<7>#153	0.315692	$metal3
+ $W=3e-07
Rc1768	vbottom<7>#152	vbottom<7>#154	0.556646	$metal3
+ $W=6e-07
Rc1769	vbottom<7>#154	vbottom<7>#155	0.556646	$metal3
+ $W=6e-07
Rc1770	vbottom<7>#155	vbottom<7>#156	0.025931	$metal3
+ $W=4.2e-06
Rc1771	vbottom<7>#153	vbottom<7>#147	0.349420	$metal3
+ $W=3e-07
Rc1772	vbottom<7>#156	vbottom<7>#152	0.025931	$metal3
+ $W=4.2e-06
Rc1773	vbottom<7>#156	vbottom<7>#154	0.025931	$metal3
+ $W=4.2e-06
Rc1774	vbottom<7>#156	vbottom<7>#157	0.025931	$metal3
+ $W=4.2e-06
Rc1775	vbottom<7>#157	vbottom<7>#151	0.225592	$metal3
+ $W=6e-07
Rc1776	vbottom<7>#157	vbottom<7>#158	0.182125	$metal3
+ $W=6e-07
Rc1777	vbottom<7>#158	vbottom<7>#155	0.337203	$metal3
+ $W=3e-07
Rc1778	vbottom<7>#158	vbottom<7>#159	0.672483	$metal3
+ $W=3e-07
Rc1779	vbottom<7>#159	vbottom<7>#160	0.337791	$metal3
+ $W=3e-07
Rc1780	vbottom<7>#160	vbottom<7>#161	0.315692	$metal3
+ $W=3e-07
Rc1781	vbottom<7>#160	vbottom<7>#162	0.556646	$metal3
+ $W=6e-07
Rc1782	vbottom<7>#162	vbottom<7>#163	0.556646	$metal3
+ $W=6e-07
Rc1783	vbottom<7>#163	vbottom<7>#164	0.025931	$metal3
+ $W=4.2e-06
Rc1784	vbottom<7>#161	vbottom<7>#155	0.349420	$metal3
+ $W=3e-07
Rc1785	vbottom<7>#164	vbottom<7>#160	0.025931	$metal3
+ $W=4.2e-06
Rc1786	vbottom<7>#164	vbottom<7>#162	0.025931	$metal3
+ $W=4.2e-06
Rc1787	vbottom<7>#164	vbottom<7>#165	0.025931	$metal3
+ $W=4.2e-06
Rc1788	vbottom<7>#165	vbottom<7>#159	0.225592	$metal3
+ $W=6e-07
Rc1789	vbottom<7>#165	vbottom<7>#166	0.182125	$metal3
+ $W=6e-07
Rc1790	vbottom<7>#166	vbottom<7>#163	0.337203	$metal3
+ $W=3e-07
Rc1791	vbottom<7>#166	vbottom<7>#167	0.672483	$metal3
+ $W=3e-07
Rc1792	vbottom<7>#167	vbottom<7>#168	0.337791	$metal3
+ $W=3e-07
Rc1793	vbottom<7>#168	vbottom<7>#169	0.315692	$metal3
+ $W=3e-07
Rc1794	vbottom<7>#168	vbottom<7>#170	0.556646	$metal3
+ $W=6e-07
Rc1795	vbottom<7>#170	vbottom<7>#171	0.556646	$metal3
+ $W=6e-07
Rc1796	vbottom<7>#171	vbottom<7>#172	0.025931	$metal3
+ $W=4.2e-06
Rc1797	vbottom<7>#169	vbottom<7>#163	0.349420	$metal3
+ $W=3e-07
Rc1798	vbottom<7>#172	vbottom<7>#168	0.025931	$metal3
+ $W=4.2e-06
Rc1799	vbottom<7>#172	vbottom<7>#170	0.025931	$metal3
+ $W=4.2e-06
Rc1800	vbottom<7>#172	vbottom<7>#173	0.025931	$metal3
+ $W=4.2e-06
Rc1801	vbottom<7>#173	vbottom<7>#167	0.225592	$metal3
+ $W=6e-07
Rc1802	vbottom<7>#173	vbottom<7>#174	0.182125	$metal3
+ $W=6e-07
Rc1803	vbottom<7>#174	vbottom<7>#171	0.337203	$metal3
+ $W=3e-07
Rc1804	vbottom<7>#174	vbottom<7>#175	0.672483	$metal3
+ $W=3e-07
Rc1805	vbottom<7>#175	vbottom<7>#176	0.337791	$metal3
+ $W=3e-07
Rc1806	vbottom<7>#176	vbottom<7>#177	0.315692	$metal3
+ $W=3e-07
Rc1807	vbottom<7>#176	vbottom<7>#178	0.556646	$metal3
+ $W=6e-07
Rc1808	vbottom<7>#178	vbottom<7>#179	0.556646	$metal3
+ $W=6e-07
Rc1809	vbottom<7>#179	vbottom<7>#180	0.025931	$metal3
+ $W=4.2e-06
Rc1810	vbottom<7>#177	vbottom<7>#171	0.349420	$metal3
+ $W=3e-07
Rc1811	vbottom<7>#180	vbottom<7>#176	0.025931	$metal3
+ $W=4.2e-06
Rc1812	vbottom<7>#180	vbottom<7>#178	0.025931	$metal3
+ $W=4.2e-06
Rc1813	vbottom<7>#180	vbottom<7>#181	0.025931	$metal3
+ $W=4.2e-06
Rc1814	vbottom<7>#181	vbottom<7>#175	0.225592	$metal3
+ $W=6e-07
Rc1815	vbottom<7>#181	vbottom<7>#182	0.182125	$metal3
+ $W=6e-07
Rc1816	vbottom<7>#182	vbottom<7>#179	0.337203	$metal3
+ $W=3e-07
Rc1817	vbottom<7>#182	vbottom<7>#183	0.672483	$metal3
+ $W=3e-07
Rc1818	vbottom<7>#183	vbottom<7>#184	0.337791	$metal3
+ $W=3e-07
Rc1819	vbottom<7>#184	vbottom<7>#185	0.315692	$metal3
+ $W=3e-07
Rc1820	vbottom<7>#184	vbottom<7>#186	0.556646	$metal3
+ $W=6e-07
Rc1821	vbottom<7>#186	vbottom<7>#187	0.556646	$metal3
+ $W=6e-07
Rc1822	vbottom<7>#187	vbottom<7>#188	0.025931	$metal3
+ $W=4.2e-06
Rc1823	vbottom<7>#185	vbottom<7>#179	0.349420	$metal3
+ $W=3e-07
Rc1824	vbottom<7>#188	vbottom<7>#184	0.025931	$metal3
+ $W=4.2e-06
Rc1825	vbottom<7>#188	vbottom<7>#186	0.025931	$metal3
+ $W=4.2e-06
Rc1826	vbottom<7>#188	vbottom<7>#189	0.025931	$metal3
+ $W=4.2e-06
Rc1827	vbottom<7>#189	vbottom<7>#183	0.225592	$metal3
+ $W=6e-07
Rc1828	vbottom<7>#189	vbottom<7>#190	0.182125	$metal3
+ $W=6e-07
Rc1829	vbottom<7>#190	vbottom<7>#187	0.337203	$metal3
+ $W=3e-07
Rc1830	vbottom<7>#190	vbottom<7>#191	0.672483	$metal3
+ $W=3e-07
Rc1831	vbottom<7>#191	vbottom<7>#192	0.337791	$metal3
+ $W=3e-07
Rc1832	vbottom<7>#192	vbottom<7>#193	0.315692	$metal3
+ $W=3e-07
Rc1833	vbottom<7>#192	vbottom<7>#194	0.556646	$metal3
+ $W=6e-07
Rc1834	vbottom<7>#194	vbottom<7>#195	0.556646	$metal3
+ $W=6e-07
Rc1835	vbottom<7>#195	vbottom<7>#196	0.025931	$metal3
+ $W=4.2e-06
Rc1836	vbottom<7>#193	vbottom<7>#187	0.349420	$metal3
+ $W=3e-07
Rc1837	vbottom<7>#196	vbottom<7>#192	0.025931	$metal3
+ $W=4.2e-06
Rc1838	vbottom<7>#196	vbottom<7>#194	0.025931	$metal3
+ $W=4.2e-06
Rc1839	vbottom<7>#196	vbottom<7>#197	0.025931	$metal3
+ $W=4.2e-06
Rc1840	vbottom<7>#197	vbottom<7>#191	0.225592	$metal3
+ $W=6e-07
Rc1841	vbottom<7>#197	vbottom<7>#198	0.182125	$metal3
+ $W=6e-07
Rc1842	vbottom<7>#198	vbottom<7>#195	0.337203	$metal3
+ $W=3e-07
Rc1843	vbottom<7>#198	vbottom<7>#199	0.672483	$metal3
+ $W=3e-07
Rc1844	vbottom<7>#199	vbottom<7>#200	0.337791	$metal3
+ $W=3e-07
Rc1845	vbottom<7>#200	vbottom<7>#201	0.315692	$metal3
+ $W=3e-07
Rc1846	vbottom<7>#200	vbottom<7>#202	0.556646	$metal3
+ $W=6e-07
Rc1847	vbottom<7>#202	vbottom<7>#203	0.556646	$metal3
+ $W=6e-07
Rc1848	vbottom<7>#203	vbottom<7>#204	0.025931	$metal3
+ $W=4.2e-06
Rc1849	vbottom<7>#201	vbottom<7>#195	0.349420	$metal3
+ $W=3e-07
Rc1850	vbottom<7>#204	vbottom<7>#200	0.025931	$metal3
+ $W=4.2e-06
Rc1851	vbottom<7>#204	vbottom<7>#202	0.025931	$metal3
+ $W=4.2e-06
Rc1852	vbottom<7>#204	vbottom<7>#205	0.025931	$metal3
+ $W=4.2e-06
Rc1853	vbottom<7>#205	vbottom<7>#199	0.225592	$metal3
+ $W=6e-07
Rc1854	vbottom<7>#205	vbottom<7>#206	0.182125	$metal3
+ $W=6e-07
Rc1855	vbottom<7>#206	vbottom<7>#203	0.337203	$metal3
+ $W=3e-07
Rc1856	vbottom<7>#206	vbottom<7>#207	0.672483	$metal3
+ $W=3e-07
Rc1857	vbottom<7>#207	vbottom<7>#208	0.337791	$metal3
+ $W=3e-07
Rc1858	vbottom<7>#208	vbottom<7>#209	0.315692	$metal3
+ $W=3e-07
Rc1859	vbottom<7>#208	vbottom<7>#210	0.556646	$metal3
+ $W=6e-07
Rc1860	vbottom<7>#210	vbottom<7>#211	0.556646	$metal3
+ $W=6e-07
Rc1861	vbottom<7>#211	vbottom<7>#212	0.025931	$metal3
+ $W=4.2e-06
Rc1862	vbottom<7>#209	vbottom<7>#203	0.349420	$metal3
+ $W=3e-07
Rc1863	vbottom<7>#212	vbottom<7>#208	0.025931	$metal3
+ $W=4.2e-06
Rc1864	vbottom<7>#212	vbottom<7>#210	0.025931	$metal3
+ $W=4.2e-06
Rc1865	vbottom<7>#212	vbottom<7>#213	0.025931	$metal3
+ $W=4.2e-06
Rc1866	vbottom<7>#213	vbottom<7>#207	0.225592	$metal3
+ $W=6e-07
Rc1867	vbottom<7>#213	vbottom<7>#214	0.182125	$metal3
+ $W=6e-07
Rc1868	vbottom<7>#214	vbottom<7>#211	0.337203	$metal3
+ $W=3e-07
Rc1869	vbottom<7>#214	vbottom<7>#215	0.672483	$metal3
+ $W=3e-07
Rc1870	vbottom<7>#215	vbottom<7>#216	0.337791	$metal3
+ $W=3e-07
Rc1871	vbottom<7>#216	vbottom<7>#217	0.315692	$metal3
+ $W=3e-07
Rc1872	vbottom<7>#216	vbottom<7>#218	0.556646	$metal3
+ $W=6e-07
Rc1873	vbottom<7>#218	vbottom<7>#219	0.556646	$metal3
+ $W=6e-07
Rc1874	vbottom<7>#219	vbottom<7>#220	0.025931	$metal3
+ $W=4.2e-06
Rc1875	vbottom<7>#217	vbottom<7>#211	0.349420	$metal3
+ $W=3e-07
Rc1876	vbottom<7>#220	vbottom<7>#216	0.025931	$metal3
+ $W=4.2e-06
Rc1877	vbottom<7>#220	vbottom<7>#218	0.025931	$metal3
+ $W=4.2e-06
Rc1878	vbottom<7>#220	vbottom<7>#221	0.025931	$metal3
+ $W=4.2e-06
Rc1879	vbottom<7>#221	vbottom<7>#215	0.225592	$metal3
+ $W=6e-07
Rc1880	vbottom<7>#221	vbottom<7>#222	0.182125	$metal3
+ $W=6e-07
Rc1881	vbottom<7>#222	vbottom<7>#219	0.337203	$metal3
+ $W=3e-07
Rc1882	vbottom<7>#222	vbottom<7>#223	0.672483	$metal3
+ $W=3e-07
Rc1883	vbottom<7>#223	vbottom<7>#224	0.337791	$metal3
+ $W=3e-07
Rc1884	vbottom<7>#224	vbottom<7>#225	0.315692	$metal3
+ $W=3e-07
Rc1885	vbottom<7>#224	vbottom<7>#226	0.556646	$metal3
+ $W=6e-07
Rc1886	vbottom<7>#226	vbottom<7>#227	0.556646	$metal3
+ $W=6e-07
Rc1887	vbottom<7>#227	vbottom<7>#228	0.025931	$metal3
+ $W=4.2e-06
Rc1888	vbottom<7>#225	vbottom<7>#219	0.349420	$metal3
+ $W=3e-07
Rc1889	vbottom<7>#228	vbottom<7>#224	0.025931	$metal3
+ $W=4.2e-06
Rc1890	vbottom<7>#228	vbottom<7>#226	0.025931	$metal3
+ $W=4.2e-06
Rc1891	vbottom<7>#228	vbottom<7>#229	0.025931	$metal3
+ $W=4.2e-06
Rc1892	vbottom<7>#229	vbottom<7>#223	0.225592	$metal3
+ $W=6e-07
Rc1893	vbottom<7>#229	vbottom<7>#230	0.182125	$metal3
+ $W=6e-07
Rc1894	vbottom<7>#230	vbottom<7>#227	0.337203	$metal3
+ $W=3e-07
Rc1895	vbottom<7>#230	vbottom<7>#231	0.672483	$metal3
+ $W=3e-07
Rc1896	vbottom<7>#231	vbottom<7>#232	0.337791	$metal3
+ $W=3e-07
Rc1897	vbottom<7>#232	vbottom<7>#233	0.315692	$metal3
+ $W=3e-07
Rc1898	vbottom<7>#232	vbottom<7>#234	0.556646	$metal3
+ $W=6e-07
Rc1899	vbottom<7>#234	vbottom<7>#235	0.556646	$metal3
+ $W=6e-07
Rc1900	vbottom<7>#235	vbottom<7>#236	0.025931	$metal3
+ $W=4.2e-06
Rc1901	vbottom<7>#233	vbottom<7>#227	0.349420	$metal3
+ $W=3e-07
Rc1902	vbottom<7>#236	vbottom<7>#232	0.025931	$metal3
+ $W=4.2e-06
Rc1903	vbottom<7>#236	vbottom<7>#234	0.025931	$metal3
+ $W=4.2e-06
Rc1904	vbottom<7>#236	vbottom<7>#237	0.025931	$metal3
+ $W=4.2e-06
Rc1905	vbottom<7>#237	vbottom<7>#231	0.225592	$metal3
+ $W=6e-07
Rc1906	vbottom<7>#237	vbottom<7>#238	0.182125	$metal3
+ $W=6e-07
Rc1907	vbottom<7>#238	vbottom<7>#235	0.337203	$metal3
+ $W=3e-07
Rc1908	vbottom<7>#238	vbottom<7>#239	0.672969	$metal3
+ $W=3e-07
Rc1909	vbottom<7>#239	vbottom<7>#240	0.345935	$metal3
+ $W=3e-07
Rc1910	vbottom<7>#240	vbottom<7>#241	0.315692	$metal3
+ $W=3e-07
Rc1911	vbottom<7>#240	vbottom<7>#242	0.556646	$metal3
+ $W=6e-07
Rc1912	vbottom<7>#242	vbottom<7>#243	0.556646	$metal3
+ $W=6e-07
Rc1913	vbottom<7>#243	vbottom<7>#244	0.025931	$metal3
+ $W=4.2e-06
Rc1914	vbottom<7>#241	vbottom<7>#235	0.349420	$metal3
+ $W=3e-07
Rc1915	vbottom<7>#244	vbottom<7>#240	0.025931	$metal3
+ $W=4.2e-06
Rc1916	vbottom<7>#244	vbottom<7>#242	0.025931	$metal3
+ $W=4.2e-06
Rc1917	vbottom<7>#244	vbottom<7>#245	0.025931	$metal3
+ $W=4.2e-06
Rc1918	vbottom<7>#245	vbottom<7>#239	0.345935	$metal3
+ $W=3e-07
Rc1919	vbottom<7>#245	vbottom<7>#246	0.215025	$metal3
+ $W=6e-07
Rc1920	vbottom<7>#246	vbottom<7>#243	0.337203	$metal3
+ $W=3e-07
Rc1921	vbottom<7>#246	vbottom<7>#247	0.672969	$metal3
+ $W=3e-07
Rc1922	vbottom<7>#247	vbottom<7>#248	0.345935	$metal3
+ $W=3e-07
Rc1923	vbottom<7>#248	vbottom<7>#249	0.315692	$metal3
+ $W=3e-07
Rc1924	vbottom<7>#248	vbottom<7>#250	0.556646	$metal3
+ $W=6e-07
Rc1925	vbottom<7>#250	vbottom<7>#251	0.556646	$metal3
+ $W=6e-07
Rc1926	vbottom<7>#251	vbottom<7>#252	0.025931	$metal3
+ $W=4.2e-06
Rc1927	vbottom<7>#249	vbottom<7>#243	0.349420	$metal3
+ $W=3e-07
Rc1928	vbottom<7>#252	vbottom<7>#248	0.025931	$metal3
+ $W=4.2e-06
Rc1929	vbottom<7>#252	vbottom<7>#250	0.025931	$metal3
+ $W=4.2e-06
Rc1930	vbottom<7>#252	vbottom<7>#253	0.025931	$metal3
+ $W=4.2e-06
Rc1931	vbottom<7>#253	vbottom<7>#247	0.345935	$metal3
+ $W=3e-07
Rc1932	vbottom<7>#253	vbottom<7>#254	0.337203	$metal3
+ $W=3e-07
Rc1933	vbottom<7>#253	vbottom<7>#255	0.698840	$metal3
+ $W=3e-07
Rc1934	vbottom<7>#255	vbottom<7>#256	0.337203	$metal3
+ $W=3e-07
Rc1935	vbottom<7>#256	vbottom<7>#257	0.330958	$metal3
+ $W=3e-07
Rc1936	vbottom<7>#254	vbottom<7>#251	0.215025	$metal3
+ $W=6e-07
Rc1937	vbottom<7>#256	vbottom<7>#258	0.215025	$metal3
+ $W=6e-07
Rc1938	vbottom<7>#258	vbottom<7>#259	0.665112	$metal3
+ $W=3e-07
Rc1939	vbottom<7>#259	vbottom<7>#260	0.025931	$metal3
+ $W=4.2e-06
Rc1940	vbottom<7>#260	vbottom<7>#261	0.025931	$metal3
+ $W=4.2e-06
Rc1941	vbottom<7>#261	vbottom<7>#262	0.665112	$metal3
+ $W=3e-07
Rc1942	vbottom<7>#262	vbottom<7>#263	0.025931	$metal3
+ $W=4.2e-06
Rc1943	vbottom<7>#263	vbottom<7>#264	0.023693	$metal3
+ $W=4.8e-06
Rc1944	vbottom<7>#264	vbottom<7>#265	0.665027	$metal3
+ $W=3e-07
Rc1945	vbottom<7>#265	vbottom<7>#266	0.025931	$metal3
+ $W=4.2e-06
Rc1946	vbottom<7>#266	vbottom<7>#267	0.023693	$metal3
+ $W=4.8e-06
Rc1947	vbottom<7>#267	vbottom<7>#268	0.665027	$metal3
+ $W=3e-07
Rc1948	vbottom<7>#268	vbottom<7>#269	0.025931	$metal3
+ $W=4.2e-06
Rc1949	vbottom<7>#269	vbottom<7>#270	0.023693	$metal3
+ $W=4.8e-06
Rc1950	vbottom<7>#270	vbottom<7>#271	0.665027	$metal3
+ $W=3e-07
Rc1951	vbottom<7>#271	vbottom<7>#272	0.025931	$metal3
+ $W=4.2e-06
Rc1952	vbottom<7>#272	vbottom<7>#273	0.023693	$metal3
+ $W=4.8e-06
Rc1953	vbottom<7>#273	vbottom<7>#274	0.665027	$metal3
+ $W=3e-07
Rc1954	vbottom<7>#274	vbottom<7>#275	0.025931	$metal3
+ $W=4.2e-06
Rc1955	vbottom<7>#275	vbottom<7>#276	0.023693	$metal3
+ $W=4.8e-06
Rc1956	vbottom<7>#276	vbottom<7>#277	0.665027	$metal3
+ $W=3e-07
Rc1957	vbottom<7>#277	vbottom<7>#278	0.025931	$metal3
+ $W=4.2e-06
Rc1958	vbottom<7>#278	vbottom<7>#279	0.023693	$metal3
+ $W=4.8e-06
Rc1959	vbottom<7>#279	vbottom<7>#280	0.665027	$metal3
+ $W=3e-07
Rc1960	vbottom<7>#280	vbottom<7>#281	0.025931	$metal3
+ $W=4.2e-06
Rc1961	vbottom<7>#281	vbottom<7>#282	0.023693	$metal3
+ $W=4.8e-06
Rc1962	vbottom<7>#282	vbottom<7>#283	0.665027	$metal3
+ $W=3e-07
Rc1963	vbottom<7>#283	vbottom<7>#284	0.025931	$metal3
+ $W=4.2e-06
Rc1964	vbottom<7>#284	vbottom<7>#285	0.023693	$metal3
+ $W=4.8e-06
Rc1965	vbottom<7>#285	vbottom<7>#286	0.665027	$metal3
+ $W=3e-07
Rc1966	vbottom<7>#286	vbottom<7>#287	0.025931	$metal3
+ $W=4.2e-06
Rc1967	vbottom<7>#287	vbottom<7>#288	0.023693	$metal3
+ $W=4.8e-06
Rc1968	vbottom<7>#288	vbottom<7>#289	0.665027	$metal3
+ $W=3e-07
Rc1969	vbottom<7>#289	vbottom<7>#290	0.025931	$metal3
+ $W=4.2e-06
Rc1970	vbottom<7>#290	vbottom<7>#291	0.023693	$metal3
+ $W=4.8e-06
Rc1971	vbottom<7>#291	vbottom<7>#292	0.665027	$metal3
+ $W=3e-07
Rc1972	vbottom<7>#292	vbottom<7>#293	0.025931	$metal3
+ $W=4.2e-06
Rc1973	vbottom<7>#293	vbottom<7>#294	0.023693	$metal3
+ $W=4.8e-06
Rc1974	vbottom<7>#294	vbottom<7>#295	0.665027	$metal3
+ $W=3e-07
Rc1975	vbottom<7>#295	vbottom<7>#296	0.025931	$metal3
+ $W=4.2e-06
Rc1976	vbottom<7>#296	vbottom<7>#297	0.023693	$metal3
+ $W=4.8e-06
Rc1977	vbottom<7>#297	vbottom<7>#298	0.665027	$metal3
+ $W=3e-07
Rc1978	vbottom<7>#298	vbottom<7>#299	0.025931	$metal3
+ $W=4.2e-06
Rc1979	vbottom<7>#257	vbottom<7>#247	0.330268	$metal3
+ $W=3e-07
Rc1980	vbottom<7>#261	vbottom<7>#300	0.225592	$metal3
+ $W=6e-07
Rc1981	vbottom<7>#300	vbottom<7>#301	0.329783	$metal3
+ $W=3e-07
Rc1982	vbottom<7>#298	vbottom<7>#141	0.226767	$metal3
+ $W=6e-07
Rc1983	vbottom<7>#299	vbottom<7>#138	0.025931	$metal3
+ $W=4.2e-06
Rc1984	vbottom<7>#299	vbottom<7>#139	0.025894	$metal3
+ $W=4.2e-06
Rc1985	vbottom<7>#299	vbottom<7>#302	0.025894	$metal3
+ $W=4.2e-06
Rc1986	vbottom<7>#302	vbottom<7>#303	0.226767	$metal3
+ $W=6e-07
Rc1987	vbottom<7>#303	vbottom<7>#304	0.661227	$metal3
+ $W=3e-07
Rc1988	vbottom<7>#300	vbottom<7>#305	0.048308	$metal3
+ $W=3e-07
Rc1989	vbottom<7>#305	vbottom<7>#306	0.315608	$metal3
+ $W=3e-07
Rc1990	vbottom<7>#301	vbottom<7>#239	0.330268	$metal3
+ $W=3e-07
Rc1991	vbottom<7>#303	vbottom<7>#138	0.337203	$metal3
+ $W=3e-07
Rc1992	vbottom<7>#304	vbottom<7>#96	0.345935	$metal3
+ $W=3e-07
Rc1993	vbottom<7>#304	vbottom<7>#136	0.345935	$metal3
+ $W=3e-07
Rc1994	vbottom<7>#304	vbottom<7>#307	0.672969	$metal3
+ $W=3e-07
Rc1995	vbottom<7>#305	vbottom<7>#260	0.022837	$metal3
+ $W=4.8e-06
Rc1996	vbottom<7>#306	vbottom<7>#245	0.349420	$metal3
+ $W=3e-07
Rc1997	vbottom<7>#307	vbottom<7>#95	0.337203	$metal3
+ $W=3e-07
Rc1998	vbottom<7>#307	vbottom<7>#308	0.215025	$metal3
+ $W=6e-07
Rc1999	vbottom<7>#308	vbottom<7>#309	0.025931	$metal3
+ $W=4.2e-06
Rc2000	vbottom<7>#308	vbottom<7>#310	0.193867	$metal3
+ $W=6e-07
Rc2001	vbottom<7>#309	vbottom<7>#94	0.025931	$metal3
+ $W=4.2e-06
Rc2002	vbottom<7>#309	vbottom<7>#95	0.025931	$metal3
+ $W=4.2e-06
Rc2003	vbottom<7>#309	vbottom<7>#93	0.025931	$metal3
+ $W=4.2e-06
Rc2004	vbottom<7>#310	vbottom<7>#93	0.337203	$metal3
+ $W=3e-07
Rc2005	vbottom<7>#310	vbottom<7>#311	0.685401	$metal3
+ $W=3e-07
Rc2006	vbottom<7>#311	vbottom<7>#92	0.337203	$metal3
+ $W=3e-07
Rc2007	vbottom<7>#311	vbottom<7>#312	0.215025	$metal3
+ $W=6e-07
Rc2008	vbottom<7>#312	vbottom<7>#313	0.025931	$metal3
+ $W=4.2e-06
Rc2009	vbottom<7>#312	vbottom<7>#314	0.193867	$metal3
+ $W=6e-07
Rc2010	vbottom<7>#313	vbottom<7>#91	0.025931	$metal3
+ $W=4.2e-06
Rc2011	vbottom<7>#313	vbottom<7>#92	0.025931	$metal3
+ $W=4.2e-06
Rc2012	vbottom<7>#313	vbottom<7>#90	0.025931	$metal3
+ $W=4.2e-06
Rc2013	vbottom<7>#314	vbottom<7>#90	0.337203	$metal3
+ $W=3e-07
Rc2014	vbottom<7>#314	vbottom<7>#315	0.685401	$metal3
+ $W=3e-07
Rc2015	vbottom<7>#315	vbottom<7>#89	0.337203	$metal3
+ $W=3e-07
Rc2016	vbottom<7>#315	vbottom<7>#316	0.215025	$metal3
+ $W=6e-07
Rc2017	vbottom<7>#316	vbottom<7>#317	0.025931	$metal3
+ $W=4.2e-06
Rc2018	vbottom<7>#316	vbottom<7>#318	0.193867	$metal3
+ $W=6e-07
Rc2019	vbottom<7>#317	vbottom<7>#88	0.025931	$metal3
+ $W=4.2e-06
Rc2020	vbottom<7>#317	vbottom<7>#89	0.025931	$metal3
+ $W=4.2e-06
Rc2021	vbottom<7>#317	vbottom<7>#87	0.025931	$metal3
+ $W=4.2e-06
Rc2022	vbottom<7>#318	vbottom<7>#87	0.337203	$metal3
+ $W=3e-07
Rc2023	vbottom<7>#318	vbottom<7>#319	0.685401	$metal3
+ $W=3e-07
Rc2024	vbottom<7>#319	vbottom<7>#86	0.337203	$metal3
+ $W=3e-07
Rc2025	vbottom<7>#319	vbottom<7>#320	0.215025	$metal3
+ $W=6e-07
Rc2026	vbottom<7>#320	vbottom<7>#321	0.025931	$metal3
+ $W=4.2e-06
Rc2027	vbottom<7>#320	vbottom<7>#322	0.193867	$metal3
+ $W=6e-07
Rc2028	vbottom<7>#321	vbottom<7>#85	0.025931	$metal3
+ $W=4.2e-06
Rc2029	vbottom<7>#321	vbottom<7>#86	0.025931	$metal3
+ $W=4.2e-06
Rc2030	vbottom<7>#321	vbottom<7>#84	0.025931	$metal3
+ $W=4.2e-06
Rc2031	vbottom<7>#322	vbottom<7>#84	0.337203	$metal3
+ $W=3e-07
Rc2032	vbottom<7>#322	vbottom<7>#323	0.685401	$metal3
+ $W=3e-07
Rc2033	vbottom<7>#323	vbottom<7>#83	0.337203	$metal3
+ $W=3e-07
Rc2034	vbottom<7>#323	vbottom<7>#324	0.215025	$metal3
+ $W=6e-07
Rc2035	vbottom<7>#324	vbottom<7>#325	0.025931	$metal3
+ $W=4.2e-06
Rc2036	vbottom<7>#324	vbottom<7>#326	0.193867	$metal3
+ $W=6e-07
Rc2037	vbottom<7>#325	vbottom<7>#82	0.025931	$metal3
+ $W=4.2e-06
Rc2038	vbottom<7>#325	vbottom<7>#83	0.025931	$metal3
+ $W=4.2e-06
Rc2039	vbottom<7>#325	vbottom<7>#81	0.025931	$metal3
+ $W=4.2e-06
Rc2040	vbottom<7>#326	vbottom<7>#81	0.337203	$metal3
+ $W=3e-07
Rc2041	vbottom<7>#326	vbottom<7>#327	0.685401	$metal3
+ $W=3e-07
Rc2042	vbottom<7>#327	vbottom<7>#80	0.337203	$metal3
+ $W=3e-07
Rc2043	vbottom<7>#327	vbottom<7>#328	0.215025	$metal3
+ $W=6e-07
Rc2044	vbottom<7>#328	vbottom<7>#329	0.025931	$metal3
+ $W=4.2e-06
Rc2045	vbottom<7>#328	vbottom<7>#330	0.193867	$metal3
+ $W=6e-07
Rc2046	vbottom<7>#329	vbottom<7>#79	0.025931	$metal3
+ $W=4.2e-06
Rc2047	vbottom<7>#329	vbottom<7>#80	0.025931	$metal3
+ $W=4.2e-06
Rc2048	vbottom<7>#329	vbottom<7>#78	0.025931	$metal3
+ $W=4.2e-06
Rc2049	vbottom<7>#330	vbottom<7>#78	0.337203	$metal3
+ $W=3e-07
Rc2050	vbottom<7>#330	vbottom<7>#331	0.685401	$metal3
+ $W=3e-07
Rc2051	vbottom<7>#331	vbottom<7>#77	0.337203	$metal3
+ $W=3e-07
Rc2052	vbottom<7>#331	vbottom<7>#332	0.215025	$metal3
+ $W=6e-07
Rc2053	vbottom<7>#332	vbottom<7>#333	0.025931	$metal3
+ $W=4.2e-06
Rc2054	vbottom<7>#332	vbottom<7>#334	0.193867	$metal3
+ $W=6e-07
Rc2055	vbottom<7>#333	vbottom<7>#76	0.025931	$metal3
+ $W=4.2e-06
Rc2056	vbottom<7>#333	vbottom<7>#77	0.025931	$metal3
+ $W=4.2e-06
Rc2057	vbottom<7>#333	vbottom<7>#75	0.025931	$metal3
+ $W=4.2e-06
Rc2058	vbottom<7>#334	vbottom<7>#75	0.337203	$metal3
+ $W=3e-07
Rc2059	vbottom<7>#334	vbottom<7>#335	0.685401	$metal3
+ $W=3e-07
Rc2060	vbottom<7>#335	vbottom<7>#74	0.337203	$metal3
+ $W=3e-07
Rc2061	vbottom<7>#335	vbottom<7>#336	0.215025	$metal3
+ $W=6e-07
Rc2062	vbottom<7>#336	vbottom<7>#337	0.025931	$metal3
+ $W=4.2e-06
Rc2063	vbottom<7>#336	vbottom<7>#338	0.193867	$metal3
+ $W=6e-07
Rc2064	vbottom<7>#337	vbottom<7>#73	0.025931	$metal3
+ $W=4.2e-06
Rc2065	vbottom<7>#337	vbottom<7>#74	0.025931	$metal3
+ $W=4.2e-06
Rc2066	vbottom<7>#337	vbottom<7>#72	0.025931	$metal3
+ $W=4.2e-06
Rc2067	vbottom<7>#338	vbottom<7>#72	0.337203	$metal3
+ $W=3e-07
Rc2068	vbottom<7>#338	vbottom<7>#339	0.685401	$metal3
+ $W=3e-07
Rc2069	vbottom<7>#339	vbottom<7>#71	0.337203	$metal3
+ $W=3e-07
Rc2070	vbottom<7>#339	vbottom<7>#340	0.215025	$metal3
+ $W=6e-07
Rc2071	vbottom<7>#340	vbottom<7>#341	0.025931	$metal3
+ $W=4.2e-06
Rc2072	vbottom<7>#340	vbottom<7>#342	0.193867	$metal3
+ $W=6e-07
Rc2073	vbottom<7>#341	vbottom<7>#70	0.025931	$metal3
+ $W=4.2e-06
Rc2074	vbottom<7>#341	vbottom<7>#71	0.025931	$metal3
+ $W=4.2e-06
Rc2075	vbottom<7>#341	vbottom<7>#69	0.025931	$metal3
+ $W=4.2e-06
Rc2076	vbottom<7>#342	vbottom<7>#69	0.337203	$metal3
+ $W=3e-07
Rc2077	vbottom<7>#342	vbottom<7>#343	0.685401	$metal3
+ $W=3e-07
Rc2078	vbottom<7>#343	vbottom<7>#68	0.337203	$metal3
+ $W=3e-07
Rc2079	vbottom<7>#343	vbottom<7>#344	0.215025	$metal3
+ $W=6e-07
Rc2080	vbottom<7>#344	vbottom<7>#345	0.025931	$metal3
+ $W=4.2e-06
Rc2081	vbottom<7>#344	vbottom<7>#346	0.193867	$metal3
+ $W=6e-07
Rc2082	vbottom<7>#345	vbottom<7>#67	0.025931	$metal3
+ $W=4.2e-06
Rc2083	vbottom<7>#345	vbottom<7>#68	0.025931	$metal3
+ $W=4.2e-06
Rc2084	vbottom<7>#345	vbottom<7>#66	0.025931	$metal3
+ $W=4.2e-06
Rc2085	vbottom<7>#346	vbottom<7>#66	0.337203	$metal3
+ $W=3e-07
Rc2086	vbottom<7>#346	vbottom<7>#347	0.685401	$metal3
+ $W=3e-07
Rc2087	vbottom<7>#347	vbottom<7>#65	0.337203	$metal3
+ $W=3e-07
Rc2088	vbottom<7>#347	vbottom<7>#348	0.215025	$metal3
+ $W=6e-07
Rc2089	vbottom<7>#348	vbottom<7>#349	0.025931	$metal3
+ $W=4.2e-06
Rc2090	vbottom<7>#348	vbottom<7>#350	0.193867	$metal3
+ $W=6e-07
Rc2091	vbottom<7>#349	vbottom<7>#64	0.025931	$metal3
+ $W=4.2e-06
Rc2092	vbottom<7>#349	vbottom<7>#65	0.025931	$metal3
+ $W=4.2e-06
Rc2093	vbottom<7>#349	vbottom<7>#63	0.025931	$metal3
+ $W=4.2e-06
Rc2094	vbottom<7>#350	vbottom<7>#63	0.337203	$metal3
+ $W=3e-07
Rc2095	vbottom<7>#350	vbottom<7>#351	0.685401	$metal3
+ $W=3e-07
Rc2096	vbottom<7>#351	vbottom<7>#62	0.337203	$metal3
+ $W=3e-07
Rc2097	vbottom<7>#351	vbottom<7>#352	0.215025	$metal3
+ $W=6e-07
Rc2098	vbottom<7>#352	vbottom<7>#353	0.025931	$metal3
+ $W=4.2e-06
Rc2099	vbottom<7>#352	vbottom<7>#354	0.193867	$metal3
+ $W=6e-07
Rc2100	vbottom<7>#353	vbottom<7>#61	0.025931	$metal3
+ $W=4.2e-06
Rc2101	vbottom<7>#353	vbottom<7>#62	0.025931	$metal3
+ $W=4.2e-06
Rc2102	vbottom<7>#353	vbottom<7>#60	0.025931	$metal3
+ $W=4.2e-06
Rc2103	vbottom<7>#354	vbottom<7>#60	0.337203	$metal3
+ $W=3e-07
Rc2104	vbottom<7>#354	vbottom<7>#355	0.672969	$metal3
+ $W=3e-07
Rc2105	vbottom<7>#355	vbottom<7>#59	0.345935	$metal3
+ $W=3e-07
Rc2106	vbottom<7>#355	vbottom<7>#356	0.660051	$metal3
+ $W=3e-07
Rc2107	vbottom<7>#356	vbottom<7>#357	0.225592	$metal3
+ $W=6e-07
Rc2108	vbottom<7>#357	vbottom<7>#358	0.664836	$metal3
+ $W=3e-07
Rc2109	vbottom<7>#358	vbottom<7>#359	0.556646	$metal3
+ $W=3e-07
Rc2110	vbottom<7>#359	vbottom<7>#360	0.523746	$metal3
+ $W=6e-07
Rc2111	vbottom<7>#360	vbottom<7>#361	0.664836	$metal3
+ $W=3e-07
Rc2112	vbottom<7>#361	vbottom<7>#362	0.556646	$metal3
+ $W=3e-07
Rc2113	vbottom<7>#362	vbottom<7>#363	0.523746	$metal3
+ $W=6e-07
Rc2114	vbottom<7>#363	vbottom<7>#364	0.664836	$metal3
+ $W=3e-07
Rc2115	vbottom<7>#364	vbottom<7>#365	0.556646	$metal3
+ $W=3e-07
Rc2116	vbottom<7>#365	vbottom<7>#366	0.523746	$metal3
+ $W=6e-07
Rc2117	vbottom<7>#366	vbottom<7>#367	0.664836	$metal3
+ $W=3e-07
Rc2118	vbottom<7>#367	vbottom<7>#368	0.556646	$metal3
+ $W=3e-07
Rc2119	vbottom<7>#368	vbottom<7>#369	0.523746	$metal3
+ $W=6e-07
Rc2120	vbottom<7>#369	vbottom<7>#370	0.664836	$metal3
+ $W=3e-07
Rc2121	vbottom<7>#370	vbottom<7>#371	0.556646	$metal3
+ $W=3e-07
Rc2122	vbottom<7>#371	vbottom<7>#372	0.523746	$metal3
+ $W=6e-07
Rc2123	vbottom<7>#372	vbottom<7>#373	0.664836	$metal3
+ $W=3e-07
Rc2124	vbottom<7>#373	vbottom<7>#374	0.556646	$metal3
+ $W=3e-07
Rc2125	vbottom<7>#374	vbottom<7>#375	0.523746	$metal3
+ $W=6e-07
Rc2126	vbottom<7>#375	vbottom<7>#376	0.664836	$metal3
+ $W=3e-07
Rc2127	vbottom<7>#376	vbottom<7>#377	0.556646	$metal3
+ $W=3e-07
Rc2128	vbottom<7>#377	vbottom<7>#378	0.523746	$metal3
+ $W=6e-07
Rc2129	vbottom<7>#378	vbottom<7>#379	0.664836	$metal3
+ $W=3e-07
Rc2130	vbottom<7>#379	vbottom<7>#380	0.556646	$metal3
+ $W=3e-07
Rc2131	vbottom<7>#380	vbottom<7>#381	0.523746	$metal3
+ $W=6e-07
Rc2132	vbottom<7>#381	vbottom<7>#382	0.664836	$metal3
+ $W=3e-07
Rc2133	vbottom<7>#382	vbottom<7>#383	0.556646	$metal3
+ $W=3e-07
Rc2134	vbottom<7>#383	vbottom<7>#384	0.523746	$metal3
+ $W=6e-07
Rc2135	vbottom<7>#384	vbottom<7>#385	0.664836	$metal3
+ $W=3e-07
Rc2136	vbottom<7>#385	vbottom<7>#386	0.556646	$metal3
+ $W=3e-07
Rc2137	vbottom<7>#386	vbottom<7>#387	0.523746	$metal3
+ $W=6e-07
Rc2138	vbottom<7>#387	vbottom<7>#388	0.664836	$metal3
+ $W=3e-07
Rc2139	vbottom<7>#388	vbottom<7>#389	0.556646	$metal3
+ $W=3e-07
Rc2140	vbottom<7>#389	vbottom<7>#390	0.523746	$metal3
+ $W=6e-07
Rc2141	vbottom<7>#390	vbottom<7>#391	0.664836	$metal3
+ $W=3e-07
Rc2142	vbottom<7>#391	vbottom<7>#392	0.556646	$metal3
+ $W=3e-07
Rc2143	vbottom<7>#392	vbottom<7>#393	0.523746	$metal3
+ $W=6e-07
Rc2144	vbottom<7>#393	vbottom<7>#394	0.618108	$metal3
+ $W=3e-07
Rc2145	vbottom<7>#393	vbottom<7>#395	0.337203	$metal3
+ $W=3e-07
Rc2146	vbottom<7>#395	vbottom<7>#396	0.672969	$metal3
+ $W=3e-07
Rc2147	vbottom<7>#394	vbottom<7>#302	0.046728	$metal3
+ $W=4.35e-07
Rc2148	vbottom<7>#396	vbottom<7>#302	0.345935	$metal3
+ $W=3e-07
Rc2149	vbottom<7>#396	vbottom<7>#298	0.345935	$metal3
+ $W=3e-07
Rc2150	vbottom<7>#396	vbottom<7>#397	0.661227	$metal3
+ $W=3e-07
Rc2151	vbottom<7>#397	vbottom<7>#297	0.047720	$metal3
+ $W=3e-07
Rc2152	vbottom<7>#397	vbottom<7>#398	0.226767	$metal3
+ $W=6e-07
Rc2153	vbottom<7>#398	vbottom<7>#296	0.025931	$metal3
+ $W=4.2e-06
Rc2154	vbottom<7>#398	vbottom<7>#399	0.182125	$metal3
+ $W=6e-07
Rc2155	vbottom<7>#399	vbottom<7>#295	0.337203	$metal3
+ $W=3e-07
Rc2156	vbottom<7>#399	vbottom<7>#400	0.673659	$metal3
+ $W=3e-07
Rc2157	vbottom<7>#400	vbottom<7>#294	0.047720	$metal3
+ $W=3e-07
Rc2158	vbottom<7>#400	vbottom<7>#401	0.226767	$metal3
+ $W=6e-07
Rc2159	vbottom<7>#401	vbottom<7>#293	0.025931	$metal3
+ $W=4.2e-06
Rc2160	vbottom<7>#401	vbottom<7>#402	0.182125	$metal3
+ $W=6e-07
Rc2161	vbottom<7>#402	vbottom<7>#292	0.337203	$metal3
+ $W=3e-07
Rc2162	vbottom<7>#402	vbottom<7>#403	0.673659	$metal3
+ $W=3e-07
Rc2163	vbottom<7>#403	vbottom<7>#291	0.047720	$metal3
+ $W=3e-07
Rc2164	vbottom<7>#403	vbottom<7>#404	0.226767	$metal3
+ $W=6e-07
Rc2165	vbottom<7>#404	vbottom<7>#290	0.025931	$metal3
+ $W=4.2e-06
Rc2166	vbottom<7>#404	vbottom<7>#405	0.182125	$metal3
+ $W=6e-07
Rc2167	vbottom<7>#405	vbottom<7>#289	0.337203	$metal3
+ $W=3e-07
Rc2168	vbottom<7>#405	vbottom<7>#406	0.673659	$metal3
+ $W=3e-07
Rc2169	vbottom<7>#406	vbottom<7>#288	0.047720	$metal3
+ $W=3e-07
Rc2170	vbottom<7>#406	vbottom<7>#407	0.226767	$metal3
+ $W=6e-07
Rc2171	vbottom<7>#407	vbottom<7>#287	0.025931	$metal3
+ $W=4.2e-06
Rc2172	vbottom<7>#407	vbottom<7>#408	0.182125	$metal3
+ $W=6e-07
Rc2173	vbottom<7>#408	vbottom<7>#286	0.337203	$metal3
+ $W=3e-07
Rc2174	vbottom<7>#408	vbottom<7>#409	0.673659	$metal3
+ $W=3e-07
Rc2175	vbottom<7>#409	vbottom<7>#285	0.047720	$metal3
+ $W=3e-07
Rc2176	vbottom<7>#409	vbottom<7>#410	0.226767	$metal3
+ $W=6e-07
Rc2177	vbottom<7>#410	vbottom<7>#284	0.025931	$metal3
+ $W=4.2e-06
Rc2178	vbottom<7>#410	vbottom<7>#411	0.182125	$metal3
+ $W=6e-07
Rc2179	vbottom<7>#411	vbottom<7>#283	0.337203	$metal3
+ $W=3e-07
Rc2180	vbottom<7>#411	vbottom<7>#412	0.673659	$metal3
+ $W=3e-07
Rc2181	vbottom<7>#412	vbottom<7>#282	0.047720	$metal3
+ $W=3e-07
Rc2182	vbottom<7>#412	vbottom<7>#413	0.226767	$metal3
+ $W=6e-07
Rc2183	vbottom<7>#413	vbottom<7>#281	0.025931	$metal3
+ $W=4.2e-06
Rc2184	vbottom<7>#413	vbottom<7>#414	0.182125	$metal3
+ $W=6e-07
Rc2185	vbottom<7>#414	vbottom<7>#280	0.337203	$metal3
+ $W=3e-07
Rc2186	vbottom<7>#414	vbottom<7>#415	0.673659	$metal3
+ $W=3e-07
Rc2187	vbottom<7>#415	vbottom<7>#279	0.047720	$metal3
+ $W=3e-07
Rc2188	vbottom<7>#415	vbottom<7>#416	0.226767	$metal3
+ $W=6e-07
Rc2189	vbottom<7>#416	vbottom<7>#278	0.025931	$metal3
+ $W=4.2e-06
Rc2190	vbottom<7>#416	vbottom<7>#417	0.182125	$metal3
+ $W=6e-07
Rc2191	vbottom<7>#417	vbottom<7>#277	0.337203	$metal3
+ $W=3e-07
Rc2192	vbottom<7>#417	vbottom<7>#418	0.673659	$metal3
+ $W=3e-07
Rc2193	vbottom<7>#418	vbottom<7>#276	0.047720	$metal3
+ $W=3e-07
Rc2194	vbottom<7>#418	vbottom<7>#419	0.226767	$metal3
+ $W=6e-07
Rc2195	vbottom<7>#419	vbottom<7>#275	0.025931	$metal3
+ $W=4.2e-06
Rc2196	vbottom<7>#419	vbottom<7>#420	0.182125	$metal3
+ $W=6e-07
Rc2197	vbottom<7>#420	vbottom<7>#274	0.337203	$metal3
+ $W=3e-07
Rc2198	vbottom<7>#420	vbottom<7>#421	0.673659	$metal3
+ $W=3e-07
Rc2199	vbottom<7>#421	vbottom<7>#273	0.047720	$metal3
+ $W=3e-07
Rc2200	vbottom<7>#421	vbottom<7>#422	0.226767	$metal3
+ $W=6e-07
Rc2201	vbottom<7>#422	vbottom<7>#272	0.025931	$metal3
+ $W=4.2e-06
Rc2202	vbottom<7>#422	vbottom<7>#423	0.182125	$metal3
+ $W=6e-07
Rc2203	vbottom<7>#423	vbottom<7>#271	0.337203	$metal3
+ $W=3e-07
Rc2204	vbottom<7>#423	vbottom<7>#424	0.673659	$metal3
+ $W=3e-07
Rc2205	vbottom<7>#424	vbottom<7>#270	0.047720	$metal3
+ $W=3e-07
Rc2206	vbottom<7>#424	vbottom<7>#425	0.226767	$metal3
+ $W=6e-07
Rc2207	vbottom<7>#425	vbottom<7>#269	0.025931	$metal3
+ $W=4.2e-06
Rc2208	vbottom<7>#425	vbottom<7>#426	0.182125	$metal3
+ $W=6e-07
Rc2209	vbottom<7>#426	vbottom<7>#268	0.337203	$metal3
+ $W=3e-07
Rc2210	vbottom<7>#426	vbottom<7>#427	0.673659	$metal3
+ $W=3e-07
Rc2211	vbottom<7>#427	vbottom<7>#267	0.047720	$metal3
+ $W=3e-07
Rc2212	vbottom<7>#427	vbottom<7>#428	0.226767	$metal3
+ $W=6e-07
Rc2213	vbottom<7>#428	vbottom<7>#266	0.025931	$metal3
+ $W=4.2e-06
Rc2214	vbottom<7>#428	vbottom<7>#429	0.182125	$metal3
+ $W=6e-07
Rc2215	vbottom<7>#429	vbottom<7>#265	0.337203	$metal3
+ $W=3e-07
Rc2216	vbottom<7>#429	vbottom<7>#430	0.672969	$metal3
+ $W=3e-07
Rc2217	vbottom<7>#430	vbottom<7>#264	0.056452	$metal3
+ $W=3e-07
Rc2218	vbottom<7>#430	vbottom<7>#431	0.345935	$metal3
+ $W=3e-07
Rc2219	vbottom<7>#431	vbottom<7>#263	0.025931	$metal3
+ $W=4.2e-06
Rc2220	vbottom<7>#431	vbottom<7>#432	0.215025	$metal3
+ $W=6e-07
Rc2221	vbottom<7>#431	vbottom<7>#433	0.698840	$metal3
+ $W=3e-07
Rc2222	vbottom<7>#433	vbottom<7>#434	0.337203	$metal3
+ $W=3e-07
Rc2223	vbottom<7>#434	vbottom<7>#435	0.330958	$metal3
+ $W=3e-07
Rc2224	vbottom<7>#432	vbottom<7>#262	0.337203	$metal3
+ $W=3e-07
Rc2225	vbottom<7>#432	vbottom<7>#436	0.672969	$metal3
+ $W=3e-07
Rc2226	vbottom<7>#434	vbottom<7>#437	0.215025	$metal3
+ $W=6e-07
Rc2227	vbottom<7>#437	vbottom<7>#438	0.025931	$metal3
+ $W=4.2e-06
Rc2228	vbottom<7>#435	vbottom<7>#430	0.330268	$metal3
+ $W=3e-07
Rc2229	vbottom<7>#436	vbottom<7>#261	0.345935	$metal3
+ $W=3e-07
Rc2230	vbottom<7>#436	vbottom<7>#439	0.345935	$metal3
+ $W=3e-07
Rc2231	vbottom<7>#438	vbottom<7>#433	0.025931	$metal3
+ $W=4.2e-06
Rc2232	vbottom<7>#438	vbottom<7>#440	0.025931	$metal3
+ $W=4.2e-06
Rc2233	vbottom<7>#440	vbottom<7>#441	0.337203	$metal3
+ $W=3e-07
Rc2234	vbottom<7>#439	vbottom<7>#260	0.025931	$metal3
+ $W=4.2e-06
Rc2235	vbottom<7>#439	vbottom<7>#442	0.215025	$metal3
+ $W=6e-07
Rc2236	vbottom<7>#440	vbottom<7>#443	0.556646	$metal3
+ $W=6e-07
Rc2237	vbottom<7>#443	vbottom<7>#444	0.337203	$metal3
+ $W=3e-07
Rc2238	vbottom<7>#444	vbottom<7>#445	0.684225	$metal3
+ $W=3e-07
Rc2239	vbottom<7>#445	vbottom<7>#446	0.337791	$metal3
+ $W=3e-07
Rc2240	vbottom<7>#446	vbottom<7>#447	0.315692	$metal3
+ $W=3e-07
Rc2241	vbottom<7>#441	vbottom<7>#433	0.215025	$metal3
+ $W=6e-07
Rc2242	vbottom<7>#442	vbottom<7>#259	0.337203	$metal3
+ $W=3e-07
Rc2243	vbottom<7>#442	vbottom<7>#448	0.672969	$metal3
+ $W=3e-07
Rc2244	vbottom<7>#443	vbottom<7>#438	0.025931	$metal3
+ $W=4.2e-06
Rc2245	vbottom<7>#444	vbottom<7>#437	0.182125	$metal3
+ $W=6e-07
Rc2246	vbottom<7>#446	vbottom<7>#449	0.556646	$metal3
+ $W=6e-07
Rc2247	vbottom<7>#449	vbottom<7>#450	0.025931	$metal3
+ $W=4.2e-06
Rc2248	vbottom<7>#450	vbottom<7>#451	0.025931	$metal3
+ $W=4.2e-06
Rc2249	vbottom<7>#451	vbottom<7>#452	0.193867	$metal3
+ $W=6e-07
Rc2250	vbottom<7>#452	vbottom<7>#453	0.337203	$metal3
+ $W=3e-07
Rc2251	vbottom<7>#447	vbottom<7>#443	0.349420	$metal3
+ $W=3e-07
Rc2252	vbottom<7>#448	vbottom<7>#258	0.345935	$metal3
+ $W=3e-07
Rc2253	vbottom<7>#448	vbottom<7>#454	0.345935	$metal3
+ $W=3e-07
Rc2254	vbottom<7>#454	vbottom<7>#455	0.025931	$metal3
+ $W=4.2e-06
Rc2255	vbottom<7>#450	vbottom<7>#446	0.025931	$metal3
+ $W=4.2e-06
Rc2256	vbottom<7>#451	vbottom<7>#445	0.192692	$metal3
+ $W=6e-07
Rc2257	vbottom<7>#453	vbottom<7>#450	0.025931	$metal3
+ $W=4.2e-06
Rc2258	vbottom<7>#453	vbottom<7>#456	0.337203	$metal3
+ $W=3e-07
Rc2259	vbottom<7>#453	vbottom<7>#457	0.698840	$metal3
+ $W=3e-07
Rc2260	vbottom<7>#457	vbottom<7>#458	0.337203	$metal3
+ $W=3e-07
Rc2261	vbottom<7>#458	vbottom<7>#459	0.330958	$metal3
+ $W=3e-07
Rc2262	vbottom<7>#454	vbottom<7>#460	0.698840	$metal3
+ $W=3e-07
Rc2263	vbottom<7>#460	vbottom<7>#461	0.337203	$metal3
+ $W=3e-07
Rc2264	vbottom<7>#461	vbottom<7>#462	0.330958	$metal3
+ $W=3e-07
Rc2265	vbottom<7>#455	vbottom<7>#258	0.025931	$metal3
+ $W=4.2e-06
Rc2266	vbottom<7>#455	vbottom<7>#255	0.025931	$metal3
+ $W=4.2e-06
Rc2267	vbottom<7>#455	vbottom<7>#463	0.025931	$metal3
+ $W=4.2e-06
Rc2268	vbottom<7>#463	vbottom<7>#464	0.337203	$metal3
+ $W=3e-07
Rc2269	vbottom<7>#456	vbottom<7>#449	0.215025	$metal3
+ $W=6e-07
Rc2270	vbottom<7>#458	vbottom<7>#465	0.215025	$metal3
+ $W=6e-07
Rc2271	vbottom<7>#465	vbottom<7>#466	0.025931	$metal3
+ $W=4.2e-06
Rc2272	vbottom<7>#459	vbottom<7>#452	0.342700	$metal3
+ $W=3e-07
Rc2273	vbottom<7>#461	vbottom<7>#467	0.215025	$metal3
+ $W=6e-07
Rc2274	vbottom<7>#467	vbottom<7>#468	0.025931	$metal3
+ $W=4.2e-06
Rc2275	vbottom<7>#462	vbottom<7>#448	0.330268	$metal3
+ $W=3e-07
Rc2276	vbottom<7>#463	vbottom<7>#469	0.226767	$metal3
+ $W=6e-07
Rc2277	vbottom<7>#464	vbottom<7>#255	0.215025	$metal3
+ $W=6e-07
Rc2278	vbottom<7>#466	vbottom<7>#457	0.025931	$metal3
+ $W=4.2e-06
Rc2279	vbottom<7>#466	vbottom<7>#470	0.025931	$metal3
+ $W=4.2e-06
Rc2280	vbottom<7>#470	vbottom<7>#471	0.337203	$metal3
+ $W=3e-07
Rc2281	vbottom<7>#468	vbottom<7>#460	0.025931	$metal3
+ $W=4.2e-06
Rc2282	vbottom<7>#468	vbottom<7>#472	0.025931	$metal3
+ $W=4.2e-06
Rc2283	vbottom<7>#472	vbottom<7>#473	0.337203	$metal3
+ $W=3e-07
Rc2284	vbottom<7>#469	vbottom<7>#454	0.337203	$metal3
+ $W=3e-07
Rc2285	vbottom<7>#470	vbottom<7>#474	0.556646	$metal3
+ $W=6e-07
Rc2286	vbottom<7>#474	vbottom<7>#475	0.337203	$metal3
+ $W=3e-07
Rc2287	vbottom<7>#475	vbottom<7>#476	0.684225	$metal3
+ $W=3e-07
Rc2288	vbottom<7>#476	vbottom<7>#477	0.337791	$metal3
+ $W=3e-07
Rc2289	vbottom<7>#477	vbottom<7>#478	0.315692	$metal3
+ $W=3e-07
Rc2290	vbottom<7>#471	vbottom<7>#457	0.215025	$metal3
+ $W=6e-07
Rc2291	vbottom<7>#472	vbottom<7>#479	0.556646	$metal3
+ $W=6e-07
Rc2292	vbottom<7>#479	vbottom<7>#480	0.337203	$metal3
+ $W=3e-07
Rc2293	vbottom<7>#480	vbottom<7>#481	0.684225	$metal3
+ $W=3e-07
Rc2294	vbottom<7>#481	vbottom<7>#482	0.337791	$metal3
+ $W=3e-07
Rc2295	vbottom<7>#482	vbottom<7>#483	0.315692	$metal3
+ $W=3e-07
Rc2296	vbottom<7>#473	vbottom<7>#460	0.215025	$metal3
+ $W=6e-07
Rc2297	vbottom<7>#474	vbottom<7>#466	0.025931	$metal3
+ $W=4.2e-06
Rc2298	vbottom<7>#475	vbottom<7>#465	0.182125	$metal3
+ $W=6e-07
Rc2299	vbottom<7>#477	vbottom<7>#484	0.556646	$metal3
+ $W=6e-07
Rc2300	vbottom<7>#484	vbottom<7>#485	0.025931	$metal3
+ $W=4.2e-06
Rc2301	vbottom<7>#485	vbottom<7>#486	0.025931	$metal3
+ $W=4.2e-06
Rc2302	vbottom<7>#486	vbottom<7>#487	0.193867	$metal3
+ $W=6e-07
Rc2303	vbottom<7>#487	vbottom<7>#488	0.337203	$metal3
+ $W=3e-07
Rc2304	vbottom<7>#478	vbottom<7>#474	0.349420	$metal3
+ $W=3e-07
Rc2305	vbottom<7>#479	vbottom<7>#468	0.025931	$metal3
+ $W=4.2e-06
Rc2306	vbottom<7>#480	vbottom<7>#467	0.182125	$metal3
+ $W=6e-07
Rc2307	vbottom<7>#482	vbottom<7>#489	0.556646	$metal3
+ $W=6e-07
Rc2308	vbottom<7>#489	vbottom<7>#490	0.025931	$metal3
+ $W=4.2e-06
Rc2309	vbottom<7>#490	vbottom<7>#491	0.025931	$metal3
+ $W=4.2e-06
Rc2310	vbottom<7>#491	vbottom<7>#492	0.193867	$metal3
+ $W=6e-07
Rc2311	vbottom<7>#492	vbottom<7>#493	0.337203	$metal3
+ $W=3e-07
Rc2312	vbottom<7>#483	vbottom<7>#479	0.349420	$metal3
+ $W=3e-07
Rc2313	vbottom<7>#485	vbottom<7>#477	0.025931	$metal3
+ $W=4.2e-06
Rc2314	vbottom<7>#486	vbottom<7>#476	0.192692	$metal3
+ $W=6e-07
Rc2315	vbottom<7>#488	vbottom<7>#485	0.025931	$metal3
+ $W=4.2e-06
Rc2316	vbottom<7>#488	vbottom<7>#494	0.337203	$metal3
+ $W=3e-07
Rc2317	vbottom<7>#488	vbottom<7>#495	0.698840	$metal3
+ $W=3e-07
Rc2318	vbottom<7>#495	vbottom<7>#496	0.337203	$metal3
+ $W=3e-07
Rc2319	vbottom<7>#496	vbottom<7>#497	0.330958	$metal3
+ $W=3e-07
Rc2320	vbottom<7>#490	vbottom<7>#482	0.025931	$metal3
+ $W=4.2e-06
Rc2321	vbottom<7>#491	vbottom<7>#481	0.192692	$metal3
+ $W=6e-07
Rc2322	vbottom<7>#493	vbottom<7>#490	0.025931	$metal3
+ $W=4.2e-06
Rc2323	vbottom<7>#493	vbottom<7>#498	0.337203	$metal3
+ $W=3e-07
Rc2324	vbottom<7>#493	vbottom<7>#499	0.698840	$metal3
+ $W=3e-07
Rc2325	vbottom<7>#499	vbottom<7>#500	0.337203	$metal3
+ $W=3e-07
Rc2326	vbottom<7>#500	vbottom<7>#501	0.330958	$metal3
+ $W=3e-07
Rc2327	vbottom<7>#494	vbottom<7>#484	0.215025	$metal3
+ $W=6e-07
Rc2328	vbottom<7>#496	vbottom<7>#502	0.215025	$metal3
+ $W=6e-07
Rc2329	vbottom<7>#502	vbottom<7>#503	0.025931	$metal3
+ $W=4.2e-06
Rc2330	vbottom<7>#497	vbottom<7>#487	0.342700	$metal3
+ $W=3e-07
Rc2331	vbottom<7>#498	vbottom<7>#489	0.215025	$metal3
+ $W=6e-07
Rc2332	vbottom<7>#500	vbottom<7>#504	0.215025	$metal3
+ $W=6e-07
Rc2333	vbottom<7>#504	vbottom<7>#505	0.025931	$metal3
+ $W=4.2e-06
Rc2334	vbottom<7>#501	vbottom<7>#492	0.342700	$metal3
+ $W=3e-07
Rc2335	vbottom<7>#503	vbottom<7>#495	0.025931	$metal3
+ $W=4.2e-06
Rc2336	vbottom<7>#503	vbottom<7>#506	0.025931	$metal3
+ $W=4.2e-06
Rc2337	vbottom<7>#506	vbottom<7>#507	0.337203	$metal3
+ $W=3e-07
Rc2338	vbottom<7>#505	vbottom<7>#499	0.025931	$metal3
+ $W=4.2e-06
Rc2339	vbottom<7>#505	vbottom<7>#508	0.025931	$metal3
+ $W=4.2e-06
Rc2340	vbottom<7>#508	vbottom<7>#509	0.337203	$metal3
+ $W=3e-07
Rc2341	vbottom<7>#506	vbottom<7>#510	0.556646	$metal3
+ $W=6e-07
Rc2342	vbottom<7>#510	vbottom<7>#511	0.337203	$metal3
+ $W=3e-07
Rc2343	vbottom<7>#511	vbottom<7>#512	0.684225	$metal3
+ $W=3e-07
Rc2344	vbottom<7>#512	vbottom<7>#513	0.337791	$metal3
+ $W=3e-07
Rc2345	vbottom<7>#513	vbottom<7>#514	0.315692	$metal3
+ $W=3e-07
Rc2346	vbottom<7>#507	vbottom<7>#495	0.215025	$metal3
+ $W=6e-07
Rc2347	vbottom<7>#508	vbottom<7>#515	0.556646	$metal3
+ $W=6e-07
Rc2348	vbottom<7>#515	vbottom<7>#516	0.337203	$metal3
+ $W=3e-07
Rc2349	vbottom<7>#516	vbottom<7>#517	0.684225	$metal3
+ $W=3e-07
Rc2350	vbottom<7>#517	vbottom<7>#518	0.337791	$metal3
+ $W=3e-07
Rc2351	vbottom<7>#518	vbottom<7>#519	0.315692	$metal3
+ $W=3e-07
Rc2352	vbottom<7>#509	vbottom<7>#499	0.215025	$metal3
+ $W=6e-07
Rc2353	vbottom<7>#510	vbottom<7>#503	0.025931	$metal3
+ $W=4.2e-06
Rc2354	vbottom<7>#511	vbottom<7>#502	0.182125	$metal3
+ $W=6e-07
Rc2355	vbottom<7>#513	vbottom<7>#520	0.556646	$metal3
+ $W=6e-07
Rc2356	vbottom<7>#520	vbottom<7>#521	0.025931	$metal3
+ $W=4.2e-06
Rc2357	vbottom<7>#521	vbottom<7>#522	0.025931	$metal3
+ $W=4.2e-06
Rc2358	vbottom<7>#522	vbottom<7>#523	0.193867	$metal3
+ $W=6e-07
Rc2359	vbottom<7>#523	vbottom<7>#524	0.337203	$metal3
+ $W=3e-07
Rc2360	vbottom<7>#514	vbottom<7>#510	0.349420	$metal3
+ $W=3e-07
Rc2361	vbottom<7>#515	vbottom<7>#505	0.025931	$metal3
+ $W=4.2e-06
Rc2362	vbottom<7>#516	vbottom<7>#504	0.182125	$metal3
+ $W=6e-07
Rc2363	vbottom<7>#518	vbottom<7>#525	0.556646	$metal3
+ $W=6e-07
Rc2364	vbottom<7>#525	vbottom<7>#526	0.025931	$metal3
+ $W=4.2e-06
Rc2365	vbottom<7>#526	vbottom<7>#527	0.025931	$metal3
+ $W=4.2e-06
Rc2366	vbottom<7>#527	vbottom<7>#528	0.193867	$metal3
+ $W=6e-07
Rc2367	vbottom<7>#528	vbottom<7>#529	0.337203	$metal3
+ $W=3e-07
Rc2368	vbottom<7>#519	vbottom<7>#515	0.349420	$metal3
+ $W=3e-07
Rc2369	vbottom<7>#521	vbottom<7>#513	0.025931	$metal3
+ $W=4.2e-06
Rc2370	vbottom<7>#522	vbottom<7>#512	0.192692	$metal3
+ $W=6e-07
Rc2371	vbottom<7>#524	vbottom<7>#521	0.025931	$metal3
+ $W=4.2e-06
Rc2372	vbottom<7>#524	vbottom<7>#530	0.337203	$metal3
+ $W=3e-07
Rc2373	vbottom<7>#524	vbottom<7>#531	0.698840	$metal3
+ $W=3e-07
Rc2374	vbottom<7>#531	vbottom<7>#532	0.337203	$metal3
+ $W=3e-07
Rc2375	vbottom<7>#532	vbottom<7>#533	0.330958	$metal3
+ $W=3e-07
Rc2376	vbottom<7>#526	vbottom<7>#518	0.025931	$metal3
+ $W=4.2e-06
Rc2377	vbottom<7>#527	vbottom<7>#517	0.192692	$metal3
+ $W=6e-07
Rc2378	vbottom<7>#529	vbottom<7>#526	0.025931	$metal3
+ $W=4.2e-06
Rc2379	vbottom<7>#529	vbottom<7>#534	0.337203	$metal3
+ $W=3e-07
Rc2380	vbottom<7>#529	vbottom<7>#535	0.698840	$metal3
+ $W=3e-07
Rc2381	vbottom<7>#535	vbottom<7>#536	0.337203	$metal3
+ $W=3e-07
Rc2382	vbottom<7>#536	vbottom<7>#537	0.330958	$metal3
+ $W=3e-07
Rc2383	vbottom<7>#530	vbottom<7>#520	0.215025	$metal3
+ $W=6e-07
Rc2384	vbottom<7>#532	vbottom<7>#538	0.215025	$metal3
+ $W=6e-07
Rc2385	vbottom<7>#538	vbottom<7>#539	0.025931	$metal3
+ $W=4.2e-06
Rc2386	vbottom<7>#533	vbottom<7>#523	0.342700	$metal3
+ $W=3e-07
Rc2387	vbottom<7>#534	vbottom<7>#525	0.215025	$metal3
+ $W=6e-07
Rc2388	vbottom<7>#536	vbottom<7>#540	0.215025	$metal3
+ $W=6e-07
Rc2389	vbottom<7>#540	vbottom<7>#541	0.025931	$metal3
+ $W=4.2e-06
Rc2390	vbottom<7>#537	vbottom<7>#528	0.342700	$metal3
+ $W=3e-07
Rc2391	vbottom<7>#539	vbottom<7>#531	0.025931	$metal3
+ $W=4.2e-06
Rc2392	vbottom<7>#539	vbottom<7>#542	0.025931	$metal3
+ $W=4.2e-06
Rc2393	vbottom<7>#542	vbottom<7>#543	0.337203	$metal3
+ $W=3e-07
Rc2394	vbottom<7>#541	vbottom<7>#535	0.025931	$metal3
+ $W=4.2e-06
Rc2395	vbottom<7>#541	vbottom<7>#544	0.025931	$metal3
+ $W=4.2e-06
Rc2396	vbottom<7>#544	vbottom<7>#545	0.337203	$metal3
+ $W=3e-07
Rc2397	vbottom<7>#542	vbottom<7>#546	0.556646	$metal3
+ $W=6e-07
Rc2398	vbottom<7>#546	vbottom<7>#547	0.337203	$metal3
+ $W=3e-07
Rc2399	vbottom<7>#547	vbottom<7>#548	0.684225	$metal3
+ $W=3e-07
Rc2400	vbottom<7>#548	vbottom<7>#549	0.337791	$metal3
+ $W=3e-07
Rc2401	vbottom<7>#549	vbottom<7>#550	0.315692	$metal3
+ $W=3e-07
Rc2402	vbottom<7>#543	vbottom<7>#531	0.215025	$metal3
+ $W=6e-07
Rc2403	vbottom<7>#544	vbottom<7>#551	0.556646	$metal3
+ $W=6e-07
Rc2404	vbottom<7>#551	vbottom<7>#552	0.337203	$metal3
+ $W=3e-07
Rc2405	vbottom<7>#552	vbottom<7>#553	0.684225	$metal3
+ $W=3e-07
Rc2406	vbottom<7>#553	vbottom<7>#554	0.337791	$metal3
+ $W=3e-07
Rc2407	vbottom<7>#554	vbottom<7>#555	0.315692	$metal3
+ $W=3e-07
Rc2408	vbottom<7>#545	vbottom<7>#535	0.215025	$metal3
+ $W=6e-07
Rc2409	vbottom<7>#546	vbottom<7>#539	0.025931	$metal3
+ $W=4.2e-06
Rc2410	vbottom<7>#547	vbottom<7>#538	0.182125	$metal3
+ $W=6e-07
Rc2411	vbottom<7>#549	vbottom<7>#556	0.556646	$metal3
+ $W=6e-07
Rc2412	vbottom<7>#556	vbottom<7>#557	0.025931	$metal3
+ $W=4.2e-06
Rc2413	vbottom<7>#557	vbottom<7>#558	0.025931	$metal3
+ $W=4.2e-06
Rc2414	vbottom<7>#558	vbottom<7>#559	0.523746	$metal3
+ $W=6e-07
Rc2415	vbottom<7>#550	vbottom<7>#546	0.349420	$metal3
+ $W=3e-07
Rc2416	vbottom<7>#551	vbottom<7>#541	0.025931	$metal3
+ $W=4.2e-06
Rc2417	vbottom<7>#552	vbottom<7>#540	0.182125	$metal3
+ $W=6e-07
Rc2418	vbottom<7>#554	vbottom<7>#560	0.556646	$metal3
+ $W=6e-07
Rc2419	vbottom<7>#560	vbottom<7>#561	0.025931	$metal3
+ $W=4.2e-06
Rc2420	vbottom<7>#561	vbottom<7>#562	0.025931	$metal3
+ $W=4.2e-06
Rc2421	vbottom<7>#562	vbottom<7>#563	0.193867	$metal3
+ $W=6e-07
Rc2422	vbottom<7>#563	vbottom<7>#564	0.337203	$metal3
+ $W=3e-07
Rc2423	vbottom<7>#555	vbottom<7>#551	0.349420	$metal3
+ $W=3e-07
Rc2424	vbottom<7>#557	vbottom<7>#549	0.025931	$metal3
+ $W=4.2e-06
Rc2425	vbottom<7>#558	vbottom<7>#548	0.192692	$metal3
+ $W=6e-07
Rc2426	vbottom<7>#559	vbottom<7>#557	0.025931	$metal3
+ $W=4.2e-06
Rc2427	vbottom<7>#559	vbottom<7>#565	0.337203	$metal3
+ $W=3e-07
Rc2428	vbottom<7>#561	vbottom<7>#554	0.025931	$metal3
+ $W=4.2e-06
Rc2429	vbottom<7>#562	vbottom<7>#553	0.192692	$metal3
+ $W=6e-07
Rc2430	vbottom<7>#564	vbottom<7>#561	0.025931	$metal3
+ $W=4.2e-06
Rc2431	vbottom<7>#564	vbottom<7>#566	0.337203	$metal3
+ $W=3e-07
Rc2432	vbottom<7>#564	vbottom<7>#567	0.698840	$metal3
+ $W=3e-07
Rc2433	vbottom<7>#567	vbottom<7>#568	0.337203	$metal3
+ $W=3e-07
Rc2434	vbottom<7>#568	vbottom<7>#569	0.330958	$metal3
+ $W=3e-07
Rc2435	vbottom<7>#565	vbottom<7>#556	0.215025	$metal3
+ $W=6e-07
Rc2436	vbottom<7>#566	vbottom<7>#560	0.215025	$metal3
+ $W=6e-07
Rc2437	vbottom<7>#568	vbottom<7>#570	0.215025	$metal3
+ $W=6e-07
Rc2438	vbottom<7>#570	vbottom<7>#571	0.025931	$metal3
+ $W=4.2e-06
Rc2439	vbottom<7>#569	vbottom<7>#563	0.342700	$metal3
+ $W=3e-07
Rc2440	vbottom<7>#571	vbottom<7>#567	0.025931	$metal3
+ $W=4.2e-06
Rc2441	vbottom<7>#571	vbottom<7>#572	0.025931	$metal3
+ $W=4.2e-06
Rc2442	vbottom<7>#572	vbottom<7>#573	0.337203	$metal3
+ $W=3e-07
Rc2443	vbottom<7>#572	vbottom<7>#574	0.556646	$metal3
+ $W=6e-07
Rc2444	vbottom<7>#574	vbottom<7>#575	0.337203	$metal3
+ $W=3e-07
Rc2445	vbottom<7>#575	vbottom<7>#576	0.684225	$metal3
+ $W=3e-07
Rc2446	vbottom<7>#576	vbottom<7>#577	0.337791	$metal3
+ $W=3e-07
Rc2447	vbottom<7>#577	vbottom<7>#578	0.315692	$metal3
+ $W=3e-07
Rc2448	vbottom<7>#573	vbottom<7>#567	0.215025	$metal3
+ $W=6e-07
Rc2449	vbottom<7>#574	vbottom<7>#571	0.025931	$metal3
+ $W=4.2e-06
Rc2450	vbottom<7>#575	vbottom<7>#570	0.182125	$metal3
+ $W=6e-07
Rc2451	vbottom<7>#577	vbottom<7>#579	0.556646	$metal3
+ $W=6e-07
Rc2452	vbottom<7>#579	vbottom<7>#580	0.025931	$metal3
+ $W=4.2e-06
Rc2453	vbottom<7>#580	vbottom<7>#581	0.025931	$metal3
+ $W=4.2e-06
Rc2454	vbottom<7>#581	vbottom<7>#582	0.193867	$metal3
+ $W=6e-07
Rc2455	vbottom<7>#582	vbottom<7>#583	0.337203	$metal3
+ $W=3e-07
Rc2456	vbottom<7>#578	vbottom<7>#574	0.349420	$metal3
+ $W=3e-07
Rc2457	vbottom<7>#580	vbottom<7>#577	0.025931	$metal3
+ $W=4.2e-06
Rc2458	vbottom<7>#581	vbottom<7>#576	0.192692	$metal3
+ $W=6e-07
Rc2459	vbottom<7>#583	vbottom<7>#580	0.025931	$metal3
+ $W=4.2e-06
Rc2460	vbottom<7>#583	vbottom<7>#584	0.337203	$metal3
+ $W=3e-07
Rc2461	vbottom<7>#583	vbottom<7>#585	0.698840	$metal3
+ $W=3e-07
Rc2462	vbottom<7>#585	vbottom<7>#586	0.337203	$metal3
+ $W=3e-07
Rc2463	vbottom<7>#586	vbottom<7>#587	0.330958	$metal3
+ $W=3e-07
Rc2464	vbottom<7>#584	vbottom<7>#579	0.215025	$metal3
+ $W=6e-07
Rc2465	vbottom<7>#586	vbottom<7>#588	0.215025	$metal3
+ $W=6e-07
Rc2466	vbottom<7>#588	vbottom<7>#589	0.025931	$metal3
+ $W=4.2e-06
Rc2467	vbottom<7>#587	vbottom<7>#582	0.342700	$metal3
+ $W=3e-07
Rc2468	vbottom<7>#589	vbottom<7>#585	0.025931	$metal3
+ $W=4.2e-06
Rc2469	vbottom<7>#589	vbottom<7>#590	0.025931	$metal3
+ $W=4.2e-06
Rc2470	vbottom<7>#590	vbottom<7>#591	0.337203	$metal3
+ $W=3e-07
Rc2471	vbottom<7>#590	vbottom<7>#592	0.556646	$metal3
+ $W=6e-07
Rc2472	vbottom<7>#592	vbottom<7>#593	0.337203	$metal3
+ $W=3e-07
Rc2473	vbottom<7>#593	vbottom<7>#594	0.684225	$metal3
+ $W=3e-07
Rc2474	vbottom<7>#594	vbottom<7>#595	0.337791	$metal3
+ $W=3e-07
Rc2475	vbottom<7>#595	vbottom<7>#596	0.315692	$metal3
+ $W=3e-07
Rc2476	vbottom<7>#591	vbottom<7>#585	0.215025	$metal3
+ $W=6e-07
Rc2477	vbottom<7>#592	vbottom<7>#589	0.025931	$metal3
+ $W=4.2e-06
Rc2478	vbottom<7>#593	vbottom<7>#588	0.182125	$metal3
+ $W=6e-07
Rc2479	vbottom<7>#595	vbottom<7>#597	0.556646	$metal3
+ $W=6e-07
Rc2480	vbottom<7>#597	vbottom<7>#598	0.025931	$metal3
+ $W=4.2e-06
Rc2481	vbottom<7>#598	vbottom<7>#599	0.025931	$metal3
+ $W=4.2e-06
Rc2482	vbottom<7>#599	vbottom<7>#600	0.193867	$metal3
+ $W=6e-07
Rc2483	vbottom<7>#600	vbottom<7>#601	0.337203	$metal3
+ $W=3e-07
Rc2484	vbottom<7>#596	vbottom<7>#592	0.349420	$metal3
+ $W=3e-07
Rc2485	vbottom<7>#598	vbottom<7>#595	0.025931	$metal3
+ $W=4.2e-06
Rc2486	vbottom<7>#599	vbottom<7>#594	0.192692	$metal3
+ $W=6e-07
Rc2487	vbottom<7>#601	vbottom<7>#598	0.025931	$metal3
+ $W=4.2e-06
Rc2488	vbottom<7>#601	vbottom<7>#602	0.337203	$metal3
+ $W=3e-07
Rc2489	vbottom<7>#601	vbottom<7>#603	0.698840	$metal3
+ $W=3e-07
Rc2490	vbottom<7>#603	vbottom<7>#604	0.337203	$metal3
+ $W=3e-07
Rc2491	vbottom<7>#604	vbottom<7>#605	0.330958	$metal3
+ $W=3e-07
Rc2492	vbottom<7>#602	vbottom<7>#597	0.215025	$metal3
+ $W=6e-07
Rc2493	vbottom<7>#604	vbottom<7>#606	0.215025	$metal3
+ $W=6e-07
Rc2494	vbottom<7>#606	vbottom<7>#607	0.025931	$metal3
+ $W=4.2e-06
Rc2495	vbottom<7>#605	vbottom<7>#600	0.342700	$metal3
+ $W=3e-07
Rc2496	vbottom<7>#607	vbottom<7>#603	0.025931	$metal3
+ $W=4.2e-06
Rc2497	vbottom<7>#607	vbottom<7>#608	0.025931	$metal3
+ $W=4.2e-06
Rc2498	vbottom<7>#608	vbottom<7>#609	0.337203	$metal3
+ $W=3e-07
Rc2499	vbottom<7>#608	vbottom<7>#610	0.556646	$metal3
+ $W=6e-07
Rc2500	vbottom<7>#610	vbottom<7>#611	0.337203	$metal3
+ $W=3e-07
Rc2501	vbottom<7>#611	vbottom<7>#612	0.684225	$metal3
+ $W=3e-07
Rc2502	vbottom<7>#612	vbottom<7>#613	0.337791	$metal3
+ $W=3e-07
Rc2503	vbottom<7>#613	vbottom<7>#614	0.315692	$metal3
+ $W=3e-07
Rc2504	vbottom<7>#609	vbottom<7>#603	0.215025	$metal3
+ $W=6e-07
Rc2505	vbottom<7>#610	vbottom<7>#607	0.025931	$metal3
+ $W=4.2e-06
Rc2506	vbottom<7>#611	vbottom<7>#606	0.182125	$metal3
+ $W=6e-07
Rc2507	vbottom<7>#613	vbottom<7>#615	0.556646	$metal3
+ $W=6e-07
Rc2508	vbottom<7>#615	vbottom<7>#616	0.025931	$metal3
+ $W=4.2e-06
Rc2509	vbottom<7>#616	vbottom<7>#617	0.025931	$metal3
+ $W=4.2e-06
Rc2510	vbottom<7>#617	vbottom<7>#618	0.193867	$metal3
+ $W=6e-07
Rc2511	vbottom<7>#618	vbottom<7>#619	0.337203	$metal3
+ $W=3e-07
Rc2512	vbottom<7>#614	vbottom<7>#610	0.349420	$metal3
+ $W=3e-07
Rc2513	vbottom<7>#616	vbottom<7>#613	0.025931	$metal3
+ $W=4.2e-06
Rc2514	vbottom<7>#617	vbottom<7>#612	0.192692	$metal3
+ $W=6e-07
Rc2515	vbottom<7>#619	vbottom<7>#616	0.025931	$metal3
+ $W=4.2e-06
Rc2516	vbottom<7>#619	vbottom<7>#620	0.337203	$metal3
+ $W=3e-07
Rc2517	vbottom<7>#619	vbottom<7>#621	0.698840	$metal3
+ $W=3e-07
Rc2518	vbottom<7>#621	vbottom<7>#622	0.345935	$metal3
+ $W=3e-07
Rc2519	vbottom<7>#622	vbottom<7>#623	0.672969	$metal3
+ $W=3e-07
Rc2520	vbottom<7>#623	vbottom<7>#624	0.215025	$metal3
+ $W=6e-07
Rc2521	vbottom<7>#624	vbottom<7>#625	0.345935	$metal3
+ $W=3e-07
Rc2522	vbottom<7>#625	vbottom<7>#626	0.671793	$metal3
+ $W=3e-07
Rc2523	vbottom<7>#626	vbottom<7>#627	0.213850	$metal3
+ $W=6e-07
Rc2524	vbottom<7>#627	vbottom<7>#628	0.192692	$metal3
+ $W=6e-07
Rc2525	vbottom<7>#628	vbottom<7>#629	0.671308	$metal3
+ $W=3e-07
Rc2526	vbottom<7>#629	vbottom<7>#630	0.213850	$metal3
+ $W=6e-07
Rc2527	vbottom<7>#630	vbottom<7>#631	0.192692	$metal3
+ $W=6e-07
Rc2528	vbottom<7>#631	vbottom<7>#632	0.671308	$metal3
+ $W=3e-07
Rc2529	vbottom<7>#632	vbottom<7>#633	0.213850	$metal3
+ $W=6e-07
Rc2530	vbottom<7>#633	vbottom<7>#634	0.192692	$metal3
+ $W=6e-07
Rc2531	vbottom<7>#634	vbottom<7>#635	0.671308	$metal3
+ $W=3e-07
Rc2532	vbottom<7>#635	vbottom<7>#636	0.213850	$metal3
+ $W=6e-07
Rc2533	vbottom<7>#636	vbottom<7>#637	0.192692	$metal3
+ $W=6e-07
Rc2534	vbottom<7>#637	vbottom<7>#638	0.671308	$metal3
+ $W=3e-07
Rc2535	vbottom<7>#638	vbottom<7>#639	0.213850	$metal3
+ $W=6e-07
Rc2536	vbottom<7>#639	vbottom<7>#640	0.192692	$metal3
+ $W=6e-07
Rc2537	vbottom<7>#640	vbottom<7>#641	0.671308	$metal3
+ $W=3e-07
Rc2538	vbottom<7>#641	vbottom<7>#642	0.213850	$metal3
+ $W=6e-07
Rc2539	vbottom<7>#642	vbottom<7>#643	0.192692	$metal3
+ $W=6e-07
Rc2540	vbottom<7>#643	vbottom<7>#644	0.671308	$metal3
+ $W=3e-07
Rc2541	vbottom<7>#644	vbottom<7>#645	0.213850	$metal3
+ $W=6e-07
Rc2542	vbottom<7>#645	vbottom<7>#646	0.192692	$metal3
+ $W=6e-07
Rc2543	vbottom<7>#646	vbottom<7>#647	0.671308	$metal3
+ $W=3e-07
Rc2544	vbottom<7>#647	vbottom<7>#648	0.213850	$metal3
+ $W=6e-07
Rc2545	vbottom<7>#648	vbottom<7>#649	0.192692	$metal3
+ $W=6e-07
Rc2546	vbottom<7>#649	vbottom<7>#650	0.671308	$metal3
+ $W=3e-07
Rc2547	vbottom<7>#650	vbottom<7>#651	0.213850	$metal3
+ $W=6e-07
Rc2548	vbottom<7>#651	vbottom<7>#652	0.192692	$metal3
+ $W=6e-07
Rc2549	vbottom<7>#652	vbottom<7>#653	0.671308	$metal3
+ $W=3e-07
Rc2550	vbottom<7>#653	vbottom<7>#654	0.213850	$metal3
+ $W=6e-07
Rc2551	vbottom<7>#654	vbottom<7>#655	0.192692	$metal3
+ $W=6e-07
Rc2552	vbottom<7>#655	vbottom<7>#656	0.671308	$metal3
+ $W=3e-07
Rc2553	vbottom<7>#656	vbottom<7>#657	0.213850	$metal3
+ $W=6e-07
Rc2554	vbottom<7>#657	vbottom<7>#658	0.192692	$metal3
+ $W=6e-07
Rc2555	vbottom<7>#658	vbottom<7>#659	0.660051	$metal3
+ $W=3e-07
Rc2556	vbottom<7>#659	vbottom<7>#660	0.345935	$metal3
+ $W=3e-07
Rc2557	vbottom<7>#660	vbottom<7>#661	0.225592	$metal3
+ $W=6e-07
Rc2558	vbottom<7>#661	vbottom<7>#662	0.660051	$metal3
+ $W=3e-07
Rc2559	vbottom<7>#620	vbottom<7>#615	0.215025	$metal3
+ $W=6e-07
Rc2560	vbottom<7>#622	vbottom<7>#663	0.330268	$metal3
+ $W=3e-07
Rc2561	vbottom<7>#625	vbottom<7>#664	0.672969	$metal3
+ $W=3e-07
Rc2562	vbottom<7>#664	vbottom<7>#665	0.215025	$metal3
+ $W=6e-07
Rc2563	vbottom<7>#665	vbottom<7>#666	0.193867	$metal3
+ $W=6e-07
Rc2564	vbottom<7>#666	vbottom<7>#667	0.685401	$metal3
+ $W=3e-07
Rc2565	vbottom<7>#667	vbottom<7>#668	0.215025	$metal3
+ $W=6e-07
Rc2566	vbottom<7>#668	vbottom<7>#669	0.193867	$metal3
+ $W=6e-07
Rc2567	vbottom<7>#669	vbottom<7>#670	0.685401	$metal3
+ $W=3e-07
Rc2568	vbottom<7>#670	vbottom<7>#671	0.215025	$metal3
+ $W=6e-07
Rc2569	vbottom<7>#671	vbottom<7>#672	0.193867	$metal3
+ $W=6e-07
Rc2570	vbottom<7>#672	vbottom<7>#673	0.685401	$metal3
+ $W=3e-07
Rc2571	vbottom<7>#673	vbottom<7>#674	0.215025	$metal3
+ $W=6e-07
Rc2572	vbottom<7>#674	vbottom<7>#675	0.193867	$metal3
+ $W=6e-07
Rc2573	vbottom<7>#675	vbottom<7>#676	0.685401	$metal3
+ $W=3e-07
Rc2574	vbottom<7>#676	vbottom<7>#677	0.215025	$metal3
+ $W=6e-07
Rc2575	vbottom<7>#677	vbottom<7>#678	0.193867	$metal3
+ $W=6e-07
Rc2576	vbottom<7>#678	vbottom<7>#679	0.685401	$metal3
+ $W=3e-07
Rc2577	vbottom<7>#679	vbottom<7>#680	0.215025	$metal3
+ $W=6e-07
Rc2578	vbottom<7>#680	vbottom<7>#681	0.193867	$metal3
+ $W=6e-07
Rc2579	vbottom<7>#681	vbottom<7>#682	0.685401	$metal3
+ $W=3e-07
Rc2580	vbottom<7>#682	vbottom<7>#683	0.215025	$metal3
+ $W=6e-07
Rc2581	vbottom<7>#683	vbottom<7>#684	0.193867	$metal3
+ $W=6e-07
Rc2582	vbottom<7>#684	vbottom<7>#685	0.685401	$metal3
+ $W=3e-07
Rc2583	vbottom<7>#685	vbottom<7>#686	0.215025	$metal3
+ $W=6e-07
Rc2584	vbottom<7>#686	vbottom<7>#687	0.193867	$metal3
+ $W=6e-07
Rc2585	vbottom<7>#687	vbottom<7>#688	0.685401	$metal3
+ $W=3e-07
Rc2586	vbottom<7>#688	vbottom<7>#689	0.215025	$metal3
+ $W=6e-07
Rc2587	vbottom<7>#689	vbottom<7>#690	0.193867	$metal3
+ $W=6e-07
Rc2588	vbottom<7>#690	vbottom<7>#691	0.685401	$metal3
+ $W=3e-07
Rc2589	vbottom<7>#691	vbottom<7>#692	0.215025	$metal3
+ $W=6e-07
Rc2590	vbottom<7>#692	vbottom<7>#693	0.193867	$metal3
+ $W=6e-07
Rc2591	vbottom<7>#693	vbottom<7>#694	0.685401	$metal3
+ $W=3e-07
Rc2592	vbottom<7>#694	vbottom<7>#695	0.215025	$metal3
+ $W=6e-07
Rc2593	vbottom<7>#695	vbottom<7>#696	0.193867	$metal3
+ $W=6e-07
Rc2594	vbottom<7>#696	vbottom<7>#697	0.685401	$metal3
+ $W=3e-07
Rc2595	vbottom<7>#697	vbottom<7>#698	0.215025	$metal3
+ $W=6e-07
Rc2596	vbottom<7>#698	vbottom<7>#699	0.192692	$metal3
+ $W=6e-07
Rc2597	vbottom<7>#699	vbottom<7>#700	0.329783	$metal3
+ $W=3e-07
Rc2598	vbottom<7>#660	vbottom<7>#701	0.698840	$metal3
+ $W=3e-07
Rc2599	vbottom<7>#701	vbottom<7>#702	0.556646	$metal3
+ $W=3e-07
Rc2600	vbottom<7>#702	vbottom<7>#703	0.523746	$metal3
+ $W=6e-07
Rc2601	vbottom<7>#703	vbottom<7>#704	0.698840	$metal3
+ $W=3e-07
Rc2602	vbottom<7>#704	vbottom<7>#705	0.556646	$metal3
+ $W=3e-07
Rc2603	vbottom<7>#705	vbottom<7>#706	0.523746	$metal3
+ $W=6e-07
Rc2604	vbottom<7>#706	vbottom<7>#707	0.698840	$metal3
+ $W=3e-07
Rc2605	vbottom<7>#707	vbottom<7>#708	0.556646	$metal3
+ $W=3e-07
Rc2606	vbottom<7>#708	vbottom<7>#709	0.523746	$metal3
+ $W=6e-07
Rc2607	vbottom<7>#709	vbottom<7>#710	0.698840	$metal3
+ $W=3e-07
Rc2608	vbottom<7>#710	vbottom<7>#711	0.556646	$metal3
+ $W=3e-07
Rc2609	vbottom<7>#711	vbottom<7>#712	0.523746	$metal3
+ $W=6e-07
Rc2610	vbottom<7>#712	vbottom<7>#713	0.698840	$metal3
+ $W=3e-07
Rc2611	vbottom<7>#713	vbottom<7>#714	0.556646	$metal3
+ $W=3e-07
Rc2612	vbottom<7>#714	vbottom<7>#715	0.523746	$metal3
+ $W=6e-07
Rc2613	vbottom<7>#715	vbottom<7>#716	0.698840	$metal3
+ $W=3e-07
Rc2614	vbottom<7>#716	vbottom<7>#717	0.556646	$metal3
+ $W=3e-07
Rc2615	vbottom<7>#717	vbottom<7>#718	0.523746	$metal3
+ $W=6e-07
Rc2616	vbottom<7>#718	vbottom<7>#719	0.698840	$metal3
+ $W=3e-07
Rc2617	vbottom<7>#719	vbottom<7>#720	0.556646	$metal3
+ $W=3e-07
Rc2618	vbottom<7>#720	vbottom<7>#721	0.523746	$metal3
+ $W=6e-07
Rc2619	vbottom<7>#721	vbottom<7>#722	0.698840	$metal3
+ $W=3e-07
Rc2620	vbottom<7>#722	vbottom<7>#723	0.556646	$metal3
+ $W=3e-07
Rc2621	vbottom<7>#723	vbottom<7>#724	0.523746	$metal3
+ $W=6e-07
Rc2622	vbottom<7>#724	vbottom<7>#725	0.556646	$metal3
+ $W=6e-07
Rc2623	vbottom<7>#725	vbottom<7>#726	0.025931	$metal3
+ $W=4.2e-06
Rc2624	vbottom<7>#662	vbottom<7>#357	0.345935	$metal3
+ $W=3e-07
Rc2625	vbottom<7>#662	vbottom<7>#727	0.672969	$metal3
+ $W=3e-07
Rc2626	vbottom<7>#662	vbottom<7>#728	0.345935	$metal3
+ $W=3e-07
Rc2627	vbottom<7>#728	vbottom<7>#729	0.025931	$metal3
+ $W=4.2e-06
Rc2628	vbottom<7>#729	vbottom<7>#730	0.025931	$metal3
+ $W=4.2e-06
Rc2629	vbottom<7>#730	vbottom<7>#731	0.665112	$metal3
+ $W=3e-07
Rc2630	vbottom<7>#731	vbottom<7>#732	0.025931	$metal3
+ $W=4.2e-06
Rc2631	vbottom<7>#663	vbottom<7>#618	0.342700	$metal3
+ $W=3e-07
Rc2632	vbottom<7>#699	vbottom<7>#733	0.337791	$metal3
+ $W=3e-07
Rc2633	vbottom<7>#733	vbottom<7>#734	0.315692	$metal3
+ $W=3e-07
Rc2634	vbottom<7>#700	vbottom<7>#436	0.330268	$metal3
+ $W=3e-07
Rc2635	vbottom<7>#725	vbottom<7>#735	0.226767	$metal3
+ $W=6e-07
Rc2636	vbottom<7>#726	vbottom<7>#723	0.025931	$metal3
+ $W=4.2e-06
Rc2637	vbottom<7>#726	vbottom<7>#724	0.025931	$metal3
+ $W=4.2e-06
Rc2638	vbottom<7>#726	vbottom<7>#722	0.025931	$metal3
+ $W=4.2e-06
Rc2639	vbottom<7>#727	vbottom<7>#358	0.337203	$metal3
+ $W=3e-07
Rc2640	vbottom<7>#727	vbottom<7>#736	0.215025	$metal3
+ $W=6e-07
Rc2641	vbottom<7>#736	vbottom<7>#737	0.025931	$metal3
+ $W=4.2e-06
Rc2642	vbottom<7>#729	vbottom<7>#357	0.025894	$metal3
+ $W=4.2e-06
Rc2643	vbottom<7>#730	vbottom<7>#356	0.337791	$metal3
+ $W=3e-07
Rc2644	vbottom<7>#731	vbottom<7>#355	0.345935	$metal3
+ $W=3e-07
Rc2645	vbottom<7>#731	vbottom<7>#738	0.226767	$metal3
+ $W=6e-07
Rc2646	vbottom<7>#732	vbottom<7>#58	0.025931	$metal3
+ $W=4.2e-06
Rc2647	vbottom<7>#732	vbottom<7>#59	0.025931	$metal3
+ $W=4.2e-06
Rc2648	vbottom<7>#732	vbottom<7>#57	0.025894	$metal3
+ $W=4.2e-06
Rc2649	vbottom<7>#733	vbottom<7>#739	0.556646	$metal3
+ $W=6e-07
Rc2650	vbottom<7>#739	vbottom<7>#740	0.025931	$metal3
+ $W=4.2e-06
Rc2651	vbottom<7>#734	vbottom<7>#439	0.349420	$metal3
+ $W=3e-07
Rc2652	vbottom<7>#735	vbottom<7>#722	0.337203	$metal3
+ $W=3e-07
Rc2653	vbottom<7>#735	vbottom<7>#741	0.685401	$metal3
+ $W=3e-07
Rc2654	vbottom<7>#736	vbottom<7>#742	0.193867	$metal3
+ $W=6e-07
Rc2655	vbottom<7>#737	vbottom<7>#359	0.025931	$metal3
+ $W=4.2e-06
Rc2656	vbottom<7>#737	vbottom<7>#360	0.025894	$metal3
+ $W=4.2e-06
Rc2657	vbottom<7>#737	vbottom<7>#358	0.025894	$metal3
+ $W=4.2e-06
Rc2658	vbottom<7>#738	vbottom<7>#57	0.337203	$metal3
+ $W=3e-07
Rc2659	vbottom<7>#738	vbottom<7>#743	0.672969	$metal3
+ $W=3e-07
Rc2660	vbottom<7>#740	vbottom<7>#698	0.025931	$metal3
+ $W=4.2e-06
Rc2661	vbottom<7>#740	vbottom<7>#733	0.025931	$metal3
+ $W=4.2e-06
Rc2662	vbottom<7>#740	vbottom<7>#744	0.025931	$metal3
+ $W=4.2e-06
Rc2663	vbottom<7>#741	vbottom<7>#721	0.337203	$metal3
+ $W=3e-07
Rc2664	vbottom<7>#741	vbottom<7>#745	0.215025	$metal3
+ $W=6e-07
Rc2665	vbottom<7>#745	vbottom<7>#746	0.025931	$metal3
+ $W=4.2e-06
Rc2666	vbottom<7>#742	vbottom<7>#360	0.337203	$metal3
+ $W=3e-07
Rc2667	vbottom<7>#742	vbottom<7>#747	0.685401	$metal3
+ $W=3e-07
Rc2668	vbottom<7>#743	vbottom<7>#56	0.345935	$metal3
+ $W=3e-07
Rc2669	vbottom<7>#743	vbottom<7>#748	0.661227	$metal3
+ $W=3e-07
Rc2670	vbottom<7>#748	vbottom<7>#749	0.226767	$metal3
+ $W=6e-07
Rc2671	vbottom<7>#749	vbottom<7>#750	0.700747	$metal3
+ $W=3e-07
Rc2672	vbottom<7>#750	vbottom<7>#751	0.047720	$metal3
+ $W=3e-07
Rc2673	vbottom<7>#743	vbottom<7>#53	0.345935	$metal3
+ $W=3e-07
Rc2674	vbottom<7>#744	vbottom<7>#697	0.337203	$metal3
+ $W=3e-07
Rc2675	vbottom<7>#744	vbottom<7>#752	0.337203	$metal3
+ $W=3e-07
Rc2676	vbottom<7>#744	vbottom<7>#753	0.698840	$metal3
+ $W=3e-07
Rc2677	vbottom<7>#745	vbottom<7>#754	0.193867	$metal3
+ $W=6e-07
Rc2678	vbottom<7>#746	vbottom<7>#720	0.025931	$metal3
+ $W=4.2e-06
Rc2679	vbottom<7>#746	vbottom<7>#721	0.025931	$metal3
+ $W=4.2e-06
Rc2680	vbottom<7>#746	vbottom<7>#719	0.025931	$metal3
+ $W=4.2e-06
Rc2681	vbottom<7>#747	vbottom<7>#361	0.337203	$metal3
+ $W=3e-07
Rc2682	vbottom<7>#747	vbottom<7>#755	0.215025	$metal3
+ $W=6e-07
Rc2683	vbottom<7>#755	vbottom<7>#756	0.025931	$metal3
+ $W=4.2e-06
Rc2684	vbottom<7>#748	vbottom<7>#52	0.337203	$metal3
+ $W=3e-07
Rc2685	vbottom<7>#749	vbottom<7>#51	0.025931	$metal3
+ $W=4.2e-06
Rc2686	vbottom<7>#750	vbottom<7>#729	0.022837	$metal3
+ $W=4.8e-06
Rc2687	vbottom<7>#751	vbottom<7>#728	0.215025	$metal3
+ $W=6e-07
Rc2688	vbottom<7>#751	vbottom<7>#757	0.672969	$metal3
+ $W=3e-07
Rc2689	vbottom<7>#752	vbottom<7>#739	0.215025	$metal3
+ $W=6e-07
Rc2690	vbottom<7>#753	vbottom<7>#696	0.337203	$metal3
+ $W=3e-07
Rc2691	vbottom<7>#753	vbottom<7>#758	0.556646	$metal3
+ $W=6e-07
Rc2692	vbottom<7>#758	vbottom<7>#759	0.025931	$metal3
+ $W=4.2e-06
Rc2693	vbottom<7>#754	vbottom<7>#719	0.337203	$metal3
+ $W=3e-07
Rc2694	vbottom<7>#754	vbottom<7>#760	0.685401	$metal3
+ $W=3e-07
Rc2695	vbottom<7>#755	vbottom<7>#761	0.193867	$metal3
+ $W=6e-07
Rc2696	vbottom<7>#756	vbottom<7>#362	0.025931	$metal3
+ $W=4.2e-06
Rc2697	vbottom<7>#756	vbottom<7>#363	0.025894	$metal3
+ $W=4.2e-06
Rc2698	vbottom<7>#756	vbottom<7>#361	0.025894	$metal3
+ $W=4.2e-06
Rc2699	vbottom<7>#757	vbottom<7>#749	0.345935	$metal3
+ $W=3e-07
Rc2700	vbottom<7>#757	vbottom<7>#762	0.661227	$metal3
+ $W=3e-07
Rc2701	vbottom<7>#762	vbottom<7>#763	0.226767	$metal3
+ $W=6e-07
Rc2702	vbottom<7>#763	vbottom<7>#764	0.182125	$metal3
+ $W=6e-07
Rc2703	vbottom<7>#764	vbottom<7>#765	0.673659	$metal3
+ $W=3e-07
Rc2704	vbottom<7>#765	vbottom<7>#766	0.226767	$metal3
+ $W=6e-07
Rc2705	vbottom<7>#766	vbottom<7>#767	0.182125	$metal3
+ $W=6e-07
Rc2706	vbottom<7>#767	vbottom<7>#768	0.673659	$metal3
+ $W=3e-07
Rc2707	vbottom<7>#768	vbottom<7>#769	0.226767	$metal3
+ $W=6e-07
Rc2708	vbottom<7>#769	vbottom<7>#770	0.182125	$metal3
+ $W=6e-07
Rc2709	vbottom<7>#770	vbottom<7>#771	0.673659	$metal3
+ $W=3e-07
Rc2710	vbottom<7>#771	vbottom<7>#772	0.226767	$metal3
+ $W=6e-07
Rc2711	vbottom<7>#772	vbottom<7>#773	0.182125	$metal3
+ $W=6e-07
Rc2712	vbottom<7>#773	vbottom<7>#774	0.673659	$metal3
+ $W=3e-07
Rc2713	vbottom<7>#774	vbottom<7>#775	0.226767	$metal3
+ $W=6e-07
Rc2714	vbottom<7>#775	vbottom<7>#776	0.182125	$metal3
+ $W=6e-07
Rc2715	vbottom<7>#776	vbottom<7>#777	0.673659	$metal3
+ $W=3e-07
Rc2716	vbottom<7>#777	vbottom<7>#778	0.226767	$metal3
+ $W=6e-07
Rc2717	vbottom<7>#778	vbottom<7>#779	0.182125	$metal3
+ $W=6e-07
Rc2718	vbottom<7>#779	vbottom<7>#780	0.673659	$metal3
+ $W=3e-07
Rc2719	vbottom<7>#780	vbottom<7>#781	0.226767	$metal3
+ $W=6e-07
Rc2720	vbottom<7>#781	vbottom<7>#782	0.182125	$metal3
+ $W=6e-07
Rc2721	vbottom<7>#782	vbottom<7>#783	0.673659	$metal3
+ $W=3e-07
Rc2722	vbottom<7>#783	vbottom<7>#784	0.226767	$metal3
+ $W=6e-07
Rc2723	vbottom<7>#784	vbottom<7>#785	0.182125	$metal3
+ $W=6e-07
Rc2724	vbottom<7>#785	vbottom<7>#786	0.673659	$metal3
+ $W=3e-07
Rc2725	vbottom<7>#786	vbottom<7>#787	0.226767	$metal3
+ $W=6e-07
Rc2726	vbottom<7>#787	vbottom<7>#788	0.182125	$metal3
+ $W=6e-07
Rc2727	vbottom<7>#788	vbottom<7>#789	0.673659	$metal3
+ $W=3e-07
Rc2728	vbottom<7>#789	vbottom<7>#790	0.226767	$metal3
+ $W=6e-07
Rc2729	vbottom<7>#790	vbottom<7>#791	0.182125	$metal3
+ $W=6e-07
Rc2730	vbottom<7>#791	vbottom<7>#792	0.673659	$metal3
+ $W=3e-07
Rc2731	vbottom<7>#792	vbottom<7>#793	0.226767	$metal3
+ $W=6e-07
Rc2732	vbottom<7>#793	vbottom<7>#794	0.180950	$metal3
+ $W=6e-07
Rc2733	vbottom<7>#794	vbottom<7>#795	0.671308	$metal3
+ $W=3e-07
Rc2734	vbottom<7>#795	vbottom<7>#796	0.225592	$metal3
+ $W=6e-07
Rc2735	vbottom<7>#796	vbottom<7>#797	0.180950	$metal3
+ $W=6e-07
Rc2736	vbottom<7>#797	vbottom<7>#798	0.671793	$metal3
+ $W=3e-07
Rc2737	vbottom<7>#798	vbottom<7>#799	0.672969	$metal3
+ $W=3e-07
Rc2738	vbottom<7>#799	vbottom<7>#800	0.215025	$metal3
+ $W=6e-07
Rc2739	vbottom<7>#800	vbottom<7>#801	0.665112	$metal3
+ $W=3e-07
Rc2740	vbottom<7>#801	vbottom<7>#802	0.025931	$metal3
+ $W=4.2e-06
Rc2741	vbottom<7>#802	vbottom<7>#803	0.025931	$metal3
+ $W=4.2e-06
Rc2742	vbottom<7>#803	vbottom<7>#804	0.665112	$metal3
+ $W=3e-07
Rc2743	vbottom<7>#804	vbottom<7>#805	0.025931	$metal3
+ $W=4.2e-06
Rc2744	vbottom<7>#805	vbottom<7>#806	0.025931	$metal3
+ $W=4.2e-06
Rc2745	vbottom<7>#806	vbottom<7>#807	0.665112	$metal3
+ $W=3e-07
Rc2746	vbottom<7>#807	vbottom<7>#808	0.025931	$metal3
+ $W=4.2e-06
Rc2747	vbottom<7>#808	vbottom<7>#809	0.025931	$metal3
+ $W=4.2e-06
Rc2748	vbottom<7>#809	vbottom<7>#810	0.665112	$metal3
+ $W=3e-07
Rc2749	vbottom<7>#810	vbottom<7>#811	0.025931	$metal3
+ $W=4.2e-06
Rc2750	vbottom<7>#811	vbottom<7>#812	0.025931	$metal3
+ $W=4.2e-06
Rc2751	vbottom<7>#812	vbottom<7>#813	0.665112	$metal3
+ $W=3e-07
Rc2752	vbottom<7>#813	vbottom<7>#814	0.025931	$metal3
+ $W=4.2e-06
Rc2753	vbottom<7>#814	vbottom<7>#815	0.025931	$metal3
+ $W=4.2e-06
Rc2754	vbottom<7>#815	vbottom<7>#816	0.665112	$metal3
+ $W=3e-07
Rc2755	vbottom<7>#816	vbottom<7>#817	0.025931	$metal3
+ $W=4.2e-06
Rc2756	vbottom<7>#817	vbottom<7>#818	0.025931	$metal3
+ $W=4.2e-06
Rc2757	vbottom<7>#818	vbottom<7>#819	0.665112	$metal3
+ $W=3e-07
Rc2758	vbottom<7>#819	vbottom<7>#820	0.025931	$metal3
+ $W=4.2e-06
Rc2759	vbottom<7>#820	vbottom<7>#821	0.025931	$metal3
+ $W=4.2e-06
Rc2760	vbottom<7>#821	vbottom<7>#822	0.665112	$metal3
+ $W=3e-07
Rc2761	vbottom<7>#822	vbottom<7>#823	0.025931	$metal3
+ $W=4.2e-06
Rc2762	vbottom<7>#823	vbottom<7>#824	0.025931	$metal3
+ $W=4.2e-06
Rc2763	vbottom<7>#824	vbottom<7>#825	0.665112	$metal3
+ $W=3e-07
Rc2764	vbottom<7>#825	vbottom<7>#826	0.025931	$metal3
+ $W=4.2e-06
Rc2765	vbottom<7>#826	vbottom<7>#827	0.025931	$metal3
+ $W=4.2e-06
Rc2766	vbottom<7>#827	vbottom<7>#828	0.665112	$metal3
+ $W=3e-07
Rc2767	vbottom<7>#828	vbottom<7>#829	0.025931	$metal3
+ $W=4.2e-06
Rc2768	vbottom<7>#829	vbottom<7>#830	0.025931	$metal3
+ $W=4.2e-06
Rc2769	vbottom<7>#830	vbottom<7>#831	0.665112	$metal3
+ $W=3e-07
Rc2770	vbottom<7>#831	vbottom<7>#832	0.025931	$metal3
+ $W=4.2e-06
Rc2771	vbottom<7>#832	vbottom<7>#833	0.025931	$metal3
+ $W=4.2e-06
Rc2772	vbottom<7>#833	vbottom<7>#834	0.665112	$metal3
+ $W=3e-07
Rc2773	vbottom<7>#834	vbottom<7>#835	0.025931	$metal3
+ $W=4.2e-06
Rc2774	vbottom<7>#835	vbottom<7>#836	0.025931	$metal3
+ $W=4.2e-06
Rc2775	vbottom<7>#836	vbottom<7>#837	0.315692	$metal3
+ $W=3e-07
Rc2776	vbottom<7>#757	vbottom<7>#50	0.345935	$metal3
+ $W=3e-07
Rc2777	vbottom<7>#759	vbottom<7>#695	0.025931	$metal3
+ $W=4.2e-06
Rc2778	vbottom<7>#759	vbottom<7>#753	0.025931	$metal3
+ $W=4.2e-06
Rc2779	vbottom<7>#759	vbottom<7>#838	0.025931	$metal3
+ $W=4.2e-06
Rc2780	vbottom<7>#760	vbottom<7>#718	0.337203	$metal3
+ $W=3e-07
Rc2781	vbottom<7>#760	vbottom<7>#839	0.215025	$metal3
+ $W=6e-07
Rc2782	vbottom<7>#839	vbottom<7>#840	0.025931	$metal3
+ $W=4.2e-06
Rc2783	vbottom<7>#761	vbottom<7>#363	0.337203	$metal3
+ $W=3e-07
Rc2784	vbottom<7>#761	vbottom<7>#841	0.685401	$metal3
+ $W=3e-07
Rc2785	vbottom<7>#762	vbottom<7>#49	0.337203	$metal3
+ $W=3e-07
Rc2786	vbottom<7>#763	vbottom<7>#48	0.025931	$metal3
+ $W=4.2e-06
Rc2787	vbottom<7>#764	vbottom<7>#47	0.337203	$metal3
+ $W=3e-07
Rc2788	vbottom<7>#765	vbottom<7>#46	0.337203	$metal3
+ $W=3e-07
Rc2789	vbottom<7>#766	vbottom<7>#45	0.025931	$metal3
+ $W=4.2e-06
Rc2790	vbottom<7>#767	vbottom<7>#44	0.337203	$metal3
+ $W=3e-07
Rc2791	vbottom<7>#768	vbottom<7>#43	0.337203	$metal3
+ $W=3e-07
Rc2792	vbottom<7>#769	vbottom<7>#42	0.025931	$metal3
+ $W=4.2e-06
Rc2793	vbottom<7>#770	vbottom<7>#41	0.337203	$metal3
+ $W=3e-07
Rc2794	vbottom<7>#771	vbottom<7>#40	0.337203	$metal3
+ $W=3e-07
Rc2795	vbottom<7>#772	vbottom<7>#39	0.025931	$metal3
+ $W=4.2e-06
Rc2796	vbottom<7>#773	vbottom<7>#38	0.337203	$metal3
+ $W=3e-07
Rc2797	vbottom<7>#774	vbottom<7>#37	0.337203	$metal3
+ $W=3e-07
Rc2798	vbottom<7>#775	vbottom<7>#36	0.025931	$metal3
+ $W=4.2e-06
Rc2799	vbottom<7>#776	vbottom<7>#35	0.337203	$metal3
+ $W=3e-07
Rc2800	vbottom<7>#777	vbottom<7>#34	0.337203	$metal3
+ $W=3e-07
Rc2801	vbottom<7>#778	vbottom<7>#33	0.025931	$metal3
+ $W=4.2e-06
Rc2802	vbottom<7>#779	vbottom<7>#32	0.337203	$metal3
+ $W=3e-07
Rc2803	vbottom<7>#780	vbottom<7>#31	0.337203	$metal3
+ $W=3e-07
Rc2804	vbottom<7>#781	vbottom<7>#30	0.025931	$metal3
+ $W=4.2e-06
Rc2805	vbottom<7>#782	vbottom<7>#29	0.337203	$metal3
+ $W=3e-07
Rc2806	vbottom<7>#783	vbottom<7>#28	0.337203	$metal3
+ $W=3e-07
Rc2807	vbottom<7>#784	vbottom<7>#27	0.025931	$metal3
+ $W=4.2e-06
Rc2808	vbottom<7>#785	vbottom<7>#26	0.337203	$metal3
+ $W=3e-07
Rc2809	vbottom<7>#786	vbottom<7>#25	0.337203	$metal3
+ $W=3e-07
Rc2810	vbottom<7>#787	vbottom<7>#24	0.025931	$metal3
+ $W=4.2e-06
Rc2811	vbottom<7>#788	vbottom<7>#23	0.337203	$metal3
+ $W=3e-07
Rc2812	vbottom<7>#789	vbottom<7>#22	0.337203	$metal3
+ $W=3e-07
Rc2813	vbottom<7>#790	vbottom<7>#21	0.025931	$metal3
+ $W=4.2e-06
Rc2814	vbottom<7>#791	vbottom<7>#20	0.337203	$metal3
+ $W=3e-07
Rc2815	vbottom<7>#792	vbottom<7>#18	0.337203	$metal3
+ $W=3e-07
Rc2816	vbottom<7>#800	vbottom<7>#625	0.345935	$metal3
+ $W=3e-07
Rc2817	vbottom<7>#800	vbottom<7>#842	0.025931	$metal3
+ $W=4.2e-06
Rc2818	vbottom<7>#801	vbottom<7>#626	0.337791	$metal3
+ $W=3e-07
Rc2819	vbottom<7>#802	vbottom<7>#627	0.025931	$metal3
+ $W=4.2e-06
Rc2820	vbottom<7>#803	vbottom<7>#628	0.337791	$metal3
+ $W=3e-07
Rc2821	vbottom<7>#803	vbottom<7>#843	0.556646	$metal3
+ $W=6e-07
Rc2822	vbottom<7>#804	vbottom<7>#629	0.337791	$metal3
+ $W=3e-07
Rc2823	vbottom<7>#805	vbottom<7>#630	0.025931	$metal3
+ $W=4.2e-06
Rc2824	vbottom<7>#806	vbottom<7>#631	0.337791	$metal3
+ $W=3e-07
Rc2825	vbottom<7>#806	vbottom<7>#844	0.556646	$metal3
+ $W=6e-07
Rc2826	vbottom<7>#807	vbottom<7>#632	0.337791	$metal3
+ $W=3e-07
Rc2827	vbottom<7>#808	vbottom<7>#633	0.025931	$metal3
+ $W=4.2e-06
Rc2828	vbottom<7>#809	vbottom<7>#634	0.337791	$metal3
+ $W=3e-07
Rc2829	vbottom<7>#809	vbottom<7>#845	0.556646	$metal3
+ $W=6e-07
Rc2830	vbottom<7>#810	vbottom<7>#635	0.337791	$metal3
+ $W=3e-07
Rc2831	vbottom<7>#811	vbottom<7>#636	0.025931	$metal3
+ $W=4.2e-06
Rc2832	vbottom<7>#812	vbottom<7>#637	0.337791	$metal3
+ $W=3e-07
Rc2833	vbottom<7>#812	vbottom<7>#846	0.556646	$metal3
+ $W=6e-07
Rc2834	vbottom<7>#813	vbottom<7>#638	0.337791	$metal3
+ $W=3e-07
Rc2835	vbottom<7>#814	vbottom<7>#639	0.025931	$metal3
+ $W=4.2e-06
Rc2836	vbottom<7>#815	vbottom<7>#640	0.337791	$metal3
+ $W=3e-07
Rc2837	vbottom<7>#815	vbottom<7>#847	0.556646	$metal3
+ $W=6e-07
Rc2838	vbottom<7>#816	vbottom<7>#641	0.337791	$metal3
+ $W=3e-07
Rc2839	vbottom<7>#817	vbottom<7>#642	0.025931	$metal3
+ $W=4.2e-06
Rc2840	vbottom<7>#818	vbottom<7>#643	0.337791	$metal3
+ $W=3e-07
Rc2841	vbottom<7>#818	vbottom<7>#848	0.556646	$metal3
+ $W=6e-07
Rc2842	vbottom<7>#819	vbottom<7>#644	0.337791	$metal3
+ $W=3e-07
Rc2843	vbottom<7>#820	vbottom<7>#645	0.025931	$metal3
+ $W=4.2e-06
Rc2844	vbottom<7>#821	vbottom<7>#646	0.337791	$metal3
+ $W=3e-07
Rc2845	vbottom<7>#821	vbottom<7>#849	0.556646	$metal3
+ $W=6e-07
Rc2846	vbottom<7>#822	vbottom<7>#647	0.337791	$metal3
+ $W=3e-07
Rc2847	vbottom<7>#823	vbottom<7>#648	0.025931	$metal3
+ $W=4.2e-06
Rc2848	vbottom<7>#824	vbottom<7>#649	0.337791	$metal3
+ $W=3e-07
Rc2849	vbottom<7>#824	vbottom<7>#850	0.556646	$metal3
+ $W=6e-07
Rc2850	vbottom<7>#825	vbottom<7>#650	0.337791	$metal3
+ $W=3e-07
Rc2851	vbottom<7>#826	vbottom<7>#651	0.025931	$metal3
+ $W=4.2e-06
Rc2852	vbottom<7>#827	vbottom<7>#652	0.337791	$metal3
+ $W=3e-07
Rc2853	vbottom<7>#827	vbottom<7>#851	0.556646	$metal3
+ $W=6e-07
Rc2854	vbottom<7>#828	vbottom<7>#653	0.337791	$metal3
+ $W=3e-07
Rc2855	vbottom<7>#829	vbottom<7>#654	0.025931	$metal3
+ $W=4.2e-06
Rc2856	vbottom<7>#830	vbottom<7>#655	0.337791	$metal3
+ $W=3e-07
Rc2857	vbottom<7>#830	vbottom<7>#852	0.556646	$metal3
+ $W=6e-07
Rc2858	vbottom<7>#831	vbottom<7>#656	0.337791	$metal3
+ $W=3e-07
Rc2859	vbottom<7>#832	vbottom<7>#657	0.025931	$metal3
+ $W=4.2e-06
Rc2860	vbottom<7>#833	vbottom<7>#658	0.337791	$metal3
+ $W=3e-07
Rc2861	vbottom<7>#833	vbottom<7>#853	0.556646	$metal3
+ $W=6e-07
Rc2862	vbottom<7>#834	vbottom<7>#659	0.345935	$metal3
+ $W=3e-07
Rc2863	vbottom<7>#835	vbottom<7>#660	0.025931	$metal3
+ $W=4.2e-06
Rc2864	vbottom<7>#836	vbottom<7>#661	0.337791	$metal3
+ $W=3e-07
Rc2865	vbottom<7>#836	vbottom<7>#854	0.556646	$metal3
+ $W=6e-07
Rc2866	vbottom<7>#837	vbottom<7>#728	0.349420	$metal3
+ $W=3e-07
Rc2867	vbottom<7>#838	vbottom<7>#694	0.337203	$metal3
+ $W=3e-07
Rc2868	vbottom<7>#838	vbottom<7>#855	0.337203	$metal3
+ $W=3e-07
Rc2869	vbottom<7>#838	vbottom<7>#856	0.698840	$metal3
+ $W=3e-07
Rc2870	vbottom<7>#839	vbottom<7>#857	0.193867	$metal3
+ $W=6e-07
Rc2871	vbottom<7>#840	vbottom<7>#717	0.025931	$metal3
+ $W=4.2e-06
Rc2872	vbottom<7>#840	vbottom<7>#718	0.025931	$metal3
+ $W=4.2e-06
Rc2873	vbottom<7>#840	vbottom<7>#716	0.025931	$metal3
+ $W=4.2e-06
Rc2874	vbottom<7>#841	vbottom<7>#364	0.337203	$metal3
+ $W=3e-07
Rc2875	vbottom<7>#841	vbottom<7>#858	0.215025	$metal3
+ $W=6e-07
Rc2876	vbottom<7>#858	vbottom<7>#859	0.025931	$metal3
+ $W=4.2e-06
Rc2877	vbottom<7>#842	vbottom<7>#624	0.025931	$metal3
+ $W=4.2e-06
Rc2878	vbottom<7>#842	vbottom<7>#860	0.025931	$metal3
+ $W=4.2e-06
Rc2879	vbottom<7>#843	vbottom<7>#802	0.025931	$metal3
+ $W=4.2e-06
Rc2880	vbottom<7>#843	vbottom<7>#861	0.337203	$metal3
+ $W=3e-07
Rc2881	vbottom<7>#844	vbottom<7>#805	0.025931	$metal3
+ $W=4.2e-06
Rc2882	vbottom<7>#844	vbottom<7>#862	0.337203	$metal3
+ $W=3e-07
Rc2883	vbottom<7>#845	vbottom<7>#808	0.025931	$metal3
+ $W=4.2e-06
Rc2884	vbottom<7>#845	vbottom<7>#863	0.337203	$metal3
+ $W=3e-07
Rc2885	vbottom<7>#846	vbottom<7>#811	0.025931	$metal3
+ $W=4.2e-06
Rc2886	vbottom<7>#846	vbottom<7>#864	0.337203	$metal3
+ $W=3e-07
Rc2887	vbottom<7>#847	vbottom<7>#814	0.025931	$metal3
+ $W=4.2e-06
Rc2888	vbottom<7>#847	vbottom<7>#865	0.337203	$metal3
+ $W=3e-07
Rc2889	vbottom<7>#848	vbottom<7>#817	0.025931	$metal3
+ $W=4.2e-06
Rc2890	vbottom<7>#848	vbottom<7>#866	0.337203	$metal3
+ $W=3e-07
Rc2891	vbottom<7>#849	vbottom<7>#820	0.025931	$metal3
+ $W=4.2e-06
Rc2892	vbottom<7>#849	vbottom<7>#867	0.337203	$metal3
+ $W=3e-07
Rc2893	vbottom<7>#850	vbottom<7>#823	0.025931	$metal3
+ $W=4.2e-06
Rc2894	vbottom<7>#850	vbottom<7>#868	0.337203	$metal3
+ $W=3e-07
Rc2895	vbottom<7>#851	vbottom<7>#826	0.025931	$metal3
+ $W=4.2e-06
Rc2896	vbottom<7>#851	vbottom<7>#869	0.337203	$metal3
+ $W=3e-07
Rc2897	vbottom<7>#852	vbottom<7>#829	0.025931	$metal3
+ $W=4.2e-06
Rc2898	vbottom<7>#852	vbottom<7>#870	0.337203	$metal3
+ $W=3e-07
Rc2899	vbottom<7>#853	vbottom<7>#832	0.025931	$metal3
+ $W=4.2e-06
Rc2900	vbottom<7>#853	vbottom<7>#871	0.337203	$metal3
+ $W=3e-07
Rc2901	vbottom<7>#854	vbottom<7>#835	0.025931	$metal3
+ $W=4.2e-06
Rc2902	vbottom<7>#854	vbottom<7>#872	0.337203	$metal3
+ $W=3e-07
Rc2903	vbottom<7>#855	vbottom<7>#758	0.215025	$metal3
+ $W=6e-07
Rc2904	vbottom<7>#856	vbottom<7>#693	0.337203	$metal3
+ $W=3e-07
Rc2905	vbottom<7>#856	vbottom<7>#873	0.556646	$metal3
+ $W=6e-07
Rc2906	vbottom<7>#873	vbottom<7>#874	0.025931	$metal3
+ $W=4.2e-06
Rc2907	vbottom<7>#857	vbottom<7>#716	0.337203	$metal3
+ $W=3e-07
Rc2908	vbottom<7>#857	vbottom<7>#875	0.685401	$metal3
+ $W=3e-07
Rc2909	vbottom<7>#858	vbottom<7>#876	0.193867	$metal3
+ $W=6e-07
Rc2910	vbottom<7>#859	vbottom<7>#365	0.025931	$metal3
+ $W=4.2e-06
Rc2911	vbottom<7>#859	vbottom<7>#366	0.025894	$metal3
+ $W=4.2e-06
Rc2912	vbottom<7>#859	vbottom<7>#364	0.025894	$metal3
+ $W=4.2e-06
Rc2913	vbottom<7>#860	vbottom<7>#623	0.337203	$metal3
+ $W=3e-07
Rc2914	vbottom<7>#860	vbottom<7>#877	0.665112	$metal3
+ $W=3e-07
Rc2915	vbottom<7>#861	vbottom<7>#801	0.215025	$metal3
+ $W=6e-07
Rc2916	vbottom<7>#862	vbottom<7>#804	0.215025	$metal3
+ $W=6e-07
Rc2917	vbottom<7>#863	vbottom<7>#807	0.215025	$metal3
+ $W=6e-07
Rc2918	vbottom<7>#864	vbottom<7>#810	0.215025	$metal3
+ $W=6e-07
Rc2919	vbottom<7>#865	vbottom<7>#813	0.215025	$metal3
+ $W=6e-07
Rc2920	vbottom<7>#866	vbottom<7>#816	0.215025	$metal3
+ $W=6e-07
Rc2921	vbottom<7>#867	vbottom<7>#819	0.215025	$metal3
+ $W=6e-07
Rc2922	vbottom<7>#868	vbottom<7>#822	0.215025	$metal3
+ $W=6e-07
Rc2923	vbottom<7>#869	vbottom<7>#825	0.215025	$metal3
+ $W=6e-07
Rc2924	vbottom<7>#870	vbottom<7>#828	0.215025	$metal3
+ $W=6e-07
Rc2925	vbottom<7>#871	vbottom<7>#831	0.215025	$metal3
+ $W=6e-07
Rc2926	vbottom<7>#872	vbottom<7>#834	0.215025	$metal3
+ $W=6e-07
Rc2927	vbottom<7>#874	vbottom<7>#692	0.025931	$metal3
+ $W=4.2e-06
Rc2928	vbottom<7>#874	vbottom<7>#856	0.025931	$metal3
+ $W=4.2e-06
Rc2929	vbottom<7>#874	vbottom<7>#878	0.025931	$metal3
+ $W=4.2e-06
Rc2930	vbottom<7>#875	vbottom<7>#715	0.337203	$metal3
+ $W=3e-07
Rc2931	vbottom<7>#875	vbottom<7>#879	0.215025	$metal3
+ $W=6e-07
Rc2932	vbottom<7>#879	vbottom<7>#880	0.025931	$metal3
+ $W=4.2e-06
Rc2933	vbottom<7>#876	vbottom<7>#366	0.337203	$metal3
+ $W=3e-07
Rc2934	vbottom<7>#876	vbottom<7>#881	0.685401	$metal3
+ $W=3e-07
Rc2935	vbottom<7>#877	vbottom<7>#622	0.345935	$metal3
+ $W=3e-07
Rc2936	vbottom<7>#877	vbottom<7>#882	0.025931	$metal3
+ $W=4.2e-06
Rc2937	vbottom<7>#878	vbottom<7>#691	0.337203	$metal3
+ $W=3e-07
Rc2938	vbottom<7>#878	vbottom<7>#883	0.337203	$metal3
+ $W=3e-07
Rc2939	vbottom<7>#878	vbottom<7>#884	0.698840	$metal3
+ $W=3e-07
Rc2940	vbottom<7>#879	vbottom<7>#885	0.193867	$metal3
+ $W=6e-07
Rc2941	vbottom<7>#880	vbottom<7>#714	0.025931	$metal3
+ $W=4.2e-06
Rc2942	vbottom<7>#880	vbottom<7>#715	0.025931	$metal3
+ $W=4.2e-06
Rc2943	vbottom<7>#880	vbottom<7>#713	0.025931	$metal3
+ $W=4.2e-06
Rc2944	vbottom<7>#881	vbottom<7>#367	0.337203	$metal3
+ $W=3e-07
Rc2945	vbottom<7>#881	vbottom<7>#886	0.215025	$metal3
+ $W=6e-07
Rc2946	vbottom<7>#886	vbottom<7>#887	0.025931	$metal3
+ $W=4.2e-06
Rc2947	vbottom<7>#882	vbottom<7>#621	0.025931	$metal3
+ $W=4.2e-06
Rc2948	vbottom<7>#882	vbottom<7>#888	0.025931	$metal3
+ $W=4.2e-06
Rc2949	vbottom<7>#888	vbottom<7>#889	0.337203	$metal3
+ $W=3e-07
Rc2950	vbottom<7>#883	vbottom<7>#873	0.215025	$metal3
+ $W=6e-07
Rc2951	vbottom<7>#884	vbottom<7>#690	0.337203	$metal3
+ $W=3e-07
Rc2952	vbottom<7>#884	vbottom<7>#890	0.556646	$metal3
+ $W=6e-07
Rc2953	vbottom<7>#890	vbottom<7>#891	0.025931	$metal3
+ $W=4.2e-06
Rc2954	vbottom<7>#885	vbottom<7>#713	0.337203	$metal3
+ $W=3e-07
Rc2955	vbottom<7>#885	vbottom<7>#892	0.685401	$metal3
+ $W=3e-07
Rc2956	vbottom<7>#886	vbottom<7>#893	0.193867	$metal3
+ $W=6e-07
Rc2957	vbottom<7>#887	vbottom<7>#368	0.025931	$metal3
+ $W=4.2e-06
Rc2958	vbottom<7>#887	vbottom<7>#369	0.025894	$metal3
+ $W=4.2e-06
Rc2959	vbottom<7>#887	vbottom<7>#367	0.025894	$metal3
+ $W=4.2e-06
Rc2960	vbottom<7>#888	vbottom<7>#894	0.556646	$metal3
+ $W=6e-07
Rc2961	vbottom<7>#894	vbottom<7>#895	0.337203	$metal3
+ $W=3e-07
Rc2962	vbottom<7>#895	vbottom<7>#896	0.672969	$metal3
+ $W=3e-07
Rc2963	vbottom<7>#896	vbottom<7>#897	0.672969	$metal3
+ $W=3e-07
Rc2964	vbottom<7>#897	vbottom<7>#898	0.215025	$metal3
+ $W=6e-07
Rc2965	vbottom<7>#889	vbottom<7>#621	0.215025	$metal3
+ $W=6e-07
Rc2966	vbottom<7>#891	vbottom<7>#689	0.025931	$metal3
+ $W=4.2e-06
Rc2967	vbottom<7>#891	vbottom<7>#884	0.025931	$metal3
+ $W=4.2e-06
Rc2968	vbottom<7>#891	vbottom<7>#899	0.025931	$metal3
+ $W=4.2e-06
Rc2969	vbottom<7>#892	vbottom<7>#712	0.337203	$metal3
+ $W=3e-07
Rc2970	vbottom<7>#892	vbottom<7>#900	0.215025	$metal3
+ $W=6e-07
Rc2971	vbottom<7>#900	vbottom<7>#901	0.025931	$metal3
+ $W=4.2e-06
Rc2972	vbottom<7>#893	vbottom<7>#369	0.337203	$metal3
+ $W=3e-07
Rc2973	vbottom<7>#893	vbottom<7>#902	0.685401	$metal3
+ $W=3e-07
Rc2974	vbottom<7>#894	vbottom<7>#882	0.025931	$metal3
+ $W=4.2e-06
Rc2975	vbottom<7>#895	vbottom<7>#877	0.215025	$metal3
+ $W=6e-07
Rc2976	vbottom<7>#898	vbottom<7>#798	0.345935	$metal3
+ $W=3e-07
Rc2977	vbottom<7>#898	vbottom<7>#903	0.698840	$metal3
+ $W=3e-07
Rc2978	vbottom<7>#898	vbottom<7>#904	0.025931	$metal3
+ $W=4.2e-06
Rc2979	vbottom<7>#904	vbottom<7>#905	0.025931	$metal3
+ $W=4.2e-06
Rc2980	vbottom<7>#905	vbottom<7>#906	0.665112	$metal3
+ $W=3e-07
Rc2981	vbottom<7>#906	vbottom<7>#907	0.025931	$metal3
+ $W=4.2e-06
Rc2982	vbottom<7>#907	vbottom<7>#908	0.025931	$metal3
+ $W=4.2e-06
Rc2983	vbottom<7>#908	vbottom<7>#909	0.665112	$metal3
+ $W=3e-07
Rc2984	vbottom<7>#909	vbottom<7>#910	0.025931	$metal3
+ $W=4.2e-06
Rc2985	vbottom<7>#899	vbottom<7>#688	0.337203	$metal3
+ $W=3e-07
Rc2986	vbottom<7>#899	vbottom<7>#911	0.337203	$metal3
+ $W=3e-07
Rc2987	vbottom<7>#899	vbottom<7>#912	0.698840	$metal3
+ $W=3e-07
Rc2988	vbottom<7>#900	vbottom<7>#913	0.193867	$metal3
+ $W=6e-07
Rc2989	vbottom<7>#901	vbottom<7>#711	0.025931	$metal3
+ $W=4.2e-06
Rc2990	vbottom<7>#901	vbottom<7>#712	0.025931	$metal3
+ $W=4.2e-06
Rc2991	vbottom<7>#901	vbottom<7>#710	0.025931	$metal3
+ $W=4.2e-06
Rc2992	vbottom<7>#902	vbottom<7>#370	0.337203	$metal3
+ $W=3e-07
Rc2993	vbottom<7>#902	vbottom<7>#914	0.215025	$metal3
+ $W=6e-07
Rc2994	vbottom<7>#914	vbottom<7>#915	0.025931	$metal3
+ $W=4.2e-06
Rc2995	vbottom<7>#903	vbottom<7>#799	0.337203	$metal3
+ $W=3e-07
Rc2996	vbottom<7>#903	vbottom<7>#842	0.025931	$metal3
+ $W=4.2e-06
Rc2997	vbottom<7>#903	vbottom<7>#916	0.337203	$metal3
+ $W=3e-07
Rc2998	vbottom<7>#905	vbottom<7>#798	0.345935	$metal3
+ $W=3e-07
Rc2999	vbottom<7>#905	vbottom<7>#917	0.556646	$metal3
+ $W=6e-07
Rc3000	vbottom<7>#906	vbottom<7>#797	0.337791	$metal3
+ $W=3e-07
Rc3001	vbottom<7>#907	vbottom<7>#796	0.025931	$metal3
+ $W=4.2e-06
Rc3002	vbottom<7>#908	vbottom<7>#795	0.337791	$metal3
+ $W=3e-07
Rc3003	vbottom<7>#908	vbottom<7>#918	0.556646	$metal3
+ $W=6e-07
Rc3004	vbottom<7>#909	vbottom<7>#794	0.337791	$metal3
+ $W=3e-07
Rc3005	vbottom<7>#910	vbottom<7>#18	0.025931	$metal3
+ $W=4.2e-06
Rc3006	vbottom<7>#910	vbottom<7>#793	0.025931	$metal3
+ $W=4.2e-06
Rc3007	vbottom<7>#910	vbottom<7>#919	0.025931	$metal3
+ $W=4.2e-06
Rc3008	vbottom<7>#911	vbottom<7>#890	0.215025	$metal3
+ $W=6e-07
Rc3009	vbottom<7>#912	vbottom<7>#687	0.337203	$metal3
+ $W=3e-07
Rc3010	vbottom<7>#912	vbottom<7>#920	0.556646	$metal3
+ $W=6e-07
Rc3011	vbottom<7>#920	vbottom<7>#921	0.025931	$metal3
+ $W=4.2e-06
Rc3012	vbottom<7>#913	vbottom<7>#710	0.337203	$metal3
+ $W=3e-07
Rc3013	vbottom<7>#913	vbottom<7>#922	0.685401	$metal3
+ $W=3e-07
Rc3014	vbottom<7>#914	vbottom<7>#923	0.193867	$metal3
+ $W=6e-07
Rc3015	vbottom<7>#915	vbottom<7>#371	0.025931	$metal3
+ $W=4.2e-06
Rc3016	vbottom<7>#915	vbottom<7>#372	0.025894	$metal3
+ $W=4.2e-06
Rc3017	vbottom<7>#915	vbottom<7>#370	0.025894	$metal3
+ $W=4.2e-06
Rc3018	vbottom<7>#916	vbottom<7>#860	0.215025	$metal3
+ $W=6e-07
Rc3019	vbottom<7>#917	vbottom<7>#904	0.025931	$metal3
+ $W=4.2e-06
Rc3020	vbottom<7>#917	vbottom<7>#924	0.556646	$metal3
+ $W=3e-07
Rc3021	vbottom<7>#918	vbottom<7>#907	0.025931	$metal3
+ $W=4.2e-06
Rc3022	vbottom<7>#918	vbottom<7>#925	0.337203	$metal3
+ $W=3e-07
Rc3023	vbottom<7>#919	vbottom<7>#17	0.225592	$metal3
+ $W=6e-07
Rc3024	vbottom<7>#919	vbottom<7>#926	0.337203	$metal3
+ $W=3e-07
Rc3025	vbottom<7>#921	vbottom<7>#686	0.025931	$metal3
+ $W=4.2e-06
Rc3026	vbottom<7>#921	vbottom<7>#912	0.025931	$metal3
+ $W=4.2e-06
Rc3027	vbottom<7>#921	vbottom<7>#927	0.025931	$metal3
+ $W=4.2e-06
Rc3028	vbottom<7>#922	vbottom<7>#709	0.337203	$metal3
+ $W=3e-07
Rc3029	vbottom<7>#922	vbottom<7>#928	0.215025	$metal3
+ $W=6e-07
Rc3030	vbottom<7>#928	vbottom<7>#929	0.025931	$metal3
+ $W=4.2e-06
Rc3031	vbottom<7>#923	vbottom<7>#372	0.337203	$metal3
+ $W=3e-07
Rc3032	vbottom<7>#923	vbottom<7>#930	0.685401	$metal3
+ $W=3e-07
Rc3033	vbottom<7>#924	vbottom<7>#904	0.025931	$metal3
+ $W=4.2e-06
Rc3034	vbottom<7>#924	vbottom<7>#897	0.337203	$metal3
+ $W=3e-07
Rc3035	vbottom<7>#924	vbottom<7>#931	0.665112	$metal3
+ $W=3e-07
Rc3036	vbottom<7>#925	vbottom<7>#906	0.215025	$metal3
+ $W=6e-07
Rc3037	vbottom<7>#926	vbottom<7>#909	0.215025	$metal3
+ $W=6e-07
Rc3038	vbottom<7>#927	vbottom<7>#685	0.337203	$metal3
+ $W=3e-07
Rc3039	vbottom<7>#927	vbottom<7>#932	0.337203	$metal3
+ $W=3e-07
Rc3040	vbottom<7>#927	vbottom<7>#933	0.698840	$metal3
+ $W=3e-07
Rc3041	vbottom<7>#928	vbottom<7>#934	0.193867	$metal3
+ $W=6e-07
Rc3042	vbottom<7>#929	vbottom<7>#708	0.025931	$metal3
+ $W=4.2e-06
Rc3043	vbottom<7>#929	vbottom<7>#709	0.025931	$metal3
+ $W=4.2e-06
Rc3044	vbottom<7>#929	vbottom<7>#707	0.025931	$metal3
+ $W=4.2e-06
Rc3045	vbottom<7>#930	vbottom<7>#373	0.337203	$metal3
+ $W=3e-07
Rc3046	vbottom<7>#930	vbottom<7>#935	0.215025	$metal3
+ $W=6e-07
Rc3047	vbottom<7>#935	vbottom<7>#936	0.025931	$metal3
+ $W=4.2e-06
Rc3048	vbottom<7>#931	vbottom<7>#896	0.345935	$metal3
+ $W=3e-07
Rc3049	vbottom<7>#931	vbottom<7>#937	0.025931	$metal3
+ $W=4.2e-06
Rc3050	vbottom<7>#937	vbottom<7>#938	0.025931	$metal3
+ $W=4.2e-06
Rc3051	vbottom<7>#932	vbottom<7>#920	0.215025	$metal3
+ $W=6e-07
Rc3052	vbottom<7>#933	vbottom<7>#684	0.337203	$metal3
+ $W=3e-07
Rc3053	vbottom<7>#933	vbottom<7>#939	0.556646	$metal3
+ $W=6e-07
Rc3054	vbottom<7>#939	vbottom<7>#940	0.025931	$metal3
+ $W=4.2e-06
Rc3055	vbottom<7>#934	vbottom<7>#707	0.337203	$metal3
+ $W=3e-07
Rc3056	vbottom<7>#934	vbottom<7>#941	0.685401	$metal3
+ $W=3e-07
Rc3057	vbottom<7>#935	vbottom<7>#942	0.193867	$metal3
+ $W=6e-07
Rc3058	vbottom<7>#936	vbottom<7>#374	0.025931	$metal3
+ $W=4.2e-06
Rc3059	vbottom<7>#936	vbottom<7>#375	0.025894	$metal3
+ $W=4.2e-06
Rc3060	vbottom<7>#936	vbottom<7>#373	0.025894	$metal3
+ $W=4.2e-06
Rc3061	vbottom<7>#938	vbottom<7>#896	0.345935	$metal3
+ $W=3e-07
Rc3062	vbottom<7>#938	vbottom<7>#943	0.315692	$metal3
+ $W=3e-07
Rc3063	vbottom<7>#938	vbottom<7>#944	0.267180	$metal3
+ $W=6e-07
Rc3064	vbottom<7>#940	vbottom<7>#683	0.025931	$metal3
+ $W=4.2e-06
Rc3065	vbottom<7>#940	vbottom<7>#933	0.025931	$metal3
+ $W=4.2e-06
Rc3066	vbottom<7>#940	vbottom<7>#945	0.025931	$metal3
+ $W=4.2e-06
Rc3067	vbottom<7>#941	vbottom<7>#706	0.337203	$metal3
+ $W=3e-07
Rc3068	vbottom<7>#941	vbottom<7>#946	0.215025	$metal3
+ $W=6e-07
Rc3069	vbottom<7>#946	vbottom<7>#947	0.025931	$metal3
+ $W=4.2e-06
Rc3070	vbottom<7>#942	vbottom<7>#375	0.337203	$metal3
+ $W=3e-07
Rc3071	vbottom<7>#942	vbottom<7>#948	0.685401	$metal3
+ $W=3e-07
Rc3072	vbottom<7>#943	vbottom<7>#894	0.349420	$metal3
+ $W=3e-07
Rc3073	vbottom<7>#944	vbottom<7>#937	0.022805	$metal3
+ $W=4.8e-06
Rc3074	vbottom<7>#945	vbottom<7>#682	0.337203	$metal3
+ $W=3e-07
Rc3075	vbottom<7>#945	vbottom<7>#949	0.337203	$metal3
+ $W=3e-07
Rc3076	vbottom<7>#945	vbottom<7>#950	0.698840	$metal3
+ $W=3e-07
Rc3077	vbottom<7>#946	vbottom<7>#951	0.193867	$metal3
+ $W=6e-07
Rc3078	vbottom<7>#947	vbottom<7>#705	0.025931	$metal3
+ $W=4.2e-06
Rc3079	vbottom<7>#947	vbottom<7>#706	0.025931	$metal3
+ $W=4.2e-06
Rc3080	vbottom<7>#947	vbottom<7>#704	0.025931	$metal3
+ $W=4.2e-06
Rc3081	vbottom<7>#948	vbottom<7>#376	0.337203	$metal3
+ $W=3e-07
Rc3082	vbottom<7>#948	vbottom<7>#952	0.215025	$metal3
+ $W=6e-07
Rc3083	vbottom<7>#952	vbottom<7>#953	0.025931	$metal3
+ $W=4.2e-06
Rc3084	vbottom<7>#949	vbottom<7>#939	0.215025	$metal3
+ $W=6e-07
Rc3085	vbottom<7>#950	vbottom<7>#681	0.337203	$metal3
+ $W=3e-07
Rc3086	vbottom<7>#950	vbottom<7>#954	0.556646	$metal3
+ $W=6e-07
Rc3087	vbottom<7>#954	vbottom<7>#955	0.025931	$metal3
+ $W=4.2e-06
Rc3088	vbottom<7>#951	vbottom<7>#704	0.337203	$metal3
+ $W=3e-07
Rc3089	vbottom<7>#951	vbottom<7>#956	0.685401	$metal3
+ $W=3e-07
Rc3090	vbottom<7>#952	vbottom<7>#957	0.193867	$metal3
+ $W=6e-07
Rc3091	vbottom<7>#953	vbottom<7>#377	0.025931	$metal3
+ $W=4.2e-06
Rc3092	vbottom<7>#953	vbottom<7>#378	0.025894	$metal3
+ $W=4.2e-06
Rc3093	vbottom<7>#953	vbottom<7>#376	0.025894	$metal3
+ $W=4.2e-06
Rc3094	vbottom<7>#955	vbottom<7>#680	0.025931	$metal3
+ $W=4.2e-06
Rc3095	vbottom<7>#955	vbottom<7>#950	0.025931	$metal3
+ $W=4.2e-06
Rc3096	vbottom<7>#955	vbottom<7>#958	0.025931	$metal3
+ $W=4.2e-06
Rc3097	vbottom<7>#956	vbottom<7>#703	0.337203	$metal3
+ $W=3e-07
Rc3098	vbottom<7>#956	vbottom<7>#959	0.215025	$metal3
+ $W=6e-07
Rc3099	vbottom<7>#959	vbottom<7>#960	0.025931	$metal3
+ $W=4.2e-06
Rc3100	vbottom<7>#957	vbottom<7>#378	0.337203	$metal3
+ $W=3e-07
Rc3101	vbottom<7>#957	vbottom<7>#961	0.685401	$metal3
+ $W=3e-07
Rc3102	vbottom<7>#958	vbottom<7>#679	0.337203	$metal3
+ $W=3e-07
Rc3103	vbottom<7>#958	vbottom<7>#962	0.337203	$metal3
+ $W=3e-07
Rc3104	vbottom<7>#958	vbottom<7>#963	0.698840	$metal3
+ $W=3e-07
Rc3105	vbottom<7>#959	vbottom<7>#964	0.193867	$metal3
+ $W=6e-07
Rc3106	vbottom<7>#960	vbottom<7>#702	0.025931	$metal3
+ $W=4.2e-06
Rc3107	vbottom<7>#960	vbottom<7>#703	0.025931	$metal3
+ $W=4.2e-06
Rc3108	vbottom<7>#960	vbottom<7>#701	0.025931	$metal3
+ $W=4.2e-06
Rc3109	vbottom<7>#961	vbottom<7>#379	0.337203	$metal3
+ $W=3e-07
Rc3110	vbottom<7>#961	vbottom<7>#965	0.215025	$metal3
+ $W=6e-07
Rc3111	vbottom<7>#965	vbottom<7>#966	0.025931	$metal3
+ $W=4.2e-06
Rc3112	vbottom<7>#962	vbottom<7>#954	0.215025	$metal3
+ $W=6e-07
Rc3113	vbottom<7>#963	vbottom<7>#678	0.337203	$metal3
+ $W=3e-07
Rc3114	vbottom<7>#963	vbottom<7>#967	0.556646	$metal3
+ $W=6e-07
Rc3115	vbottom<7>#967	vbottom<7>#968	0.025931	$metal3
+ $W=4.2e-06
Rc3116	vbottom<7>#964	vbottom<7>#701	0.337203	$metal3
+ $W=3e-07
Rc3117	vbottom<7>#964	vbottom<7>#969	0.330958	$metal3
+ $W=3e-07
Rc3118	vbottom<7>#965	vbottom<7>#970	0.193867	$metal3
+ $W=6e-07
Rc3119	vbottom<7>#966	vbottom<7>#380	0.025931	$metal3
+ $W=4.2e-06
Rc3120	vbottom<7>#966	vbottom<7>#381	0.025894	$metal3
+ $W=4.2e-06
Rc3121	vbottom<7>#966	vbottom<7>#379	0.025894	$metal3
+ $W=4.2e-06
Rc3122	vbottom<7>#968	vbottom<7>#677	0.025931	$metal3
+ $W=4.2e-06
Rc3123	vbottom<7>#968	vbottom<7>#963	0.025931	$metal3
+ $W=4.2e-06
Rc3124	vbottom<7>#968	vbottom<7>#971	0.025931	$metal3
+ $W=4.2e-06
Rc3125	vbottom<7>#969	vbottom<7>#659	0.330268	$metal3
+ $W=3e-07
Rc3126	vbottom<7>#970	vbottom<7>#381	0.337203	$metal3
+ $W=3e-07
Rc3127	vbottom<7>#970	vbottom<7>#972	0.685401	$metal3
+ $W=3e-07
Rc3128	vbottom<7>#971	vbottom<7>#676	0.337203	$metal3
+ $W=3e-07
Rc3129	vbottom<7>#971	vbottom<7>#973	0.337203	$metal3
+ $W=3e-07
Rc3130	vbottom<7>#971	vbottom<7>#974	0.698840	$metal3
+ $W=3e-07
Rc3131	vbottom<7>#972	vbottom<7>#382	0.337203	$metal3
+ $W=3e-07
Rc3132	vbottom<7>#972	vbottom<7>#975	0.215025	$metal3
+ $W=6e-07
Rc3133	vbottom<7>#975	vbottom<7>#976	0.025931	$metal3
+ $W=4.2e-06
Rc3134	vbottom<7>#973	vbottom<7>#967	0.215025	$metal3
+ $W=6e-07
Rc3135	vbottom<7>#974	vbottom<7>#675	0.337203	$metal3
+ $W=3e-07
Rc3136	vbottom<7>#974	vbottom<7>#977	0.556646	$metal3
+ $W=6e-07
Rc3137	vbottom<7>#977	vbottom<7>#978	0.025931	$metal3
+ $W=4.2e-06
Rc3138	vbottom<7>#975	vbottom<7>#979	0.193867	$metal3
+ $W=6e-07
Rc3139	vbottom<7>#976	vbottom<7>#383	0.025931	$metal3
+ $W=4.2e-06
Rc3140	vbottom<7>#976	vbottom<7>#384	0.025894	$metal3
+ $W=4.2e-06
Rc3141	vbottom<7>#976	vbottom<7>#382	0.025894	$metal3
+ $W=4.2e-06
Rc3142	vbottom<7>#978	vbottom<7>#674	0.025931	$metal3
+ $W=4.2e-06
Rc3143	vbottom<7>#978	vbottom<7>#974	0.025931	$metal3
+ $W=4.2e-06
Rc3144	vbottom<7>#978	vbottom<7>#980	0.025931	$metal3
+ $W=4.2e-06
Rc3145	vbottom<7>#979	vbottom<7>#384	0.337203	$metal3
+ $W=3e-07
Rc3146	vbottom<7>#979	vbottom<7>#981	0.685401	$metal3
+ $W=3e-07
Rc3147	vbottom<7>#980	vbottom<7>#673	0.337203	$metal3
+ $W=3e-07
Rc3148	vbottom<7>#980	vbottom<7>#982	0.337203	$metal3
+ $W=3e-07
Rc3149	vbottom<7>#980	vbottom<7>#983	0.698840	$metal3
+ $W=3e-07
Rc3150	vbottom<7>#981	vbottom<7>#385	0.337203	$metal3
+ $W=3e-07
Rc3151	vbottom<7>#981	vbottom<7>#984	0.215025	$metal3
+ $W=6e-07
Rc3152	vbottom<7>#984	vbottom<7>#985	0.025931	$metal3
+ $W=4.2e-06
Rc3153	vbottom<7>#982	vbottom<7>#977	0.215025	$metal3
+ $W=6e-07
Rc3154	vbottom<7>#983	vbottom<7>#672	0.337203	$metal3
+ $W=3e-07
Rc3155	vbottom<7>#983	vbottom<7>#986	0.556646	$metal3
+ $W=6e-07
Rc3156	vbottom<7>#986	vbottom<7>#987	0.025931	$metal3
+ $W=4.2e-06
Rc3157	vbottom<7>#984	vbottom<7>#988	0.193867	$metal3
+ $W=6e-07
Rc3158	vbottom<7>#985	vbottom<7>#386	0.025931	$metal3
+ $W=4.2e-06
Rc3159	vbottom<7>#985	vbottom<7>#387	0.025894	$metal3
+ $W=4.2e-06
Rc3160	vbottom<7>#985	vbottom<7>#385	0.025894	$metal3
+ $W=4.2e-06
Rc3161	vbottom<7>#987	vbottom<7>#671	0.025931	$metal3
+ $W=4.2e-06
Rc3162	vbottom<7>#987	vbottom<7>#983	0.025931	$metal3
+ $W=4.2e-06
Rc3163	vbottom<7>#987	vbottom<7>#989	0.025931	$metal3
+ $W=4.2e-06
Rc3164	vbottom<7>#988	vbottom<7>#387	0.337203	$metal3
+ $W=3e-07
Rc3165	vbottom<7>#988	vbottom<7>#990	0.685401	$metal3
+ $W=3e-07
Rc3166	vbottom<7>#989	vbottom<7>#670	0.337203	$metal3
+ $W=3e-07
Rc3167	vbottom<7>#989	vbottom<7>#991	0.337203	$metal3
+ $W=3e-07
Rc3168	vbottom<7>#989	vbottom<7>#992	0.698840	$metal3
+ $W=3e-07
Rc3169	vbottom<7>#990	vbottom<7>#388	0.337203	$metal3
+ $W=3e-07
Rc3170	vbottom<7>#990	vbottom<7>#993	0.215025	$metal3
+ $W=6e-07
Rc3171	vbottom<7>#993	vbottom<7>#994	0.025931	$metal3
+ $W=4.2e-06
Rc3172	vbottom<7>#991	vbottom<7>#986	0.215025	$metal3
+ $W=6e-07
Rc3173	vbottom<7>#992	vbottom<7>#669	0.337203	$metal3
+ $W=3e-07
Rc3174	vbottom<7>#992	vbottom<7>#995	0.556646	$metal3
+ $W=6e-07
Rc3175	vbottom<7>#995	vbottom<7>#996	0.025931	$metal3
+ $W=4.2e-06
Rc3176	vbottom<7>#993	vbottom<7>#997	0.193867	$metal3
+ $W=6e-07
Rc3177	vbottom<7>#994	vbottom<7>#389	0.025931	$metal3
+ $W=4.2e-06
Rc3178	vbottom<7>#994	vbottom<7>#390	0.025894	$metal3
+ $W=4.2e-06
Rc3179	vbottom<7>#994	vbottom<7>#388	0.025894	$metal3
+ $W=4.2e-06
Rc3180	vbottom<7>#996	vbottom<7>#668	0.025931	$metal3
+ $W=4.2e-06
Rc3181	vbottom<7>#996	vbottom<7>#992	0.025931	$metal3
+ $W=4.2e-06
Rc3182	vbottom<7>#996	vbottom<7>#998	0.025931	$metal3
+ $W=4.2e-06
Rc3183	vbottom<7>#997	vbottom<7>#390	0.337203	$metal3
+ $W=3e-07
Rc3184	vbottom<7>#997	vbottom<7>#999	0.685401	$metal3
+ $W=3e-07
Rc3185	vbottom<7>#998	vbottom<7>#667	0.337203	$metal3
+ $W=3e-07
Rc3186	vbottom<7>#998	vbottom<7>#1000	0.337203	$metal3
+ $W=3e-07
Rc3187	vbottom<7>#998	vbottom<7>#1001	0.698840	$metal3
+ $W=3e-07
Rc3188	vbottom<7>#999	vbottom<7>#391	0.337203	$metal3
+ $W=3e-07
Rc3189	vbottom<7>#999	vbottom<7>#1002	0.182125	$metal3
+ $W=6e-07
Rc3190	vbottom<7>#1002	vbottom<7>#1003	0.025931	$metal3
+ $W=4.2e-06
Rc3191	vbottom<7>#1000	vbottom<7>#995	0.215025	$metal3
+ $W=6e-07
Rc3192	vbottom<7>#1001	vbottom<7>#666	0.337203	$metal3
+ $W=3e-07
Rc3193	vbottom<7>#1001	vbottom<7>#1004	0.556646	$metal3
+ $W=6e-07
Rc3194	vbottom<7>#1004	vbottom<7>#1005	0.025931	$metal3
+ $W=4.2e-06
Rc3195	vbottom<7>#1002	vbottom<7>#395	0.193867	$metal3
+ $W=6e-07
Rc3196	vbottom<7>#1003	vbottom<7>#392	0.025931	$metal3
+ $W=4.2e-06
Rc3197	vbottom<7>#1003	vbottom<7>#393	0.025894	$metal3
+ $W=4.2e-06
Rc3198	vbottom<7>#1003	vbottom<7>#391	0.025894	$metal3
+ $W=4.2e-06
Rc3199	vbottom<7>#1005	vbottom<7>#665	0.025931	$metal3
+ $W=4.2e-06
Rc3200	vbottom<7>#1005	vbottom<7>#1001	0.025931	$metal3
+ $W=4.2e-06
Rc3201	vbottom<7>#1005	vbottom<7>#1006	0.025931	$metal3
+ $W=4.2e-06
Rc3202	vbottom<7>#1006	vbottom<7>#664	0.337203	$metal3
+ $W=3e-07
Rc3203	vbottom<7>#1006	vbottom<7>#1007	0.337203	$metal3
+ $W=3e-07
Rc3204	vbottom<7>#1006	vbottom<7>#1008	0.315692	$metal3
+ $W=3e-07
Rc3205	vbottom<7>#1007	vbottom<7>#1004	0.215025	$metal3
+ $W=6e-07
Rc3206	vbottom<7>#1008	vbottom<7>#624	0.349420	$metal3
+ $W=3e-07
Rc3207	vbottom<3>#15	vbottom<3>#12	9.776300	$metal3
+ $W=3e-07
Rc3208	vssa#219	vssa#210	2.273333	$metal3
+ $W=1e-06
Rc3209	vssa#221	vssa#205	3.410000	$metal3
+ $W=6e-07
Rc3210	vssa#223	vssa#197	3.410000	$metal3
+ $W=6e-07
Rc3211	vssa#225	vssa#226	0.359916	$metal3
+ $W=3e-07
Rc3212	vssa#226	vssa#227	0.025931	$metal3
+ $W=4.2e-06
Rc3213	vssa#227	vssa#228	0.036000	$metal3
+ $W=4.2e-06
Rc3214	vssa#228	vssa#229	0.672211	$metal3
+ $W=3e-07
Rc3215	vssa#229	vssa#230	0.036000	$metal3
+ $W=4.2e-06
Rc3216	vssa#230	vssa#231	0.036000	$metal3
+ $W=4.2e-06
Rc3217	vssa#231	vssa#232	0.672211	$metal3
+ $W=3e-07
Rc3218	vssa#232	vssa#233	0.036000	$metal3
+ $W=4.2e-06
Rc3219	vssa#233	vssa#234	0.036000	$metal3
+ $W=4.2e-06
Rc3220	vssa#234	vssa#235	0.672211	$metal3
+ $W=3e-07
Rc3221	vssa#235	vssa#236	0.036000	$metal3
+ $W=4.2e-06
Rc3222	vssa#236	vssa#237	0.036000	$metal3
+ $W=4.2e-06
Rc3223	vssa#237	vssa#238	0.672211	$metal3
+ $W=3e-07
Rc3224	vssa#238	vssa#239	0.036000	$metal3
+ $W=4.2e-06
Rc3225	vssa#239	vssa#240	0.036000	$metal3
+ $W=4.2e-06
Rc3226	vssa#240	vssa#241	0.672211	$metal3
+ $W=3e-07
Rc3227	vssa#241	vssa#242	0.036000	$metal3
+ $W=4.2e-06
Rc3228	vssa#242	vssa#243	0.036000	$metal3
+ $W=4.2e-06
Rc3229	vssa#243	vssa#244	0.672211	$metal3
+ $W=3e-07
Rc3230	vssa#244	vssa#245	0.036000	$metal3
+ $W=4.2e-06
Rc3231	vssa#245	vssa#246	0.036000	$metal3
+ $W=4.2e-06
Rc3232	vssa#246	vssa#247	0.672211	$metal3
+ $W=3e-07
Rc3233	vssa#247	vssa#248	0.036000	$metal3
+ $W=4.2e-06
Rc3234	vssa#248	vssa#249	0.036000	$metal3
+ $W=4.2e-06
Rc3235	vssa#249	vssa#250	0.672211	$metal3
+ $W=3e-07
Rc3236	vssa#250	vssa#251	0.036000	$metal3
+ $W=4.2e-06
Rc3237	vssa#251	vssa#252	0.036000	$metal3
+ $W=4.2e-06
Rc3238	vssa#252	vssa#253	0.672211	$metal3
+ $W=3e-07
Rc3239	vssa#253	vssa#254	0.036000	$metal3
+ $W=4.2e-06
Rc3240	vssa#254	vssa#255	0.036000	$metal3
+ $W=4.2e-06
Rc3241	vssa#255	vssa#256	0.672211	$metal3
+ $W=3e-07
Rc3242	vssa#256	vssa#257	0.036000	$metal3
+ $W=4.2e-06
Rc3243	vssa#257	vssa#258	0.036000	$metal3
+ $W=4.2e-06
Rc3244	vssa#258	vssa#259	0.672211	$metal3
+ $W=3e-07
Rc3245	vssa#259	vssa#260	0.036000	$metal3
+ $W=4.2e-06
Rc3246	vssa#260	vssa#261	0.036000	$metal3
+ $W=4.2e-06
Rc3247	vssa#261	vssa#262	0.672211	$metal3
+ $W=3e-07
Rc3248	vssa#262	vssa#263	0.036000	$metal3
+ $W=4.2e-06
Rc3249	vssa#263	vssa#264	0.036000	$metal3
+ $W=4.2e-06
Rc3250	vssa#264	vssa#265	0.672211	$metal3
+ $W=3e-07
Rc3251	vssa#265	vssa#266	0.036000	$metal3
+ $W=4.2e-06
Rc3252	vssa#266	vssa#267	0.036000	$metal3
+ $W=4.2e-06
Rc3253	vssa#267	vssa#268	0.672211	$metal3
+ $W=3e-07
Rc3254	vssa#268	vssa#269	0.036000	$metal3
+ $W=4.2e-06
Rc3255	vssa#269	vssa#270	0.036000	$metal3
+ $W=4.2e-06
Rc3256	vssa#270	vssa#271	0.672211	$metal3
+ $W=3e-07
Rc3257	vssa#271	vssa#272	0.036000	$metal3
+ $W=4.2e-06
Rc3258	vssa#272	vssa#273	0.025931	$metal3
+ $W=4.2e-06
Rc3259	vssa#273	vssa#274	0.314794	$metal3
+ $W=3e-07
Rc3260	vssa#274	vssa#275	0.337626	$metal3
+ $W=3e-07
Rc3261	vssa#275	vssa#276	0.025931	$metal3
+ $W=4.2e-06
Rc3262	vssa#276	vssa#277	0.025931	$metal3
+ $W=4.2e-06
Rc3263	vssa#277	vssa#278	0.556646	$metal3
+ $W=6e-07
Rc3264	vssa#278	vssa#279	0.334635	$metal3
+ $W=3e-07
Rc3265	vssa#279	vssa#280	0.351797	$metal3
+ $W=3e-07
Rc3266	vssa#280	vssa#281	0.556646	$metal3
+ $W=3e-07
Rc3267	vssa#281	vssa#282	0.523746	$metal3
+ $W=6e-07
Rc3268	vssa#282	vssa#283	0.698840	$metal3
+ $W=3e-07
Rc3269	vssa#283	vssa#284	0.556646	$metal3
+ $W=3e-07
Rc3270	vssa#284	vssa#285	0.523746	$metal3
+ $W=6e-07
Rc3271	vssa#285	vssa#286	0.664836	$metal3
+ $W=3e-07
Rc3272	vssa#286	vssa#287	0.556646	$metal3
+ $W=3e-07
Rc3273	vssa#287	vssa#288	0.523746	$metal3
+ $W=6e-07
Rc3274	vssa#288	vssa#289	0.664836	$metal3
+ $W=3e-07
Rc3275	vssa#289	vssa#290	0.556646	$metal3
+ $W=3e-07
Rc3276	vssa#290	vssa#291	0.523746	$metal3
+ $W=6e-07
Rc3277	vssa#291	vssa#292	0.664836	$metal3
+ $W=3e-07
Rc3278	vssa#292	vssa#293	0.556646	$metal3
+ $W=3e-07
Rc3279	vssa#293	vssa#294	0.523746	$metal3
+ $W=6e-07
Rc3280	vssa#294	vssa#295	0.664836	$metal3
+ $W=3e-07
Rc3281	vssa#295	vssa#296	0.556646	$metal3
+ $W=3e-07
Rc3282	vssa#296	vssa#297	0.523746	$metal3
+ $W=6e-07
Rc3283	vssa#297	vssa#298	0.664836	$metal3
+ $W=3e-07
Rc3284	vssa#298	vssa#299	0.556646	$metal3
+ $W=3e-07
Rc3285	vssa#299	vssa#300	0.523746	$metal3
+ $W=6e-07
Rc3286	vssa#300	vssa#301	0.664836	$metal3
+ $W=3e-07
Rc3287	vssa#301	vssa#302	0.556646	$metal3
+ $W=3e-07
Rc3288	vssa#302	vssa#303	0.523746	$metal3
+ $W=6e-07
Rc3289	vssa#303	vssa#304	0.664836	$metal3
+ $W=3e-07
Rc3290	vssa#304	vssa#305	0.556646	$metal3
+ $W=3e-07
Rc3291	vssa#305	vssa#306	0.523746	$metal3
+ $W=6e-07
Rc3292	vssa#306	vssa#307	0.698840	$metal3
+ $W=3e-07
Rc3293	vssa#307	vssa#308	0.556646	$metal3
+ $W=3e-07
Rc3294	vssa#308	vssa#309	0.523746	$metal3
+ $W=6e-07
Rc3295	vssa#309	vssa#310	0.698840	$metal3
+ $W=3e-07
Rc3296	vssa#310	vssa#311	0.556646	$metal3
+ $W=3e-07
Rc3297	vssa#311	vssa#312	0.523746	$metal3
+ $W=6e-07
Rc3298	vssa#312	vssa#313	0.698840	$metal3
+ $W=3e-07
Rc3299	vssa#313	vssa#314	0.556646	$metal3
+ $W=3e-07
Rc3300	vssa#314	vssa#315	0.523746	$metal3
+ $W=6e-07
Rc3301	vssa#315	vssa#316	0.698840	$metal3
+ $W=3e-07
Rc3302	vssa#316	vssa#317	0.556646	$metal3
+ $W=3e-07
Rc3303	vssa#317	vssa#318	0.523746	$metal3
+ $W=6e-07
Rc3304	vssa#318	vssa#319	0.698840	$metal3
+ $W=3e-07
Rc3305	vssa#319	vssa#320	0.556646	$metal3
+ $W=3e-07
Rc3306	vssa#320	vssa#321	0.523746	$metal3
+ $W=6e-07
Rc3307	vssa#321	vssa#322	0.698840	$metal3
+ $W=3e-07
Rc3308	vssa#322	vssa#323	0.556646	$metal3
+ $W=3e-07
Rc3309	vssa#323	vssa#324	0.523746	$metal3
+ $W=6e-07
Rc3310	vssa#324	vssa#325	0.698840	$metal3
+ $W=3e-07
Rc3311	vssa#325	vssa#326	0.556646	$metal3
+ $W=3e-07
Rc3312	vssa#326	vssa#327	0.523746	$metal3
+ $W=6e-07
Rc3313	vssa#327	vssa#328	0.342397	$metal3
+ $W=3e-07
Rc3314	vssa#328	vssa#329	0.345531	$metal3
+ $W=3e-07
Rc3315	vssa#329	vssa#330	0.556646	$metal3
+ $W=3e-07
Rc3316	vssa#330	vssa#331	0.523746	$metal3
+ $W=6e-07
Rc3317	vssa#331	vssa#332	0.556646	$metal3
+ $W=6e-07
Rc3318	vssa#332	vssa#333	0.025931	$metal3
+ $W=4.2e-06
Rc3319	vssa#228	vssa#334	0.782161	$metal3
+ $W=6e-07
Rc3320	vssa#231	vssa#335	0.782161	$metal3
+ $W=6e-07
Rc3321	vssa#234	vssa#336	0.782161	$metal3
+ $W=6e-07
Rc3322	vssa#240	vssa#337	0.782161	$metal3
+ $W=6e-07
Rc3323	vssa#243	vssa#338	0.782161	$metal3
+ $W=6e-07
Rc3324	vssa#246	vssa#339	0.782161	$metal3
+ $W=6e-07
Rc3325	vssa#249	vssa#340	0.782161	$metal3
+ $W=6e-07
Rc3326	vssa#252	vssa#341	0.782161	$metal3
+ $W=6e-07
Rc3327	vssa#255	vssa#342	0.782161	$metal3
+ $W=6e-07
Rc3328	vssa#258	vssa#343	0.782161	$metal3
+ $W=6e-07
Rc3329	vssa#261	vssa#344	0.782161	$metal3
+ $W=6e-07
Rc3330	vssa#264	vssa#345	0.782161	$metal3
+ $W=6e-07
Rc3331	vssa#267	vssa#346	0.782161	$metal3
+ $W=6e-07
Rc3332	vssa#270	vssa#347	0.782161	$metal3
+ $W=6e-07
Rc3333	vssa#273	vssa#348	0.556646	$metal3
+ $W=6e-07
Rc3334	vssa#277	vssa#349	0.523746	$metal3
+ $W=6e-07
Rc3335	vssa#278	vssa#276	0.025931	$metal3
+ $W=4.2e-06
Rc3336	vssa#332	vssa#350	0.340261	$metal3
+ $W=3e-07
Rc3337	vssa#333	vssa#330	0.025931	$metal3
+ $W=4.2e-06
Rc3338	vssa#333	vssa#331	0.025931	$metal3
+ $W=4.2e-06
Rc3339	vssa#333	vssa#329	0.025931	$metal3
+ $W=4.2e-06
Rc3340	vssa#334	vssa#227	0.025931	$metal3
+ $W=4.2e-06
Rc3341	vssa#334	vssa#351	0.337203	$metal3
+ $W=3e-07
Rc3342	vssa#335	vssa#230	0.025931	$metal3
+ $W=4.2e-06
Rc3343	vssa#335	vssa#352	0.340788	$metal3
+ $W=3e-07
Rc3344	vssa#336	vssa#233	0.025931	$metal3
+ $W=4.2e-06
Rc3345	vssa#336	vssa#353	0.340788	$metal3
+ $W=3e-07
Rc3346	vssa#337	vssa#239	0.025931	$metal3
+ $W=4.2e-06
Rc3347	vssa#337	vssa#354	0.215025	$metal3
+ $W=6e-07
Rc3348	vssa#338	vssa#242	0.025931	$metal3
+ $W=4.2e-06
Rc3349	vssa#338	vssa#355	0.340788	$metal3
+ $W=3e-07
Rc3350	vssa#339	vssa#245	0.025931	$metal3
+ $W=4.2e-06
Rc3351	vssa#339	vssa#356	0.340788	$metal3
+ $W=3e-07
Rc3352	vssa#340	vssa#248	0.025931	$metal3
+ $W=4.2e-06
Rc3353	vssa#340	vssa#357	0.340788	$metal3
+ $W=3e-07
Rc3354	vssa#341	vssa#251	0.025931	$metal3
+ $W=4.2e-06
Rc3355	vssa#341	vssa#358	0.340788	$metal3
+ $W=3e-07
Rc3356	vssa#342	vssa#254	0.025931	$metal3
+ $W=4.2e-06
Rc3357	vssa#342	vssa#359	0.340788	$metal3
+ $W=3e-07
Rc3358	vssa#343	vssa#257	0.025931	$metal3
+ $W=4.2e-06
Rc3359	vssa#343	vssa#360	0.340788	$metal3
+ $W=3e-07
Rc3360	vssa#344	vssa#260	0.025931	$metal3
+ $W=4.2e-06
Rc3361	vssa#344	vssa#361	0.340788	$metal3
+ $W=3e-07
Rc3362	vssa#345	vssa#263	0.025931	$metal3
+ $W=4.2e-06
Rc3363	vssa#345	vssa#362	0.340788	$metal3
+ $W=3e-07
Rc3364	vssa#346	vssa#266	0.025931	$metal3
+ $W=4.2e-06
Rc3365	vssa#346	vssa#363	0.340788	$metal3
+ $W=3e-07
Rc3366	vssa#347	vssa#269	0.025931	$metal3
+ $W=4.2e-06
Rc3367	vssa#347	vssa#364	0.340788	$metal3
+ $W=3e-07
Rc3368	vssa#348	vssa#272	0.025931	$metal3
+ $W=4.2e-06
Rc3369	vssa#348	vssa#365	0.340788	$metal3
+ $W=3e-07
Rc3370	vssa#349	vssa#276	0.025931	$metal3
+ $W=4.2e-06
Rc3371	vssa#349	vssa#366	0.337203	$metal3
+ $W=3e-07
Rc3372	vssa#350	vssa#367	0.314366	$metal3
+ $W=3e-07
Rc3373	vssa#367	vssa#368	0.556646	$metal3
+ $W=6e-07
Rc3374	vssa#368	vssa#369	0.556646	$metal3
+ $W=6e-07
Rc3375	vssa#369	vssa#370	0.025931	$metal3
+ $W=4.2e-06
Rc3376	vssa#351	vssa#226	0.215025	$metal3
+ $W=6e-07
Rc3377	vssa#352	vssa#229	0.437015	$metal3
+ $W=6e-07
Rc3378	vssa#353	vssa#232	0.437015	$metal3
+ $W=6e-07
Rc3379	vssa#354	vssa#238	0.523909	$metal3
+ $W=6e-07
Rc3380	vssa#354	vssa#371	0.673659	$metal3
+ $W=3e-07
Rc3381	vssa#355	vssa#241	0.437015	$metal3
+ $W=6e-07
Rc3382	vssa#356	vssa#244	0.437015	$metal3
+ $W=6e-07
Rc3383	vssa#357	vssa#247	0.437015	$metal3
+ $W=6e-07
Rc3384	vssa#358	vssa#250	0.437015	$metal3
+ $W=6e-07
Rc3385	vssa#359	vssa#253	0.437015	$metal3
+ $W=6e-07
Rc3386	vssa#360	vssa#256	0.437015	$metal3
+ $W=6e-07
Rc3387	vssa#361	vssa#259	0.437015	$metal3
+ $W=6e-07
Rc3388	vssa#362	vssa#262	0.437015	$metal3
+ $W=6e-07
Rc3389	vssa#363	vssa#265	0.437015	$metal3
+ $W=6e-07
Rc3390	vssa#364	vssa#268	0.437015	$metal3
+ $W=6e-07
Rc3391	vssa#365	vssa#271	0.437015	$metal3
+ $W=6e-07
Rc3392	vssa#366	vssa#275	0.215025	$metal3
+ $W=6e-07
Rc3393	vssa#370	vssa#367	0.025931	$metal3
+ $W=4.2e-06
Rc3394	vssa#370	vssa#368	0.025931	$metal3
+ $W=4.2e-06
Rc3395	vssa#370	vssa#372	0.025931	$metal3
+ $W=4.2e-06
Rc3396	vssa#372	vssa#373	0.226767	$metal3
+ $W=6e-07
Rc3397	vssa#373	vssa#374	0.329561	$metal3
+ $W=3e-07
Rc3398	vssa#374	vssa#375	0.321109	$metal3
+ $W=3e-07
Rc3399	vssa#371	vssa#237	0.523909	$metal3
+ $W=6e-07
Rc3400	vssa#371	vssa#376	0.226767	$metal3
+ $W=6e-07
Rc3401	vssa#373	vssa#367	0.337203	$metal3
+ $W=3e-07
Rc3402	vssa#375	vssa#329	0.345935	$metal3
+ $W=3e-07
Rc3403	vssa#375	vssa#332	0.345935	$metal3
+ $W=3e-07
Rc3404	vssa#375	vssa#377	0.326379	$metal3
+ $W=3e-07
Rc3405	vssa#376	vssa#236	0.025931	$metal3
+ $W=4.2e-06
Rc3406	vssa#376	vssa#378	0.340788	$metal3
+ $W=3e-07
Rc3407	vssa#377	vssa#379	0.335678	$metal3
+ $W=3e-07
Rc3408	vssa#378	vssa#235	0.437015	$metal3
+ $W=6e-07
Rc3409	vssa#379	vssa#327	0.337203	$metal3
+ $W=3e-07
Rc3410	vssa#379	vssa#380	0.215025	$metal3
+ $W=6e-07
Rc3411	vssa#380	vssa#381	0.025931	$metal3
+ $W=4.2e-06
Rc3412	vssa#380	vssa#382	0.193867	$metal3
+ $W=6e-07
Rc3413	vssa#381	vssa#326	0.025931	$metal3
+ $W=4.2e-06
Rc3414	vssa#381	vssa#327	0.025931	$metal3
+ $W=4.2e-06
Rc3415	vssa#381	vssa#325	0.025931	$metal3
+ $W=4.2e-06
Rc3416	vssa#382	vssa#325	0.337203	$metal3
+ $W=3e-07
Rc3417	vssa#382	vssa#383	0.685401	$metal3
+ $W=3e-07
Rc3418	vssa#383	vssa#324	0.337203	$metal3
+ $W=3e-07
Rc3419	vssa#383	vssa#384	0.215025	$metal3
+ $W=6e-07
Rc3420	vssa#384	vssa#385	0.025931	$metal3
+ $W=4.2e-06
Rc3421	vssa#384	vssa#386	0.193867	$metal3
+ $W=6e-07
Rc3422	vssa#385	vssa#323	0.025931	$metal3
+ $W=4.2e-06
Rc3423	vssa#385	vssa#324	0.025931	$metal3
+ $W=4.2e-06
Rc3424	vssa#385	vssa#322	0.025931	$metal3
+ $W=4.2e-06
Rc3425	vssa#386	vssa#322	0.337203	$metal3
+ $W=3e-07
Rc3426	vssa#386	vssa#387	0.685401	$metal3
+ $W=3e-07
Rc3427	vssa#387	vssa#321	0.337203	$metal3
+ $W=3e-07
Rc3428	vssa#387	vssa#388	0.215025	$metal3
+ $W=6e-07
Rc3429	vssa#388	vssa#389	0.025931	$metal3
+ $W=4.2e-06
Rc3430	vssa#388	vssa#390	0.193867	$metal3
+ $W=6e-07
Rc3431	vssa#389	vssa#320	0.025931	$metal3
+ $W=4.2e-06
Rc3432	vssa#389	vssa#321	0.025931	$metal3
+ $W=4.2e-06
Rc3433	vssa#389	vssa#319	0.025931	$metal3
+ $W=4.2e-06
Rc3434	vssa#390	vssa#319	0.337203	$metal3
+ $W=3e-07
Rc3435	vssa#390	vssa#391	0.685401	$metal3
+ $W=3e-07
Rc3436	vssa#391	vssa#318	0.337203	$metal3
+ $W=3e-07
Rc3437	vssa#391	vssa#392	0.215025	$metal3
+ $W=6e-07
Rc3438	vssa#392	vssa#393	0.025931	$metal3
+ $W=4.2e-06
Rc3439	vssa#392	vssa#394	0.193867	$metal3
+ $W=6e-07
Rc3440	vssa#393	vssa#317	0.025931	$metal3
+ $W=4.2e-06
Rc3441	vssa#393	vssa#318	0.025931	$metal3
+ $W=4.2e-06
Rc3442	vssa#393	vssa#316	0.025931	$metal3
+ $W=4.2e-06
Rc3443	vssa#394	vssa#316	0.337203	$metal3
+ $W=3e-07
Rc3444	vssa#394	vssa#395	0.685401	$metal3
+ $W=3e-07
Rc3445	vssa#395	vssa#315	0.337203	$metal3
+ $W=3e-07
Rc3446	vssa#395	vssa#396	0.215025	$metal3
+ $W=6e-07
Rc3447	vssa#396	vssa#397	0.025931	$metal3
+ $W=4.2e-06
Rc3448	vssa#396	vssa#398	0.193867	$metal3
+ $W=6e-07
Rc3449	vssa#397	vssa#314	0.025931	$metal3
+ $W=4.2e-06
Rc3450	vssa#397	vssa#315	0.025931	$metal3
+ $W=4.2e-06
Rc3451	vssa#397	vssa#313	0.025931	$metal3
+ $W=4.2e-06
Rc3452	vssa#398	vssa#313	0.337203	$metal3
+ $W=3e-07
Rc3453	vssa#398	vssa#399	0.685401	$metal3
+ $W=3e-07
Rc3454	vssa#399	vssa#312	0.337203	$metal3
+ $W=3e-07
Rc3455	vssa#399	vssa#400	0.215025	$metal3
+ $W=6e-07
Rc3456	vssa#400	vssa#401	0.025931	$metal3
+ $W=4.2e-06
Rc3457	vssa#400	vssa#402	0.193867	$metal3
+ $W=6e-07
Rc3458	vssa#401	vssa#311	0.025931	$metal3
+ $W=4.2e-06
Rc3459	vssa#401	vssa#312	0.025931	$metal3
+ $W=4.2e-06
Rc3460	vssa#401	vssa#310	0.025931	$metal3
+ $W=4.2e-06
Rc3461	vssa#402	vssa#310	0.337203	$metal3
+ $W=3e-07
Rc3462	vssa#402	vssa#403	0.685401	$metal3
+ $W=3e-07
Rc3463	vssa#403	vssa#309	0.337203	$metal3
+ $W=3e-07
Rc3464	vssa#403	vssa#404	0.215025	$metal3
+ $W=6e-07
Rc3465	vssa#404	vssa#405	0.025931	$metal3
+ $W=4.2e-06
Rc3466	vssa#404	vssa#406	0.193867	$metal3
+ $W=6e-07
Rc3467	vssa#405	vssa#308	0.025931	$metal3
+ $W=4.2e-06
Rc3468	vssa#405	vssa#309	0.025931	$metal3
+ $W=4.2e-06
Rc3469	vssa#405	vssa#307	0.025931	$metal3
+ $W=4.2e-06
Rc3470	vssa#406	vssa#307	0.337203	$metal3
+ $W=3e-07
Rc3471	vssa#406	vssa#407	0.685401	$metal3
+ $W=3e-07
Rc3472	vssa#407	vssa#306	0.337203	$metal3
+ $W=3e-07
Rc3473	vssa#407	vssa#408	0.215025	$metal3
+ $W=6e-07
Rc3474	vssa#408	vssa#409	0.025931	$metal3
+ $W=4.2e-06
Rc3475	vssa#408	vssa#410	0.193867	$metal3
+ $W=6e-07
Rc3476	vssa#409	vssa#305	0.025931	$metal3
+ $W=4.2e-06
Rc3477	vssa#409	vssa#306	0.025931	$metal3
+ $W=4.2e-06
Rc3478	vssa#409	vssa#304	0.025894	$metal3
+ $W=4.2e-06
Rc3479	vssa#410	vssa#304	0.337203	$metal3
+ $W=3e-07
Rc3480	vssa#410	vssa#411	0.685401	$metal3
+ $W=3e-07
Rc3481	vssa#411	vssa#303	0.337203	$metal3
+ $W=3e-07
Rc3482	vssa#411	vssa#412	0.215025	$metal3
+ $W=6e-07
Rc3483	vssa#412	vssa#413	0.025931	$metal3
+ $W=4.2e-06
Rc3484	vssa#412	vssa#414	0.193867	$metal3
+ $W=6e-07
Rc3485	vssa#413	vssa#302	0.025931	$metal3
+ $W=4.2e-06
Rc3486	vssa#413	vssa#303	0.025894	$metal3
+ $W=4.2e-06
Rc3487	vssa#413	vssa#301	0.025894	$metal3
+ $W=4.2e-06
Rc3488	vssa#414	vssa#301	0.337203	$metal3
+ $W=3e-07
Rc3489	vssa#414	vssa#415	0.685401	$metal3
+ $W=3e-07
Rc3490	vssa#415	vssa#300	0.337203	$metal3
+ $W=3e-07
Rc3491	vssa#415	vssa#416	0.215025	$metal3
+ $W=6e-07
Rc3492	vssa#416	vssa#417	0.025931	$metal3
+ $W=4.2e-06
Rc3493	vssa#416	vssa#418	0.193867	$metal3
+ $W=6e-07
Rc3494	vssa#417	vssa#299	0.025931	$metal3
+ $W=4.2e-06
Rc3495	vssa#417	vssa#300	0.025894	$metal3
+ $W=4.2e-06
Rc3496	vssa#417	vssa#298	0.025894	$metal3
+ $W=4.2e-06
Rc3497	vssa#418	vssa#298	0.337203	$metal3
+ $W=3e-07
Rc3498	vssa#418	vssa#419	0.685401	$metal3
+ $W=3e-07
Rc3499	vssa#419	vssa#297	0.337203	$metal3
+ $W=3e-07
Rc3500	vssa#419	vssa#420	0.215025	$metal3
+ $W=6e-07
Rc3501	vssa#420	vssa#421	0.025931	$metal3
+ $W=4.2e-06
Rc3502	vssa#420	vssa#422	0.193867	$metal3
+ $W=6e-07
Rc3503	vssa#421	vssa#296	0.025931	$metal3
+ $W=4.2e-06
Rc3504	vssa#421	vssa#297	0.025894	$metal3
+ $W=4.2e-06
Rc3505	vssa#421	vssa#295	0.025894	$metal3
+ $W=4.2e-06
Rc3506	vssa#422	vssa#295	0.337203	$metal3
+ $W=3e-07
Rc3507	vssa#422	vssa#423	0.685401	$metal3
+ $W=3e-07
Rc3508	vssa#423	vssa#294	0.337203	$metal3
+ $W=3e-07
Rc3509	vssa#423	vssa#424	0.215025	$metal3
+ $W=6e-07
Rc3510	vssa#424	vssa#425	0.025931	$metal3
+ $W=4.2e-06
Rc3511	vssa#424	vssa#426	0.193867	$metal3
+ $W=6e-07
Rc3512	vssa#425	vssa#293	0.025931	$metal3
+ $W=4.2e-06
Rc3513	vssa#425	vssa#294	0.025894	$metal3
+ $W=4.2e-06
Rc3514	vssa#425	vssa#292	0.025894	$metal3
+ $W=4.2e-06
Rc3515	vssa#426	vssa#292	0.337203	$metal3
+ $W=3e-07
Rc3516	vssa#426	vssa#427	0.685401	$metal3
+ $W=3e-07
Rc3517	vssa#427	vssa#291	0.337203	$metal3
+ $W=3e-07
Rc3518	vssa#427	vssa#428	0.215025	$metal3
+ $W=6e-07
Rc3519	vssa#428	vssa#429	0.025931	$metal3
+ $W=4.2e-06
Rc3520	vssa#428	vssa#430	0.193867	$metal3
+ $W=6e-07
Rc3521	vssa#429	vssa#290	0.025931	$metal3
+ $W=4.2e-06
Rc3522	vssa#429	vssa#291	0.025894	$metal3
+ $W=4.2e-06
Rc3523	vssa#429	vssa#289	0.025894	$metal3
+ $W=4.2e-06
Rc3524	vssa#430	vssa#289	0.337203	$metal3
+ $W=3e-07
Rc3525	vssa#430	vssa#431	0.685401	$metal3
+ $W=3e-07
Rc3526	vssa#431	vssa#288	0.337203	$metal3
+ $W=3e-07
Rc3527	vssa#431	vssa#432	0.215025	$metal3
+ $W=6e-07
Rc3528	vssa#432	vssa#433	0.025931	$metal3
+ $W=4.2e-06
Rc3529	vssa#432	vssa#434	0.193867	$metal3
+ $W=6e-07
Rc3530	vssa#433	vssa#287	0.025931	$metal3
+ $W=4.2e-06
Rc3531	vssa#433	vssa#288	0.025894	$metal3
+ $W=4.2e-06
Rc3532	vssa#433	vssa#286	0.025894	$metal3
+ $W=4.2e-06
Rc3533	vssa#434	vssa#286	0.337203	$metal3
+ $W=3e-07
Rc3534	vssa#434	vssa#435	0.685401	$metal3
+ $W=3e-07
Rc3535	vssa#435	vssa#285	0.337203	$metal3
+ $W=3e-07
Rc3536	vssa#435	vssa#436	0.215025	$metal3
+ $W=6e-07
Rc3537	vssa#436	vssa#437	0.025931	$metal3
+ $W=4.2e-06
Rc3538	vssa#436	vssa#438	0.193867	$metal3
+ $W=6e-07
Rc3539	vssa#437	vssa#284	0.025931	$metal3
+ $W=4.2e-06
Rc3540	vssa#437	vssa#285	0.025894	$metal3
+ $W=4.2e-06
Rc3541	vssa#437	vssa#283	0.025931	$metal3
+ $W=4.2e-06
Rc3542	vssa#438	vssa#283	0.337203	$metal3
+ $W=3e-07
Rc3543	vssa#438	vssa#439	0.685401	$metal3
+ $W=3e-07
Rc3544	vssa#439	vssa#282	0.337203	$metal3
+ $W=3e-07
Rc3545	vssa#439	vssa#440	0.215025	$metal3
+ $W=6e-07
Rc3546	vssa#440	vssa#441	0.025931	$metal3
+ $W=4.2e-06
Rc3547	vssa#440	vssa#442	0.193867	$metal3
+ $W=6e-07
Rc3548	vssa#441	vssa#281	0.025931	$metal3
+ $W=4.2e-06
Rc3549	vssa#441	vssa#282	0.025931	$metal3
+ $W=4.2e-06
Rc3550	vssa#441	vssa#280	0.025931	$metal3
+ $W=4.2e-06
Rc3551	vssa#442	vssa#280	0.337203	$metal3
+ $W=3e-07
Rc3552	vssa#442	vssa#443	0.345078	$metal3
+ $W=3e-07
Rc3553	vssa#443	vssa#444	0.315555	$metal3
+ $W=3e-07
Rc3554	vssa#444	vssa#278	0.345935	$metal3
+ $W=3e-07
Rc3555	vssa#444	vssa#445	0.318474	$metal3
+ $W=3e-07
Rc3556	vssa#444	vssa#275	0.345935	$metal3
+ $W=3e-07
Rc3557	vssa#445	vssa#446	0.330131	$metal3
+ $W=3e-07
Rc3558	vssa#446	vssa#447	0.226767	$metal3
+ $W=6e-07
Rc3559	vssa#447	vssa#448	0.376315	$metal3
+ $W=3e-07
Rc3560	vssa#448	vssa#449	0.612270	$metal3
+ $W=3e-07
Rc3561	vssa#449	vssa#450	0.376315	$metal3
+ $W=3e-07
Rc3562	vssa#450	vssa#451	0.376315	$metal3
+ $W=3e-07
Rc3563	vssa#451	vssa#452	0.612270	$metal3
+ $W=3e-07
Rc3564	vssa#452	vssa#453	0.376315	$metal3
+ $W=3e-07
Rc3565	vssa#453	vssa#454	0.376315	$metal3
+ $W=3e-07
Rc3566	vssa#454	vssa#455	0.612270	$metal3
+ $W=3e-07
Rc3567	vssa#455	vssa#456	0.376315	$metal3
+ $W=3e-07
Rc3568	vssa#456	vssa#457	0.376315	$metal3
+ $W=3e-07
Rc3569	vssa#457	vssa#458	0.612270	$metal3
+ $W=3e-07
Rc3570	vssa#458	vssa#459	0.376315	$metal3
+ $W=3e-07
Rc3571	vssa#459	vssa#460	0.376315	$metal3
+ $W=3e-07
Rc3572	vssa#460	vssa#461	0.612270	$metal3
+ $W=3e-07
Rc3573	vssa#461	vssa#462	0.376315	$metal3
+ $W=3e-07
Rc3574	vssa#462	vssa#463	0.376315	$metal3
+ $W=3e-07
Rc3575	vssa#463	vssa#464	0.612270	$metal3
+ $W=3e-07
Rc3576	vssa#464	vssa#465	0.376315	$metal3
+ $W=3e-07
Rc3577	vssa#465	vssa#466	0.376315	$metal3
+ $W=3e-07
Rc3578	vssa#466	vssa#467	0.612270	$metal3
+ $W=3e-07
Rc3579	vssa#467	vssa#468	0.376315	$metal3
+ $W=3e-07
Rc3580	vssa#468	vssa#469	0.376315	$metal3
+ $W=3e-07
Rc3581	vssa#469	vssa#470	0.612270	$metal3
+ $W=3e-07
Rc3582	vssa#470	vssa#471	0.376315	$metal3
+ $W=3e-07
Rc3583	vssa#471	vssa#472	0.376315	$metal3
+ $W=3e-07
Rc3584	vssa#472	vssa#473	0.612270	$metal3
+ $W=3e-07
Rc3585	vssa#473	vssa#474	0.376315	$metal3
+ $W=3e-07
Rc3586	vssa#474	vssa#475	0.376315	$metal3
+ $W=3e-07
Rc3587	vssa#475	vssa#476	0.612270	$metal3
+ $W=3e-07
Rc3588	vssa#476	vssa#477	0.376315	$metal3
+ $W=3e-07
Rc3589	vssa#477	vssa#478	0.376315	$metal3
+ $W=3e-07
Rc3590	vssa#478	vssa#479	0.612270	$metal3
+ $W=3e-07
Rc3591	vssa#479	vssa#480	0.376315	$metal3
+ $W=3e-07
Rc3592	vssa#480	vssa#481	0.376315	$metal3
+ $W=3e-07
Rc3593	vssa#481	vssa#482	0.612270	$metal3
+ $W=3e-07
Rc3594	vssa#482	vssa#483	0.376315	$metal3
+ $W=3e-07
Rc3595	vssa#483	vssa#484	0.376315	$metal3
+ $W=3e-07
Rc3596	vssa#484	vssa#485	0.612270	$metal3
+ $W=3e-07
Rc3597	vssa#485	vssa#486	0.376315	$metal3
+ $W=3e-07
Rc3598	vssa#486	vssa#487	0.376315	$metal3
+ $W=3e-07
Rc3599	vssa#487	vssa#488	0.612270	$metal3
+ $W=3e-07
Rc3600	vssa#488	vssa#489	0.376315	$metal3
+ $W=3e-07
Rc3601	vssa#489	vssa#490	0.376315	$metal3
+ $W=3e-07
Rc3602	vssa#490	vssa#491	0.612270	$metal3
+ $W=3e-07
Rc3603	vssa#491	vssa#492	0.376315	$metal3
+ $W=3e-07
Rc3604	vssa#492	vssa#493	0.215025	$metal3
+ $W=6e-07
Rc3605	vssa#493	vssa#494	0.353196	$metal3
+ $W=3e-07
Rc3606	vssa#446	vssa#273	0.337203	$metal3
+ $W=3e-07
Rc3607	vssa#447	vssa#272	0.025931	$metal3
+ $W=4.2e-06
Rc3608	vssa#448	vssa#271	0.437015	$metal3
+ $W=6e-07
Rc3609	vssa#449	vssa#270	0.437015	$metal3
+ $W=6e-07
Rc3610	vssa#450	vssa#269	0.025931	$metal3
+ $W=4.2e-06
Rc3611	vssa#451	vssa#268	0.437015	$metal3
+ $W=6e-07
Rc3612	vssa#452	vssa#267	0.437015	$metal3
+ $W=6e-07
Rc3613	vssa#453	vssa#266	0.025931	$metal3
+ $W=4.2e-06
Rc3614	vssa#454	vssa#265	0.437015	$metal3
+ $W=6e-07
Rc3615	vssa#455	vssa#264	0.437015	$metal3
+ $W=6e-07
Rc3616	vssa#456	vssa#263	0.025931	$metal3
+ $W=4.2e-06
Rc3617	vssa#457	vssa#262	0.437015	$metal3
+ $W=6e-07
Rc3618	vssa#458	vssa#261	0.437015	$metal3
+ $W=6e-07
Rc3619	vssa#459	vssa#260	0.025931	$metal3
+ $W=4.2e-06
Rc3620	vssa#460	vssa#259	0.437015	$metal3
+ $W=6e-07
Rc3621	vssa#461	vssa#258	0.437015	$metal3
+ $W=6e-07
Rc3622	vssa#462	vssa#257	0.025931	$metal3
+ $W=4.2e-06
Rc3623	vssa#463	vssa#256	0.437015	$metal3
+ $W=6e-07
Rc3624	vssa#464	vssa#255	0.437015	$metal3
+ $W=6e-07
Rc3625	vssa#465	vssa#254	0.025931	$metal3
+ $W=4.2e-06
Rc3626	vssa#466	vssa#253	0.437015	$metal3
+ $W=6e-07
Rc3627	vssa#467	vssa#252	0.437015	$metal3
+ $W=6e-07
Rc3628	vssa#468	vssa#251	0.025931	$metal3
+ $W=4.2e-06
Rc3629	vssa#469	vssa#250	0.437015	$metal3
+ $W=6e-07
Rc3630	vssa#470	vssa#249	0.437015	$metal3
+ $W=6e-07
Rc3631	vssa#471	vssa#248	0.025931	$metal3
+ $W=4.2e-06
Rc3632	vssa#472	vssa#247	0.437015	$metal3
+ $W=6e-07
Rc3633	vssa#473	vssa#246	0.437015	$metal3
+ $W=6e-07
Rc3634	vssa#474	vssa#245	0.025931	$metal3
+ $W=4.2e-06
Rc3635	vssa#475	vssa#244	0.437015	$metal3
+ $W=6e-07
Rc3636	vssa#476	vssa#243	0.437015	$metal3
+ $W=6e-07
Rc3637	vssa#477	vssa#242	0.025931	$metal3
+ $W=4.2e-06
Rc3638	vssa#478	vssa#241	0.437015	$metal3
+ $W=6e-07
Rc3639	vssa#479	vssa#240	0.437015	$metal3
+ $W=6e-07
Rc3640	vssa#480	vssa#239	0.025931	$metal3
+ $W=4.2e-06
Rc3641	vssa#481	vssa#238	0.521597	$metal3
+ $W=6e-07
Rc3642	vssa#482	vssa#237	0.521597	$metal3
+ $W=6e-07
Rc3643	vssa#483	vssa#236	0.025931	$metal3
+ $W=4.2e-06
Rc3644	vssa#484	vssa#235	0.437015	$metal3
+ $W=6e-07
Rc3645	vssa#485	vssa#234	0.437015	$metal3
+ $W=6e-07
Rc3646	vssa#486	vssa#233	0.025931	$metal3
+ $W=4.2e-06
Rc3647	vssa#487	vssa#232	0.437015	$metal3
+ $W=6e-07
Rc3648	vssa#488	vssa#231	0.437015	$metal3
+ $W=6e-07
Rc3649	vssa#489	vssa#230	0.025931	$metal3
+ $W=4.2e-06
Rc3650	vssa#490	vssa#229	0.437015	$metal3
+ $W=6e-07
Rc3651	vssa#491	vssa#228	0.437015	$metal3
+ $W=6e-07
Rc3652	vssa#492	vssa#227	0.025931	$metal3
+ $W=4.2e-06
Rc3653	vssa#493	vssa#226	0.337203	$metal3
+ $W=3e-07
Rc3654	vssa#494	vssa#495	0.307864	$metal3
+ $W=3e-07
Rc3655	vssa#495	vssa#496	0.320184	$metal3
+ $W=3e-07
Rc3656	vssa#496	vssa#497	0.341944	$metal3
+ $W=3e-07
Rc3657	vssa#497	vssa#498	0.215025	$metal3
+ $W=6e-07
Rc3658	vssa#498	vssa#499	0.193867	$metal3
+ $W=6e-07
Rc3659	vssa#499	vssa#500	0.685401	$metal3
+ $W=3e-07
Rc3660	vssa#500	vssa#501	0.215025	$metal3
+ $W=6e-07
Rc3661	vssa#501	vssa#502	0.193867	$metal3
+ $W=6e-07
Rc3662	vssa#502	vssa#503	0.685401	$metal3
+ $W=3e-07
Rc3663	vssa#503	vssa#504	0.215025	$metal3
+ $W=6e-07
Rc3664	vssa#504	vssa#505	0.193867	$metal3
+ $W=6e-07
Rc3665	vssa#505	vssa#506	0.685401	$metal3
+ $W=3e-07
Rc3666	vssa#506	vssa#507	0.215025	$metal3
+ $W=6e-07
Rc3667	vssa#507	vssa#508	0.193867	$metal3
+ $W=6e-07
Rc3668	vssa#508	vssa#509	0.685401	$metal3
+ $W=3e-07
Rc3669	vssa#509	vssa#510	0.215025	$metal3
+ $W=6e-07
Rc3670	vssa#510	vssa#511	0.193867	$metal3
+ $W=6e-07
Rc3671	vssa#511	vssa#512	0.685401	$metal3
+ $W=3e-07
Rc3672	vssa#512	vssa#513	0.215025	$metal3
+ $W=6e-07
Rc3673	vssa#513	vssa#514	0.193867	$metal3
+ $W=6e-07
Rc3674	vssa#514	vssa#515	0.685401	$metal3
+ $W=3e-07
Rc3675	vssa#515	vssa#516	0.215025	$metal3
+ $W=6e-07
Rc3676	vssa#516	vssa#517	0.193867	$metal3
+ $W=6e-07
Rc3677	vssa#517	vssa#518	0.685401	$metal3
+ $W=3e-07
Rc3678	vssa#518	vssa#519	0.215025	$metal3
+ $W=6e-07
Rc3679	vssa#519	vssa#520	0.193867	$metal3
+ $W=6e-07
Rc3680	vssa#520	vssa#521	0.685401	$metal3
+ $W=3e-07
Rc3681	vssa#521	vssa#522	0.215025	$metal3
+ $W=6e-07
Rc3682	vssa#522	vssa#523	0.193867	$metal3
+ $W=6e-07
Rc3683	vssa#523	vssa#524	0.685401	$metal3
+ $W=3e-07
Rc3684	vssa#524	vssa#525	0.215025	$metal3
+ $W=6e-07
Rc3685	vssa#525	vssa#526	0.193867	$metal3
+ $W=6e-07
Rc3686	vssa#526	vssa#527	0.685401	$metal3
+ $W=3e-07
Rc3687	vssa#527	vssa#528	0.215025	$metal3
+ $W=6e-07
Rc3688	vssa#528	vssa#529	0.193867	$metal3
+ $W=6e-07
Rc3689	vssa#529	vssa#530	0.685401	$metal3
+ $W=3e-07
Rc3690	vssa#530	vssa#531	0.215025	$metal3
+ $W=6e-07
Rc3691	vssa#531	vssa#532	0.193867	$metal3
+ $W=6e-07
Rc3692	vssa#532	vssa#533	0.685401	$metal3
+ $W=3e-07
Rc3693	vssa#533	vssa#534	0.215025	$metal3
+ $W=6e-07
Rc3694	vssa#534	vssa#535	0.193867	$metal3
+ $W=6e-07
Rc3695	vssa#535	vssa#536	0.685401	$metal3
+ $W=3e-07
Rc3696	vssa#536	vssa#537	0.215025	$metal3
+ $W=6e-07
Rc3697	vssa#537	vssa#538	0.193867	$metal3
+ $W=6e-07
Rc3698	vssa#538	vssa#539	0.685401	$metal3
+ $W=3e-07
Rc3699	vssa#539	vssa#540	0.215025	$metal3
+ $W=6e-07
Rc3700	vssa#540	vssa#541	0.193867	$metal3
+ $W=6e-07
Rc3701	vssa#541	vssa#542	0.685401	$metal3
+ $W=3e-07
Rc3702	vssa#542	vssa#543	0.215025	$metal3
+ $W=6e-07
Rc3703	vssa#543	vssa#544	0.193867	$metal3
+ $W=6e-07
Rc3704	vssa#544	vssa#545	0.344722	$metal3
+ $W=3e-07
Rc3705	vssa#545	vssa#546	0.318190	$metal3
+ $W=3e-07
Rc3706	vssa#546	vssa#547	0.322818	$metal3
+ $W=3e-07
Rc3707	vssa#547	vssa#548	0.338775	$metal3
+ $W=3e-07
Rc3708	vssa#548	vssa#549	0.213850	$metal3
+ $W=6e-07
Rc3709	vssa#549	vssa#550	0.192692	$metal3
+ $W=6e-07
Rc3710	vssa#550	vssa#551	0.671308	$metal3
+ $W=3e-07
Rc3711	vssa#551	vssa#552	0.213850	$metal3
+ $W=6e-07
Rc3712	vssa#552	vssa#553	0.192692	$metal3
+ $W=6e-07
Rc3713	vssa#553	vssa#554	0.671308	$metal3
+ $W=3e-07
Rc3714	vssa#554	vssa#555	0.213850	$metal3
+ $W=6e-07
Rc3715	vssa#555	vssa#556	0.192692	$metal3
+ $W=6e-07
Rc3716	vssa#556	vssa#557	0.671308	$metal3
+ $W=3e-07
Rc3717	vssa#557	vssa#558	0.213850	$metal3
+ $W=6e-07
Rc3718	vssa#558	vssa#559	0.192692	$metal3
+ $W=6e-07
Rc3719	vssa#559	vssa#560	0.671308	$metal3
+ $W=3e-07
Rc3720	vssa#560	vssa#561	0.213850	$metal3
+ $W=6e-07
Rc3721	vssa#561	vssa#562	0.192692	$metal3
+ $W=6e-07
Rc3722	vssa#562	vssa#563	0.671308	$metal3
+ $W=3e-07
Rc3723	vssa#563	vssa#564	0.213850	$metal3
+ $W=6e-07
Rc3724	vssa#564	vssa#565	0.192692	$metal3
+ $W=6e-07
Rc3725	vssa#565	vssa#566	0.671308	$metal3
+ $W=3e-07
Rc3726	vssa#566	vssa#567	0.213850	$metal3
+ $W=6e-07
Rc3727	vssa#567	vssa#568	0.192692	$metal3
+ $W=6e-07
Rc3728	vssa#568	vssa#569	0.671308	$metal3
+ $W=3e-07
Rc3729	vssa#569	vssa#570	0.213850	$metal3
+ $W=6e-07
Rc3730	vssa#570	vssa#571	0.192692	$metal3
+ $W=6e-07
Rc3731	vssa#571	vssa#572	0.671308	$metal3
+ $W=3e-07
Rc3732	vssa#572	vssa#573	0.213850	$metal3
+ $W=6e-07
Rc3733	vssa#573	vssa#574	0.192692	$metal3
+ $W=6e-07
Rc3734	vssa#574	vssa#575	0.671308	$metal3
+ $W=3e-07
Rc3735	vssa#575	vssa#576	0.213850	$metal3
+ $W=6e-07
Rc3736	vssa#576	vssa#577	0.192692	$metal3
+ $W=6e-07
Rc3737	vssa#577	vssa#578	0.671308	$metal3
+ $W=3e-07
Rc3738	vssa#578	vssa#579	0.213850	$metal3
+ $W=6e-07
Rc3739	vssa#579	vssa#580	0.192692	$metal3
+ $W=6e-07
Rc3740	vssa#580	vssa#581	0.671308	$metal3
+ $W=3e-07
Rc3741	vssa#581	vssa#582	0.213850	$metal3
+ $W=6e-07
Rc3742	vssa#582	vssa#583	0.192692	$metal3
+ $W=6e-07
Rc3743	vssa#583	vssa#584	0.671308	$metal3
+ $W=3e-07
Rc3744	vssa#584	vssa#585	0.213850	$metal3
+ $W=6e-07
Rc3745	vssa#585	vssa#586	0.192692	$metal3
+ $W=6e-07
Rc3746	vssa#586	vssa#587	0.671308	$metal3
+ $W=3e-07
Rc3747	vssa#587	vssa#588	0.213850	$metal3
+ $W=6e-07
Rc3748	vssa#588	vssa#589	0.192692	$metal3
+ $W=6e-07
Rc3749	vssa#589	vssa#590	0.671308	$metal3
+ $W=3e-07
Rc3750	vssa#590	vssa#591	0.213850	$metal3
+ $W=6e-07
Rc3751	vssa#591	vssa#592	0.192692	$metal3
+ $W=6e-07
Rc3752	vssa#592	vssa#593	0.672483	$metal3
+ $W=3e-07
Rc3753	vssa#592	vssa#594	0.337791	$metal3
+ $W=3e-07
Rc3754	vssa#594	vssa#595	0.315692	$metal3
+ $W=3e-07
Rc3755	vssa#593	vssa#372	0.182125	$metal3
+ $W=6e-07
Rc3756	vssa#593	vssa#369	0.337203	$metal3
+ $W=3e-07
Rc3757	vssa#594	vssa#596	0.556646	$metal3
+ $W=6e-07
Rc3758	vssa#596	vssa#597	0.556646	$metal3
+ $W=6e-07
Rc3759	vssa#597	vssa#598	0.025931	$metal3
+ $W=4.2e-06
Rc3760	vssa#595	vssa#369	0.349420	$metal3
+ $W=3e-07
Rc3761	vssa#597	vssa#599	0.665112	$metal3
+ $W=3e-07
Rc3762	vssa#599	vssa#600	0.556646	$metal3
+ $W=6e-07
Rc3763	vssa#600	vssa#601	0.556646	$metal3
+ $W=6e-07
Rc3764	vssa#601	vssa#602	0.025931	$metal3
+ $W=4.2e-06
Rc3765	vssa#597	vssa#590	0.337791	$metal3
+ $W=3e-07
Rc3766	vssa#598	vssa#594	0.025931	$metal3
+ $W=4.2e-06
Rc3767	vssa#598	vssa#596	0.025931	$metal3
+ $W=4.2e-06
Rc3768	vssa#598	vssa#591	0.025931	$metal3
+ $W=4.2e-06
Rc3769	vssa#599	vssa#589	0.337791	$metal3
+ $W=3e-07
Rc3770	vssa#601	vssa#603	0.665112	$metal3
+ $W=3e-07
Rc3771	vssa#603	vssa#604	0.556646	$metal3
+ $W=6e-07
Rc3772	vssa#604	vssa#605	0.556646	$metal3
+ $W=6e-07
Rc3773	vssa#605	vssa#606	0.025931	$metal3
+ $W=4.2e-06
Rc3774	vssa#601	vssa#587	0.337791	$metal3
+ $W=3e-07
Rc3775	vssa#602	vssa#599	0.025931	$metal3
+ $W=4.2e-06
Rc3776	vssa#602	vssa#600	0.025931	$metal3
+ $W=4.2e-06
Rc3777	vssa#602	vssa#588	0.025931	$metal3
+ $W=4.2e-06
Rc3778	vssa#603	vssa#586	0.337791	$metal3
+ $W=3e-07
Rc3779	vssa#605	vssa#607	0.665112	$metal3
+ $W=3e-07
Rc3780	vssa#607	vssa#608	0.556646	$metal3
+ $W=6e-07
Rc3781	vssa#608	vssa#609	0.556646	$metal3
+ $W=6e-07
Rc3782	vssa#609	vssa#610	0.025931	$metal3
+ $W=4.2e-06
Rc3783	vssa#605	vssa#584	0.337791	$metal3
+ $W=3e-07
Rc3784	vssa#606	vssa#603	0.025931	$metal3
+ $W=4.2e-06
Rc3785	vssa#606	vssa#604	0.025931	$metal3
+ $W=4.2e-06
Rc3786	vssa#606	vssa#585	0.025931	$metal3
+ $W=4.2e-06
Rc3787	vssa#607	vssa#583	0.337791	$metal3
+ $W=3e-07
Rc3788	vssa#609	vssa#611	0.665112	$metal3
+ $W=3e-07
Rc3789	vssa#611	vssa#612	0.556646	$metal3
+ $W=6e-07
Rc3790	vssa#612	vssa#613	0.556646	$metal3
+ $W=6e-07
Rc3791	vssa#613	vssa#614	0.025931	$metal3
+ $W=4.2e-06
Rc3792	vssa#609	vssa#581	0.337791	$metal3
+ $W=3e-07
Rc3793	vssa#610	vssa#607	0.025931	$metal3
+ $W=4.2e-06
Rc3794	vssa#610	vssa#608	0.025931	$metal3
+ $W=4.2e-06
Rc3795	vssa#610	vssa#582	0.025931	$metal3
+ $W=4.2e-06
Rc3796	vssa#611	vssa#580	0.337791	$metal3
+ $W=3e-07
Rc3797	vssa#613	vssa#615	0.665112	$metal3
+ $W=3e-07
Rc3798	vssa#615	vssa#616	0.556646	$metal3
+ $W=6e-07
Rc3799	vssa#616	vssa#617	0.556646	$metal3
+ $W=6e-07
Rc3800	vssa#617	vssa#618	0.025931	$metal3
+ $W=4.2e-06
Rc3801	vssa#613	vssa#578	0.337791	$metal3
+ $W=3e-07
Rc3802	vssa#614	vssa#611	0.025931	$metal3
+ $W=4.2e-06
Rc3803	vssa#614	vssa#612	0.025931	$metal3
+ $W=4.2e-06
Rc3804	vssa#614	vssa#579	0.025931	$metal3
+ $W=4.2e-06
Rc3805	vssa#615	vssa#577	0.337791	$metal3
+ $W=3e-07
Rc3806	vssa#617	vssa#619	0.665112	$metal3
+ $W=3e-07
Rc3807	vssa#619	vssa#620	0.556646	$metal3
+ $W=6e-07
Rc3808	vssa#620	vssa#621	0.556646	$metal3
+ $W=6e-07
Rc3809	vssa#621	vssa#622	0.025931	$metal3
+ $W=4.2e-06
Rc3810	vssa#617	vssa#575	0.337791	$metal3
+ $W=3e-07
Rc3811	vssa#618	vssa#615	0.025931	$metal3
+ $W=4.2e-06
Rc3812	vssa#618	vssa#616	0.025931	$metal3
+ $W=4.2e-06
Rc3813	vssa#618	vssa#576	0.025931	$metal3
+ $W=4.2e-06
Rc3814	vssa#619	vssa#574	0.337791	$metal3
+ $W=3e-07
Rc3815	vssa#621	vssa#623	0.665112	$metal3
+ $W=3e-07
Rc3816	vssa#623	vssa#624	0.556646	$metal3
+ $W=6e-07
Rc3817	vssa#624	vssa#625	0.556646	$metal3
+ $W=6e-07
Rc3818	vssa#625	vssa#626	0.025931	$metal3
+ $W=4.2e-06
Rc3819	vssa#621	vssa#572	0.337791	$metal3
+ $W=3e-07
Rc3820	vssa#622	vssa#619	0.025931	$metal3
+ $W=4.2e-06
Rc3821	vssa#622	vssa#620	0.025931	$metal3
+ $W=4.2e-06
Rc3822	vssa#622	vssa#573	0.025931	$metal3
+ $W=4.2e-06
Rc3823	vssa#623	vssa#571	0.337791	$metal3
+ $W=3e-07
Rc3824	vssa#625	vssa#627	0.665112	$metal3
+ $W=3e-07
Rc3825	vssa#627	vssa#628	0.556646	$metal3
+ $W=6e-07
Rc3826	vssa#628	vssa#629	0.556646	$metal3
+ $W=6e-07
Rc3827	vssa#629	vssa#630	0.025931	$metal3
+ $W=4.2e-06
Rc3828	vssa#625	vssa#569	0.337791	$metal3
+ $W=3e-07
Rc3829	vssa#626	vssa#623	0.025931	$metal3
+ $W=4.2e-06
Rc3830	vssa#626	vssa#624	0.025931	$metal3
+ $W=4.2e-06
Rc3831	vssa#626	vssa#570	0.025931	$metal3
+ $W=4.2e-06
Rc3832	vssa#627	vssa#568	0.337791	$metal3
+ $W=3e-07
Rc3833	vssa#629	vssa#631	0.665112	$metal3
+ $W=3e-07
Rc3834	vssa#631	vssa#632	0.556646	$metal3
+ $W=6e-07
Rc3835	vssa#632	vssa#633	0.556646	$metal3
+ $W=6e-07
Rc3836	vssa#633	vssa#634	0.025931	$metal3
+ $W=4.2e-06
Rc3837	vssa#629	vssa#566	0.337791	$metal3
+ $W=3e-07
Rc3838	vssa#630	vssa#627	0.025931	$metal3
+ $W=4.2e-06
Rc3839	vssa#630	vssa#628	0.025931	$metal3
+ $W=4.2e-06
Rc3840	vssa#630	vssa#567	0.025931	$metal3
+ $W=4.2e-06
Rc3841	vssa#631	vssa#565	0.337791	$metal3
+ $W=3e-07
Rc3842	vssa#633	vssa#635	0.665112	$metal3
+ $W=3e-07
Rc3843	vssa#635	vssa#636	0.556646	$metal3
+ $W=6e-07
Rc3844	vssa#636	vssa#637	0.556646	$metal3
+ $W=6e-07
Rc3845	vssa#637	vssa#638	0.025931	$metal3
+ $W=4.2e-06
Rc3846	vssa#633	vssa#563	0.337791	$metal3
+ $W=3e-07
Rc3847	vssa#634	vssa#631	0.025931	$metal3
+ $W=4.2e-06
Rc3848	vssa#634	vssa#632	0.025931	$metal3
+ $W=4.2e-06
Rc3849	vssa#634	vssa#564	0.025931	$metal3
+ $W=4.2e-06
Rc3850	vssa#635	vssa#562	0.337791	$metal3
+ $W=3e-07
Rc3851	vssa#637	vssa#639	0.665112	$metal3
+ $W=3e-07
Rc3852	vssa#639	vssa#640	0.556646	$metal3
+ $W=6e-07
Rc3853	vssa#640	vssa#641	0.556646	$metal3
+ $W=6e-07
Rc3854	vssa#641	vssa#642	0.025931	$metal3
+ $W=4.2e-06
Rc3855	vssa#637	vssa#560	0.337791	$metal3
+ $W=3e-07
Rc3856	vssa#638	vssa#635	0.025931	$metal3
+ $W=4.2e-06
Rc3857	vssa#638	vssa#636	0.025931	$metal3
+ $W=4.2e-06
Rc3858	vssa#638	vssa#561	0.025931	$metal3
+ $W=4.2e-06
Rc3859	vssa#639	vssa#559	0.337791	$metal3
+ $W=3e-07
Rc3860	vssa#641	vssa#643	0.665112	$metal3
+ $W=3e-07
Rc3861	vssa#643	vssa#644	0.556646	$metal3
+ $W=6e-07
Rc3862	vssa#644	vssa#645	0.556646	$metal3
+ $W=6e-07
Rc3863	vssa#645	vssa#646	0.025931	$metal3
+ $W=4.2e-06
Rc3864	vssa#641	vssa#557	0.337791	$metal3
+ $W=3e-07
Rc3865	vssa#642	vssa#639	0.025931	$metal3
+ $W=4.2e-06
Rc3866	vssa#642	vssa#640	0.025931	$metal3
+ $W=4.2e-06
Rc3867	vssa#642	vssa#558	0.025931	$metal3
+ $W=4.2e-06
Rc3868	vssa#643	vssa#556	0.337791	$metal3
+ $W=3e-07
Rc3869	vssa#645	vssa#647	0.665112	$metal3
+ $W=3e-07
Rc3870	vssa#647	vssa#648	0.556646	$metal3
+ $W=6e-07
Rc3871	vssa#648	vssa#649	0.556646	$metal3
+ $W=6e-07
Rc3872	vssa#649	vssa#650	0.025931	$metal3
+ $W=4.2e-06
Rc3873	vssa#645	vssa#554	0.337791	$metal3
+ $W=3e-07
Rc3874	vssa#646	vssa#643	0.025931	$metal3
+ $W=4.2e-06
Rc3875	vssa#646	vssa#644	0.025931	$metal3
+ $W=4.2e-06
Rc3876	vssa#646	vssa#555	0.025931	$metal3
+ $W=4.2e-06
Rc3877	vssa#647	vssa#553	0.337791	$metal3
+ $W=3e-07
Rc3878	vssa#649	vssa#651	0.665112	$metal3
+ $W=3e-07
Rc3879	vssa#651	vssa#652	0.556646	$metal3
+ $W=6e-07
Rc3880	vssa#652	vssa#653	0.556646	$metal3
+ $W=6e-07
Rc3881	vssa#653	vssa#654	0.025931	$metal3
+ $W=4.2e-06
Rc3882	vssa#649	vssa#551	0.337791	$metal3
+ $W=3e-07
Rc3883	vssa#650	vssa#647	0.025931	$metal3
+ $W=4.2e-06
Rc3884	vssa#650	vssa#648	0.025931	$metal3
+ $W=4.2e-06
Rc3885	vssa#650	vssa#552	0.025931	$metal3
+ $W=4.2e-06
Rc3886	vssa#651	vssa#550	0.337791	$metal3
+ $W=3e-07
Rc3887	vssa#653	vssa#655	0.346670	$metal3
+ $W=3e-07
Rc3888	vssa#653	vssa#548	0.337791	$metal3
+ $W=3e-07
Rc3889	vssa#654	vssa#651	0.025931	$metal3
+ $W=4.2e-06
Rc3890	vssa#654	vssa#652	0.025931	$metal3
+ $W=4.2e-06
Rc3891	vssa#654	vssa#549	0.025931	$metal3
+ $W=4.2e-06
Rc3892	vssa#655	vssa#656	0.308242	$metal3
+ $W=3e-07
Rc3893	vssa#656	vssa#657	0.556646	$metal3
+ $W=6e-07
Rc3894	vssa#657	vssa#658	0.556646	$metal3
+ $W=6e-07
Rc3895	vssa#658	vssa#659	0.025931	$metal3
+ $W=4.2e-06
Rc3896	vssa#656	vssa#546	0.345935	$metal3
+ $W=3e-07
Rc3897	vssa#659	vssa#656	0.025931	$metal3
+ $W=4.2e-06
Rc3898	vssa#659	vssa#657	0.025931	$metal3
+ $W=4.2e-06
Rc3899	vssa#659	vssa#660	0.025931	$metal3
+ $W=4.2e-06
Rc3900	vssa#660	vssa#546	0.345935	$metal3
+ $W=3e-07
Rc3901	vssa#660	vssa#661	0.337203	$metal3
+ $W=3e-07
Rc3902	vssa#660	vssa#662	0.337341	$metal3
+ $W=3e-07
Rc3903	vssa#661	vssa#658	0.215025	$metal3
+ $W=6e-07
Rc3904	vssa#662	vssa#663	0.351441	$metal3
+ $W=3e-07
Rc3905	vssa#663	vssa#544	0.337203	$metal3
+ $W=3e-07
Rc3906	vssa#663	vssa#664	0.556646	$metal3
+ $W=6e-07
Rc3907	vssa#664	vssa#665	0.025931	$metal3
+ $W=4.2e-06
Rc3908	vssa#665	vssa#543	0.025931	$metal3
+ $W=4.2e-06
Rc3909	vssa#665	vssa#663	0.025931	$metal3
+ $W=4.2e-06
Rc3910	vssa#665	vssa#666	0.025931	$metal3
+ $W=4.2e-06
Rc3911	vssa#666	vssa#542	0.337203	$metal3
+ $W=3e-07
Rc3912	vssa#666	vssa#667	0.337203	$metal3
+ $W=3e-07
Rc3913	vssa#666	vssa#668	0.698840	$metal3
+ $W=3e-07
Rc3914	vssa#667	vssa#664	0.215025	$metal3
+ $W=6e-07
Rc3915	vssa#668	vssa#541	0.337203	$metal3
+ $W=3e-07
Rc3916	vssa#668	vssa#669	0.556646	$metal3
+ $W=6e-07
Rc3917	vssa#669	vssa#670	0.025931	$metal3
+ $W=4.2e-06
Rc3918	vssa#670	vssa#540	0.025931	$metal3
+ $W=4.2e-06
Rc3919	vssa#670	vssa#668	0.025931	$metal3
+ $W=4.2e-06
Rc3920	vssa#670	vssa#671	0.025931	$metal3
+ $W=4.2e-06
Rc3921	vssa#671	vssa#539	0.337203	$metal3
+ $W=3e-07
Rc3922	vssa#671	vssa#672	0.337203	$metal3
+ $W=3e-07
Rc3923	vssa#671	vssa#673	0.698840	$metal3
+ $W=3e-07
Rc3924	vssa#672	vssa#669	0.215025	$metal3
+ $W=6e-07
Rc3925	vssa#673	vssa#538	0.337203	$metal3
+ $W=3e-07
Rc3926	vssa#673	vssa#674	0.556646	$metal3
+ $W=6e-07
Rc3927	vssa#674	vssa#675	0.025931	$metal3
+ $W=4.2e-06
Rc3928	vssa#675	vssa#537	0.025931	$metal3
+ $W=4.2e-06
Rc3929	vssa#675	vssa#673	0.025931	$metal3
+ $W=4.2e-06
Rc3930	vssa#675	vssa#676	0.025931	$metal3
+ $W=4.2e-06
Rc3931	vssa#676	vssa#536	0.337203	$metal3
+ $W=3e-07
Rc3932	vssa#676	vssa#677	0.337203	$metal3
+ $W=3e-07
Rc3933	vssa#676	vssa#678	0.698840	$metal3
+ $W=3e-07
Rc3934	vssa#677	vssa#674	0.215025	$metal3
+ $W=6e-07
Rc3935	vssa#678	vssa#535	0.337203	$metal3
+ $W=3e-07
Rc3936	vssa#678	vssa#679	0.556646	$metal3
+ $W=6e-07
Rc3937	vssa#679	vssa#680	0.025931	$metal3
+ $W=4.2e-06
Rc3938	vssa#680	vssa#534	0.025931	$metal3
+ $W=4.2e-06
Rc3939	vssa#680	vssa#678	0.025931	$metal3
+ $W=4.2e-06
Rc3940	vssa#680	vssa#681	0.025931	$metal3
+ $W=4.2e-06
Rc3941	vssa#681	vssa#533	0.337203	$metal3
+ $W=3e-07
Rc3942	vssa#681	vssa#682	0.337203	$metal3
+ $W=3e-07
Rc3943	vssa#681	vssa#683	0.698840	$metal3
+ $W=3e-07
Rc3944	vssa#682	vssa#679	0.215025	$metal3
+ $W=6e-07
Rc3945	vssa#683	vssa#532	0.337203	$metal3
+ $W=3e-07
Rc3946	vssa#683	vssa#684	0.556646	$metal3
+ $W=6e-07
Rc3947	vssa#684	vssa#685	0.025931	$metal3
+ $W=4.2e-06
Rc3948	vssa#685	vssa#531	0.025931	$metal3
+ $W=4.2e-06
Rc3949	vssa#685	vssa#683	0.025931	$metal3
+ $W=4.2e-06
Rc3950	vssa#685	vssa#686	0.025931	$metal3
+ $W=4.2e-06
Rc3951	vssa#686	vssa#530	0.337203	$metal3
+ $W=3e-07
Rc3952	vssa#686	vssa#687	0.337203	$metal3
+ $W=3e-07
Rc3953	vssa#686	vssa#688	0.698840	$metal3
+ $W=3e-07
Rc3954	vssa#687	vssa#684	0.215025	$metal3
+ $W=6e-07
Rc3955	vssa#688	vssa#529	0.337203	$metal3
+ $W=3e-07
Rc3956	vssa#688	vssa#689	0.556646	$metal3
+ $W=6e-07
Rc3957	vssa#689	vssa#690	0.025931	$metal3
+ $W=4.2e-06
Rc3958	vssa#690	vssa#528	0.025931	$metal3
+ $W=4.2e-06
Rc3959	vssa#690	vssa#688	0.025931	$metal3
+ $W=4.2e-06
Rc3960	vssa#690	vssa#691	0.025931	$metal3
+ $W=4.2e-06
Rc3961	vssa#691	vssa#527	0.337203	$metal3
+ $W=3e-07
Rc3962	vssa#691	vssa#692	0.337203	$metal3
+ $W=3e-07
Rc3963	vssa#691	vssa#693	0.698840	$metal3
+ $W=3e-07
Rc3964	vssa#692	vssa#689	0.215025	$metal3
+ $W=6e-07
Rc3965	vssa#693	vssa#526	0.337203	$metal3
+ $W=3e-07
Rc3966	vssa#693	vssa#694	0.556646	$metal3
+ $W=6e-07
Rc3967	vssa#694	vssa#695	0.025931	$metal3
+ $W=4.2e-06
Rc3968	vssa#695	vssa#525	0.025931	$metal3
+ $W=4.2e-06
Rc3969	vssa#695	vssa#693	0.025931	$metal3
+ $W=4.2e-06
Rc3970	vssa#695	vssa#696	0.025931	$metal3
+ $W=4.2e-06
Rc3971	vssa#696	vssa#524	0.337203	$metal3
+ $W=3e-07
Rc3972	vssa#696	vssa#697	0.337203	$metal3
+ $W=3e-07
Rc3973	vssa#696	vssa#698	0.698840	$metal3
+ $W=3e-07
Rc3974	vssa#697	vssa#694	0.215025	$metal3
+ $W=6e-07
Rc3975	vssa#698	vssa#523	0.337203	$metal3
+ $W=3e-07
Rc3976	vssa#698	vssa#699	0.556646	$metal3
+ $W=6e-07
Rc3977	vssa#699	vssa#700	0.025931	$metal3
+ $W=4.2e-06
Rc3978	vssa#700	vssa#522	0.025931	$metal3
+ $W=4.2e-06
Rc3979	vssa#700	vssa#698	0.025931	$metal3
+ $W=4.2e-06
Rc3980	vssa#700	vssa#701	0.025931	$metal3
+ $W=4.2e-06
Rc3981	vssa#701	vssa#521	0.337203	$metal3
+ $W=3e-07
Rc3982	vssa#701	vssa#702	0.337203	$metal3
+ $W=3e-07
Rc3983	vssa#701	vssa#703	0.698840	$metal3
+ $W=3e-07
Rc3984	vssa#702	vssa#699	0.215025	$metal3
+ $W=6e-07
Rc3985	vssa#703	vssa#520	0.337203	$metal3
+ $W=3e-07
Rc3986	vssa#703	vssa#704	0.556646	$metal3
+ $W=6e-07
Rc3987	vssa#704	vssa#705	0.025931	$metal3
+ $W=4.2e-06
Rc3988	vssa#705	vssa#519	0.025931	$metal3
+ $W=4.2e-06
Rc3989	vssa#705	vssa#703	0.025931	$metal3
+ $W=4.2e-06
Rc3990	vssa#705	vssa#706	0.025931	$metal3
+ $W=4.2e-06
Rc3991	vssa#706	vssa#518	0.337203	$metal3
+ $W=3e-07
Rc3992	vssa#706	vssa#707	0.337203	$metal3
+ $W=3e-07
Rc3993	vssa#706	vssa#708	0.698840	$metal3
+ $W=3e-07
Rc3994	vssa#707	vssa#704	0.215025	$metal3
+ $W=6e-07
Rc3995	vssa#708	vssa#517	0.337203	$metal3
+ $W=3e-07
Rc3996	vssa#708	vssa#709	0.556646	$metal3
+ $W=6e-07
Rc3997	vssa#709	vssa#710	0.025931	$metal3
+ $W=4.2e-06
Rc3998	vssa#710	vssa#516	0.025931	$metal3
+ $W=4.2e-06
Rc3999	vssa#710	vssa#708	0.025931	$metal3
+ $W=4.2e-06
Rc4000	vssa#710	vssa#711	0.025931	$metal3
+ $W=4.2e-06
Rc4001	vssa#711	vssa#515	0.337203	$metal3
+ $W=3e-07
Rc4002	vssa#711	vssa#712	0.337203	$metal3
+ $W=3e-07
Rc4003	vssa#711	vssa#713	0.698840	$metal3
+ $W=3e-07
Rc4004	vssa#712	vssa#709	0.215025	$metal3
+ $W=6e-07
Rc4005	vssa#713	vssa#514	0.337203	$metal3
+ $W=3e-07
Rc4006	vssa#713	vssa#714	0.556646	$metal3
+ $W=6e-07
Rc4007	vssa#714	vssa#715	0.025931	$metal3
+ $W=4.2e-06
Rc4008	vssa#715	vssa#513	0.025931	$metal3
+ $W=4.2e-06
Rc4009	vssa#715	vssa#713	0.025931	$metal3
+ $W=4.2e-06
Rc4010	vssa#715	vssa#716	0.025931	$metal3
+ $W=4.2e-06
Rc4011	vssa#716	vssa#512	0.337203	$metal3
+ $W=3e-07
Rc4012	vssa#716	vssa#717	0.337203	$metal3
+ $W=3e-07
Rc4013	vssa#716	vssa#718	0.698840	$metal3
+ $W=3e-07
Rc4014	vssa#717	vssa#714	0.215025	$metal3
+ $W=6e-07
Rc4015	vssa#718	vssa#511	0.337203	$metal3
+ $W=3e-07
Rc4016	vssa#718	vssa#719	0.556646	$metal3
+ $W=6e-07
Rc4017	vssa#719	vssa#720	0.025931	$metal3
+ $W=4.2e-06
Rc4018	vssa#720	vssa#510	0.025931	$metal3
+ $W=4.2e-06
Rc4019	vssa#720	vssa#718	0.025931	$metal3
+ $W=4.2e-06
Rc4020	vssa#720	vssa#721	0.025931	$metal3
+ $W=4.2e-06
Rc4021	vssa#721	vssa#509	0.337203	$metal3
+ $W=3e-07
Rc4022	vssa#721	vssa#722	0.337203	$metal3
+ $W=3e-07
Rc4023	vssa#721	vssa#723	0.698840	$metal3
+ $W=3e-07
Rc4024	vssa#722	vssa#719	0.215025	$metal3
+ $W=6e-07
Rc4025	vssa#723	vssa#508	0.337203	$metal3
+ $W=3e-07
Rc4026	vssa#723	vssa#724	0.556646	$metal3
+ $W=6e-07
Rc4027	vssa#724	vssa#725	0.025931	$metal3
+ $W=4.2e-06
Rc4028	vssa#725	vssa#507	0.025931	$metal3
+ $W=4.2e-06
Rc4029	vssa#725	vssa#723	0.025931	$metal3
+ $W=4.2e-06
Rc4030	vssa#725	vssa#726	0.025931	$metal3
+ $W=4.2e-06
Rc4031	vssa#726	vssa#506	0.337203	$metal3
+ $W=3e-07
Rc4032	vssa#726	vssa#727	0.337203	$metal3
+ $W=3e-07
Rc4033	vssa#726	vssa#728	0.698840	$metal3
+ $W=3e-07
Rc4034	vssa#727	vssa#724	0.215025	$metal3
+ $W=6e-07
Rc4035	vssa#728	vssa#505	0.337203	$metal3
+ $W=3e-07
Rc4036	vssa#728	vssa#729	0.556646	$metal3
+ $W=6e-07
Rc4037	vssa#729	vssa#730	0.025931	$metal3
+ $W=4.2e-06
Rc4038	vssa#730	vssa#504	0.025931	$metal3
+ $W=4.2e-06
Rc4039	vssa#730	vssa#728	0.025931	$metal3
+ $W=4.2e-06
Rc4040	vssa#730	vssa#731	0.025931	$metal3
+ $W=4.2e-06
Rc4041	vssa#731	vssa#503	0.337203	$metal3
+ $W=3e-07
Rc4042	vssa#731	vssa#732	0.337203	$metal3
+ $W=3e-07
Rc4043	vssa#731	vssa#733	0.698840	$metal3
+ $W=3e-07
Rc4044	vssa#732	vssa#729	0.215025	$metal3
+ $W=6e-07
Rc4045	vssa#733	vssa#502	0.337203	$metal3
+ $W=3e-07
Rc4046	vssa#733	vssa#734	0.556646	$metal3
+ $W=6e-07
Rc4047	vssa#734	vssa#735	0.025931	$metal3
+ $W=4.2e-06
Rc4048	vssa#735	vssa#501	0.025931	$metal3
+ $W=4.2e-06
Rc4049	vssa#735	vssa#733	0.025931	$metal3
+ $W=4.2e-06
Rc4050	vssa#735	vssa#736	0.025931	$metal3
+ $W=4.2e-06
Rc4051	vssa#736	vssa#500	0.337203	$metal3
+ $W=3e-07
Rc4052	vssa#736	vssa#737	0.337203	$metal3
+ $W=3e-07
Rc4053	vssa#736	vssa#738	0.698840	$metal3
+ $W=3e-07
Rc4054	vssa#737	vssa#734	0.215025	$metal3
+ $W=6e-07
Rc4055	vssa#738	vssa#499	0.337203	$metal3
+ $W=3e-07
Rc4056	vssa#738	vssa#739	0.556646	$metal3
+ $W=6e-07
Rc4057	vssa#739	vssa#740	0.025931	$metal3
+ $W=4.2e-06
Rc4058	vssa#740	vssa#498	0.025931	$metal3
+ $W=4.2e-06
Rc4059	vssa#740	vssa#738	0.025931	$metal3
+ $W=4.2e-06
Rc4060	vssa#740	vssa#741	0.025931	$metal3
+ $W=4.2e-06
Rc4061	vssa#741	vssa#497	0.337203	$metal3
+ $W=3e-07
Rc4062	vssa#741	vssa#742	0.337203	$metal3
+ $W=3e-07
Rc4063	vssa#741	vssa#743	0.348664	$metal3
+ $W=3e-07
Rc4064	vssa#742	vssa#739	0.215025	$metal3
+ $W=6e-07
Rc4065	vssa#743	vssa#744	0.339406	$metal3
+ $W=3e-07
Rc4066	vssa#744	vssa#495	0.345935	$metal3
+ $W=3e-07
Rc4067	vssa#744	vssa#745	0.556646	$metal3
+ $W=6e-07
Rc4068	vssa#745	vssa#746	0.025931	$metal3
+ $W=4.2e-06
Rc4069	vssa#746	vssa#747	0.025931	$metal3
+ $W=4.2e-06
Rc4070	vssa#747	vssa#748	0.116725	$metal3
+ $W=3e-07
Rc4071	vssa#746	vssa#744	0.025931	$metal3
+ $W=4.2e-06
Rc4072	vssa#747	vssa#495	0.345935	$metal3
+ $W=3e-07
Rc4073	vssa#747	vssa#749	0.556646	$metal3
+ $W=6e-07
Rc4074	vssa#748	vssa#225	0.176562	$metal3
+ $W=3e-07
Rc4075	vssa#749	vssa#746	0.025931	$metal3
+ $W=4.2e-06
Rc4076	vssa#749	vssa#750	0.337203	$metal3
+ $W=3e-07
Rc4077	vssa#750	vssa#745	0.215025	$metal3
+ $W=6e-07
Rc4123	vssa#209	vssa#743	1.705000	$metal3
+ $W=8e-08
Rc4109	vssa#197	vssa#274	1.705000	$metal3
+ $W=8e-08
Rc4110	vssa#201	vssa#279	1.705000	$metal3
+ $W=8e-08
Rc4111	vssa#164	vssa#328	1.705000	$metal3
+ $W=8e-08
Rc4112	vssa#160	vssa#350	1.705000	$metal3
+ $W=8e-08
Rc4113	vssa#160	vssa#374	1.705000	$metal3
+ $W=8e-08
Rc4114	vssa#163	vssa#377	1.705000	$metal3
+ $W=8e-08
Rc4115	vssa#200	vssa#443	1.705000	$metal3
+ $W=8e-08
Rc4116	vssa#197	vssa#445	1.705000	$metal3
+ $W=8e-08
Rc4093	vbottom<2>	vbottom<2>#34	3.410000	$metal3
+ $W=4e-08
Rc4117	vssa#205	vssa#494	1.705000	$metal3
+ $W=8e-08
Rc4118	vssa#208	vssa#496	1.705000	$metal3
+ $W=8e-08
Rc4119	vssa#149	vssa#545	1.705000	$metal3
+ $W=8e-08
Rc4120	vssa#148	vssa#547	1.705000	$metal3
+ $W=8e-08
Rc4108	vssa#205	vssa#225	1.705000	$metal3
+ $W=8e-08
Rc4121	vssa#147	vssa#655	1.705000	$metal3
+ $W=8e-08
Rc4122	vssa#149	vssa#662	1.705000	$metal3
+ $W=8e-08
Rb1	XI10/vbsh#31	XI10/vbsh#29	0.226664	$metal4
+ $W=9.45e-07
Rb2	XI10/vbsh#29	XI10/vbsh#33	0.093655	$metal4
+ $W=1.2e-06
Rb3	XI10/vbsh#33	XI10/vbsh#34	0.240733	$metal4
+ $W=1.2e-06
Rb4	XI10/vbsh#34	XI10/vbsh#35	0.252358	$metal4
+ $W=1.2e-06
Rb5	XI10/vbsh#33	XI10/vbsh#36	0.049494	$metal4
+ $W=1.115e-06
Rb6	XI10/vbsh#34	XI10/vbsh#37	0.128251	$metal4
+ $W=1.225e-06
Rb7	vout#15	vout#16	0.799000	$metal4
+ $W=3e-07
Rb8	vout#16	vout#17	1.378667	$metal4
+ $W=3e-07
Rb9	vout#17	vout#18	0.799000	$metal4
+ $W=3e-07
Rb10	vout#18	vout#19	1.378667	$metal4
+ $W=3e-07
Rb11	vout#19	vout#20	0.799000	$metal4
+ $W=3e-07
Rb12	vout#17	vout#21	0.799000	$metal4
+ $W=3e-07
Rb13	vout#20	vout#22	1.378667	$metal4
+ $W=3e-07
Rb14	vout#22	vout#23	0.799000	$metal4
+ $W=3e-07
Rb15	vout#19	vout#24	0.799000	$metal4
+ $W=3e-07
Rb16	vout#23	vout#25	1.378667	$metal4
+ $W=3e-07
Rb17	vout#25	vout#26	0.799000	$metal4
+ $W=3e-07
Rb18	vout#22	vout#27	0.799000	$metal4
+ $W=3e-07
Rb19	vout#26	vout#28	1.378667	$metal4
+ $W=3e-07
Rb20	vout#24	vout#29	0.799000	$metal4
+ $W=3e-07
Rb21	vout#28	vout#30	0.799000	$metal4
+ $W=3e-07
Rb22	vout#25	vout#31	0.799000	$metal4
+ $W=3e-07
Rb23	vout#30	vout#32	1.378667	$metal4
+ $W=3e-07
Rb24	vout#27	vout#33	0.799000	$metal4
+ $W=3e-07
Rb25	vout#32	vout#34	0.799000	$metal4
+ $W=3e-07
Rb26	vout#28	vout#35	0.799000	$metal4
+ $W=3e-07
Rb27	vout#34	vout#36	1.378667	$metal4
+ $W=3e-07
Rb28	vout#31	vout#37	0.799000	$metal4
+ $W=3e-07
Rb29	vout#36	vout#38	0.374057	$metal4
+ $W=3e-07
Rb30	vout#38	vout#39	1.838541	$metal4
+ $W=3e-07
Rb31	vout#39	vout#40	0.416579	$metal4
+ $W=3e-07
Rb32	vout#32	vout#41	0.799000	$metal4
+ $W=3e-07
Rb33	vout#33	vout#42	0.799000	$metal4
+ $W=3e-07
Rb34	vout#38	vout#43	1.365537	$metal4
+ $W=3e-07
Rb35	vout#43	vout#44	0.411813	$metal4
+ $W=3e-07
Rb36	vout#39	vout#45	0.378823	$metal4
+ $W=3e-07
Rb37	vout#35	vout#46	0.799000	$metal4
+ $W=3e-07
Rb38	vout#43	vout#47	1.365537	$metal4
+ $W=3e-07
Rb39	vout#47	vout#48	0.411813	$metal4
+ $W=3e-07
Rb40	vout#43	vout#34	0.374057	$metal4
+ $W=3e-07
Rb41	vout#40	vout#49	0.799000	$metal4
+ $W=3e-07
Rb42	vout#36	vout#50	0.799000	$metal4
+ $W=3e-07
Rb43	vout#37	vout#51	0.799000	$metal4
+ $W=3e-07
Rb44	vout#47	vout#52	1.365537	$metal4
+ $W=3e-07
Rb45	vout#52	vout#53	0.411813	$metal4
+ $W=3e-07
Rb46	vout#47	vout#54	0.374057	$metal4
+ $W=3e-07
Rb47	vout#44	vout#55	0.799000	$metal4
+ $W=3e-07
Rb48	vout#49	vout#56	1.378667	$metal4
+ $W=3e-07
Rb49	vout#40	vout#57	1.378667	$metal4
+ $W=3e-07
Rb50	vout#41	vout#58	0.799000	$metal4
+ $W=3e-07
Rb51	vout#52	vout#59	1.365537	$metal4
+ $W=3e-07
Rb52	vout#59	vout#60	0.411813	$metal4
+ $W=3e-07
Rb53	vout#52	vout#61	0.374057	$metal4
+ $W=3e-07
Rb54	vout#48	vout#62	0.799000	$metal4
+ $W=3e-07
Rb55	vout#45	vout#63	0.799000	$metal4
+ $W=3e-07
Rb56	vout#49	vout#64	0.799000	$metal4
+ $W=3e-07
Rb57	vout#56	vout#65	0.799000	$metal4
+ $W=3e-07
Rb58	vout#57	vout#66	0.799000	$metal4
+ $W=3e-07
Rb59	vout#46	vout#67	0.799000	$metal4
+ $W=3e-07
Rb60	vout#59	vout#68	1.365537	$metal4
+ $W=3e-07
Rb61	vout#68	vout#69	0.411813	$metal4
+ $W=3e-07
Rb62	vout#59	vout#70	0.374057	$metal4
+ $W=3e-07
Rb63	vout#53	vout#71	0.799000	$metal4
+ $W=3e-07
Rb64	vout#55	vout#72	0.799000	$metal4
+ $W=3e-07
Rb65	vout#65	vout#73	1.378667	$metal4
+ $W=3e-07
Rb66	vout#56	vout#74	0.799000	$metal4
+ $W=3e-07
Rb67	vout#50	vout#75	0.799000	$metal4
+ $W=3e-07
Rb68	vout#51	vout#76	0.799000	$metal4
+ $W=3e-07
Rb69	vout#68	vout#77	1.365537	$metal4
+ $W=3e-07
Rb70	vout#77	vout#78	0.411813	$metal4
+ $W=3e-07
Rb71	vout#68	vout#79	0.374057	$metal4
+ $W=3e-07
Rb72	vout#60	vout#80	0.799000	$metal4
+ $W=3e-07
Rb73	vout#54	vout#30	0.799000	$metal4
+ $W=3e-07
Rb74	vout#62	vout#81	0.799000	$metal4
+ $W=3e-07
Rb75	vout#64	vout#82	0.799000	$metal4
+ $W=3e-07
Rb76	vout#65	vout#83	0.799000	$metal4
+ $W=3e-07
Rb77	vout#73	vout#84	0.799000	$metal4
+ $W=3e-07
Rb78	vout#57	vout#85	0.209150	$metal4
+ $W=3e-07
Rb79	vout#66	vout#86	0.799000	$metal4
+ $W=3e-07
Rb80	vout#58	vout#87	0.799000	$metal4
+ $W=3e-07
Rb81	vout#77	vout#88	1.365537	$metal4
+ $W=3e-07
Rb82	vout#88	vout#89	0.411813	$metal4
+ $W=3e-07
Rb83	vout#77	vout#90	0.374057	$metal4
+ $W=3e-07
Rb84	vout#69	vout#91	0.799000	$metal4
+ $W=3e-07
Rb85	vout#61	vout#92	0.799000	$metal4
+ $W=3e-07
Rb86	vout#71	vout#93	0.799000	$metal4
+ $W=3e-07
Rb87	vout#72	vout#94	0.799000	$metal4
+ $W=3e-07
Rb88	vout#63	vout#95	0.799000	$metal4
+ $W=3e-07
Rb89	vout#84	vout#96	1.378667	$metal4
+ $W=3e-07
Rb90	vout#73	vout#97	0.799000	$metal4
+ $W=3e-07
Rb91	vout#85	vout#38	0.202663	$metal4
+ $W=3e-07
Rb92	vout#67	vout#98	0.799000	$metal4
+ $W=3e-07
Rb93	vout#88	vout#13	3.930618	$metal4
+ $W=3e-07
Rb94	vout#88	vout#100	0.374057	$metal4
+ $W=3e-07
Rb95	vout#78	vout#101	0.799000	$metal4
+ $W=3e-07
Rb96	vout#70	vout#102	0.799000	$metal4
+ $W=3e-07
Rb97	vout#80	vout#103	0.799000	$metal4
+ $W=3e-07
Rb98	vout#81	vout#104	0.799000	$metal4
+ $W=3e-07
Rb99	vout#82	vout#105	0.799000	$metal4
+ $W=3e-07
Rb100	vout#83	vout#106	0.799000	$metal4
+ $W=3e-07
Rb101	vout#84	vout#107	0.799000	$metal4
+ $W=3e-07
Rb102	vout#96	vout#108	0.799000	$metal4
+ $W=3e-07
Rb103	vout#74	vout#109	0.799000	$metal4
+ $W=3e-07
Rb104	vout#86	vout#110	0.799000	$metal4
+ $W=3e-07
Rb105	vout#75	vout#111	0.799000	$metal4
+ $W=3e-07
Rb106	vout#89	vout#112	0.799000	$metal4
+ $W=3e-07
Rb107	vout#79	vout#113	0.799000	$metal4
+ $W=3e-07
Rb108	vout#91	vout#114	0.799000	$metal4
+ $W=3e-07
Rb109	vout#93	vout#115	0.799000	$metal4
+ $W=3e-07
Rb110	vout#94	vout#116	0.799000	$metal4
+ $W=3e-07
Rb111	vout#108	vout#117	1.378667	$metal4
+ $W=3e-07
Rb112	vout#96	vout#118	0.799000	$metal4
+ $W=3e-07
Rb113	vout#87	vout#119	0.799000	$metal4
+ $W=3e-07
Rb114	vout#90	vout#120	0.799000	$metal4
+ $W=3e-07
Rb115	vout#101	vout#121	0.799000	$metal4
+ $W=3e-07
Rb116	vout#103	vout#122	0.799000	$metal4
+ $W=3e-07
Rb117	vout#92	vout#26	0.799000	$metal4
+ $W=3e-07
Rb118	vout#104	vout#123	0.799000	$metal4
+ $W=3e-07
Rb119	vout#95	vout#124	0.799000	$metal4
+ $W=3e-07
Rb120	vout#105	vout#125	0.799000	$metal4
+ $W=3e-07
Rb121	vout#106	vout#126	0.799000	$metal4
+ $W=3e-07
Rb122	vout#107	vout#127	0.799000	$metal4
+ $W=3e-07
Rb123	vout#108	vout#128	0.799000	$metal4
+ $W=3e-07
Rb124	vout#117	vout#129	0.799000	$metal4
+ $W=3e-07
Rb125	vout#97	vout#130	0.799000	$metal4
+ $W=3e-07
Rb126	vout#110	vout#131	0.799000	$metal4
+ $W=3e-07
Rb127	vout#98	vout#132	0.799000	$metal4
+ $W=3e-07
Rb128	vout#100	vout#133	0.799000	$metal4
+ $W=3e-07
Rb129	vout#112	vout#134	0.799000	$metal4
+ $W=3e-07
Rb130	vout#114	vout#135	0.799000	$metal4
+ $W=3e-07
Rb131	vout#102	vout#136	0.799000	$metal4
+ $W=3e-07
Rb132	vout#115	vout#137	0.799000	$metal4
+ $W=3e-07
Rb133	vout#116	vout#138	0.799000	$metal4
+ $W=3e-07
Rb134	vout#129	vout#139	1.378667	$metal4
+ $W=3e-07
Rb135	vout#117	vout#140	0.799000	$metal4
+ $W=3e-07
Rb136	vout#109	vout#141	0.799000	$metal4
+ $W=3e-07
Rb137	vout#111	vout#142	0.799000	$metal4
+ $W=3e-07
Rb138	vout#121	vout#143	0.799000	$metal4
+ $W=3e-07
Rb139	vout#113	vout#144	0.799000	$metal4
+ $W=3e-07
Rb140	vout#122	vout#145	0.799000	$metal4
+ $W=3e-07
Rb141	vout#123	vout#146	0.799000	$metal4
+ $W=3e-07
Rb142	vout#125	vout#147	0.799000	$metal4
+ $W=3e-07
Rb143	vout#126	vout#148	0.799000	$metal4
+ $W=3e-07
Rb144	vout#127	vout#149	0.799000	$metal4
+ $W=3e-07
Rb145	vout#128	vout#150	0.799000	$metal4
+ $W=3e-07
Rb146	vout#129	vout#151	0.799000	$metal4
+ $W=3e-07
Rb147	vout#139	vout#152	0.799000	$metal4
+ $W=3e-07
Rb148	vout#118	vout#153	0.799000	$metal4
+ $W=3e-07
Rb149	vout#131	vout#154	0.799000	$metal4
+ $W=3e-07
Rb150	vout#119	vout#155	0.799000	$metal4
+ $W=3e-07
Rb151	vout#134	vout#156	0.799000	$metal4
+ $W=3e-07
Rb152	vout#120	vout#157	0.799000	$metal4
+ $W=3e-07
Rb153	vout#135	vout#158	0.799000	$metal4
+ $W=3e-07
Rb154	vout#137	vout#159	0.799000	$metal4
+ $W=3e-07
Rb155	vout#138	vout#160	0.799000	$metal4
+ $W=3e-07
Rb156	vout#124	vout#161	0.799000	$metal4
+ $W=3e-07
Rb157	vout#152	vout#162	1.378667	$metal4
+ $W=3e-07
Rb158	vout#139	vout#163	0.799000	$metal4
+ $W=3e-07
Rb159	vout#130	vout#164	0.799000	$metal4
+ $W=3e-07
Rb160	vout#133	vout#165	0.799000	$metal4
+ $W=3e-07
Rb161	vout#143	vout#166	0.799000	$metal4
+ $W=3e-07
Rb162	vout#136	vout#23	0.799000	$metal4
+ $W=3e-07
Rb163	vout#145	vout#167	0.799000	$metal4
+ $W=3e-07
Rb164	vout#146	vout#168	0.799000	$metal4
+ $W=3e-07
Rb165	vout#147	vout#169	0.799000	$metal4
+ $W=3e-07
Rb166	vout#148	vout#170	0.799000	$metal4
+ $W=3e-07
Rb167	vout#149	vout#171	0.799000	$metal4
+ $W=3e-07
Rb168	vout#150	vout#172	0.799000	$metal4
+ $W=3e-07
Rb169	vout#151	vout#173	0.799000	$metal4
+ $W=3e-07
Rb170	vout#152	vout#174	0.799000	$metal4
+ $W=3e-07
Rb171	vout#162	vout#175	0.799000	$metal4
+ $W=3e-07
Rb172	vout#140	vout#176	0.799000	$metal4
+ $W=3e-07
Rb173	vout#141	vout#177	0.799000	$metal4
+ $W=3e-07
Rb174	vout#154	vout#178	0.799000	$metal4
+ $W=3e-07
Rb175	vout#142	vout#179	0.799000	$metal4
+ $W=3e-07
Rb176	vout#156	vout#180	0.799000	$metal4
+ $W=3e-07
Rb177	vout#144	vout#181	0.799000	$metal4
+ $W=3e-07
Rb178	vout#158	vout#182	0.799000	$metal4
+ $W=3e-07
Rb179	vout#159	vout#183	0.799000	$metal4
+ $W=3e-07
Rb180	vout#160	vout#184	0.799000	$metal4
+ $W=3e-07
Rb181	vout#175	vout#185	1.378667	$metal4
+ $W=3e-07
Rb182	vout#162	vout#186	0.799000	$metal4
+ $W=3e-07
Rb183	vout#153	vout#187	0.799000	$metal4
+ $W=3e-07
Rb184	vout#155	vout#188	0.799000	$metal4
+ $W=3e-07
Rb185	vout#157	vout#189	0.799000	$metal4
+ $W=3e-07
Rb186	vout#166	vout#190	0.799000	$metal4
+ $W=3e-07
Rb187	vout#167	vout#191	0.799000	$metal4
+ $W=3e-07
Rb188	vout#168	vout#192	0.799000	$metal4
+ $W=3e-07
Rb189	vout#161	vout#193	0.799000	$metal4
+ $W=3e-07
Rb190	vout#163	vout#194	0.799000	$metal4
+ $W=3e-07
Rb191	vout#164	vout#195	0.799000	$metal4
+ $W=3e-07
Rb192	vout#178	vout#196	0.799000	$metal4
+ $W=3e-07
Rb193	vout#165	vout#197	0.799000	$metal4
+ $W=3e-07
Rb194	vout#180	vout#198	0.799000	$metal4
+ $W=3e-07
Rb195	vout#182	vout#199	0.799000	$metal4
+ $W=3e-07
Rb196	vout#183	vout#200	0.799000	$metal4
+ $W=3e-07
Rb197	vout#185	vout#201	0.799000	$metal4
+ $W=3e-07
Rb198	vout#176	vout#202	0.799000	$metal4
+ $W=3e-07
Rb199	vout#177	vout#203	0.799000	$metal4
+ $W=3e-07
Rb200	vout#179	vout#204	0.799000	$metal4
+ $W=3e-07
Rb201	vout#190	vout#205	0.799000	$metal4
+ $W=3e-07
Rb202	vout#181	vout#20	0.799000	$metal4
+ $W=3e-07
Rb203	vout#191	vout#206	0.799000	$metal4
+ $W=3e-07
Rb204	vout#186	vout#207	0.799000	$metal4
+ $W=3e-07
Rb205	vout#187	vout#208	0.799000	$metal4
+ $W=3e-07
Rb206	vout#198	vout#209	0.799000	$metal4
+ $W=3e-07
Rb207	vout#189	vout#210	0.799000	$metal4
+ $W=3e-07
Rb208	vout#199	vout#211	0.799000	$metal4
+ $W=3e-07
Rb209	vout#193	vout#212	0.799000	$metal4
+ $W=3e-07
Rb210	vout#194	vout#213	0.799000	$metal4
+ $W=3e-07
Rb211	vout#195	vout#214	0.799000	$metal4
+ $W=3e-07
Rb212	vout#197	vout#215	0.799000	$metal4
+ $W=3e-07
Rb213	vout#205	vout#216	0.799000	$metal4
+ $W=3e-07
Rb214	vout#201	vout#217	0.799000	$metal4
+ $W=3e-07
Rb215	vout#202	vout#218	0.799000	$metal4
+ $W=3e-07
Rb216	vout#203	vout#219	0.799000	$metal4
+ $W=3e-07
Rb217	vout#204	vout#220	0.799000	$metal4
+ $W=3e-07
Rb218	vout#209	vout#221	0.799000	$metal4
+ $W=3e-07
Rb219	vout#207	vout#222	0.799000	$metal4
+ $W=3e-07
Rb220	vout#208	vout#223	0.799000	$metal4
+ $W=3e-07
Rb221	vout#210	vout#18	0.799000	$metal4
+ $W=3e-07
Rb222	vout#212	vout#224	0.799000	$metal4
+ $W=3e-07
Rb223	vout#213	vout#225	0.799000	$metal4
+ $W=3e-07
Rb224	vout#214	vout#226	0.799000	$metal4
+ $W=3e-07
Rb225	vout#215	vout#227	0.799000	$metal4
+ $W=3e-07
Rb226	vout#217	vout#228	0.799000	$metal4
+ $W=3e-07
Rb227	vout#218	vout#229	0.799000	$metal4
+ $W=3e-07
Rb228	vout#219	vout#230	0.799000	$metal4
+ $W=3e-07
Rb229	vout#222	vout#231	0.799000	$metal4
+ $W=3e-07
Rb230	vout#223	vout#232	0.799000	$metal4
+ $W=3e-07
Rb231	vout#225	vout#233	0.799000	$metal4
+ $W=3e-07
Rb232	vout#226	vout#234	0.799000	$metal4
+ $W=3e-07
Rb233	vout#227	vout#16	0.799000	$metal4
+ $W=3e-07
Rb234	vout#228	vout#235	0.799000	$metal4
+ $W=3e-07
Rb235	vout#229	vout#236	0.799000	$metal4
+ $W=3e-07
Rb236	vout#230	vout#237	0.799000	$metal4
+ $W=3e-07
Rb237	vout#231	vout#238	0.799000	$metal4
+ $W=3e-07
Rb238	vout#232	vout#239	0.799000	$metal4
+ $W=3e-07
Rb239	vout#233	vout#240	0.799000	$metal4
+ $W=3e-07
Rb240	vout#234	vout#241	0.799000	$metal4
+ $W=3e-07
Rb241	vout#235	vout#242	0.799000	$metal4
+ $W=3e-07
Rb242	vout#236	vout#243	0.799000	$metal4
+ $W=3e-07
Rb243	vout#237	vout#244	0.799000	$metal4
+ $W=3e-07
Rb244	vout#238	vout#245	0.799000	$metal4
+ $W=3e-07
Rb245	vout#239	vout#246	0.799000	$metal4
+ $W=3e-07
Rb246	vout#240	vout#247	0.799000	$metal4
+ $W=3e-07
Rb247	vout#241	vout#248	0.799000	$metal4
+ $W=3e-07
Rb248	vout#242	vout#249	0.799000	$metal4
+ $W=3e-07
Rb249	vout#243	vout#250	0.799000	$metal4
+ $W=3e-07
Rb250	vout#245	vout#251	0.799000	$metal4
+ $W=3e-07
Rb251	vout#246	vout#252	0.799000	$metal4
+ $W=3e-07
Rb252	vout#247	vout#253	0.799000	$metal4
+ $W=3e-07
Rb253	vout#248	vout#254	0.799000	$metal4
+ $W=3e-07
Rb254	vout#249	vout#255	0.799000	$metal4
+ $W=3e-07
Rb255	vout#250	vout#256	0.799000	$metal4
+ $W=3e-07
Rb256	vout#251	vout#257	0.799000	$metal4
+ $W=3e-07
Rb257	vout#252	vout#258	0.799000	$metal4
+ $W=3e-07
Rb258	vout#253	vout#259	0.799000	$metal4
+ $W=3e-07
Rb259	vout#255	vout#260	0.799000	$metal4
+ $W=3e-07
Rb260	vout#256	vout#261	0.799000	$metal4
+ $W=3e-07
Rb261	vout#257	vout#262	0.799000	$metal4
+ $W=3e-07
Rb262	vout#258	vout#263	0.799000	$metal4
+ $W=3e-07
Rb263	vout#259	vout#264	0.799000	$metal4
+ $W=3e-07
Rb264	vout#260	vout#265	0.799000	$metal4
+ $W=3e-07
Rb265	vout#261	vout#266	0.799000	$metal4
+ $W=3e-07
Rb266	vout#262	vout#267	0.799000	$metal4
+ $W=3e-07
Rb267	vout#264	vout#268	0.799000	$metal4
+ $W=3e-07
Rb268	vout#265	vout#269	0.799000	$metal4
+ $W=3e-07
Rb269	vout#266	vout#270	0.799000	$metal4
+ $W=3e-07
Rb270	vout#267	vout#271	0.799000	$metal4
+ $W=3e-07
Rb271	vout#268	vout#272	0.799000	$metal4
+ $W=3e-07
Rb272	vout#269	vout#273	0.799000	$metal4
+ $W=3e-07
Rb273	vout#271	vout#274	0.799000	$metal4
+ $W=3e-07
Rb274	vout#272	vout#275	0.799000	$metal4
+ $W=3e-07
Rb275	vout#273	vout#276	0.799000	$metal4
+ $W=3e-07
Rb276	vout#274	vout#277	0.799000	$metal4
+ $W=3e-07
Rb277	vout#276	vout#278	0.799000	$metal4
+ $W=3e-07
Rb278	vout#277	vout#279	0.799000	$metal4
+ $W=3e-07
Rb279	vout#278	vout#280	0.799000	$metal4
+ $W=3e-07
Rb280	vout#280	vout#281	0.799000	$metal4
+ $W=3e-07
Rb281	vssa#751	vssa#221	0.649553	$metal4
+ $W=3e-07
Rb282	vssa#221	vssa#753	0.713858	$metal4
+ $W=3e-07
Rb283	vssa#753	vssa#754	1.378667	$metal4
+ $W=3e-07
Rb284	vssa#754	vssa#755	1.378667	$metal4
+ $W=3e-07
Rb285	vssa#755	vssa#756	1.378667	$metal4
+ $W=3e-07
Rb286	vssa#756	vssa#757	1.378667	$metal4
+ $W=3e-07
Rb287	vssa#757	vssa#758	1.378667	$metal4
+ $W=3e-07
Rb288	vssa#758	vssa#759	1.378667	$metal4
+ $W=3e-07
Rb289	vssa#759	vssa#760	1.378667	$metal4
+ $W=3e-07
Rb290	vssa#760	vssa#761	1.378667	$metal4
+ $W=3e-07
Rb291	vssa#761	vssa#762	1.378667	$metal4
+ $W=3e-07
Rb292	vssa#762	vssa#763	1.378667	$metal4
+ $W=3e-07
Rb293	vssa#763	vssa#764	1.378667	$metal4
+ $W=3e-07
Rb294	vssa#764	vssa#765	1.378667	$metal4
+ $W=3e-07
Rb295	vssa#765	vssa#766	1.378667	$metal4
+ $W=3e-07
Rb296	vssa#766	vssa#767	1.378667	$metal4
+ $W=3e-07
Rb297	vssa#767	vssa#768	1.378667	$metal4
+ $W=3e-07
Rb298	vssa#768	vssa#223	0.687082	$metal4
+ $W=3e-07
Rb299	vssa#223	vssa#770	0.676186	$metal4
+ $W=3e-07
Rb300	vssa#770	vssa#771	0.799000	$metal4
+ $W=3e-07
Rb301	vssa#771	vssa#772	0.799000	$metal4
+ $W=3e-07
Rb302	vssa#772	vssa#773	0.799000	$metal4
+ $W=3e-07
Rb303	vssa#773	vssa#774	0.799000	$metal4
+ $W=3e-07
Rb304	vssa#774	vssa#775	0.799000	$metal4
+ $W=3e-07
Rb305	vssa#775	vssa#776	0.799000	$metal4
+ $W=3e-07
Rb306	vssa#776	vssa#777	0.799000	$metal4
+ $W=3e-07
Rb307	vssa#777	vssa#778	0.799000	$metal4
+ $W=3e-07
Rb308	vssa#778	vssa#779	0.799000	$metal4
+ $W=3e-07
Rb309	vssa#779	vssa#780	0.799000	$metal4
+ $W=3e-07
Rb310	vssa#780	vssa#781	0.799000	$metal4
+ $W=3e-07
Rb311	vssa#781	vssa#782	0.799000	$metal4
+ $W=3e-07
Rb312	vssa#782	vssa#783	0.799000	$metal4
+ $W=3e-07
Rb313	vssa#783	vssa#784	0.799000	$metal4
+ $W=3e-07
Rb314	vssa#784	vssa#785	0.799000	$metal4
+ $W=3e-07
Rb315	vssa#785	vssa#786	0.799000	$metal4
+ $W=3e-07
Rb316	vssa#786	vssa#217	0.397384	$metal4
+ $W=3e-07
Rb317	vssa#217	vssa#788	0.386503	$metal4
+ $W=3e-07
Rb318	vssa#788	vssa#213	0.686512	$metal4
+ $W=3e-07
Rb319	vssa#213	vssa#790	0.678608	$metal4
+ $W=3e-07
Rb320	vssa#790	vssa#791	1.378667	$metal4
+ $W=3e-07
Rb321	vssa#791	vssa#792	1.378667	$metal4
+ $W=3e-07
Rb322	vssa#792	vssa#793	1.378667	$metal4
+ $W=3e-07
Rb323	vssa#793	vssa#794	1.378667	$metal4
+ $W=3e-07
Rb324	vssa#794	vssa#795	1.378667	$metal4
+ $W=3e-07
Rb325	vssa#795	vssa#796	1.378667	$metal4
+ $W=3e-07
Rb326	vssa#796	vssa#797	1.378667	$metal4
+ $W=3e-07
Rb327	vssa#797	vssa#798	1.378667	$metal4
+ $W=3e-07
Rb328	vssa#798	vssa#799	1.378667	$metal4
+ $W=3e-07
Rb329	vssa#799	vssa#800	1.378667	$metal4
+ $W=3e-07
Rb330	vssa#800	vssa#801	1.378667	$metal4
+ $W=3e-07
Rb331	vssa#801	vssa#802	1.378667	$metal4
+ $W=3e-07
Rb332	vssa#802	vssa#803	1.378667	$metal4
+ $W=3e-07
Rb333	vssa#803	vssa#804	1.378667	$metal4
+ $W=3e-07
Rb334	vssa#804	vssa#805	1.378667	$metal4
+ $W=3e-07
Rb335	vssa#805	vssa#211	0.690500	$metal4
+ $W=3e-07
Rb336	vssa#211	vssa#807	0.676329	$metal4
+ $W=3e-07
Rb337	vssa#807	vssa#215	0.386075	$metal4
+ $W=3e-07
Rb338	vssa#215	vssa#809	0.398452	$metal4
+ $W=3e-07
Rb339	vssa#809	vssa#810	0.799000	$metal4
+ $W=3e-07
Rb340	vssa#810	vssa#811	0.799000	$metal4
+ $W=3e-07
Rb341	vssa#811	vssa#812	0.799000	$metal4
+ $W=3e-07
Rb342	vssa#812	vssa#813	0.799000	$metal4
+ $W=3e-07
Rb343	vssa#813	vssa#814	0.799000	$metal4
+ $W=3e-07
Rb344	vssa#814	vssa#815	0.799000	$metal4
+ $W=3e-07
Rb345	vssa#815	vssa#816	0.799000	$metal4
+ $W=3e-07
Rb346	vssa#816	vssa#817	0.799000	$metal4
+ $W=3e-07
Rb347	vssa#817	vssa#818	0.799000	$metal4
+ $W=3e-07
Rb348	vssa#818	vssa#819	0.799000	$metal4
+ $W=3e-07
Rb349	vssa#819	vssa#820	0.799000	$metal4
+ $W=3e-07
Rb350	vssa#820	vssa#821	0.799000	$metal4
+ $W=3e-07
Rb351	vssa#821	vssa#822	0.799000	$metal4
+ $W=3e-07
Rb352	vssa#822	vssa#823	0.799000	$metal4
+ $W=3e-07
Rb353	vssa#823	vssa#824	0.799000	$metal4
+ $W=3e-07
Rb354	vssa#824	vssa#219	0.406300	$metal4
+ $W=3e-07
Rb355	vssa#219	vssa#751	0.376376	$metal4
+ $W=3e-07
*
*       CAP/DIODE CARDS
*
*
CXI10/CC4	XI10/vbsh#31	XI10/vbsl#19	L=5e-06 W=5e-06 m=1  
CXI10/CC2	XI10/vbsh#36	XI10/vbsl#17	L=5e-06 W=5e-06 m=1  
CXI10/CC1	XI10/vbsh#37	XI10/vbsl#16	L=5e-06 W=5e-06 m=1  
CXI10/CC0	XI10/vbsh#35	XI10/vbsl#15	L=5e-06 W=5e-06 m=1  
CXI0/XC10/XC3/CC0	vssa#807	vssa#659	L=4e-06 W=4e-06 m=1  
CXI0/XC10/XC2/CC0	vssa#809	vssa#665	L=4e-06 W=4e-06 m=1  
CXI0/XC10/XC1/CC0	vssa#810	vssa#670	L=4e-06 W=4e-06 m=1  
CXI0/XC10/XC0/CC0	vssa#811	vssa#675	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC9/CC0	vssa#812	vssa#680	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC8/CC0	vssa#813	vssa#685	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC7/CC0	vssa#814	vssa#690	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC63/CC0	vssa#815	vssa#695	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC62/CC0	vssa#816	vssa#700	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC61/CC0	vssa#817	vssa#705	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC60/CC0	vssa#818	vssa#710	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC6/CC0	vssa#819	vssa#715	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC59/CC0	vssa#820	vssa#720	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC58/CC0	vssa#821	vssa#725	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC57/CC0	vssa#822	vssa#730	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC56/CC0	vssa#823	vssa#735	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC55/CC0	vssa#824	vssa#740	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC54/CC0	vssa#751	vssa#746	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC53/CC0	vssa#805	vssa#654	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC99/CC0	vout#221	vbottom<7>#252	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC98/CC0	vout#209	vbottom<7>#455	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC97/CC0	vout#198	vbottom<7>#468	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC96/CC0	vout#180	vbottom<7>#490	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC95/CC0	vout#156	vbottom<7>#505	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC94/CC0	vout#134	vbottom<7>#526	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC93/CC0	vout#112	vbottom<7>#541	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC92/CC0	vout#89	vbottom<7>#561	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC91/CC0	vout#100	vbottom<7>#571	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC90/CC0	vout#133	vbottom<7>#580	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC9/CC0	vout#165	vbottom<7>#589	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC89/CC0	vout#197	vbottom<7>#598	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC88/CC0	vout#215	vbottom<7>#607	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC87/CC0	vout#227	vbottom<7>#616	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC86/CC0	vout#16	vbottom<7>#882	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC85/CC0	vout#15	vbottom<7>#937	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC52/CC0	vssa#753	vssa#227	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC51/CC0	vssa#804	vssa#650	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC84/CC0	vout#216	vbottom<7>#244	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC83/CC0	vout#205	vbottom<7>#260	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC82/CC0	vout#190	vbottom<7>#740	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC81/CC0	vout#166	vbottom<7>#759	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC80/CC0	vout#143	vbottom<7>#874	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC8/CC0	vout#121	vbottom<7>#891	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC79/CC0	vout#101	vbottom<7>#921	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC78/CC0	vout#78	vbottom<7>#940	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC77/CC0	vout#90	vbottom<7>#955	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC76/CC0	vout#120	vbottom<7>#968	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC75/CC0	vout#157	vbottom<7>#978	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC74/CC0	vout#189	vbottom<7>#987	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC73/CC0	vout#210	vbottom<7>#996	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC72/CC0	vout#18	vbottom<7>#1005
+ L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC71/CC0	vout#17	vbottom<7>#842	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC70/CC0	vout#21	vbottom<7>#904	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC50/CC0	vssa#754	vssa#230	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC5/CC0	vssa#803	vssa#646	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC7/CC0	vout#211	vbottom<7>#236	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC69/CC0	vout#199	vbottom<7>#263	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC68/CC0	vout#182	vbottom<7>#438	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC67/CC0	vout#158	vbottom<7>#450	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC66/CC0	vout#135	vbottom<7>#466	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC65/CC0	vout#114	vbottom<7>#485	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC64/CC0	vout#91	vbottom<7>#503	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC63/CC0	vout#69	vbottom<7>#521	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC62/CC0	vout#79	vbottom<7>#539	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC61/CC0	vout#113	vbottom<7>#557	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC9/CC0	vout#144	vbottom<6>#404	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC8/CC0	vout#181	vbottom<6>#421	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC7/CC0	vout#20	vbottom<6>#438	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC63/CC0	vout#19	vbottom<6>#450	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC60/CC0	vout#24	vbottom<7>#802	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC6/CC0	vout#29	vbottom<7>#907	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC49/CC0	vssa#755	vssa#233	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC48/CC0	vssa#802	vssa#642	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC59/CC0	vout#206	vbottom<7>#228	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC58/CC0	vout#191	vbottom<7>#266	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC62/CC0	vout#167	vbottom<6>#442	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC61/CC0	vout#145	vbottom<6>#458	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC60/CC0	vout#122	vbottom<6>#469	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC6/CC0	vout#103	vbottom<6>#474	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC59/CC0	vout#80	vbottom<6>#479	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC58/CC0	vout#60	vbottom<6>#484	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC57/CC0	vout#70	vbottom<6>#489	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC56/CC0	vout#102	vbottom<6>#494	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC55/CC0	vout#136	vbottom<6>#248	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC54/CC0	vout#23	vbottom<6>#262	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC53/CC0	vout#22	vbottom<6>#279	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC52/CC0	vout#27	vbottom<6>#453	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC57/CC0	vout#33	vbottom<7>#805	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC56/CC0	vout#42	vbottom<7>#910	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC47/CC0	vssa#756	vssa#236	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC46/CC0	vssa#801	vssa#638	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC55/CC0	vout#200	vbottom<7>#220	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC54/CC0	vout#183	vbottom<7>#269	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC51/CC0	vout#159	vbottom<6>#436	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC50/CC0	vout#137	vbottom<6>#323	L=4e-06 W=4e-06 m=1  
CXI0/XC5/XC9/CC0	vout#115	vbottom<5>#212	L=4e-06 W=4e-06 m=1  
CXI0/XC5/XC8/CC0	vout#93	vbottom<5>#217	L=4e-06 W=4e-06 m=1  
CXI0/XC5/XC7/CC0	vout#71	vbottom<5>#222	L=4e-06 W=4e-06 m=1  
CXI0/XC5/XC6/CC0	vout#53	vbottom<5>#227	L=4e-06 W=4e-06 m=1  
CXI0/XC5/XC5/CC0	vout#61	vbottom<5>#232	L=4e-06 W=4e-06 m=1  
CXI0/XC5/XC4/CC0	vout#92	vbottom<5>#237	L=4e-06 W=4e-06 m=1  
CXI0/XC5/XC31/CC0	vout#26	vbottom<5>#242	L=4e-06 W=4e-06 m=1  
CXI0/XC5/XC30/CC0	vout#25	vbottom<5>#247	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC5/CC0	vout#31	vbottom<6>#282	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC49/CC0	vout#37	vbottom<6>#456	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC53/CC0	vout#51	vbottom<7>#808	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC52/CC0	vout#76	vbottom<7>#21	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC45/CC0	vssa#757	vssa#239	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC44/CC0	vssa#800	vssa#634	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC51/CC0	vout#192	vbottom<7>#212	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC50/CC0	vout#168	vbottom<7>#272	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC48/CC0	vout#146	vbottom<6>#430	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC47/CC0	vout#123	vbottom<6>#310	L=4e-06 W=4e-06 m=1  
CXI0/XC5/XC3/CC0	vout#104	vbottom<5>#208	L=4e-06 W=4e-06 m=1  
CXI0/XC5/XC29/CC0	vout#81	vbottom<5>#179	L=4e-06 W=4e-06 m=1  
CXI0/XC5/XC28/CC0	vout#62	vbottom<5>#195	L=4e-06 W=4e-06 m=1  
CXI0/XC4/XC9/CC0	vout#48	vbottom<4>#103	L=4e-06 W=4e-06 m=1  
CXI0/XC4/XC8/CC0	vout#54	vbottom<4>#109	L=4e-06 W=4e-06 m=1  
CXI0/XC4/XC7/CC0	vout#30	vbottom<4>#114	L=4e-06 W=4e-06 m=1  
CXI0/XC4/XC6/CC0	vout#28	vbottom<4>#119	L=4e-06 W=4e-06 m=1  
CXI0/XC5/XC27/CC0	vout#35	vbottom<5>#250	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC46/CC0	vout#46	vbottom<6>#285	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC45/CC0	vout#67	vbottom<6>#21	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC5/CC0	vout#98	vbottom<7>#811	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC49/CC0	vout#132	vbottom<7>#24	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC43/CC0	vssa#758	vssa#242	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC42/CC0	vssa#799	vssa#630	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC48/CC0	vout#184	vbottom<7>#204	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC47/CC0	vout#160	vbottom<7>#275	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC44/CC0	vout#138	vbottom<6>#425	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC43/CC0	vout#116	vbottom<6>#277	L=4e-06 W=4e-06 m=1  
CXI0/XC5/XC26/CC0	vout#94	vbottom<5>#204	L=4e-06 W=4e-06 m=1  
CXI0/XC4/XC5/CC0	vout#72	vbottom<4>#75	L=4e-06 W=4e-06 m=1  
CXI0/XC3/XC7/CC0	vout#55	vbottom<3>#31	L=4e-06 W=4e-06 m=1  
CXI0/XC3/XC6/CC0	vout#44	vbottom<3>#36	L=4e-06 W=4e-06 m=1  
CXI0/XC3/XC5/CC0	vout#34	vbottom<3>#41	L=4e-06 W=4e-06 m=1  
CXI0/XC3/XC4/CC0	vout#32	vbottom<3>#46	L=4e-06 W=4e-06 m=1  
CXI0/XC4/XC4/CC0	vout#41	vbottom<4>#122	L=4e-06 W=4e-06 m=1  
CXI0/XC5/XC25/CC0	vout#58	vbottom<5>#21	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC42/CC0	vout#87	vbottom<6>#288	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC41/CC0	vout#119	vbottom<6>#24	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC46/CC0	vout#155	vbottom<7>#814	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC45/CC0	vout#188	vbottom<7>#27	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC41/CC0	vssa#759	vssa#245	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC40/CC0	vssa#798	vssa#626	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC44/CC0	vout#196	vbottom<7>#196	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC43/CC0	vout#178	vbottom<7>#278	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC40/CC0	vout#154	vbottom<6>#419	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC4/CC0	vout#131	vbottom<6>#271	L=4e-06 W=4e-06 m=1  
CXI0/XC5/XC24/CC0	vout#110	vbottom<5>#199	L=4e-06 W=4e-06 m=1  
CXI0/XC4/XC3/CC0	vout#86	vbottom<4>#63	L=4e-06 W=4e-06 m=1  
CXI0/XC2/XC3/CC0	vout#66	vbottom<2>#24	L=4e-06 W=4e-06 m=1  
CXI0/XC1/XC1/CC0	vout#57	vbottom<1>#20	L=4e-06 W=4e-06 m=1  
CXI0/XC0/CC0	vout#36	vbottom<0>#16	L=4e-06 W=4e-06 m=1  
CXI0/XC2/XC2/CC0	vout#50	vbottom<2>#29	L=4e-06 W=4e-06 m=1  
CXI0/XC4/XC2/CC0	vout#75	vbottom<4>#125	L=4e-06 W=4e-06 m=1  
CXI0/XC5/XC23/CC0	vout#111	vbottom<5>#24	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC39/CC0	vout#142	vbottom<6>#291	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC38/CC0	vout#179	vbottom<6>#27	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC42/CC0	vout#204	vbottom<7>#817	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC41/CC0	vout#220	vbottom<7>#30	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC4/CC0	vssa#760	vssa#248	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC39/CC0	vssa#797	vssa#622	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC40/CC0	vout#169	vbottom<7>#188	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC4/CC0	vout#147	vbottom<7>#281	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC37/CC0	vout#125	vbottom<6>#413	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC36/CC0	vout#105	vbottom<6>#266	L=4e-06 W=4e-06 m=1  
CXI0/XC5/XC22/CC0	vout#82	vbottom<5>#193	L=4e-06 W=4e-06 m=1  
CXI0/XC4/XC15/CC0	vout#64	vbottom<4>#50	L=4e-06 W=4e-06 m=1  
CXI0/XC2/XC1/CC0	vout#49	vbottom<2>#18	L=4e-06 W=4e-06 m=1  
CXI0/XC8/CC0	vout#40	net3#19	L=4e-06 W=4e-06 m=1  
CXI0/XC1/XC0/CC0	vout#45	vbottom<1>#22	L=4e-06 W=4e-06 m=1  
CXI0/XC2/XC0/CC0	vout#63	vbottom<2>#31	L=4e-06 W=4e-06 m=1  
CXI0/XC4/XC14/CC0	vout#95	vbottom<4>#128	L=4e-06 W=4e-06 m=1  
CXI0/XC5/XC21/CC0	vout#124	vbottom<5>#27	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC35/CC0	vout#161	vbottom<6>#294	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC34/CC0	vout#193	vbottom<6>#30	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC39/CC0	vout#212	vbottom<7>#820	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC38/CC0	vout#224	vbottom<7>#33	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC38/CC0	vssa#761	vssa#251	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC37/CC0	vssa#796	vssa#618	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC37/CC0	vout#170	vbottom<7>#180	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC36/CC0	vout#148	vbottom<7>#284	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC33/CC0	vout#126	vbottom<6>#408	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC32/CC0	vout#106	vbottom<6>#260	L=4e-06 W=4e-06 m=1  
CXI0/XC5/XC20/CC0	vout#83	vbottom<5>#185	L=4e-06 W=4e-06 m=1  
CXI0/XC4/XC13/CC0	vout#65	vbottom<4>#37	L=4e-06 W=4e-06 m=1  
CXI0/XC3/XC3/CC0	vout#56	vbottom<3>#64	L=4e-06 W=4e-06 m=1  
CXI0/XC3/XC2/CC0	vout#74	vbottom<3>#68	L=4e-06 W=4e-06 m=1  
CXI0/XC3/XC1/CC0	vout#109	vbottom<3>#72	L=4e-06 W=4e-06 m=1  
CXI0/XC3/XC0/CC0	vout#141	vbottom<3>#76	L=4e-06 W=4e-06 m=1  
CXI0/XC4/XC12/CC0	vout#177	vbottom<4>#131	L=4e-06 W=4e-06 m=1  
CXI0/XC5/XC2/CC0	vout#203	vbottom<5>#30	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC31/CC0	vout#219	vbottom<6>#297	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC30/CC0	vout#230	vbottom<6>#33	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC35/CC0	vout#237	vbottom<7>#823	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC34/CC0	vout#244	vbottom<7>#36	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC36/CC0	vssa#762	vssa#254	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC35/CC0	vssa#795	vssa#614	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC33/CC0	vout#171	vbottom<7>#172	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC32/CC0	vout#149	vbottom<7>#287	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC3/CC0	vout#127	vbottom<6>#391	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC29/CC0	vout#107	vbottom<6>#254	L=4e-06 W=4e-06 m=1  
CXI0/XC5/XC19/CC0	vout#84	vbottom<5>#71	L=4e-06 W=4e-06 m=1  
CXI0/XC4/XC11/CC0	vout#73	vbottom<4>#33	L=4e-06 W=4e-06 m=1  
CXI0/XC4/XC10/CC0	vout#97	vbottom<4>#47	L=4e-06 W=4e-06 m=1  
CXI0/XC4/XC1/CC0	vout#130	vbottom<4>#56	L=4e-06 W=4e-06 m=1  
CXI0/XC4/XC0/CC0	vout#164	vbottom<4>#67	L=4e-06 W=4e-06 m=1  
CXI0/XC5/XC18/CC0	vout#195	vbottom<5>#115	L=4e-06 W=4e-06 m=1  
CXI0/XC5/XC17/CC0	vout#214	vbottom<5>#119	L=4e-06 W=4e-06 m=1  
CXI0/XC5/XC16/CC0	vout#226	vbottom<5>#33	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC28/CC0	vout#234	vbottom<6>#300	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC27/CC0	vout#241	vbottom<6>#36	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC31/CC0	vout#248	vbottom<7>#826	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC30/CC0	vout#254	vbottom<7>#39	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC34/CC0	vssa#763	vssa#257	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC33/CC0	vssa#794	vssa#610	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC3/CC0	vout#172	vbottom<7>#164	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC29/CC0	vout#150	vbottom<7>#290	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC26/CC0	vout#128	vbottom<6>#111	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC25/CC0	vout#108	vbottom<6>#136	L=4e-06 W=4e-06 m=1  
CXI0/XC5/XC15/CC0	vout#96	vbottom<5>#61	L=4e-06 W=4e-06 m=1  
CXI0/XC5/XC14/CC0	vout#118	vbottom<5>#83	L=4e-06 W=4e-06 m=1  
CXI0/XC5/XC13/CC0	vout#153	vbottom<5>#87	L=4e-06 W=4e-06 m=1  
CXI0/XC5/XC12/CC0	vout#187	vbottom<5>#91	L=4e-06 W=4e-06 m=1  
CXI0/XC5/XC11/CC0	vout#208	vbottom<5>#95	L=4e-06 W=4e-06 m=1  
CXI0/XC5/XC10/CC0	vout#223	vbottom<5>#99	L=4e-06 W=4e-06 m=1  
CXI0/XC5/XC1/CC0	vout#232	vbottom<5>#103	L=4e-06 W=4e-06 m=1  
CXI0/XC5/XC0/CC0	vout#239	vbottom<5>#36	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC24/CC0	vout#246	vbottom<6>#303	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC23/CC0	vout#252	vbottom<6>#39	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC28/CC0	vout#258	vbottom<7>#829	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC27/CC0	vout#263	vbottom<7>#42	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC32/CC0	vssa#764	vssa#260	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC31/CC0	vssa#793	vssa#606	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC26/CC0	vout#173	vbottom<7>#156	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC25/CC0	vout#151	vbottom<7>#293	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC22/CC0	vout#129	vbottom<6>#97	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC21/CC0	vout#117	vbottom<6>#131	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC20/CC0	vout#140	vbottom<6>#143	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC2/CC0	vout#176	vbottom<6>#147	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC19/CC0	vout#202	vbottom<6>#151	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC18/CC0	vout#218	vbottom<6>#155	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC17/CC0	vout#229	vbottom<6>#159	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC16/CC0	vout#236	vbottom<6>#163	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC15/CC0	vout#243	vbottom<6>#167	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC14/CC0	vout#250	vbottom<6>#171	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC13/CC0	vout#256	vbottom<6>#306	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC12/CC0	vout#261	vbottom<6>#42	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC24/CC0	vout#266	vbottom<7>#832	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC23/CC0	vout#270	vbottom<7>#45	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC30/CC0	vssa#765	vssa#263	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC3/CC0	vssa#792	vssa#602	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC22/CC0	vout#174	vbottom<7>#148	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC21/CC0	vout#152	vbottom<7>#296	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC11/CC0	vout#139	vbottom<6>#82	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC10/CC0	vout#163	vbottom<6>#93	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC1/CC0	vout#194	vbottom<6>#116	L=4e-06 W=4e-06 m=1  
CXI0/XC6/XC0/CC0	vout#213	vbottom<6>#128	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC20/CC0	vout#225	vbottom<7>#726	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC2/CC0	vout#233	vbottom<7>#746	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC19/CC0	vout#240	vbottom<7>#840	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC18/CC0	vout#247	vbottom<7>#880	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC17/CC0	vout#253	vbottom<7>#901	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC16/CC0	vout#259	vbottom<7>#929	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC15/CC0	vout#264	vbottom<7>#947	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC14/CC0	vout#268	vbottom<7>#960	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC13/CC0	vout#272	vbottom<7>#835	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC127/CC0	vout#275	vbottom<7>#48	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC29/CC0	vssa#766	vssa#266	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC28/CC0	vssa#791	vssa#598	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC126/CC0	vout#175	vbottom<7>#119	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC125/CC0	vout#162	vbottom<7>#299	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC124/CC0	vout#186	vbottom<7>#1003
+ L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC123/CC0	vout#207	vbottom<7>#994	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC122/CC0	vout#222	vbottom<7>#985	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC121/CC0	vout#231	vbottom<7>#976	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC120/CC0	vout#238	vbottom<7>#966	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC12/CC0	vout#245	vbottom<7>#953	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC119/CC0	vout#251	vbottom<7>#936	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC118/CC0	vout#257	vbottom<7>#915	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC117/CC0	vout#262	vbottom<7>#887	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC116/CC0	vout#267	vbottom<7>#859	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC115/CC0	vout#271	vbottom<7>#756	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC114/CC0	vout#274	vbottom<7>#737	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC113/CC0	vout#277	vbottom<7>#729	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC112/CC0	vout#279	vbottom<7>#51	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC27/CC0	vssa#767	vssa#269	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC26/CC0	vssa#790	vssa#370	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC111/CC0	vout#185	vbottom<7>#103	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC110/CC0	vout#201	vbottom<7>#137	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC11/CC0	vout#217	vbottom<7>#309	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC109/CC0	vout#228	vbottom<7>#313	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC108/CC0	vout#235	vbottom<7>#317	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC107/CC0	vout#242	vbottom<7>#321	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC106/CC0	vout#249	vbottom<7>#325	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC105/CC0	vout#255	vbottom<7>#329	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC104/CC0	vout#260	vbottom<7>#333	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC103/CC0	vout#265	vbottom<7>#337	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC102/CC0	vout#269	vbottom<7>#341	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC101/CC0	vout#273	vbottom<7>#345	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC100/CC0	vout#276	vbottom<7>#349	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC10/CC0	vout#278	vbottom<7>#353	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC1/CC0	vout#280	vbottom<7>#732	L=4e-06 W=4e-06 m=1  
CXI0/XC7/XC0/CC0	vout#281	vbottom<7>#54	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC25/CC0	vssa#768	vssa#272	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC24/CC0	vssa#788	vssa#333	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC23/CC0	vssa#786	vssa#381	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC22/CC0	vssa#785	vssa#385	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC21/CC0	vssa#784	vssa#389	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC20/CC0	vssa#783	vssa#393	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC2/CC0	vssa#782	vssa#397	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC19/CC0	vssa#781	vssa#401	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC18/CC0	vssa#780	vssa#405	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC17/CC0	vssa#779	vssa#409	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC16/CC0	vssa#778	vssa#413	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC15/CC0	vssa#777	vssa#417	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC14/CC0	vssa#776	vssa#421	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC13/CC0	vssa#775	vssa#425	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC12/CC0	vssa#774	vssa#429	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC11/CC0	vssa#773	vssa#433	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC10/CC0	vssa#772	vssa#437	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC1/CC0	vssa#771	vssa#441	L=4e-06 W=4e-06 m=1  
CXI0/XC9/XC0/CC0	vssa#770	vssa#276	L=4e-06 W=4e-06 m=1  
*
*
*       CAPACITOR CARDS
*
*
C329	vbottom<6>#195	vssa#138	4.63139e-15
C330	vbottom<6>#364	vbottom<4>#14	2.85711e-16
C331	vout#244	vssa#465	3.40614e-17
C332	vout#237	vbottom<7>#774	2.94458e-17
C333	vout#215	vout#227	3.49973e-17
C334	vout#87	vbottom<6>#189	2.30681e-15
C335	vbottom<5>#13	vref	1.4102e-15
C336	vout#175	vssa#596	4.61453e-17
C337	vout#248	vssa#138	7.27199e-16
C338	vout#251	vbottom<7>#372	2.25845e-17
C339	vbottom<7>#533	vssa#138	4.40581e-15
C340	vout#201	vout#162	4.03581e-17
C341	XI10/enb#31	sample#10	7.50032e-18
C342	vssa#816	vout#12	1.52513e-17
C343	vout#218	vbottom<6>#65	2.2191e-17
C344	vssa#817	vssa#210	2.46062e-16
C345	ctl<0>#10	vssa#33	1.831e-17
C346	vout#140	vbottom<6>#68	2.21768e-17
C347	vssa#544	vref	1.04974e-16
C348	vssa#762	vbottom<7>#774	3.64851e-17
C349	vout#214	vbottom<5>#41	5.90278e-17
C350	vout#245	vssa#138	6.66904e-16
C351	vssa#768	vssa#450	2.3666e-17
C352	vbottom<4>#83	net3	2.93809e-16
C353	vssa#821	vssa#511	2.2188e-17
C354	vout#229	vbottom<5>#47	3.43058e-17
C355	vout#237	vbottom<6>#364	2.94458e-17
C356	vout#160	vbottom<7>#279	2.70367e-17
C357	vout#28	vbottom<5>#140	5.41617e-17
C358	vbottom<2>#11	vbottom<1>#11	1.61601e-15
C359	vout#159	vout#167	4.03581e-17
C360	vout#267	vout#271	3.49788e-17
C361	vbottom<7>#771	vbottom<4>#13	3.37328e-16
C362	vbottom<7>#356	vbottom<7>#969	4.05397e-17
C363	vout#95	net3	3.87599e-17
C364	vout#175	vssa#138	6.52005e-16
C365	vout#23	vbottom<6>#198	2.21768e-17
C366	vout#233	vbottom<6>#62	3.43058e-17
C367	vout#42	vbottom<7>#789	2.71806e-17
C368	vssa#802	vbottom<7>#226	3.64851e-17
C369	vout#233	vbottom<7>#721	2.43454e-15
C370	vbottom<6>#183	net3	2.81951e-16
C371	vssa#765	vssa#453	2.21539e-17
C372	vout#137	vout#145	4.03581e-17
C373	vout#165	vbottom<7>#675	3.43058e-17
C374	XI10/net2#17	XI10/net2#13	3.75804e-17
C375	vout#198	vssa#538	5.90278e-17
C376	vout#276	vssa#138	6.7639e-16
C377	vref#56	vref#55	2.49999e-17
C378	vssa#223	vssa#138	1.0713e-16
C379	vbottom<6>#11	vdda#30	1.13575e-16
C380	vout#57	vbottom<2>#14	1.07247e-17
C381	XI10/enb#27	XI10/enb#15	2.4869e-17
C382	vout#135	vbottom<7>#693	5.90278e-17
C383	vssa#809	vssa#544	2.31386e-15
C384	vout#143	vbottom<7>#459	3.43058e-17
C385	vout#175	vout#162	3.49788e-17
C386	vbottom<3>#29	vssa#138	4.23325e-15
C387	vssa#489	vssa#138	4.46276e-15
C388	XI10/vbsh#34	XI10/vbsh#37	9.93031e-17
C389	vssa#790	vssa#791	3.49674e-17
C390	vout#224	net3#11	2.45344e-17
C391	vssa#781	vssa#138	5.7258e-16
C392	vout#60	vbottom<7>#514	4.75203e-17
C393	vssa#764	vssa#763	3.49664e-17
C394	vbottom<6>#109	vssa#138	4.36789e-15
C395	vout#247	vbottom<7>#712	2.21768e-17
C396	vssa#541	vref	1.04974e-16
C397	vbottom<5>#189	vbottom<5>#175	2.94976e-17
C398	vssa#816	vssa#523	2.38898e-15
C399	vout#95	vbottom<4>#82	3.02268e-17
C400	vout#190	vout#198	4.18065e-17
C401	vout#70	vbottom<5>#146	3.43058e-17
C402	vout#142	vbottom<3>#16	1.36973e-17
C403	net3#17	vssa#138	3.34153e-15
C404	vout#32	vbottom<0>	1.38456e-17
C405	vbottom<7>#202	vbottom<7>#210	4.05222e-17
C406	vout#97	vbottom<5>#53	5.90278e-17
C407	vbottom<7>#687	vssa#138	4.51243e-15
C408	vout#113	vssa#138	7.32035e-16
C409	vout#131	vout#116	4.03581e-17
C410	vout#108	vbottom<6>#109	4.15297e-17
C411	vbottom<2>#11	ctl<2>#8	2.78004e-18
C412	vout#32	vbottom<3>#23	2.50498e-17
C413	vout#18	vout#227	4.18065e-17
C414	vout#197	vbottom<7>#605	3.35485e-17
C415	vout#193	vbottom<6>#183	2.94458e-17
C416	vbottom<4>#11	vref#76	2.62197e-16
C417	vout#182	vssa#138	6.78788e-16
C418	vssa#813	vssa#535	2.21768e-17
C419	vout#250	vbottom<6>#47	2.21768e-17
C420	vssa#815	vssa#529	2.21768e-17
C421	vbottom<2>#36	vref	1.42369e-16
C422	vbottom<7>#640	vbottom<5>#13	2.6449e-16
C423	vout#13	vssa#208	7.85045e-17
C424	vssa#819	vref	1.10096e-16
C425	XI10/vbsl#19	XI10/vbsh#28	8.79331e-16
C426	vout#269	vout#273	3.49973e-17
C427	vout#210	vbottom<6>#396	3.43058e-17
C428	vout#92	vbottom<5>#143	2.43457e-15
C429	vout#33	vssa#138	7.86515e-16
C430	vssa#783	vout#228	4.18065e-17
C431	vref#41	vref#42	1.46352e-17
C432	vout#107	vout#106	4.03581e-17
C433	vssa#538	vref	1.04974e-16
C434	vout#172	vout#171	3.96617e-17
C435	vbottom<1>	vref#53	3.12455e-17
C436	vout#44	vout#48	4.18065e-17
C437	vssa#775	vref	1.25441e-16
C438	vout#163	vout#117	4.18376e-17
C439	vout#57	vssa#138	9.4237e-16
C440	vout#123	vbottom<5>#206	2.94458e-17
C441	vout#110	vbottom<5>#191	2.70367e-17
C442	vssa#816	sample#15	2.45569e-17
C443	vout#166	vbottom<7>#242	2.21768e-17
C444	vout#31	vout#37	3.58176e-17
C445	vbottom<4>#101	vssa#138	4.1073e-15
C446	vout#53	vbottom<4>#101	3.43058e-17
C447	vout#79	vbottom<6>#210	3.43058e-17
C448	vout#177	vbottom<3>#13	1.80349e-17
C449	vbottom<5>#11	vbottom<5>#9	1.24312e-17
C450	vout#196	vssa#138	6.44838e-16
C451	vout#74	vbottom<4>#25	5.90278e-17
C452	vssa#818	vssa#520	2.2188e-17
C453	vbottom<6>#192	vbottom<5>#14	2.68607e-17
C454	vout#140	vbottom<6>#74	2.21768e-17
C455	vssa#757	vssa#483	2.38696e-17
C456	vout#134	vout#112	3.49973e-17
C457	vout#113	vbottom<6>#402	2.94458e-17
C458	vbottom<5>#110	vssa#138	4.20402e-15
C459	vbottom<6>#373	vbottom<5>#15	4.23995e-17
C460	vout#213	vout#225	3.58176e-17
C461	vout#31	vbottom<6>#379	2.94458e-17
C462	vout#228	vbottom<7>#390	3.43058e-17
C463	vout#195	vbottom<5>#113	2.36313e-15
C464	vout#100	vbottom<7>#578	7.95669e-17
C465	vout#213	vout#176	4.18376e-17
C466	vbottom<7>#637	vssa#138	3.38214e-15
C467	vout#258	vbottom<7>#658	3.19307e-17
C468	ctl<4>#10	vssa#49	1.7893e-17
C469	vout#226	vout#234	3.58176e-17
C470	vout#161	vssa#138	4.41899e-17
C471	vbottom<2>#32	vref	1.18033e-16
C472	vout#90	vout#120	3.49973e-17
C473	vout#17	vbottom<7>#1008	5.21676e-17
C474	vout#243	vbottom<7>#712	5.90278e-17
C475	vout#260	vbottom<7>#80	2.2191e-17
C476	vout#206	vbottom<7>#226	2.25978e-15
C477	vout#88	vout#100	8.27234e-17
C478	vout#22	vbottom<6>#396	5.41617e-17
C479	vout#65	vssa#138	8.5411e-16
C480	vout#232	vbottom<5>#38	2.21768e-17
C481	vssa#535	vref	1.04974e-16
C482	vout#249	vbottom<7>#80	2.21768e-17
C483	vbottom<6>#91	vssa#138	4.10046e-15
C484	vout#178	vbottom<7>#282	2.70367e-17
C485	vout#201	vssa#324	5.90247e-17
C486	vout#34	vbottom<4>#98	5.06136e-17
C487	vssa#620	vssa#138	4.4388e-15
C488	vbottom<4>#83	vbottom<1>#13	3.53752e-17
C489	vout#151	vout#129	3.65289e-17
C490	vout#141	net3	1.30811e-17
C491	vbottom<3>#4	vssa#1	1.57337e-17
C492	vssa#801	vssa#636	2.36483e-15
C493	vbottom<7>#969	vssa#138	5.45866e-15
C494	vout#257	vout#247	4.18065e-17
C495	vout#263	vout#254	3.96617e-17
C496	vout#111	vbottom<4>#86	2.94458e-17
C497	vout#230	vbottom<4>	1.54667e-17
C498	vout#155	vbottom<7>#783	2.94458e-17
C499	vssa#306	vssa#138	4.42005e-15
C500	vout#259	vout#250	4.18065e-17
C501	vout#155	vout#188	3.58176e-17
C502	vssa#803	vssa#648	2.3665e-17
C503	vout#253	vssa#138	6.76431e-16
C504	vout#83	vbottom<5>#183	2.32389e-15
C505	vssa#138	vbottom<4>#15	2.91413e-16
C506	vbottom<6>#186	vbottom<2>	3.53752e-17
C507	vbottom<6>#11	vssa#92	2.91855e-17
C508	vout#29	vbottom<7>#795	2.25978e-15
C509	vout#52	vbottom<5>#149	1.94308e-16
C510	vssa#523	vssa#138	3.74721e-15
C511	vbottom<7>#897	vssa#138	4.90294e-15
C512	vout#18	vout#17	3.57086e-17
C513	vout#163	vssa#138	6.781e-16
C514	vbottom<7>#646	vbottom<3>#12	3.53752e-17
C515	vssa#799	vssa#624	2.21768e-17
C516	vout#72	vbottom<5>#189	1.15045e-17
C517	vbottom<7>#605	vssa#138	4.44331e-15
C518	vssa#138	sample#15	9.67318e-16
C519	vout#219	vbottom<4>#14	3.93799e-17
C520	vout#201	vbottom<7>#101	2.21768e-17
C521	vout#29	vout#21	3.96617e-17
C522	vssa#762	vssa#465	2.39296e-15
C523	vout#86	vbottom<4>#61	2.3109e-15
C524	vout#279	vssa#138	5.78225e-16
C525	vout#73	vbottom<5>#56	5.87804e-17
C526	vout#96	vbottom<5>#59	2.47649e-15
C527	vin#10	XI10/net2#17	4.29333e-18
C528	vssa#801	vssa#802	3.49674e-17
C529	vout#161	vout#193	3.58176e-17
C530	vbottom<4>#22	vssa#138	4.05722e-15
C531	XI10/vbsh#33	XI10/vbsl#17	2.94622e-15
C532	vout#277	vbottom<7>#356	2.44324e-15
C533	vout#203	vbottom<5>#106	3.97194e-17
C534	vout#89	vssa#138	4.87294e-16
C535	vout#171	vbottom<7>#178	2.70367e-17
C536	vout#184	vbottom<7>#194	2.70367e-17
C537	sample#15	vref	6.1667e-15
C538	vout#62	vbottom<4>#101	2.94458e-17
C539	vout#65	vbottom<3>#62	2.94458e-17
C540	vout#58	vout#87	3.58176e-17
C541	vbottom<3>#11	vbottom<3>#2	1.4671e-17
C542	vssa#778	vssa#303	2.35626e-15
C543	vout#244	vbottom<4>#13	3.63097e-17
C544	vout#71	vbottom<5>#189	3.43058e-17
C545	vout#221	vssa#138	5.89609e-16
C546	vout#47	vbottom<4>#101	1.94308e-16
C547	vbottom<6>#222	vssa#138	4.51243e-15
C548	vout#222	vbottom<6>#114	3.43058e-17
C549	vout#122	vout#103	3.49973e-17
C550	vout#61	vbottom<5>#143	2.12705e-17
C551	vout#188	vssa#759	4.05119e-17
C552	vssa#809	vssa#657	2.52128e-17
C553	net3#11	vref#75	2.62197e-16
C554	XI10/enb#34	XI10/vbsl#11	2.9534e-16
C555	vbottom<4>#82	net3	3.41212e-17
C556	vout#210	vssa#138	6.84294e-16
C557	vout#151	vout#150	4.03581e-17
C558	vout#248	vbottom<7>#655	3.19307e-17
C559	vout#80	vbottom<6>#213	2.21768e-17
C560	vout#78	vbottom<7>#687	2.16626e-17
C561	vout#63	vbottom<2>	1.79819e-17
C562	vout#210	vbottom<7>#672	2.21818e-17
C563	vout#47	vout#54	8.27234e-17
C564	vout#63	vout#95	3.58176e-17
C565	vout#114	vssa#138	6.76436e-16
C566	vbottom<7>#226	vssa#138	4.6507e-15
C567	vssa#823	vbottom<7>#663	3.64851e-17
C568	vbottom<5>#125	vbottom<3>#13	3.53752e-17
C569	vout#256	vout#261	3.49973e-17
C570	vout#251	vbottom<7>#77	5.90278e-17
C571	vout#191	vbottom<7>#226	2.94458e-17
C572	vout#90	vbottom<7>#533	3.43058e-17
C573	vout#234	vbottom<6>#174	3.19307e-17
C574	vssa#82	vref	6.58994e-15
C575	vout#162	vbottom<7>#139	2.54128e-15
C576	vout#181	vout#20	3.49959e-17
C577	vout#58	vref	1.65672e-17
C578	vbottom<7>#643	vbottom<1>#11	2.81951e-16
C579	vout#261	vbottom<6>#44	2.37401e-15
C580	vout#26	vbottom<4>#92	2.94458e-17
C581	vssa#798	vout#196	4.05119e-17
C582	vout#41	vssa#138	7.14725e-16
C583	vout#30	vbottom<4>#95	2.49217e-15
C584	vssa#822	vssa#210	3.44888e-16
C585	vbottom<7>#65	vssa#138	4.51244e-15
C586	vout#67	vout#37	4.03076e-17
C587	vssa#138	vbottom<4>	1.31037e-15
C588	vout#269	vssa#297	5.90247e-17
C589	vout#269	vbottom<7>#68	2.21768e-17
C590	vssa#774	vssa#773	3.49788e-17
C591	vin#10	vref	1.29701e-16
C592	vssa#776	vbottom<7>#71	3.64851e-17
C593	vout#239	vbottom<6>#50	5.90278e-17
C594	vout#87	vbottom<3>#16	1.39692e-17
C595	vout#214	vout#177	4.16356e-17
C596	sample#12	sample#9	3.25341e-17
C597	vout#35	vref	1.42547e-17
C598	vout#116	vssa#138	7.86881e-16
C599	vout#91	vbottom<6>#216	3.43058e-17
C600	vssa#754	vssa#486	2.21539e-17
C601	vout#281	vssa#768	4.05119e-17
C602	vout#145	vbottom<7>#447	4.75203e-17
C603	vout#147	vbottom<7>#285	3.19307e-17
C604	vbottom<6>#174	vssa#138	4.63139e-15
C605	vssa#219	vssa#208	1.42482e-17
C606	vout#113	vbottom<7>#678	5.90217e-17
C607	vout#187	vout#208	3.49973e-17
C608	vout#66	vout#55	4.18065e-17
C609	vout#135	vbottom<6>#222	3.43058e-17
C610	vbottom<4>#9	vbottom<4>#11	1.24663e-17
C611	vin#9	vref	4.15648e-15
C612	vssa#774	vssa#294	2.25845e-17
C613	vbottom<7>#11	vdda#30	1.10632e-16
C614	vout#212	vbottom<2>#11	1.80349e-17
C615	vssa#761	net3#11	3.22839e-17
C616	vssa#824	vssa#499	2.31365e-15
C617	vout#206	vssa#640	3.40614e-17
C618	vout#155	vout#98	4.03581e-17
C619	vout#70	vout#79	4.18065e-17
C620	vssa#779	vout#255	4.18065e-17
C621	vbottom<7>#715	vssa#138	4.51244e-15
C622	vout#117	vbottom<6>#74	2.54262e-15
C623	vout#208	vssa#138	6.76061e-16
C624	vout#17	vbottom<7>#666	2.85969e-17
C625	vout#117	vbottom<6>#80	1.15075e-17
C626	vout#8	vref	9.5442e-16
C627	vssa#82	vin#10	1.28259e-16
C628	vout#117	vbottom<6>#134	2.37165e-17
C629	vout#148	vout#126	3.58176e-17
C630	vout#194	vbottom<6>#71	3.43058e-17
C631	vout#150	vssa#138	7.86881e-16
C632	vbottom<7>#378	vssa#138	4.53336e-15
C633	vout#259	vbottom<7>#709	2.43454e-15
C634	vout#5	vref	1.61357e-16
C635	vout#36	vbottom<0>	3.57753e-17
C636	vout#217	vbottom<7>#393	3.43058e-17
C637	vbottom<5>#69	vssa#138	4.32851e-15
C638	vout#237	vbottom<7>#652	3.02268e-17
C639	vout#280	vbottom<7>#56	2.25845e-17
C640	vout#172	vout#150	3.58176e-17
C641	vout#45	vout#63	3.58176e-17
C642	vout#95	vbottom<3>#13	2.34729e-17
C643	vbottom<7>#623	vssa#138	4.99775e-15
C644	vout#34	vbottom<0>#18	2.37369e-17
C645	vout#261	vssa#138	7.21092e-16
C646	vbottom<6>#396	vssa#138	4.51094e-15
C647	vbottom<6>#11	ctl<6>#10	6.22159e-18
C648	vssa#751	vssa#208	1.31242e-16
C649	vssa#523	vref	1.30814e-16
C650	vout#164	vout#109	4.11135e-17
C651	XI10/enb#37	vref	3.5165e-16
C652	vssa#784	vssa#324	2.21768e-17
C653	vout#181	vbottom<6>#201	3.43058e-17
C654	vssa#221	vssa#495	2.82593e-17
C655	vout#249	vssa#138	6.7639e-16
C656	vout#203	vout#124	4.03581e-17
C657	vout#275	vbottom<7>#762	2.25978e-15
C658	vbottom<7>#605	vbottom<7>#596	2.94985e-17
C659	vout#102	vout#113	4.18065e-17
C660	vbottom<6>#68	vssa#138	4.51241e-15
C661	vout#222	vbottom<7>#384	2.25845e-17
C662	vout#124	vbottom<4>#83	2.94458e-17
C663	vssa#781	vout#242	4.18065e-17
C664	vout#46	vbottom<6>#192	2.31209e-15
C665	vssa#788	vssa#138	5.26809e-16
C666	XI10/enb#30	vref	1.96974e-16
C667	vssa#499	vssa#210	2.58098e-15
C668	vout#153	vbottom<6>#65	5.90278e-17
C669	vout#36	vbottom<1>#22	2.81964e-17
C670	XI10/vbsh#29	XI10/vbsh#28	2.08576e-16
C671	vout#122	vbottom<6>#219	2.21768e-17
C672	vout#16	vssa#499	4.66652e-17
C673	vssa#771	vbottom<7>#56	3.64851e-17
C674	vbottom<5>#143	vssa#138	4.51001e-15
C675	ctl<0>#10	vssa#105	1.4479e-17
C676	vout#268	vbottom<7>#706	2.2191e-17
C677	vbottom<7>#666	vssa#138	4.33225e-15
C678	vout#232	vout#239	3.49973e-17
C679	XI10/enb#38	vref	2.59314e-16
C680	vbottom<3>#23	vref	1.16805e-16
C681	vbottom<2>#11	vref#74	2.2466e-16
C682	vout#89	vbottom<7>#555	2.38876e-15
C683	vbottom<6>#91	vbottom<6>#129	3.11114e-17
C684	vout#63	net3	4.17257e-17
C685	vssa#820	vref	1.10096e-16
C686	vssa#759	vssa#758	3.49664e-17
C687	vout#129	vbottom<6>#80	3.65604e-17
C688	vssa#812	vssa#138	5.67625e-16
C689	vbottom<7>#285	vssa#138	4.63139e-15
C690	vssa#780	vssa#779	3.49973e-17
C691	vout#226	vbottom<5>#38	4.14234e-17
C692	vout#236	vbottom<6>#56	2.43454e-15
C693	vssa#520	vref	1.07726e-16
C694	XI10/enb#34	vref	7.40635e-17
C695	vout#134	vssa#814	4.18065e-17
C696	vssa#792	vssa#604	2.3665e-17
C697	vssa#774	vref	1.25441e-16
C698	vssa#514	sample#15	1.50585e-16
C699	vssa#815	sample#15	5.28117e-17
C700	vssa#788	vssa#327	2.63025e-17
C701	vbottom<6>#109	vbottom<6>#389	4.05397e-17
C702	vout#271	vbottom<7>#706	3.43058e-17
C703	vout#121	vbottom<7>#690	2.43458e-15
C704	vout#55	vout#44	3.49973e-17
C705	vout#74	vbottom<3>#56	2.21768e-17
C706	vbottom<0>	vbottom<3>#16	8.35165e-16
C707	vssa#121	vref	3.84869e-17
C708	vout#33	vbottom<7>#792	2.94458e-17
C709	vout#215	vbottom<7>#596	2.21768e-17
C710	vbottom<4>#17	vbottom<4>#14	7.94313e-17
C711	XI10/vbsl#11	vref	5.59662e-16
C712	vout#270	vbottom<7>#768	2.70367e-17
C713	vout#61	vssa#138	4.93331e-16
C714	vout#57	net3#17	2.4966e-17
C715	vssa#92	vssa#1	1.11589e-17
C716	vssa#781	vssa#780	3.49973e-17
C717	vout#171	vssa#612	3.40614e-17
C718	vout#148	vbottom<7>#288	3.19307e-17
C719	XI10/vbsl#11	XI10/vbsh#20	4.29092e-17
C720	vout#212	vbottom<7>#649	3.02268e-17
C721	vout#183	vssa#138	7.86881e-16
C722	XI10/vbsh#22	vref	3.96999e-16
C723	vout#260	vout#265	3.49973e-17
C724	vout#63	vbottom<1>#22	2.94458e-17
C725	vbottom<3>#20	vref	3.10746e-17
C726	vbottom<7>#9	ctl<7>#10	1.29975e-17
C727	vssa#517	vssa#208	1.41438e-15
C728	XI10/vbsh#34	XI10/vbsl#15	1.8262e-16
C729	vout#277	vbottom<7>#969	2.70367e-17
C730	vout#169	vout#196	3.96617e-17
C731	vssa#770	vssa#282	2.513e-17
C732	vout#211	vbottom<7>#264	2.94458e-17
C733	vssa#819	vssa#208	1.37238e-16
C734	vout#67	vbottom<6>#373	2.57588e-17
C735	vout#153	vbottom<5>#50	2.21768e-17
C736	vssa#814	vssa#529	2.36266e-15
C737	vout#179	vbottom<3>#15	2.08017e-17
C738	vout#223	vbottom<5>#47	2.2191e-17
C739	vssa#754	vbottom<7>#897	3.64851e-17
C740	vout#230	vout#193	4.03581e-17
C741	vbottom<7>#792	vbottom<7>#14	3.68719e-17
C742	vout#67	vssa#138	6.5725e-16
C743	vout#7	vref	8.23502e-15
C744	vout#201	vbottom<7>#95	2.21768e-17
C745	vout#215	vbottom<7>#669	3.43058e-17
C746	vbottom<2>#9	ctl<2>#8	8.77383e-18
C747	vssa#517	sample#15	1.80918e-16
C748	vout#202	vbottom<6>#62	2.21768e-17
C749	vbottom<4>#11	ctl<4>#10	3.44155e-18
C750	vssa#759	vssa#477	2.31023e-17
C751	vout#180	vout#156	3.49973e-17
C752	vout#49	vssa#138	8.64792e-16
C753	vout#73	vbottom<5>#69	4.18114e-17
C754	vout#67	vout#98	3.58176e-17
C755	vout#148	vout#147	4.03581e-17
C756	vssa#117	vref	3.84869e-17
C757	vout#55	vbottom<3>#29	2.36844e-15
C758	vout#94	vout#72	3.58176e-17
C759	vdda#30	vref	9.51258e-15
C760	vout#222	vbottom<7>#390	2.26006e-17
C761	vout#50	vbottom<3>#20	4.31944e-17
C762	vssa#796	vssa#138	7.55178e-16
C763	vout#61	vbottom<6>#210	5.08519e-17
C764	vout#241	vbottom<6>#361	2.31209e-15
C765	vout#160	vout#138	3.58176e-17
C766	vout#273	vbottom<7>#65	2.21768e-17
C767	vout#39	vbottom<1>#22	9.08617e-17
C768	vbottom<6>#370	vbottom<3>#15	3.06699e-17
C769	vout#86	vbottom<4>#73	3.26546e-17
C770	vssa#819	vssa#514	2.3635e-15
C771	vssa#285	vssa#138	4.42638e-15
C772	vdda#20	vref	7.08181e-15
C773	vout#138	vbottom<6>#417	2.70367e-17
C774	vout#24	vbottom<7>#623	5.09007e-17
C775	vout#226	vssa#138	6.59107e-16
C776	vssa#209	vssa#219	8.37082e-17
C777	vout#174	vbottom<7>#146	2.2663e-15
C778	vref#53	vref#54	1.46352e-17
C779	net3#17	vbottom<1>#14	1.49956e-17
C780	vssa#784	vssa#318	2.21768e-17
C781	vout#84	vssa#138	8.54438e-16
C782	vssa#520	sample#15	1.80918e-16
C783	vssa#753	vssa#493	2.30635e-15
C784	vbottom<4>#11	vref	4.09969e-16
C785	vssa#495	vssa#208	1.28875e-15
C786	vout#179	vbottom<6>#186	2.94458e-17
C787	vout#278	vbottom<7>#59	2.21768e-17
C788	vout#125	vbottom<6>#417	2.70367e-17
C789	vout#263	vssa#459	3.40614e-17
C790	vout#103	vout#80	3.49973e-17
C791	vout#35	vout#25	4.03581e-17
C792	vout#129	vbottom<6>#74	2.21768e-17
C793	vout#249	vbottom<7>#86	2.2191e-17
C794	vssa#764	vssa#138	5.81501e-16
C795	vssa#113	vref	3.84869e-17
C796	vout#156	vbottom<7>#501	2.38868e-15
C797	vssa#773	vssa#291	2.25845e-17
C798	vout#28	vbottom<4>#89	2.67924e-17
C799	net3#11	vref	1.54068e-15
C800	vout#255	vbottom<7>#378	3.43058e-17
C801	vout#204	vbottom<7>#646	2.57588e-17
C802	vout#162	vbottom<7>#117	3.80355e-17
C803	vbottom<5>#113	vbottom<4>#14	3.97088e-17
C804	vout#93	vbottom<5>#155	2.43458e-15
C805	vout#265	vssa#138	6.7639e-16
C806	vbottom<7>#92	vssa#138	4.51244e-15
C807	vout#48	vbottom<4>#98	1.64895e-17
C808	vout#23	vbottom<5>#137	2.94458e-17
C809	vout#25	vbottom<5>#134	2.67924e-17
C810	vssa#793	vssa#794	3.49674e-17
C811	vssa#41	vssa#42	2.15015e-17
C812	vout#135	vbottom<7>#478	8.05014e-17
C813	ctl<2>#10	vssa#112	2.71322e-17
C814	vout#109	net3	1.4153e-17
C815	vout#35	vbottom<5>#131	2.76621e-17
C816	vbottom<2>#11	vref	1.12702e-15
C817	vout#179	vbottom<6>#373	3.02268e-17
C818	vbottom<1>#11	vref#73	2.2466e-16
C819	vout#217	vssa#138	6.7639e-16
C820	vssa#790	vssa#331	2.52128e-17
C821	vout#154	vbottom<6>#411	2.70367e-17
C822	vout#48	vbottom<3>#26	3.43058e-17
C823	vssa#105	vssa#104	4.38474e-17
C824	vout#118	vbottom<4>#31	3.43058e-17
C825	vout#234	vbottom<4>	1.8259e-17
C826	vssa#775	vbottom<7>#68	3.64851e-17
C827	vbottom<6>#201	vssa#138	4.51635e-15
C828	vssa#523	sample#15	1.80918e-16
C829	vout#58	vbottom<5>#128	2.57588e-17
C830	vout#209	vssa#541	5.90278e-17
C831	vssa#759	vbottom<7>#783	3.64851e-17
C832	vout#116	vbottom<5>#202	2.94458e-17
C833	vout#276	vbottom<7>#62	2.21768e-17
C834	vout#224	vbottom<2>#11	1.36583e-17
C835	vbottom<1>#11	vref	1.20371e-15
C836	vssa#801	vbottom<7>#218	3.64851e-17
C837	vssa#772	vssa#138	5.7952e-16
C838	vbottom<7>#637	vbottom<5>#15	1.29275e-16
C839	vout#188	vbottom<5>#13	3.63445e-17
C840	vssa#471	vbottom<1>#11	2.59483e-16
C841	vout#120	vbottom<7>#550	3.43058e-17
C842	vout#261	vbottom<7>#969	1.3155e-17
C843	vbottom<2>#32	vbottom<2>	1.5823e-16
C844	vssa#793	vbottom<7>#154	3.64851e-17
C845	vout#149	vbottom<7>#291	3.19307e-17
C846	vout#34	vbottom<3>#23	2.43781e-15
C847	vout#263	vbottom<7>#765	2.90578e-17
C848	vout#101	vssa#138	6.76452e-16
C849	vssa#109	vref	6.10702e-17
C850	vout#206	vbottom<7>#267	2.94458e-17
C851	vout#126	vbottom<6>#411	2.70367e-17
C852	vout#248	vout#254	3.58176e-17
C853	vout#111	vbottom<5>#125	2.57588e-17
C854	vbottom<0>#11	vref	1.19065e-15
C855	vout#251	vbottom<7>#718	3.43058e-17
C856	vout#262	vbottom<7>#369	2.42764e-15
C857	vout#105	vbottom<6>#258	3.19307e-17
C858	vbottom<7>#777	vbottom<2>#11	2.78974e-16
C859	vssa#803	vssa#138	7.48403e-16
C860	vout#231	vbottom<7>#384	2.42764e-15
C861	vout#268	vout#261	4.18376e-17
C862	vout#156	vssa#813	4.18065e-17
C863	vbottom<3>#11	vref	4.666e-16
C864	vssa#771	vssa#285	2.21768e-17
C865	vssa#803	vssa#640	2.21768e-17
C866	vout#90	vbottom<7>#681	2.38365e-15
C867	vbottom<4>#15	vbottom<3>#56	7.60815e-17
C868	vssa#278	vssa#138	3.73972e-15
C869	vbottom<7>#210	vbottom<7>#218	4.05222e-17
C870	vout#145	vout#122	3.49973e-17
C871	vout#23	vssa#138	8.13456e-16
C872	vssa#526	sample#15	1.80918e-16
C873	vout#200	vbottom<7>#218	2.25978e-15
C874	vssa#211	vssa#138	1.47135e-16
C875	vout#124	vbottom<5>#122	3.02268e-17
C876	vssa#772	vbottom<7>#59	3.64851e-17
C877	vssa#756	vssa#480	1.9598e-17
C878	vout#216	vbottom<7>#250	3.85473e-17
C879	vbottom<7>#1008	vbottom<7>#666	3.60585e-17
C880	vout#125	vbottom<6>#406	3.19307e-17
C881	vssa#22	vssa#1	1.08924e-17
C882	vout#155	vbottom<7>#643	2.57588e-17
C883	vout#115	vbottom<5>#210	2.37141e-15
C884	vout#281	vout#279	3.96617e-17
C885	vbottom<5>#11	vref	4.09803e-16
C886	vout#261	vbottom<7>#703	4.74489e-17
C887	vout#122	vssa#138	6.76087e-16
C888	vin#9	vssa#82	4.52436e-16
C889	vout#191	vout#167	3.58176e-17
C890	vbottom<7>#264	vssa#138	9.21082e-15
C891	vssa#764	vssa#459	2.34524e-15
C892	vout#251	vbottom<7>#378	2.26006e-17
C893	vssa#820	vssa#508	2.21831e-17
C894	vssa#520	vssa#210	2.39811e-15
C895	ctl<4>#10	vssa#121	1.42509e-17
C896	vout#49	vbottom<3>#62	4.46783e-17
C897	vout#41	vout#28	4.03581e-17
C898	vout#83	vbottom<6>#258	2.94458e-17
C899	vssa#772	vssa#288	2.25845e-17
C900	vout#219	vbottom<6>#177	3.02268e-17
C901	vssa#105	vref	3.86084e-17
C902	vout#66	vbottom<2>#19	2.62403e-17
C903	vssa#804	vssa#805	3.49674e-17
C904	vbottom<6>#11	vref	4.10184e-16
C905	vout#111	vbottom<3>#16	1.97255e-17
C906	vbottom<6>#308	vssa#138	4.63139e-15
C907	vout#228	vbottom<7>#92	2.43454e-15
C908	vout#47	vssa#138	4.85604e-16
C909	vout#169	vout#147	3.58176e-17
C910	sample#9	XI10/enb#16	1.44524e-17
C911	vout#265	vout#269	3.49973e-17
C912	vssa#805	vssa#652	2.3251e-15
C913	vbottom<0>#18	vssa#138	3.26748e-15
C914	vout#189	vout#197	4.18065e-17
C915	vout#109	vbottom<3>#56	2.43192e-15
C916	vout#115	vbottom<6>#222	5.90278e-17
C917	vout#248	vout#237	4.03581e-17
C918	vbottom<7>#693	vssa#138	4.51243e-15
C919	vout#63	vssa#138	5.95141e-16
C920	vout#21	vssa#754	4.05119e-17
C921	vout#62	vbottom<5>#175	2.21768e-17
C922	vout#29	vssa#486	3.40614e-17
C923	vout#71	vbottom<6>#216	5.90278e-17
C924	vout#127	vbottom<6>#406	2.70367e-17
C925	vout#183	vbottom<7>#218	2.94458e-17
C926	vbottom<7>#11	vref	4.11186e-16
C927	vout#75	vout#111	3.58176e-17
C928	vout#92	vout#26	3.49973e-17
C929	vout#212	vbottom<6>#367	2.94458e-17
C930	vout#70	vbottom<6>#213	1.6331e-17
C931	vout#118	vbottom<5>#53	2.21768e-17
C932	vssa#529	sample#15	1.80918e-16
C933	XI10/enb#38	vin#11	8.43951e-18
C934	vssa#796	vssa#620	2.3665e-17
C935	vout#125	vssa#138	7.86881e-16
C936	vssa#768	vssa#767	3.49664e-17
C937	vout#254	vbottom<7>#771	2.2545e-15
C938	vout#163	vbottom<6>#129	1.30071e-17
C939	vbottom<6>#361	vbottom<4>#14	3.0779e-17
C940	vout#74	vout#40	4.17561e-17
C941	vout#236	vbottom<5>#44	3.43058e-17
C942	vbottom<5>#41	vssa#138	4.51244e-15
C943	vout#158	vbottom<7>#459	3.35516e-17
C944	vssa#120	vref	5.30999e-15
C945	vssa#801	vout#200	4.05119e-17
C946	vbottom<5>#128	vbottom<0>	3.15028e-16
C947	vout#101	vbottom<7>#687	2.43458e-15
C948	vout#119	vbottom<3>#15	1.73839e-17
C949	vbottom<5>#125	vbottom<1>#13	3.53752e-17
C950	vout#237	vssa#138	1.82365e-17
C951	vbottom<1>#11	ctl<1>#8	2.78004e-18
C952	vbottom<6>#192	vref	1.22519e-16
C953	vssa#101	vref	6.10702e-17
C954	vout#107	vbottom<5>#69	2.94458e-17
C955	vout#226	vbottom<5>#110	2.2191e-17
C956	vout#109	vbottom<4>#22	4.2226e-17
C957	vbottom<7>#578	vbottom<7>#569	3.6031e-17
C958	vssa#116	vref	7.72189e-16
C959	vout#233	vssa#138	6.76431e-16
C960	vssa#477	vbottom<6>#13	3.22792e-16
C961	vout#69	vbottom<7>#533	2.05082e-17
C962	vout#160	vout#168	4.03581e-17
C963	vbottom<7>#170	vssa#138	4.6507e-15
C964	vout#273	vssa#294	5.90247e-17
C965	vout#98	vbottom<7>#640	2.57588e-17
C966	vbottom<5>#131	vbottom<3>#16	3.00037e-16
C967	vbottom<6>#47	vssa#138	4.84834e-15
C968	vout#84	vbottom<6>#252	4.15297e-17
C969	vssa#791	vssa#368	2.21768e-17
C970	vbottom<5>#122	net3	3.53752e-17
C971	vbottom<6>#370	vbottom<1>#11	1.66867e-16
C972	vout#195	vout#141	4.18065e-17
C973	vout#83	vout#65	3.65289e-17
C974	vssa#774	vbottom<7>#65	3.64851e-17
C975	vout#174	vssa#138	6.29173e-16
C976	vbottom<6>#180	vbottom<4>	2.68607e-17
C977	vout#80	vbottom<6>#219	2.21768e-17
C978	vssa#754	vssa#753	3.49664e-17
C979	vssa#112	vref	5.50323e-16
C980	vout#200	vbottom<7>#270	2.94458e-17
C981	vbottom<0>#11	vref#72	2.35634e-16
C982	vout#150	vbottom<7>#294	3.19307e-17
C983	vssa#532	sample#15	1.73997e-16
C984	vbottom<7>#11	vssa#88	3.03282e-17
C985	vbottom<5>#122	vssa#138	3.49127e-15
C986	vssa#821	vref	1.10096e-16
C987	vout#106	vbottom<6>#252	3.19307e-17
C988	vout#120	vbottom<7>#675	2.21768e-17
C989	vout#196	vbottom<7>#186	2.70367e-17
C990	vout#271	vssa#138	6.66904e-16
C991	vssa#790	vout#185	4.12232e-17
C992	vout#265	vbottom<7>#77	2.2191e-17
C993	vout#130	vbottom<4>#22	2.21768e-17
C994	vssa#221	vssa#138	1.83676e-17
C995	vssa#773	vbottom<7>#62	3.64851e-17
C996	vout#264	vbottom<7>#703	2.21768e-17
C997	vssa#812	vssa#532	2.21768e-17
C998	vout#256	vbottom<6>#174	2.70367e-17
C999	vout#116	vout#94	3.58176e-17
C1000	vssa#108	vref	4.29736e-16
C1001	XI10/vbsh#37	sample#15	6.5966e-17
C1002	vout#20	vbottom<6>#399	2.4132e-17
C1003	vssa#773	vref	1.25441e-16
C1004	vout#97	vout#56	4.18065e-17
C1005	vout#276	vout#271	4.18065e-17
C1006	vout#230	vout#237	3.58176e-17
C1007	vout#242	vssa#138	6.7639e-16
C1008	vout#89	vout#88	7.4616e-17
C1009	vout#188	vout#132	3.96617e-17
C1010	vbottom<5>#134	vbottom<5>#14	3.76709e-17
C1011	vbottom<6>#189	vref	2.6045e-16
C1012	vout#209	vout#198	3.49973e-17
C1013	vssa#97	vref	6.10702e-17
C1014	vssa#628	vssa#138	4.4388e-15
C1015	vssa#221	vssa#208	9.22139e-17
C1016	vout#78	vbottom<7>#514	3.43058e-17
C1017	vssa#104	vref	4.39133e-16
C1018	vssa#814	sample#15	5.28117e-17
C1019	vbottom<6>#180	net3	3.53752e-17
C1020	vout#172	vbottom<7>#170	2.70367e-17
C1021	vssa#817	vssa#517	2.21831e-17
C1022	vout#103	vout#114	4.18065e-17
C1023	vout#25	vbottom<6>#201	5.41617e-17
C1024	vssa#312	vssa#138	4.38716e-15
C1025	vout#120	vssa#138	6.7642e-16
C1026	vbottom<7>#154	vbottom<7>#162	4.05222e-17
C1027	vssa#100	vref	5.92159e-16
C1028	vout#120	vbottom<7>#578	4.75233e-17
C1029	vssa#138	vbottom<2>#14	4.96373e-16
C1030	vout#68	vbottom<7>#533	3.04944e-16
C1031	vout#244	vbottom<7>#777	2.57588e-17
C1032	vout#22	vout#20	3.71123e-17
C1033	vout#51	vbottom<7>#637	2.57588e-17
C1034	vout#207	vbottom<7>#393	2.26006e-17
C1035	XI10/enb#16	XI10/enb#17	1.14855e-17
C1036	XI10/vbsh#37	XI10/vbsh#33	1.61507e-16
C1037	vssa#529	vssa#138	4.29745e-15
C1038	vssa#794	vssa#608	2.36483e-15
C1039	vout#190	vssa#138	6.76452e-16
C1040	vssa#815	vssa#816	3.49973e-17
C1041	vout#31	vbottom<6>#195	2.31737e-15
C1042	vssa#96	vref	8.06467e-16
C1043	vout#164	vbottom<5>#113	2.94458e-17
C1044	vout#207	vbottom<7>#387	2.25845e-17
C1045	vout#246	vout#234	4.03581e-17
C1046	vbottom<2>#19	vbottom<2>#14	4.57392e-17
C1047	vout#66	vbottom<1>#18	2.94458e-17
C1048	vout#257	vbottom<7>#74	5.90278e-17
C1049	vout#192	vout#200	3.96617e-17
C1050	vout#45	vbottom<2>	1.58676e-17
C1051	vout#24	vssa#138	7.55157e-16
C1052	vout#155	vbottom<5>#14	1.19759e-17
C1053	vout#143	vbottom<7>#690	2.21768e-17
C1054	vbottom<7>#478	vssa#138	4.51049e-15
C1055	vout#219	vbottom<4>	1.97255e-17
C1056	vbottom<6>#186	vref	2.60667e-16
C1057	vssa#782	vssa#315	2.36317e-15
C1058	vssa#88	vbottom<7>#9	1.00174e-17
C1059	vout#142	vout#87	4.03581e-17
C1060	vbottom<7>#786	vbottom<5>#13	3.41889e-16
C1061	vout#45	net3	3.10768e-17
C1062	vssa#93	vref	6.10702e-17
C1063	vout#238	vbottom<7>#83	5.90278e-17
C1064	vout#41	vbottom<4>#86	2.57588e-17
C1065	vout#89	vbottom<7>#684	3.43058e-17
C1066	vout#203	vbottom<4>#14	3.87599e-17
C1067	vbottom<7>#783	vbottom<0>#11	4.23995e-17
C1068	vout#17	vout#21	3.49973e-17
C1069	vssa#92	vref	8.20603e-16
C1070	vbottom<4>#28	vssa#138	4.51245e-15
C1071	vout#64	vbottom<5>#191	2.94458e-17
C1072	vout#44	vssa#138	5.18458e-16
C1073	vout#162	vbottom<7>#98	5.06594e-17
C1074	vout#122	vout#135	4.18065e-17
C1075	vbottom<6>#189	vbottom<5>#14	3.00037e-16
C1076	XI10/net2#21	XI10/net2#15	3.68073e-17
C1077	vout#227	vssa#505	5.90217e-17
C1078	vout#202	vbottom<7>#724	4.95352e-17
C1079	XI10/vbsl#11	XI10/vbsh#22	2.9148e-17
C1080	vssa#88	vref	2.00347e-15
C1081	vout#184	vssa#138	6.44838e-16
C1082	XI10/enb#21	XI10/enb#13	3.08291e-17
C1083	vssa#812	vssa#538	2.21768e-17
C1084	vout#112	vssa#815	4.18065e-17
C1085	vout#254	vssa#763	4.05119e-17
C1086	vout#247	vbottom<7>#718	2.2191e-17
C1087	vout#106	vout#83	3.58176e-17
C1088	XI10/vbsh#29	vdda#21	6.60583e-17
C1089	vout#126	vbottom<6>#258	2.94458e-17
C1090	vssa#761	vbottom<2>#11	2.97626e-17
C1091	vout#142	vssa#138	3.20366e-16
C1092	vout#33	vbottom<7>#634	2.70367e-17
C1093	vout#75	vbottom<2>#36	2.94458e-17
C1094	vout#217	vout#228	3.49973e-17
C1095	vout#192	vbottom<7>#273	2.94458e-17
C1096	vbottom<3>#4	vssa#101	1.89594e-17
C1097	vout#151	vbottom<7>#297	3.19307e-17
C1098	vout#64	vssa#138	7.86224e-16
C1099	vbottom<6>#183	vref	2.62927e-16
C1100	vssa#761	vssa#471	2.31023e-17
C1101	vssa#89	vref	6.10702e-17
C1102	vssa#495	vref	9.29281e-17
C1103	vssa#781	vssa#312	2.36317e-15
C1104	vbottom<6>#11	vbottom<6>#9	1.24663e-17
C1105	vout#153	vbottom<5>#56	2.2191e-17
C1106	vbottom<3>#11	vref#71	2.35634e-16
C1107	vout#210	vbottom<7>#605	5.90309e-17
C1108	vout#107	vbottom<6>#258	2.70367e-17
C1109	vout#202	vbottom<6>#68	2.2191e-17
C1110	vssa#804	vssa#144	8.84951e-17
C1111	vout#243	vssa#138	6.76427e-16
C1112	vout#141	vbottom<3>#56	2.2191e-17
C1113	vbottom<7>#71	vssa#138	4.51244e-15
C1114	vssa#138	vbottom<4>#17	3.60313e-16
C1115	vout#58	vbottom<3>#16	1.75654e-17
C1116	vout#65	vbottom<4>#48	2.67266e-17
C1117	vssa#823	vssa#505	2.2188e-17
C1118	vbottom<4>#9	vref	5.02645e-17
C1119	vbottom<7>#896	vssa#138	4.30722e-15
C1120	vbottom<6>#183	vbottom<2>	2.81951e-16
C1121	vssa#493	vref	8.3223e-17
C1122	vout#117	vssa#138	7.53849e-16
C1123	vout#24	vbottom<7>#631	2.70367e-17
C1124	vout#136	vout#23	3.49973e-17
C1125	vbottom<7>#537	vbottom<7>#519	2.94976e-17
C1126	net3#17	vbottom<2>#14	1.13742e-16
C1127	vout#191	vout#199	4.03581e-17
C1128	vssa#777	vssa#300	2.35626e-15
C1129	vbottom<6>#180	vssa#138	2.01715e-15
C1130	vssa#147	vssa#148	3.40736e-17
C1131	vout#227	vbottom<7>#614	2.42321e-15
C1132	vout#245	vout#251	3.49788e-17
C1133	vbottom<6>#180	vref	2.60667e-16
C1134	vout#126	vbottom<6>#389	3.19307e-17
C1135	vout#117	vout#140	3.49973e-17
C1136	vout#275	vssa#138	6.28892e-16
C1137	vout#259	vbottom<6>#50	3.43058e-17
C1138	vssa#786	vssa#331	2.52128e-17
C1139	vout#129	vout#117	3.49973e-17
C1140	vout#69	vout#78	4.18065e-17
C1141	vout#72	vout#55	3.58176e-17
C1142	vout#179	vbottom<1>#11	1.21103e-17
C1143	vout#140	vout#176	3.49973e-17
C1144	vout#245	vbottom<7>#375	2.25845e-17
C1145	vbottom<7>#721	vssa#138	4.51244e-15
C1146	vout#242	vbottom<7>#86	2.43454e-15
C1147	vssa#816	vssa#138	4.19324e-16
C1148	vout#224	vbottom<7>#774	2.77798e-17
C1149	vout#192	vout#168	3.58176e-17
C1150	vout#8	vssa#82	3.65297e-16
C1151	vout#56	vout#74	3.49973e-17
C1152	vbottom<7>#777	vbottom<3>#12	2.31904e-16
C1153	ctl<0>#10	vbottom<0>#9	1.43752e-17
C1154	vout#61	vout#92	3.49973e-17
C1155	vout#67	vref	1.65672e-17
C1156	vssa#792	vssa#596	2.21768e-17
C1157	vssa#809	vssa#138	5.1037e-16
C1158	vbottom<7>#384	vssa#138	4.53336e-15
C1159	vssa#465	vbottom<4>#13	3.18154e-16
C1160	vout#118	vbottom<5>#59	2.21768e-17
C1161	vout#144	vout#157	4.18065e-17
C1162	net3#9	vref	5.02645e-17
C1163	vout#240	vbottom<7>#375	5.90217e-17
C1164	vout#17	vbottom<7>#628	2.67924e-17
C1165	vout#215	vssa#138	5.63486e-16
C1166	vout#37	vref	1.42547e-17
C1167	vout#271	vbottom<7>#366	2.26006e-17
C1168	vbottom<6>#402	vssa#138	4.23953e-15
C1169	vout#186	vbottom<6>#80	3.43058e-17
C1170	vout#277	vout#272	4.03581e-17
C1171	vout#48	vout#47	7.4616e-17
C1172	vbottom<6>#177	vref	1.30225e-16
C1173	vout#184	vbottom<7>#276	2.94458e-17
C1174	vout#228	vout#235	3.49973e-17
C1175	vout#268	vout#272	3.49973e-17
C1176	vout#61	vbottom<5>#149	1.6331e-17
C1177	ctl<7>#10	ctl<7>#8	2.72821e-17
C1178	vout#112	vbottom<7>#537	2.38868e-15
C1179	vout#230	vbottom<4>#13	1.90861e-17
C1180	vout#121	vssa#138	6.76415e-16
C1181	vssa#489	vref	8.3223e-17
C1182	vout#225	vbottom<6>#65	3.43058e-17
C1183	vout#79	vbottom<7>#550	7.95669e-17
C1184	vout#126	vout#106	3.58176e-17
C1185	vbottom<6>#74	vssa#138	4.81636e-15
C1186	vout#277	vout#279	3.49973e-17
C1187	vout#50	vbottom<2>#36	2.2908e-15
C1188	vbottom<3>#2	vbottom<3>	2.68293e-17
C1189	vssa#758	vssa#474	2.08759e-17
C1190	XI10/vbsh#33	sample#14	1.13293e-17
C1191	vout#128	vbottom<6>#389	2.70367e-17
C1192	vbottom<5>#122	vbottom<3>#13	2.81951e-16
C1193	vout#119	vbottom<6>#189	2.94458e-17
C1194	vout#53	vbottom<5>#149	2.39278e-15
C1195	vbottom<5>#149	vssa#138	4.38647e-15
C1196	vout#166	vbottom<7>#447	3.43058e-17
C1197	vout#74	vbottom<3>#62	2.21768e-17
C1198	vbottom<7>#672	vssa#138	4.51237e-15
C1199	vout#276	vssa#291	5.90247e-17
C1200	vbottom<5>#13	vssa#138	1.7626e-16
C1201	vout#28	vssa#138	8.6142e-16
C1202	vout#198	vout#180	3.49973e-17
C1203	vssa#138	vbottom<5>#14	7.66099e-16
C1204	vout#187	vbottom<5>#50	2.43454e-15
C1205	vout#88	vbottom<7>#555	1.32706e-16
C1206	vout#264	vbottom<7>#363	5.90217e-17
C1207	vbottom<5>#113	vbottom<4>#17	9.95763e-17
C1208	vout#138	vout#116	3.58176e-17
C1209	vbottom<2>#9	vref	5.02719e-17
C1210	vout#221	vssa#544	4.66683e-17
C1211	vout#94	vout#104	4.03581e-17
C1212	vbottom<3>#53	vssa#138	3.67729e-15
C1213	XI10/vbsh#29	vout#12	1.32322e-16
C1214	vout#229	vbottom<6>#56	2.21768e-17
C1215	vout#123	vssa#138	7.86515e-16
C1216	vout#143	vbottom<7>#696	2.21768e-17
C1217	vout#167	vout#145	3.49973e-17
C1218	vbottom<7>#294	vssa#138	4.61601e-15
C1219	vout#205	vbottom<7>#250	5.09099e-17
C1220	vbottom<7>#578	vssa#138	4.40713e-15
C1221	vout#199	vbottom<7>#264	2.40307e-15
C1222	vout#108	vbottom<6>#252	2.67924e-17
C1223	vout#57	vbottom<0>#18	1.08515e-16
C1224	XI10/vbsl#15	vref	1.90573e-15
C1225	vout#161	vbottom<6>#180	3.02235e-17
C1226	vssa#486	vref	8.3223e-17
C1227	vout#184	vssa#628	3.40614e-17
C1228	vout#104	vbottom<5>#206	2.335e-15
C1229	vout#39	vbottom<1>#13	2.4276e-17
C1230	vssa#767	vssa#446	2.21539e-17
C1231	vbottom<5>#11	vref#70	2.62211e-16
C1232	vbottom<7>#11	ctl<7>#10	3.40075e-18
C1233	vout#181	vbottom<7>#672	5.90217e-17
C1234	vbottom<5>#202	vssa#138	4.63139e-15
C1235	vbottom<7>#646	vbottom<2>#11	2.81951e-16
C1236	vout#127	vbottom<6>#252	2.94458e-17
C1237	vout#164	vssa#138	6.70806e-16
C1238	vssa#800	vssa#636	2.3665e-17
C1239	vout#191	vbottom<6>#440	2.94458e-17
C1240	vout#240	vout#229	4.18065e-17
C1241	vout#208	vbottom<6>#59	5.90278e-17
C1242	vout#220	vbottom<7>#780	2.25142e-15
C1243	vout#133	vout#165	3.49973e-17
C1244	vssa#822	vref	1.10096e-16
C1245	vbottom<4>#86	vssa#138	3.49007e-15
C1246	vbottom<6>#186	vbottom<1>#13	2.81937e-16
C1247	vbottom<2>	vbottom<1>#11	1.73055e-16
C1248	vssa#796	vssa#797	3.49674e-17
C1249	vout#266	vbottom<7>#969	4.14264e-17
C1250	vout#34	vout#54	4.18065e-17
C1251	vout#89	vssa#523	5.52955e-17
C1252	vout#131	vbottom<5>#197	2.94458e-17
C1253	vssa#788	vref	2.11049e-16
C1254	vout#149	vssa#138	7.86881e-16
C1255	vbottom<1>#9	vref	5.00699e-17
C1256	XI10/vbsh#35	sample#15	1.94967e-16
C1257	vout#17	vout#16	3.56638e-17
C1258	vout#227	vbottom<7>#663	3.35485e-17
C1259	XI10/vbsl	vref	2.2509e-16
C1260	sample#12	XI10/enb#16	2.8469e-17
C1261	vout#140	vbottom<6>#129	1.15136e-17
C1262	vssa#772	vref	1.12228e-16
C1263	vssa#804	vout#216	4.05119e-17
C1264	vbottom<5>#134	vref	1.11069e-16
C1265	vout#252	vssa#138	7.71211e-16
C1266	vssa#786	vout#185	4.11102e-17
C1267	vssa#790	vref	1.83296e-16
C1268	vout#88	vssa#520	1.44541e-17
C1269	vout#168	vbottom<7>#210	2.94458e-17
C1270	vssa#813	sample#15	6.61937e-17
C1271	vssa#483	vref	2.43865e-16
C1272	vbottom<2>#14	vref	3.25691e-16
C1273	vout#196	vbottom<7>#279	2.94458e-17
C1274	vout#75	vbottom<4>#83	2.57588e-17
C1275	vout#209	vssa#810	4.18065e-17
C1276	vout#238	vssa#138	6.66904e-16
C1277	vbottom<7>#210	vssa#138	4.6507e-15
C1278	vssa#798	vssa#624	2.36483e-15
C1279	vout#232	vbottom<5>#44	2.2191e-17
C1280	vout#186	vbottom<7>#390	2.25845e-17
C1281	vout#211	vbottom<7>#242	3.85473e-17
C1282	vout#72	vout#81	4.18065e-17
C1283	vssa#758	vbottom<6>#13	4.43898e-17
C1284	vout#175	vbottom<7>#139	2.25845e-17
C1285	vssa#791	vref	2.17127e-16
C1286	vout#151	vbottom<6>#95	2.94458e-17
C1287	vssa#600	vssa#138	4.46932e-15
C1288	vout#194	vbottom<7>#387	5.90217e-17
C1289	vssa#763	vssa#762	3.49664e-17
C1290	vout#57	vout#36	1.22291e-16
C1291	vssa#790	vssa#138	6.73733e-16
C1292	vout#281	vssa#282	4.66683e-17
C1293	XI10/vbsh#28	vref	3.06646e-16
C1294	vout#37	vbottom<6>#376	2.76621e-17
C1295	vout#230	vbottom<6>#364	2.30681e-15
C1296	vssa#766	vssa#453	2.34524e-15
C1297	vssa#819	vssa#820	3.49973e-17
C1298	vbottom<6>#264	vssa#138	4.63783e-15
C1299	vout#246	vbottom<6>#177	2.70367e-17
C1300	vssa#792	vref	1.89732e-16
C1301	vssa#291	vssa#138	4.40804e-15
C1302	net3#9	net3#11	1.24663e-17
C1303	vout#208	vout#223	3.49973e-17
C1304	vbottom<0>#9	vref	5.00159e-17
C1305	vssa#775	vssa#138	5.63017e-16
C1306	vout#44	vbottom<3>#23	1.64895e-17
C1307	vout#235	vout#242	3.49973e-17
C1308	vbottom<3>#15	vssa#138	3.91252e-16
C1309	vout#83	vbottom<5>#191	2.70367e-17
C1310	net3	vref	1.07395e-15
C1311	vout#192	vbottom<7>#210	2.25978e-15
C1312	vout#129	vbottom<6>#95	2.48447e-15
C1313	vout#36	vbottom<2>#36	2.82939e-17
C1314	vbottom<6>#379	vbottom<6>#14	3.76709e-17
C1315	vbottom<5>#131	vref	1.96565e-16
C1316	vout#211	vout#216	3.96617e-17
C1317	vout#145	vbottom<6>#334	2.43755e-15
C1318	vssa#782	vssa#138	5.7258e-16
C1319	vout#275	vssa#453	3.40614e-17
C1320	vssa#793	vref	2.17127e-16
C1321	vssa#219	vssa#210	2.75208e-16
C1322	vout#76	vssa#480	3.40614e-17
C1323	vout#23	vbottom<6>#204	2.41978e-17
C1324	vbottom<7>#537	vssa#138	4.54669e-15
C1325	vbottom<5>#69	vbottom<5>#183	4.05397e-17
C1326	vout#246	vbottom<6>#358	2.94458e-17
C1327	vout#77	vbottom<7>#681	2.43234e-16
C1328	vssa#514	vssa#208	1.41438e-15
C1329	vssa#480	vref	3.4056e-16
C1330	vbottom<1>#14	vref	1.13853e-16
C1331	vout#83	vbottom<4>#35	2.94458e-17
C1332	vbottom<0>#11	vbottom<3>#11	3.38163e-16
C1333	vout#250	vbottom<6>#53	2.2191e-17
C1334	vout#256	vbottom<6>#44	2.21768e-17
C1335	vssa#807	vssa#657	2.27053e-15
C1336	vout#77	vout#90	8.27234e-17
C1337	vout#223	vout#232	3.49973e-17
C1338	vout#273	vbottom<7>#366	3.43058e-17
C1339	vssa#818	vbottom<7>#578	3.64851e-17
C1340	vout#167	vbottom<6>#440	2.37141e-15
C1341	vout#93	vbottom<5>#175	3.43058e-17
C1342	vssa#794	vref	2.17114e-16
C1343	vout#117	vbottom<6>#95	3.36905e-17
C1344	vbottom<7>#218	vbottom<7>#226	4.05222e-17
C1345	vbottom<5>#191	vssa#138	4.63783e-15
C1346	vout#185	vssa#368	4.6427e-17
C1347	vbottom<6>#370	vbottom<2>	3.53678e-17
C1348	vout#12	vref	1.04768e-15
C1349	vout#54	vbottom<5>#146	5.08519e-17
C1350	vout#70	vssa#138	4.93331e-16
C1351	vbottom<7>#98	vssa#138	4.84834e-15
C1352	vssa#821	vssa#822	3.49973e-17
C1353	vssa#800	vbottom<7>#210	3.64851e-17
C1354	vbottom<7>#789	vbottom<7>#14	9.7624e-17
C1355	vbottom<4>#11	vssa#120	2.91855e-17
C1356	vout#278	vssa#288	5.90247e-17
C1357	vssa#795	vref	1.89078e-16
C1358	vout#225	vout#202	4.18065e-17
C1359	net3#11	ctl_dum#10	6.22159e-18
C1360	vbottom<3>#9	vref	5.00878e-17
C1361	vout#191	vssa#138	7.7085e-16
C1362	vssa#796	vssa#612	2.21768e-17
C1363	vout#204	vbottom<1>#11	1.80349e-17
C1364	vbottom<1>#13	vref	1.03861e-15
C1365	vssa#138	vdda	4.09573e-16
C1366	vout#83	vout#82	4.03581e-17
C1367	vbottom<6>#207	vssa#138	4.39227e-15
C1368	vbottom<5>#128	vref	2.60601e-16
C1369	vout#240	vbottom<7>#715	2.21768e-17
C1370	vssa#796	vref	2.17114e-16
C1371	vout#188	vbottom<7>#786	2.77798e-17
C1372	vout#37	vssa#138	7.22781e-16
C1373	vbottom<6>#11	vref#69	2.62197e-16
C1374	vout#261	vbottom<7>#658	2.94458e-17
C1375	vssa#477	vref	2.87196e-16
C1376	vbottom<4>#15	vref	2.75636e-16
C1377	vout#214	vbottom<4>#14	1.03278e-17
C1378	vout#95	vbottom<2>#32	2.94458e-17
C1379	vout#169	vbottom<7>#282	2.94458e-17
C1380	vout#97	vbottom<4>#28	2.43454e-15
C1381	vout#137	vbottom<6>#321	2.31737e-15
C1382	vout#119	vbottom<6>#376	3.02268e-17
C1383	vssa#824	vssa#208	1.39875e-16
C1384	vout#280	vssa#285	5.90247e-17
C1385	vssa#793	vout#173	4.05119e-17
C1386	vout#66	vssa#138	7.40564e-16
C1387	vout#191	vbottom<7>#267	2.31737e-15
C1388	vout#262	vbottom<7>#71	5.90278e-17
C1389	vout#211	vout#199	3.58176e-17
C1390	vbottom<5>#11	vbottom<5>#2	1.63997e-17
C1391	vssa#797	vref	2.14271e-16
C1392	vout#269	vbottom<7>#74	2.2191e-17
C1393	vout#185	vbottom<7>#101	2.4189e-15
C1394	vssa#821	vssa#210	3.44888e-16
C1395	vbottom<4>#17	vref	2.37009e-16
C1396	vout#145	vbottom<6>#222	2.21768e-17
C1397	vout#181	vbottom<6>#399	2.43381e-15
C1398	vout#226	vbottom<4>	1.71614e-17
C1399	vssa#797	vssa#138	7.54429e-16
C1400	vout#22	vbottom<6>#198	2.4886e-15
C1401	vbottom<6>#252	vssa#138	4.8874e-15
C1402	vssa#798	vref	1.9343e-16
C1403	vssa#775	vout#273	4.18065e-17
C1404	vbottom<5>#9	vref	5.03305e-17
C1405	vout#56	vbottom<3>#59	2.21768e-17
C1406	vbottom<0>	vref	9.59533e-16
C1407	vout#203	vssa#138	5.84012e-16
C1408	vssa#756	vbottom<7>#792	3.64851e-17
C1409	vbottom<5>#125	vref	2.62927e-16
C1410	vout#227	vssa#822	4.18065e-17
C1411	vssa#108	ctl<1>#10	2.35049e-17
C1412	vbottom<2>#36	vssa#138	3.46985e-15
C1413	vssa#799	vref	2.17114e-16
C1414	vout#32	vout#30	3.71123e-17
C1415	vout#253	vout#243	4.18065e-17
C1416	vout#132	vbottom<5>#13	1.97338e-17
C1417	vout#83	vssa#138	7.86881e-16
C1418	vbottom<7>#273	vssa#138	4.63139e-15
C1419	vout#145	vbottom<6>#440	2.21768e-17
C1420	vout#217	vout#186	4.18065e-17
C1421	vbottom<6>#13	vdda#30	1.47016e-16
C1422	vssa#474	vref	2.69641e-16
C1423	vssa#792	vbottom<7>#146	3.64851e-17
C1424	vout#218	vout#187	4.18065e-17
C1425	vbottom<2>	vref	1.13538e-15
C1426	vout#243	vbottom<5>#41	3.43058e-17
C1427	vbottom<3>#12	net3	1.0105e-16
C1428	vout#162	vbottom<7>#393	2.25845e-17
C1429	vout#75	vbottom<3>#16	1.97255e-17
C1430	vout#19	vbottom<7>#666	5.33069e-17
C1431	XI10/net2#14	XI10/net2#13	4.696e-18
C1432	vout#267	vbottom<7>#363	2.25845e-17
C1433	vssa#800	vref	1.9055e-16
C1434	XI10/enb#16	vssa#6	2.26982e-17
C1435	vssa#763	vssa#138	4.45324e-16
C1436	vout#158	vbottom<7>#696	5.90278e-17
C1437	vout#13	vout#12	6.20147e-17
C1438	vout#279	vbottom<7>#56	3.92536e-17
C1439	vbottom<6>#334	vssa#138	4.84826e-15
C1440	vout#43	vout#34	9.1794e-17
C1441	vout#169	vbottom<7>#178	2.90578e-17
C1442	vbottom<3>#13	vref	6.38427e-16
C1443	vbottom<5>#110	vbottom<4>#14	8.18903e-17
C1444	vout#259	vout#264	3.49973e-17
C1445	XI10/vbsl#17	sample#14	2.06619e-17
C1446	vssa#764	vbottom<7>#768	3.64851e-17
C1447	vssa#821	vbottom<7>#605	3.64851e-17
C1448	vout#254	vout#244	3.96617e-17
C1449	vout#123	vbottom<6>#308	2.31737e-15
C1450	vbottom<7>#9	ctl<7>#8	8.69314e-18
C1451	vssa#495	vssa#210	2.36393e-15
C1452	vout#257	vssa#138	6.66904e-16
C1453	vssa#801	vref	2.17114e-16
C1454	vbottom<6>#9	vref	5.01636e-17
C1455	vssa#763	vssa#465	2.31023e-17
C1456	vout#281	vbottom<7>#748	2.70367e-17
C1457	vbottom<3>#16	vref	6.33005e-16
C1458	vbottom<4>#22	vref	9.97498e-17
C1459	vbottom<4>#86	vbottom<2>	3.53752e-17
C1460	vout#186	vssa#138	6.66478e-16
C1461	vbottom<7>#363	vssa#138	4.53336e-15
C1462	vout#134	vbottom<7>#501	2.21768e-17
C1463	vout#142	vbottom<1>#13	1.85957e-17
C1464	vout#202	vbottom<5>#53	3.43058e-17
C1465	vout#195	vbottom<3>#53	2.93933e-17
C1466	vout#98	vout#132	3.58176e-17
C1467	vssa#751	vssa#499	2.63088e-17
C1468	vbottom<5>#122	vref	2.58371e-16
C1469	vout#60	vbottom<6>#210	1.64895e-17
C1470	vssa#802	vref	1.88259e-16
C1471	vbottom<5>#47	vssa#138	4.51244e-15
C1472	vssa#785	vssa#324	2.36317e-15
C1473	vout#274	vbottom<7>#360	2.42764e-15
C1474	vssa#768	vbottom<7>#56	3.64851e-17
C1475	vssa#818	vssa#208	1.37238e-16
C1476	vssa#471	vref	2.60402e-16
C1477	vout#65	vout#56	3.65289e-17
C1478	vout#130	vbottom<4>#28	2.2191e-17
C1479	vout#280	vssa#138	6.56442e-16
C1480	vbottom<4>#14	vref	7.69413e-16
C1481	vout#170	vbottom<7>#285	2.94458e-17
C1482	vout#238	vbottom<7>#381	2.42764e-15
C1483	vout#16	vbottom<7>#897	2.70367e-17
C1484	vbottom<6>#376	vssa#138	3.60348e-15
C1485	vout#108	vbottom<5>#59	2.94458e-17
C1486	vssa#784	vbottom<7>#95	3.64851e-17
C1487	vssa#517	vssa#210	2.70576e-15
C1488	vout#22	vout#27	3.49973e-17
C1489	vbottom<4>#48	vssa#138	4.33508e-15
C1490	vssa#453	vssa#138	4.46276e-15
C1491	vssa#803	vref	2.17114e-16
C1492	vout#174	vssa#600	3.40614e-17
C1493	vout#132	vssa#758	4.05119e-17
C1494	vbottom<7>#765	vssa#138	4.62744e-15
C1495	vout#18	vbottom<6>#393	2.9443e-17
C1496	vout#112	vssa#138	6.79158e-16
C1497	vref#59	vref#58	2.49999e-17
C1498	ctl<4>#10	vbottom<4>#9	1.30003e-17
C1499	vbottom<4>	vref	8.02632e-16
C1500	vbottom<6>#53	vssa#138	4.51244e-15
C1501	vout#173	vbottom<7>#162	2.70367e-17
C1502	vout#140	vout#96	4.18065e-17
C1503	vssa#804	vssa#138	6.66335e-16
C1504	XI10/vbsl	XI10/vbsh#22	6.05468e-17
C1505	vout#80	vout#91	4.18065e-17
C1506	vssa#804	vref	2.17127e-16
C1507	ctl_dum#10	vssa#45	1.7893e-17
C1508	vout#189	vbottom<7>#669	2.21768e-17
C1509	vbottom<0>#11	ctl<0>#8	2.78004e-18
C1510	vbottom<7>#9	vref	5.09981e-17
C1511	vout#227	vout#16	3.49973e-17
C1512	vbottom<5>#128	vssa#138	3.49007e-15
C1513	vbottom<5>#14	vref	6.0896e-16
C1514	vout#132	vbottom<7>#783	2.57588e-17
C1515	vout#102	vbottom<6>#207	2.39155e-15
C1516	vout#181	vssa#138	6.79617e-16
C1517	vbottom<5>#113	vref	2.10476e-17
C1518	vssa#101	vssa#100	4.38474e-17
C1519	vssa#215	vssa#138	1.07067e-16
C1520	vssa#805	vref	1.57269e-16
C1521	vout#33	vbottom<6>#392	2.94458e-17
C1522	vout#236	vbottom<7>#715	5.90278e-17
C1523	vssa#468	vref	2.66197e-16
C1524	vout#91	vout#69	3.49973e-17
C1525	vssa#755	vssa#486	2.34524e-15
C1526	vout#135	vssa#138	6.79158e-16
C1527	vbottom<5>#15	vref	5.30884e-16
C1528	vout#21	vout#16	3.96617e-17
C1529	vbottom<3>#53	vbottom<4>#15	5.44774e-17
C1530	vout#204	vbottom<6>#370	2.94458e-17
C1531	vout#44	vbottom<1>#18	3.43058e-17
C1532	vssa#514	sample	3.03027e-17
C1533	vssa#477	vbottom<5>#13	3.18154e-16
C1534	vssa#807	vref	2.28284e-16
C1535	vssa#636	vssa#138	4.4388e-15
C1536	XI10/vbsl#19	XI10/vbsh#22	3.88699e-16
C1537	vssa#756	vssa#138	4.47176e-16
C1538	vbottom<6>#14	vref	4.29041e-16
C1539	vout#252	vbottom<7>#655	2.94458e-17
C1540	vout#183	vbottom<7>#270	2.31737e-15
C1541	vbottom<6>#370	vbottom<1>#13	1.15069e-16
C1542	vssa#760	vssa#468	2.08759e-17
C1543	vout#43	vssa#138	4.8166e-16
C1544	vout#27	vbottom<6>#393	4.14172e-17
C1545	vssa#823	vref	1.10096e-16
C1546	vout#65	vbottom<4>#35	2.4275e-15
C1547	vssa#318	vssa#138	4.41041e-15
C1548	vout#129	vout#128	4.03581e-17
C1549	vssa#786	vref	1.08194e-16
C1550	vout#50	vssa#138	5.9278e-16
C1551	vout#194	vbottom<6>#91	2.27271e-17
C1552	vout#203	vout#219	3.58176e-17
C1553	XI10/vbsl#17	vref	6.6144e-16
C1554	vbottom<6>#129	vssa#138	5.15472e-16
C1555	vbottom<6>#15	vref	3.50924e-16
C1556	vssa#535	vssa#138	4.37433e-15
C1557	vout#262	vout#267	3.49788e-17
C1558	vout#199	vbottom<7>#242	5.09099e-17
C1559	vssa#771	vref	1.25441e-16
C1560	vout#63	vbottom<2>#32	2.2908e-15
C1561	vout#65	vout#64	4.03554e-17
C1562	vout#239	vbottom<5>#106	2.70367e-17
C1563	vout#154	vssa#138	7.86881e-16
C1564	vout#279	vssa#767	4.05119e-17
C1565	vbottom<4>#11	vdda	1.13575e-16
C1566	vbottom<7>#356	vssa#138	4.94824e-15
C1567	vssa#511	sample	1.80918e-16
C1568	vout#7	vdda#21	3.90192e-16
C1569	vout#171	vbottom<7>#288	2.94458e-17
C1570	vbottom<2>#14	vbottom<1>#14	1.03626e-16
C1571	vssa#465	vref	3.23235e-16
C1572	vout#69	vbottom<6>#213	3.43058e-17
C1573	vbottom<7>#14	vref	2.62603e-16
C1574	vout#133	vbottom<7>#587	3.35485e-17
C1575	vout#190	vbottom<7>#250	5.90278e-17
C1576	net3#11	vdda	2.60755e-16
C1577	vbottom<3>#53	vbottom<4>#14	5.34019e-17
C1578	vssa#768	vssa#278	2.52128e-17
C1579	vout#142	vout#179	3.58176e-17
C1580	vout#142	vbottom<6>#183	2.57588e-17
C1581	vout#220	vbottom<1>#11	1.36583e-17
C1582	vbottom<4>#35	vssa#138	4.32192e-15
C1583	vout#246	vbottom<6>#47	5.09068e-17
C1584	vssa#446	vssa#138	4.17254e-15
C1585	vbottom<1>#22	vbottom<2>	8.62217e-17
C1586	vout#163	vbottom<6>#91	2.41046e-15
C1587	vout#176	vbottom<5>#56	3.43058e-17
C1588	vout#218	vssa#138	6.76427e-16
C1589	vbottom<7>#15	vref	1.94118e-16
C1590	vbottom<1>#4	vssa#1	1.57337e-17
C1591	vbottom<5>#128	vbottom<3>#16	2.68607e-17
C1592	vout#177	vbottom<4>#14	3.87112e-17
C1593	vbottom<6>#177	vbottom<4>	2.94929e-16
C1594	vout#202	vout#218	3.49973e-17
C1595	vssa#786	vssa#785	3.49973e-17
C1596	ctl<2>#10	ctl<2>#8	2.72711e-17
C1597	vout#173	vssa#138	6.44838e-16
C1598	vssa#508	sample	1.80918e-16
C1599	vout#214	vbottom<5>#110	2.42926e-15
C1600	vout#94	vbottom<4>#73	2.94458e-17
C1601	vout#94	vbottom<5>#202	2.31737e-15
C1602	vssa#809	vssa#810	3.49973e-17
C1603	vssa#474	vbottom<3>#15	2.85502e-16
C1604	vbottom<1>#9	ctl<1>#8	8.77383e-18
C1605	vbottom<3>#12	vref	7.48973e-16
C1606	vssa#468	vbottom<1>#11	3.72121e-17
C1607	vout#235	vout#222	4.18065e-17
C1608	vout#203	vbottom<4>	1.97255e-17
C1609	vout#250	vout#239	4.18065e-17
C1610	vout#264	vssa#138	6.76066e-16
C1611	vout#98	vout#51	4.03581e-17
C1612	vbottom<6>#423	vssa#138	4.63139e-15
C1613	vout#163	vbottom<7>#390	5.90217e-17
C1614	vssa#758	vssa#757	3.49664e-17
C1615	vssa#462	vref	1.80486e-16
C1616	vout#139	vbottom<6>#91	2.28647e-17
C1617	vbottom<3>#15	vref	1.04855e-15
C1618	vbottom<5>#131	vbottom<5>#14	9.60843e-17
C1619	vssa#811	vssa#541	2.21768e-17
C1620	vout#245	vbottom<7>#381	2.26006e-17
C1621	vssa#776	vssa#297	2.35855e-15
C1622	vout#67	vbottom<6>#192	2.94458e-17
C1623	vout#37	vout#27	4.03581e-17
C1624	vout#114	vbottom<7>#459	2.21768e-17
C1625	vout#231	vssa#138	6.66904e-16
C1626	vout#134	vssa#529	5.90278e-17
C1627	vout#35	vout#46	3.58176e-17
C1628	vbottom<7>#250	vssa#138	1.3989e-14
C1629	vbottom<5>#106	vref	1.25837e-16
C1630	vout#119	vbottom<5>#14	3.58425e-17
C1631	vout#267	vbottom<7>#68	5.90278e-17
C1632	vbottom<7>#459	vbottom<7>#447	2.94976e-17
C1633	vout#132	vbottom<6>#14	1.19759e-17
C1634	vout#174	vout#173	3.96617e-17
C1635	vssa#505	sample	1.80918e-16
C1636	vssa#208	vref	6.23965e-15
C1637	vout#234	vbottom<6>#180	2.30557e-17
C1638	vout#246	vout#252	3.58176e-17
C1639	vout#76	vbottom<7>#789	2.25227e-15
C1640	vout#41	vbottom<3>#16	1.73839e-17
C1641	vout#126	vout#125	4.03581e-17
C1642	vdda#6	XI10/enb#23	1.79983e-17
C1643	vout#133	vssa#138	5.60782e-16
C1644	vout#175	vbottom<7>#117	2.42374e-15
C1645	vout#172	vbottom<7>#291	2.94458e-17
C1646	vbottom<7>#77	vssa#138	4.51244e-15
C1647	vout#100	vout#133	3.49973e-17
C1648	vout#160	vbottom<7>#202	2.94458e-17
C1649	vssa#811	vssa#535	2.21768e-17
C1650	vssa#802	vssa#640	2.36465e-15
C1651	vbottom<7>#663	vbottom<7>#614	2.94985e-17
C1652	vssa#813	vssa#814	3.49973e-17
C1653	vssa#483	vbottom<7>#15	1.23174e-16
C1654	vout#277	vbottom<7>#59	5.16094e-17
C1655	vout#258	vbottom<7>#768	2.94458e-17
C1656	vbottom<7>#640	vbottom<5>#14	7.14612e-17
C1657	vout#198	vssa#138	6.79158e-16
C1658	vout#41	vbottom<3>#20	2.94458e-17
C1659	vout#100	vbottom<7>#569	2.33777e-15
C1660	vout#189	vout#210	3.49973e-17
C1661	vssa#800	vssa#628	2.21768e-17
C1662	vbottom<6>#186	vssa#138	2.0196e-15
C1663	vssa#459	vref	8.3223e-17
C1664	XI10/net2#32	XI10/enb#14	1.4718e-17
C1665	vssa#502	sample	1.80918e-16
C1666	vout#276	vout#278	3.49973e-17
C1667	vout#130	vbottom<3>#59	3.43058e-17
C1668	vssa#480	vbottom<7>#13	3.4616e-16
C1669	vout#83	vbottom<5>#69	3.19307e-17
C1670	vout#179	vbottom<0>#11	1.95199e-17
C1671	vout#17	vssa#138	7.19422e-16
C1672	vout#165	vssa#514	5.90217e-17
C1673	vout#45	net3#17	2.2772e-17
C1674	vout#28	vbottom<4>#95	2.50498e-17
C1675	vssa#804	vssa#652	2.3665e-17
C1676	vout#247	vout#236	4.18065e-17
C1677	vssa#817	vssa#523	2.09039e-17
C1678	vssa#799	vssa#800	3.49674e-17
C1679	vout#48	vssa#138	5.58443e-16
C1680	vout#48	vout#53	4.18065e-17
C1681	vbottom<7>#154	vssa#138	4.6507e-15
C1682	vout#168	vbottom<7>#273	2.31737e-15
C1683	vout#273	vbottom<7>#71	2.2191e-17
C1684	vout#245	vbottom<7>#721	3.43058e-17
C1685	XI10/vbsh#22	vdda#21	1.53411e-16
C1686	vssa#822	vssa#502	2.21831e-17
C1687	vout#180	vssa#812	4.18065e-17
C1688	vin#9	vout#8	1.42814e-16
C1689	vout#241	vbottom<7>#652	2.94458e-17
C1690	vout#192	vssa#138	6.44838e-16
C1691	vssa#210	vref	8.04803e-15
C1692	vbottom<7>#390	vssa#138	4.53336e-15
C1693	vin#10	vout#5	5.486e-17
C1694	vssa#499	sample	1.80918e-16
C1695	vout#206	vbottom<7>#234	2.90578e-17
C1696	vssa#780	vout#249	4.18065e-17
C1697	vout#55	vbottom<5>#189	4.95413e-17
C1698	vout#50	vbottom<0>#18	2.94458e-17
C1699	vout#87	vssa#138	6.24706e-16
C1700	vssa#456	vref	8.3223e-17
C1701	vbottom<6>#411	vssa#138	4.63783e-15
C1702	vssa#754	vssa#493	2.3666e-17
C1703	vbottom<7>#162	vbottom<7>#170	4.05222e-17
C1704	vbottom<3>#20	vssa#138	3.95618e-15
C1705	vbottom<6>#367	vbottom<1>#11	2.9857e-17
C1706	vbottom<7>#792	vssa#138	4.19961e-15
C1707	vout#86	vssa#138	7.90164e-16
C1708	vout#214	vbottom<4>#82	2.76223e-17
C1709	vout#239	vbottom<5>#41	2.2191e-17
C1710	vout#182	vbottom<7>#264	2.41086e-15
C1711	vbottom<6>#80	vssa#138	4.78016e-15
C1712	vout#138	vout#146	4.03581e-17
C1713	vout#173	vbottom<7>#294	2.94458e-17
C1714	vout#50	vout#75	3.58176e-17
C1715	vbottom<7>#13	vbottom<7>#15	1.91781e-17
C1716	vssa#208	vssa#209	3.51544e-17
C1717	vout#44	vbottom<4>#101	4.21003e-17
C1718	vout#45	vbottom<2>#32	2.82939e-17
C1719	vout#176	vbottom<6>#126	3.79562e-17
C1720	vout#21	vbottom<7>#897	2.32591e-15
C1721	vbottom<5>#155	vssa#138	4.51243e-15
C1722	vout#255	vbottom<7>#80	2.43454e-15
C1723	vout#157	vbottom<7>#675	2.43457e-15
C1724	XI10/vbsh#33	XI10/vbsh#29	1.55055e-16
C1725	vout#281	vbottom<7>#59	2.26003e-17
C1726	vssa#779	vssa#303	2.25845e-17
C1727	vbottom<7>#678	vssa#138	4.51237e-15
C1728	vbottom<4>#22	vbottom<4>#15	2.5925e-17
C1729	vssa#138	vbottom<4>#13	1.0258e-15
C1730	vout#232	vssa#138	6.76265e-16
C1731	vssa#495	sample	1.80918e-16
C1732	vbottom<0>	vssa#138	8.49426e-16
C1733	vout#76	vref	1.65672e-17
C1734	vssa#805	vssa#144	6.42664e-17
C1735	vout#271	vbottom<7>#65	5.90278e-17
C1736	vssa#814	vssa#815	3.49973e-17
C1737	vout#177	vout#95	4.03581e-17
C1738	vbottom<4>	vbottom<4>#13	5.66652e-17
C1739	vbottom<3>#59	vssa#138	4.24447e-15
C1740	vout#120	vbottom<7>#681	2.21818e-17
C1741	vout#108	vssa#138	8.38773e-16
C1742	vssa#453	vref	8.3223e-17
C1743	vout#184	vbottom<7>#202	2.25978e-15
C1744	vout#274	vbottom<7>#62	5.90278e-17
C1745	vout#188	vssa#474	3.40614e-17
C1746	vout#145	vout#158	4.18065e-17
C1747	vout#42	vref	1.42427e-17
C1748	vssa#499	vssa#219	1.72539e-17
C1749	vbottom<7>#11	vbottom<7>#9	1.22926e-17
C1750	vbottom<7>#774	vbottom<3>#12	2.78937e-16
C1751	vbottom<6>#361	vbottom<4>#13	1.16116e-17
C1752	vbottom<4>#48	vbottom<4>#59	3.856e-17
C1753	vout#279	vbottom<7>#356	2.2191e-17
C1754	vbottom<7>#226	vbottom<7>#234	4.05222e-17
C1755	vout#270	vssa#138	6.44928e-16
C1756	vbottom<7>#663	vssa#138	4.81214e-15
C1757	vssa#796	vout#170	4.05119e-17
C1758	vbottom<5>#210	vssa#138	4.56915e-15
C1759	vout#37	vout#51	3.58176e-17
C1760	vout#124	vout#111	3.96617e-17
C1761	XI10/net2#35	vdda#24	4.70377e-17
C1762	vssa#763	vbottom<4>#13	4.47766e-17
C1763	vout#176	vout#202	3.49973e-17
C1764	vssa#778	vssa#138	5.63007e-16
C1765	vout#42	vbottom<7>#795	2.90578e-17
C1766	vout#193	vout#179	3.96617e-17
C1767	vout#167	vout#182	4.18065e-17
C1768	vout#240	vbottom<6>#59	3.43058e-17
C1769	vssa#471	vbottom<2>#11	3.72121e-17
C1770	vbottom<5>#175	vbottom<5>#206	3.60301e-17
C1771	vout#162	vout#186	3.49788e-17
C1772	vbottom<4>#92	vssa#138	4.57705e-15
C1773	vssa#760	vbottom<1>#11	2.97626e-17
C1774	vdda#30	sample	3.41735e-16
C1775	sample#15	sample#12	3.61418e-17
C1776	vssa#785	vssa#138	5.72215e-16
C1777	vout#212	vbottom<7>#777	2.92015e-17
C1778	vbottom<7>#780	vbottom<0>#11	3.1126e-16
C1779	vout#234	vbottom<6>#361	2.94458e-17
C1780	vout#174	vbottom<7>#297	2.94458e-17
C1781	vout#144	vbottom<6>#399	2.29007e-17
C1782	vssa#450	vref	8.3223e-17
C1783	vout#176	vout#118	4.18065e-17
C1784	vout#25	vbottom<5>#140	2.50498e-17
C1785	vout#35	vbottom<5>#137	4.14172e-17
C1786	vssa#213	vref	4.22137e-17
C1787	vbottom<7>#628	vssa#138	4.63149e-15
C1788	vout#250	vbottom<5>#38	3.43058e-17
C1789	vout#253	vbottom<7>#712	2.43454e-15
C1790	vout#58	vbottom<5>#134	3.10294e-17
C1791	vout#116	vout#123	4.03581e-17
C1792	vout#139	vbottom<7>#393	5.87773e-17
C1793	vssa#809	vref	1.11424e-16
C1794	vssa#757	vssa#480	2.46302e-15
C1795	vout#134	vssa#138	6.76436e-16
C1796	vbottom<6>#367	net3#11	2.93809e-16
C1797	vout#114	vbottom<6>#219	3.43058e-17
C1798	vout#229	vbottom<6>#62	2.2191e-17
C1799	vbottom<1>#22	vbottom<1>#13	4.36399e-17
C1800	vssa#211	vref	6.81102e-17
C1801	vout#214	vout#226	3.49973e-17
C1802	vout#182	vbottom<7>#242	5.90309e-17
C1803	vout#111	vbottom<5>#131	3.02268e-17
C1804	vssa#788	vssa#331	2.27559e-15
C1805	vssa#824	vref	1.00377e-16
C1806	vssa#608	vssa#138	4.4388e-15
C1807	vssa#793	vssa#608	2.3665e-17
C1808	vout#160	vbottom<7>#276	2.31737e-15
C1809	vssa#785	vref	1.25441e-16
C1810	vout#198	vssa#811	4.18065e-17
C1811	vout#162	vout#152	3.56638e-17
C1812	vout#103	vbottom<6>#216	2.21768e-17
C1813	vout#44	vbottom<3>#29	2.16626e-17
C1814	vbottom<5>#122	vbottom<4>	2.68607e-17
C1815	vout#79	vout#90	4.18065e-17
C1816	vbottom<6>#275	vssa#138	4.63139e-15
C1817	vssa#108	vssa#1	1.11589e-17
C1818	vssa#778	vout#260	4.18065e-17
C1819	vout#217	vbottom<7>#98	2.2191e-17
C1820	vssa#215	vref	4.24388e-17
C1821	vbottom<2>#22	vssa#138	3.80091e-15
C1822	vssa#297	vssa#138	4.44264e-15
C1823	vout#193	vbottom<6>#367	2.30029e-15
C1824	vssa#770	vref	1.88979e-16
C1825	vout#113	vout#120	4.18065e-17
C1826	vout#230	vbottom<7>#649	2.94458e-17
C1827	vout#124	vbottom<5>#128	2.57588e-17
C1828	vout#26	vssa#138	8.18447e-16
C1829	vout#237	vout#244	3.58176e-17
C1830	vout#106	vout#105	4.03581e-17
C1831	vbottom<5>#15	vssa#138	6.29977e-16
C1832	vssa#765	vssa#459	2.3666e-17
C1833	XI10/vbsl#19	vref	6.31491e-16
C1834	vssa#217	vref	4.43614e-17
C1835	net3#11	vssa#116	2.91855e-17
C1836	vout#182	vbottom<7>#447	8.05014e-17
C1837	vout#228	vout#207	4.18065e-17
C1838	vout#211	vssa#644	3.40614e-17
C1839	vout#36	vout#50	3.58176e-17
C1840	vout#137	vssa#138	7.55189e-16
C1841	vssa#768	vref	1.02847e-16
C1842	vout#130	vout#164	3.49973e-17
C1843	vout#266	vbottom<7>#658	2.31737e-15
C1844	vout#117	vout#108	3.56638e-17
C1845	vout#204	vbottom<0>#11	3.87599e-17
C1846	vout#136	vbottom<6>#201	2.21768e-17
C1847	vout#257	vbottom<7>#372	2.42764e-15
C1848	vout#279	vout#275	3.96617e-17
C1849	vssa#446	vref	8.3223e-17
C1850	vout#203	vbottom<5>#125	2.57588e-17
C1851	XI10/vbsh#29	vref	3.61967e-16
C1852	vssa#767	vssa#766	3.49664e-17
C1853	vout#132	vssa#138	4.35102e-17
C1854	vout#27	vbottom<6>#379	2.70367e-17
C1855	vssa#757	vbottom<6>#13	4.0311e-17
C1856	vout#276	vbottom<7>#68	2.2191e-17
C1857	vout#217	vssa#321	5.90247e-17
C1858	vssa#799	vbottom<7>#202	3.64851e-17
C1859	vssa#767	vref	1.18323e-16
C1860	vout#194	vbottom<6>#126	2.34149e-17
C1861	vout#111	vbottom<1>#13	1.80349e-17
C1862	vssa#753	vssa#751	3.61262e-17
C1863	vout#109	vssa#138	5.72881e-16
C1864	vbottom<7>#117	vssa#138	4.62958e-15
C1865	vssa#809	vbottom<7>#250	3.64851e-17
C1866	vout#13	vref	3.88174e-17
C1867	vout#109	vout#45	4.18065e-17
C1868	vssa#766	vref	1.18323e-16
C1869	vout#78	vout#77	7.4616e-17
C1870	vout#174	vout#152	3.65289e-17
C1871	vout#148	vssa#138	7.86881e-16
C1872	vssa#45	vssa#46	2.15015e-17
C1873	vout#72	vbottom<4>#61	2.77606e-17
C1874	vbottom<6>#213	vssa#138	4.38641e-15
C1875	vout#53	vbottom<6>#213	5.15868e-17
C1876	vbottom<1>#2	vref#53	3.77308e-17
C1877	vout#280	vbottom<7>#62	2.2191e-17
C1878	vout#135	vout#114	3.49973e-17
C1879	vout#226	vbottom<5>#122	2.57588e-17
C1880	vssa#211	vssa#146	1.02841e-16
C1881	vssa#219	vref	3.45022e-17
C1882	vout#255	vout#245	4.18065e-17
C1883	vbottom<0>#18	vref	1.61759e-16
C1884	vssa#765	vref	1.18323e-16
C1885	vssa#762	vssa#462	2.08759e-17
C1886	vout#41	vbottom<4>#92	4.14172e-17
C1887	vout#241	vssa#138	7.27194e-16
C1888	vout#55	vout#62	4.18065e-17
C1889	vout#165	vbottom<7>#578	2.21768e-17
C1890	vbottom<6>#183	vbottom<1>#13	3.53752e-17
C1891	vbottom<7>#649	net3#11	3.53752e-17
C1892	vout#25	vout#23	3.71123e-17
C1893	vref#76	vref	4.12848e-15
C1894	vssa#820	vssa#514	2.2188e-17
C1895	vout#71	vbottom<5>#152	2.43458e-15
C1896	vout#156	vbottom<7>#693	3.43058e-17
C1897	vssa#821	vssa#508	2.3635e-15
C1898	vout#170	vbottom<7>#170	2.90578e-17
C1899	vssa#223	vref	3.84141e-17
C1900	vout#243	vbottom<6>#53	2.43454e-15
C1901	vout#225	vssa#138	7.32082e-16
C1902	vout#167	vbottom<7>#267	2.94458e-17
C1903	vout#261	vout#252	4.03581e-17
C1904	vout#29	vbottom<7>#792	2.70367e-17
C1905	vssa#764	vref	1.18323e-16
C1906	vout#237	vout#212	4.03581e-17
C1907	vout#170	vssa#616	3.40614e-17
C1908	vout#176	vbottom<6>#68	2.43454e-15
C1909	vout#87	vbottom<6>#186	2.57561e-17
C1910	vssa#761	vbottom<7>#777	2.04841e-17
C1911	XI10/vbsl#15	sample#14	1.186e-17
C1912	vssa#511	vssa#208	1.41438e-15
C1913	vssa#117	vssa#1	4.36473e-17
C1914	vref#75	vref	8.58654e-16
C1915	vssa#791	vssa#138	7.54884e-16
C1916	ctl_dum#10	vssa#117	1.42509e-17
C1917	vout#57	vout#34	3.63841e-17
C1918	vssa#221	vref	3.83847e-17
C1919	vout#208	vbottom<5>#47	2.43454e-15
C1920	vssa#763	vref	1.61656e-16
C1921	vbottom<6>#376	vbottom<6>#14	9.60843e-17
C1922	vbottom<7>#13	vdda#30	1.50486e-16
C1923	vout#89	vbottom<7>#537	2.16626e-17
C1924	vout#273	vssa#138	6.7639e-16
C1925	vout#278	vbottom<7>#65	2.2191e-17
C1926	vref#74	vref	6.16768e-16
C1927	vbottom<7>#56	vssa#138	4.57499e-15
C1928	vout#67	vbottom<6>#379	3.10294e-17
C1929	vout#49	vbottom<2>#22	2.59959e-17
C1930	vbottom<7>#786	vbottom<6>#13	2.64512e-16
C1931	vssa#790	vssa#368	2.28319e-15
C1932	vssa#791	vssa#792	3.49674e-17
C1933	vssa#762	vref	2.28062e-16
C1934	vout#132	vout#76	3.96617e-17
C1935	vout#235	vssa#138	6.7639e-16
C1936	vout#233	vbottom<7>#378	5.90217e-17
C1937	vbottom<7>#282	vssa#138	4.63783e-15
C1938	vout#235	vbottom<7>#89	2.43454e-15
C1939	vbottom<4>#13	vdda	1.47016e-16
C1940	vout#240	vbottom<7>#721	2.2191e-17
C1941	vout#251	vout#257	3.49788e-17
C1942	vref#73	vref	4.36111e-16
C1943	vout#214	vbottom<4>	2.03054e-17
C1944	vin#9	vout#5	5.09735e-17
C1945	vout#150	vout#128	3.58176e-17
C1946	vout#110	vbottom<5>#197	2.31085e-15
C1947	vout#258	vbottom<7>#655	2.31737e-15
C1948	vout#171	vout#170	3.96617e-17
C1949	vbottom<2>#11	ctl<2>#10	2.60784e-18
C1950	vssa#767	vbottom<7>#748	3.64851e-17
C1951	vbottom<7>#943	vbottom<7>#663	3.60301e-17
C1952	vssa#761	vref	2.15621e-16
C1953	vout#217	vbottom<7>#92	2.21768e-17
C1954	vssa#770	vssa#138	4.53304e-16
C1955	vout#178	vbottom<7>#279	2.31085e-15
C1956	vout#54	vbottom<4>#98	2.38365e-15
C1957	vout#219	vbottom<6>#183	2.57601e-17
C1958	vout#16	vbottom<7>#896	2.28992e-15
C1959	vbottom<7>#614	vbottom<7>#605	3.6031e-17
C1960	vbottom<4>	vbottom<4>#14	1.1387e-15
C1961	vbottom<7>#2	vbottom<7>	2.6877e-17
C1962	vssa#791	vssa#596	2.3713e-15
C1963	vout#198	vbottom<7>#483	8.05014e-17
C1964	vref#72	vref	4.52386e-16
C1965	vssa#331	vssa#138	3.79602e-15
C1966	vbottom<7>#706	vssa#138	4.51244e-15
C1967	vout#79	vssa#138	4.96044e-16
C1968	vin#10	vin#11	1.71833e-17
C1969	vssa#760	vref	2.16464e-16
C1970	vout#193	vbottom<7>#646	2.94458e-17
C1971	vbottom<6>#367	vbottom<2>	2.81951e-16
C1972	vout#98	vbottom<7>#786	2.94458e-17
C1973	vout#279	vbottom<7>#762	2.70367e-17
C1974	vout#174	vbottom<7>#154	2.70367e-17
C1975	vssa#775	vssa#294	2.35626e-15
C1976	vref#71	vref	6.70607e-16
C1977	vout#199	vssa#138	6.99567e-16
C1978	vbottom<7>#369	vssa#138	4.53336e-15
C1979	vbottom<5>#4	vssa#97	1.89594e-17
C1980	vout#26	vbottom<5>#140	2.49217e-15
C1981	vout#62	vout#48	3.58176e-17
C1982	vssa#780	vssa#306	2.21768e-17
C1983	net3#17	vref	1.80636e-16
C1984	vout#267	vbottom<7>#709	3.43058e-17
C1985	vbottom<5>#53	vssa#138	4.51244e-15
C1986	vssa#759	vref	2.09357e-16
C1987	vout#60	vbottom<6>#216	2.16626e-17
C1988	vout#249	vout#255	3.49973e-17
C1989	vout#27	vssa#138	7.15026e-16
C1990	vbottom<7>#643	vbottom<2>#11	3.86904e-17
C1991	vssa#783	vssa#321	2.21768e-17
C1992	vref#70	vref	8.96427e-16
C1993	vbottom<2>#9	vbottom<2>#11	1.14167e-17
C1994	ctl<0>#10	vssa#104	2.72822e-17
C1995	vbottom<7>#652	vbottom<4>#13	3.37328e-16
C1996	vssa#459	vssa#138	4.46276e-15
C1997	vout#197	vssa#820	4.18065e-17
C1998	vout#193	vout#212	3.58176e-17
C1999	vssa#758	vref	2.03903e-16
C2000	vbottom<7>#771	vssa#138	4.04307e-15
C2001	vout#55	vssa#138	7.47722e-16
C2002	vbottom<7>#194	vssa#138	4.65312e-15
C2003	vout#244	vssa#762	4.05119e-17
C2004	vssa#773	vout#278	4.18065e-17
C2005	vout#187	vbottom<4>#25	3.43058e-17
C2006	vbottom<6>#376	vbottom<5>#14	2.68607e-17
C2007	vbottom<6>#59	vssa#138	4.51244e-15
C2008	vref#69	vref	9.12699e-16
C2009	vout#178	vbottom<7>#194	2.94458e-17
C2010	vout#264	vbottom<7>#709	2.2191e-17
C2011	vout#88	vbottom<7>#569	3.04986e-16
C2012	vssa#798	vssa#138	7.51057e-16
C2013	vssa#783	vssa#315	2.21768e-17
C2014	vssa#757	vref	1.7535e-16
C2015	vout#242	vout#231	4.18065e-17
C2016	vbottom<5>#134	vssa#138	4.21056e-15
C2017	vout#37	vbottom<6>#195	2.94458e-17
C2018	vbottom<7>#655	vssa#138	4.63149e-15
C2019	vout#124	vssa#138	5.73653e-16
C2020	vout#246	vbottom<5>#38	2.94458e-17
C2021	vout#197	vbottom<7>#596	2.42321e-15
C2022	vout#28	vout#26	3.71123e-17
C2023	vssa#756	vref	1.29527e-16
C2024	vout#164	vbottom<4>#25	2.2191e-17
C2025	vout#84	vbottom<4>#31	2.94458e-17
C2026	vout#82	vssa#138	7.86881e-16
C2027	vout#41	vout#58	3.58176e-17
C2028	vbottom<7>#483	vssa#138	4.51049e-15
C2029	vssa#810	vssa#544	2.21768e-17
C2030	vout#27	vbottom<6>#392	2.38353e-15
C2031	vout#150	vout#149	4.03581e-17
C2032	vbottom<6>#126	vssa#138	4.05097e-15
C2033	vout#220	vbottom<0>#11	2.45344e-17
C2034	vout#248	vbottom<7>#652	2.31209e-15
C2035	vbottom<5>#175	vssa#138	4.51049e-15
C2036	vssa#644	vssa#138	4.4388e-15
C2037	vssa#755	vref	1.18323e-16
C2038	vssa#514	vssa#210	2.70577e-15
C2039	vssa#804	vssa#644	2.21768e-17
C2040	vout#116	vbottom<6>#423	2.94458e-17
C2041	vout#81	vbottom<5>#189	3.35516e-17
C2042	vout#242	vout#249	3.49973e-17
C2043	vout#39	net3	1.81333e-17
C2044	vout#88	vssa#138	1.44794e-16
C2045	vssa#324	vssa#138	4.38716e-15
C2046	vssa#797	vssa#624	2.3665e-17
C2047	vbottom<6>#114	vbottom<6>#129	2.95212e-17
C2048	vssa#754	vref	1.18323e-16
C2049	vout#102	vbottom<5>#143	3.43058e-17
C2050	vout#247	vssa#138	6.76431e-16
C2051	vout#123	vbottom<6>#428	2.94458e-17
C2052	vssa#146	vssa#138	1.50319e-16
C2053	vout#271	vout#264	4.18065e-17
C2054	vout#92	vbottom<4>#95	3.43058e-17
C2055	vout#183	vbottom<6>#434	2.94458e-17
C2056	vssa#802	vssa#803	3.49674e-17
C2057	vout#88	vssa#523	1.61145e-17
C2058	vout#20	vout#210	4.18065e-17
C2059	vssa#541	vssa#138	4.37433e-15
C2060	vout#102	vout#136	3.55958e-17
C2061	vout#141	vbottom<5>#113	4.37707e-17
C2062	vout#114	vbottom<7>#690	5.90278e-17
C2063	vout#139	vssa#138	8.04736e-16
C2064	vbottom<1>#18	vref	3.40763e-17
C2065	vout#44	vout#43	7.4616e-17
C2066	vssa#753	vref	1.03338e-16
C2067	vout#159	vbottom<6>#434	2.31737e-15
C2068	vssa#805	vssa#657	2.52128e-17
C2069	vbottom<4>#83	vbottom<2>	2.81951e-16
C2070	vssa#810	vref	1.2927e-16
C2071	vout#257	vout#262	3.49788e-17
C2072	vout#147	vbottom<7>#282	2.31085e-15
C2073	vout#137	vbottom<6>#434	2.94458e-17
C2074	vout#277	vssa#138	6.43836e-16
C2075	vout#80	vbottom<7>#497	5.90278e-17
C2076	vout#159	vbottom<7>#270	2.94458e-17
C2077	vssa#751	vref	1.70557e-16
C2078	vssa#784	vref	1.25441e-16
C2079	vout#116	vbottom<6>#275	2.31737e-15
C2080	vout#147	vout#125	3.58176e-17
C2081	vssa#815	vssa#138	5.35165e-16
C2082	vout#234	vout#219	4.03581e-17
C2083	vssa#823	vssa#208	1.37e-16
C2084	vout#87	vout#46	4.03581e-17
C2085	vout#179	vbottom<7>#643	2.94458e-17
C2086	vout#114	vout#91	3.49973e-17
C2087	vout#59	vbottom<6>#210	2.43234e-16
C2088	vout#103	vbottom<6>#222	2.21768e-17
C2089	vout#280	vbottom<7>#356	2.70367e-17
C2090	vout#19	vbottom<6>#396	2.57737e-17
C2091	vbottom<7>#637	vbottom<5>#13	2.10716e-16
C2092	vout#103	vbottom<7>#478	4.75203e-17
C2093	vout#200	vbottom<7>#226	2.90578e-17
C2094	vssa#805	vssa#138	6.00967e-16
C2095	vout#104	vout#81	3.49973e-17
C2096	vout#146	vbottom<6>#428	2.31737e-15
C2097	vout#133	vbottom<7>#678	3.43058e-17
C2098	vout#144	vbottom<6>#204	3.43058e-17
C2099	vout#121	vbottom<7>#519	4.75203e-17
C2100	vout#141	vbottom<4>#14	2.08557e-17
C2101	vout#84	vbottom<5>#59	3.65573e-17
C2102	vout#155	vbottom<6>#373	2.94458e-17
C2103	vout#93	vbottom<6>#219	5.90278e-17
C2104	vssa#759	vssa#474	2.38809e-15
C2105	vout#264	vbottom<6>#47	3.43058e-17
C2106	vout#75	vbottom<4>#89	3.02268e-17
C2107	vbottom<1>#13	vbottom<0>#18	1.04928e-16
C2108	vssa#799	vout#184	4.05119e-17
C2109	vout#189	vssa#138	6.7642e-16
C2110	vout#119	vbottom<5>#15	2.42676e-17
C2111	vout#77	vbottom<7>#684	1.94308e-16
C2112	vbottom<3>#9	ctl<3>#10	2.24909e-17
C2113	vssa#217	vssa#138	2.80363e-16
C2114	vbottom<6>#434	vssa#138	4.63139e-15
C2115	vssa#812	vssa#813	3.49973e-17
C2116	vssa#493	vssa#138	4.11357e-15
C2117	vout#82	vbottom<4>#48	2.94458e-17
C2118	vout#210	vbottom<7>#669	2.43457e-15
C2119	vout#237	vbottom<7>#649	2.30681e-15
C2120	vout#143	vssa#138	6.76452e-16
C2121	vbottom<6>#114	vssa#138	4.10712e-15
C2122	vssa#331	vssa#217	1.93034e-17
C2123	vout#141	vout#63	4.16436e-17
C2124	vssa#795	vssa#612	2.36483e-15
C2125	vout#227	vbottom<7>#605	2.21768e-17
C2126	vbottom<7>#234	vbottom<7>#242	4.05222e-17
C2127	vssa#755	vssa#138	5.81339e-16
C2128	vout#72	vbottom<4>#73	2.30788e-15
C2129	vout#138	vbottom<6>#423	2.31737e-15
C2130	vout#177	vbottom<4>	2.0374e-17
C2131	vout#39	vssa#138	1.81628e-16
C2132	vout#171	vout#149	3.58176e-17
C2133	vssa#116	ctl_dum	2.27288e-16
C2134	vout#168	vbottom<6>#428	2.94458e-17
C2135	vout#32	vbottom<3>#20	2.41799e-15
C2136	vbottom<7>#777	net3#11	2.90833e-16
C2137	vout#32	vssa#138	8.22446e-16
C2138	vbottom<7>#83	vssa#138	4.51244e-15
C2139	vout#62	vbottom<3>#29	3.43058e-17
C2140	vbottom<7>#117	vbottom<7>#146	4.05222e-17
C2141	vout#231	vbottom<6>#126	3.43058e-17
C2142	vdda#24	vref	4.85104e-16
C2143	vout#270	vbottom<7>#765	2.25978e-15
C2144	vout#128	vbottom<6>#134	2.94458e-17
C2145	vssa#97	vssa#96	4.38474e-17
C2146	vout#166	vbottom<7>#693	2.21768e-17
C2147	vout#92	vbottom<5>#140	2.21768e-17
C2148	vout#138	vssa#138	7.86881e-16
C2149	vout#82	vbottom<5>#183	3.19307e-17
C2150	vout#272	vout#275	3.58176e-17
C2151	vout#157	vbottom<7>#587	5.90309e-17
C2152	vbottom<6>#192	vssa#138	4.06917e-15
C2153	vssa#818	vssa#517	2.3635e-15
C2154	vbottom<6>#189	vbottom<0>	4.23995e-17
C2155	vout#272	vout#266	4.03581e-17
C2156	vout#16	vbottom<7>#623	2.21768e-17
C2157	vbottom<3>#15	vssa#471	1.30748e-16
C2158	vssa#779	vssa#309	2.21768e-17
C2159	vssa#810	vssa#538	2.21768e-17
C2160	vout#135	vbottom<7>#459	2.38868e-15
C2161	vout#40	vout#57	3.62264e-17
C2162	vssa#820	vssa#210	3.44888e-16
C2163	vout#73	vbottom<4>#31	2.47649e-15
C2164	vbottom<7>#514	vssa#138	4.38597e-15
C2165	vout#87	vbottom<5>#14	3.58425e-17
C2166	vssa#817	vssa#208	1.23655e-16
C2167	vout#91	vbottom<7>#478	2.21768e-17
C2168	vssa#768	vssa#446	2.30295e-15
C2169	vout#196	vbottom<7>#194	2.25978e-15
C2170	vout#21	vbottom<7>#896	3.85473e-17
C2171	vout#131	vbottom<6>#269	2.31085e-15
C2172	vout#127	vbottom<6>#109	3.19307e-17
C2173	vbottom<7>#748	vssa#138	4.90302e-15
C2174	vout#187	vssa#138	6.76427e-16
C2175	vout#68	vout#79	8.27234e-17
C2176	vout#158	vbottom<7>#264	2.21768e-17
C2177	vout#261	vout#266	3.58176e-17
C2178	vout#224	vssa#468	2.37383e-17
C2179	vssa#810	vbottom<7>#250	3.64851e-17
C2180	vout#172	vssa#138	6.44838e-16
C2181	vout#157	vbottom<6>#402	3.43058e-17
C2182	vssa#762	vssa#761	3.49664e-17
C2183	vdda#21	vref	6.30972e-15
C2184	vout#57	vbottom<2>#22	5.35741e-17
C2185	vssa#776	vout#269	4.18065e-17
C2186	vout#218	vbottom<6>#62	2.43454e-15
C2187	vbottom<7>#478	vbottom<7>#459	3.60301e-17
C2188	vout#148	vbottom<7>#285	2.31737e-15
C2189	vout#212	vbottom<7>#646	2.30029e-15
C2190	vout#256	vssa#138	6.60007e-16
C2191	vout#24	vbottom<7>#795	2.94458e-17
C2192	vout#195	vbottom<5>#110	2.21768e-17
C2193	vbottom<6>#11	vbottom<6>#2	1.64632e-17
C2194	vout#98	vbottom<6>#14	3.63532e-17
C2195	vssa#368	vref	8.41646e-17
C2196	vssa#761	vbottom<3>#12	3.50698e-17
C2197	vbottom<3>#26	vssa#138	4.38665e-15
C2198	vssa#486	vssa#138	4.46276e-15
C2199	vbottom<2>#22	vref	2.48401e-16
C2200	ctl<1>#10	ctl<1>#8	2.72821e-17
C2201	vout#119	vbottom<7>#640	2.94458e-17
C2202	vout#263	vbottom<7>#771	2.70367e-17
C2203	vout#168	vout#146	3.58176e-17
C2204	vout#213	vssa#138	7.3406e-16
C2205	vssa#774	vssa#291	2.35626e-15
C2206	vssa#816	vssa#520	2.08956e-17
C2207	vout#57	vbottom<1>#14	6.63102e-17
C2208	vssa#760	vbottom<0>#11	3.08587e-17
C2209	vout#16	vssa#823	4.18065e-17
C2210	vout#144	vout#181	3.49973e-17
C2211	vout#268	vbottom<7>#703	2.42183e-15
C2212	vout#233	vbottom<7>#718	2.21768e-17
C2213	vssa#767	vssa#453	2.3666e-17
C2214	vout#147	vout#178	3.96617e-17
C2215	vout#54	vbottom<3>#23	3.43058e-17
C2216	vout#136	vbottom<6>#402	4.95352e-17
C2217	vout#79	vbottom<7>#681	5.08519e-17
C2218	vout#12	vssa#208	5.42477e-17
C2219	vout#160	vbottom<6>#423	2.94458e-17
C2220	vssa#211	vssa#147	5.09348e-17
C2221	vout#16	vssa#753	4.05119e-17
C2222	vbottom<7>#684	vssa#138	4.38641e-15
C2223	vbottom<3>#13	vbottom<2>#32	1.52655e-17
C2224	vbottom<1>#22	vref	1.07203e-16
C2225	vout#219	vbottom<6>#364	2.94458e-17
C2226	vout#196	vout#184	3.96617e-17
C2227	vout#46	vbottom<6>#189	2.57588e-17
C2228	vout#158	vout#135	3.49973e-17
C2229	vout#166	vbottom<7>#483	4.75203e-17
C2230	vssa#138	net3	1.08813e-15
C2231	vout#221	vbottom<7>#242	2.70367e-17
C2232	vbottom<5>#106	vbottom<4>#14	5.39963e-17
C2233	vssa#790	vbottom<7>#101	3.64851e-17
C2234	vssa#793	vssa#600	2.21768e-17
C2235	vout#75	vbottom<1>#13	1.80349e-17
C2236	vssa#786	vssa#324	2.21768e-17
C2237	vssa#811	vssa#138	5.67625e-16
C2238	XI10/net2#35	vref	1.0844e-16
C2239	vout#163	vbottom<6>#114	2.34149e-17
C2240	vout#201	vbottom<7>#139	2.70367e-17
C2241	vout#146	vbottom<7>#273	2.94458e-17
C2242	vbottom<7>#637	vbottom<6>#15	4.23995e-17
C2243	vssa#764	vssa#456	2.21539e-17
C2244	vout#45	vbottom<0>#18	2.96686e-17
C2245	vout#256	vbottom<7>#706	5.90278e-17
C2246	vbottom<2>#19	vref	1.67155e-16
C2247	vout#97	vbottom<3>#62	3.43058e-17
C2248	vout#56	vout#49	3.71123e-17
C2249	vout#16	vssa#138	1.12885e-15
C2250	vbottom<7>#459	vssa#138	4.54669e-15
C2251	vbottom<6>#361	vssa#138	4.05001e-15
C2252	vbottom<7>#587	vbottom<7>#578	2.94985e-17
C2253	vout#157	vout#165	4.18065e-17
C2254	vssa#331	vref	1.60446e-16
C2255	vout#161	vbottom<6>#186	2.57555e-17
C2256	vout#53	vssa#138	5.02959e-16
C2257	vout#57	vbottom<3>#26	5.78617e-17
C2258	vout#204	vbottom<7>#643	2.30029e-15
C2259	vout#105	vbottom<6>#264	2.31085e-15
C2260	vbottom<6>#373	vbottom<0>#11	2.07359e-17
C2261	vbottom<4>#98	vssa#138	4.3706e-15
C2262	vout#260	vbottom<7>#77	2.43454e-15
C2263	vout#91	vbottom<7>#687	5.90278e-17
C2264	vout#239	vbottom<6>#174	2.94458e-17
C2265	vout#200	vssa#138	6.44838e-16
C2266	vbottom<4>#17	vbottom<3>#56	1.30983e-17
C2267	vout#186	vbottom<7>#95	5.90278e-17
C2268	vout#259	vbottom<7>#706	2.21768e-17
C2269	vssa#780	vssa#312	2.21768e-17
C2270	vssa#815	vssa#526	2.36671e-15
C2271	vout#241	vbottom<6>#358	3.19307e-17
C2272	vout#82	vout#64	3.58176e-17
C2273	vout#270	vbottom<7>#658	2.94458e-17
C2274	vbottom<7>#634	vssa#138	4.06936e-15
C2275	vout#46	vssa#138	7.30108e-16
C2276	XI10/net2#32	vref	2.77263e-16
C2277	vout#114	vout#121	4.18065e-17
C2278	vout#66	vbottom<4>#61	2.94458e-17
C2279	vout#67	vbottom<5>#15	1.97318e-17
C2280	vssa#771	vssa#282	2.31526e-15
C2281	vout#72	vssa#138	7.75183e-16
C2282	vbottom<2>#11	vssa#112	2.91855e-17
C2283	vout#194	vbottom<6>#137	1.30071e-17
C2284	vbottom<7>#234	vssa#138	4.6507e-15
C2285	vout#267	vbottom<7>#369	2.26006e-17
C2286	vssa#616	vssa#138	4.4388e-15
C2287	vout#149	vbottom<7>#288	2.31737e-15
C2288	vout#141	vbottom<4>#82	2.94458e-17
C2289	vssa#762	vbottom<4>#13	4.0311e-17
C2290	vout#45	vbottom<3>#56	4.53397e-17
C2291	vref#50	vref#49	2.49999e-17
C2292	vout#281	vssa#446	3.40614e-17
C2293	vssa#121	vssa#120	4.38474e-17
C2294	vout#30	vbottom<4>#92	2.21768e-17
C2295	vout#70	vout#102	3.49973e-17
C2296	vout#199	vout#182	3.49973e-17
C2297	vout#215	vbottom<7>#614	8.04732e-17
C2298	vout#67	vbottom<7>#637	2.94458e-17
C2299	vssa#303	vssa#138	4.40804e-15
C2300	vssa#327	vref	9.70776e-17
C2301	vout#36	vbottom<1>#18	2.39243e-17
C2302	vssa#777	vout#265	4.18065e-17
C2303	vout#214	vssa#138	6.08724e-16
C2304	vbottom<7>#170	vbottom<7>#178	4.05222e-17
C2305	vssa#138	vbottom<2>	9.26674e-16
C2306	vout#95	vbottom<4>#86	2.57588e-17
C2307	vssa#811	vref	1.2927e-16
C2308	vout#189	vbottom<7>#605	1.14983e-17
C2309	vout#74	net3#17	2.85968e-17
C2310	vout#256	vbottom<6>#50	2.2191e-17
C2311	vout#254	vbottom<7>#768	2.90578e-17
C2312	vout#263	vbottom<7>#655	2.94458e-17
C2313	vssa#807	vssa#144	5.59211e-17
C2314	vout#107	vssa#138	7.86881e-16
C2315	vout#179	vbottom<6>#370	2.30029e-15
C2316	vout#155	vbottom<7>#640	2.30681e-15
C2317	sample#14	XI10/enb#31	2.36264e-17
C2318	vout#123	vout#104	3.58176e-17
C2319	vbottom<7>#596	vssa#138	4.40713e-15
C2320	vssa#773	vssa#772	3.49788e-17
C2321	vout#171	vbottom<7>#162	2.90578e-17
C2322	vssa#773	vssa#288	2.35626e-15
C2323	vssa#783	vref	1.12257e-16
C2324	vout#233	vout#240	3.49973e-17
C2325	vbottom<4>#35	vbottom<4>#45	3.856e-17
C2326	vssa#798	vbottom<7>#194	3.64851e-17
C2327	vout#78	vout#89	4.18065e-17
C2328	vout#263	vssa#138	6.44928e-16
C2329	vbottom<7>#1008	vssa#138	4.61584e-16
C2330	vssa#778	vssa#300	2.25845e-17
C2331	vout#105	vbottom<5>#191	2.94458e-17
C2332	vbottom<6>#192	vbottom<5>#15	3.13411e-16
C2333	vbottom<6>#364	vbottom<4>	2.68552e-17
C2334	vssa#794	vssa#795	3.49674e-17
C2335	vout#147	vbottom<7>#186	2.94458e-17
C2336	vout#225	vbottom<7>#724	2.36841e-15
C2337	vout#79	vbottom<7>#533	2.33777e-15
C2338	vout#260	vssa#138	6.7639e-16
C2339	vssa#109	vssa#1	4.4397e-17
C2340	vbottom<7>#139	vssa#138	5.16761e-15
C2341	vssa#818	vssa#819	3.49973e-17
C2342	vout#244	vout#224	3.96617e-17
C2343	vout#16	vbottom<7>#663	2.57279e-15
C2344	vssa#775	vssa#774	3.49788e-17
C2345	vssa#324	vref	9.70776e-17
C2346	vout#76	vssa#757	4.05119e-17
C2347	vout#201	vssa#138	6.59961e-16
C2348	vout#254	vbottom<7>#652	2.94458e-17
C2349	vssa#801	vssa#640	2.3665e-17
C2350	vbottom<6>#219	vssa#138	4.51236e-15
C2351	vssa#772	vssa#285	2.36408e-15
C2352	vout#78	vbottom<7>#684	2.39278e-15
C2353	vout#196	vout#178	3.58176e-17
C2354	vout#135	vout#143	4.18065e-17
C2355	vssa#814	vbottom<7>#519	3.64851e-17
C2356	vout#248	vbottom<4>#13	2.4399e-17
C2357	vssa#773	vssa#138	5.63007e-16
C2358	vout#134	vbottom<7>#537	3.35516e-17
C2359	vout#51	vout#76	3.58176e-17
C2360	vbottom<0>#9	ctl<0>#8	8.77383e-18
C2361	vout#242	vbottom<7>#384	3.43058e-17
C2362	vssa#756	vssa#486	2.3666e-17
C2363	vssa#799	vssa#628	2.36483e-15
C2364	vssa#814	vssa#138	5.32631e-16
C2365	vbottom<4>#14	vbottom<4>#82	1.09729e-16
C2366	vout#49	vout#40	3.65289e-17
C2367	vbottom<5>#13	vdda#30	1.47426e-16
C2368	vout#168	vout#183	4.03581e-17
C2369	vout#98	vbottom<7>#637	2.30681e-15
C2370	vout#269	vbottom<7>#369	3.43058e-17
C2371	vout#259	vbottom<7>#366	5.90217e-17
C2372	vout#252	vbottom<6>#44	4.14234e-17
C2373	vssa#813	vssa#532	2.36158e-15
C2374	vout#261	vbottom<6>#358	2.70367e-17
C2375	vbottom<5>#113	vbottom<4>	3.75163e-17
C2376	vout#244	vbottom<7>#649	2.94458e-17
C2377	vout#180	vbottom<7>#501	3.35516e-17
C2378	vout#192	vssa#632	3.40614e-17
C2379	vbottom<1>#18	vbottom<2>#14	6.04379e-17
C2380	vssa#758	vbottom<7>#786	3.64851e-17
C2381	vssa#810	vssa#811	3.49973e-17
C2382	vout#27	vbottom<6>#198	2.21818e-17
C2383	vout#194	vbottom<6>#114	2.41048e-15
C2384	XI10/vbsl#17	vdda#6	1.31321e-17
C2385	vssa#321	vref	9.70776e-17
C2386	vssa#805	vssa#807	3.61262e-17
C2387	vssa#751	vssa#210	1.97249e-16
C2388	vout#244	vbottom<7>#774	2.24922e-15
C2389	vout#229	vbottom<7>#718	5.90278e-17
C2390	vout#81	vout#62	3.49973e-17
C2391	vssa#210	sample	1.56006e-15
C2392	vout#234	vbottom<5>#106	2.94458e-17
C2393	vout#136	vssa#138	7.2502e-16
C2394	vout#138	vbottom<7>#276	2.94458e-17
C2395	vbottom<7>#62	vssa#138	4.51244e-15
C2396	vssa#138	vbottom<6>#14	4.86234e-16
C2397	vssa#791	vbottom<7>#117	3.64851e-17
C2398	vout#26	vbottom<6>#204	5.94862e-17
C2399	vout#150	vbottom<7>#291	2.31737e-15
C2400	vout#105	vout#82	3.58176e-17
C2401	vssa#819	vssa#511	2.21831e-17
C2402	vssa#761	vssa#468	2.39615e-15
C2403	vssa#88	ctl<7>	2.40845e-16
C2404	vout#145	vssa#138	6.59996e-16
C2405	vout#54	vout#61	4.18065e-17
C2406	vssa#219	vssa#495	2.15654e-17
C2407	vbottom<7>#291	vssa#138	4.63139e-15
C2408	vout#224	vbottom<7>#646	2.94458e-17
C2409	vout#37	vbottom<7>#634	2.94458e-17
C2410	vbottom<7>#569	vssa#138	4.30231e-15
C2411	vssa#802	vout#206	4.05119e-17
C2412	vout#8	XI10/enb#37	1.22613e-17
C2413	vout#229	vout#208	4.18065e-17
C2414	vbottom<7>#447	vbottom<7>#264	3.60301e-17
C2415	ctl_dum#10	net3#9	2.17741e-17
C2416	vout#175	vbottom<7>#146	2.67924e-17
C2417	vout#76	vssa#138	4.66403e-16
C2418	vout#103	vbottom<5>#155	3.43058e-17
C2419	vout#236	vbottom<6>#53	2.21768e-17
C2420	vout#64	vbottom<4>#48	2.31747e-15
C2421	vout#189	vbottom<7>#675	2.21818e-17
C2422	vssa#797	vssa#616	2.21768e-17
C2423	vssa#824	vssa#495	2.52191e-17
C2424	vbottom<4>#59	vssa#138	2.86397e-16
C2425	vbottom<7>#1008	vbottom<7>#623	3.20503e-17
C2426	vssa#822	vssa#823	3.49973e-17
C2427	sample#15	vssa#84	1.84444e-16
C2428	vout#16	vssa#824	4.11102e-17
C2429	vbottom<7>#712	vssa#138	4.51244e-15
C2430	vout#220	vbottom<7>#643	2.94458e-17
C2431	vout#45	vssa#138	3.75467e-16
C2432	vout#51	vbottom<7>#634	2.31209e-15
C2433	vssa#318	vref	8.47931e-17
C2434	vout#195	vbottom<4>#22	2.94458e-17
C2435	vout#195	vout#214	3.49973e-17
C2436	vout#275	vssa#766	4.05119e-17
C2437	vout#72	vbottom<5>#175	4.75203e-17
C2438	vbottom<7>#555	vbottom<7>#537	3.60301e-17
C2439	vssa#819	vbottom<7>#587	3.64851e-17
C2440	vssa#201	vssa#200	3.67494e-17
C2441	vout#147	vssa#138	7.86881e-16
C2442	vbottom<7>#375	vssa#138	4.53336e-15
C2443	vssa#209	vssa#210	2.50576e-16
C2444	vssa#508	vssa#208	1.41438e-15
C2445	vbottom<7>#242	vbottom<7>#250	4.05222e-17
C2446	vbottom<7>#792	vref	1.08875e-16
C2447	vout#29	vbottom<7>#628	2.94458e-17
C2448	vout#108	vbottom<6>#74	4.60469e-17
C2449	vout#188	vbottom<7>#640	2.94458e-17
C2450	vout#96	vout#118	3.49973e-17
C2451	vout#164	vout#195	3.58176e-17
C2452	vssa#770	vssa#201	3.65433e-17
C2453	vout#20	vout#19	3.57086e-17
C2454	vbottom<5>#59	vssa#138	4.52976e-15
C2455	vssa#757	vssa#756	3.47745e-17
C2456	vout#140	vbottom<6>#71	2.43454e-15
C2457	vout#230	vssa#138	1.73952e-17
C2458	vout#273	vout#267	4.18065e-17
C2459	vout#42	vbottom<7>#631	2.94458e-17
C2460	vout#132	vbottom<7>#637	2.94458e-17
C2461	vbottom<6>#114	vbottom<6>#137	3.11114e-17
C2462	vbottom<6>#393	vssa#138	4.56249e-15
C2463	vout#76	vbottom<7>#634	2.94458e-17
C2464	vout#186	vout#207	3.49788e-17
C2465	vout#223	vbottom<5>#44	2.43454e-15
C2466	vout#208	vbottom<4>#22	3.43058e-17
C2467	vssa#468	vbottom<2>#11	2.59483e-16
C2468	vout#209	vbottom<7>#242	2.70367e-17
C2469	ctl<2>#10	vssa#41	1.7893e-17
C2470	vout#202	vssa#138	6.92097e-16
C2471	vssa#523	vout#12	1.59825e-16
C2472	vout#250	vout#256	3.49973e-17
C2473	vbottom<6>#65	vssa#138	4.51244e-15
C2474	vssa#791	vout#175	4.12232e-17
C2475	vout#108	vout#96	3.65289e-17
C2476	vout#192	vbottom<7>#218	2.90578e-17
C2477	vssa#84	vref	6.00334e-16
C2478	vssa#792	vssa#138	7.46849e-16
C2479	vssa#759	vbottom<5>#13	4.38716e-17
C2480	vssa#315	vref	9.70776e-17
C2481	vbottom<7>#943	vssa#138	4.61584e-16
C2482	vout#108	vbottom<6>#134	2.42745e-15
C2483	vbottom<5>#140	vssa#138	4.51635e-15
C2484	vssa#812	vbottom<7>#483	3.64851e-17
C2485	vssa#811	vbottom<7>#250	3.64851e-17
C2486	vout#224	vbottom<7>#780	2.57588e-17
C2487	vout#33	vbottom<7>#631	2.31737e-15
C2488	vbottom<1>#11	ctl<1>#10	2.60784e-18
C2489	vout#267	vssa#138	6.66904e-16
C2490	vout#200	vout#206	3.96617e-17
C2491	vbottom<7>#789	vref	1.95483e-16
C2492	vbottom<6>#364	net3#11	3.53752e-17
C2493	vout#243	vout#232	4.18065e-17
C2494	vout#222	vssa#138	6.66904e-16
C2495	vout#72	vbottom<3>#29	2.94458e-17
C2496	vout#223	vbottom<6>#56	5.90278e-17
C2497	vout#114	vbottom<7>#497	3.35516e-17
C2498	vssa#816	vssa#817	3.49973e-17
C2499	vout#20	vbottom<6>#396	2.49136e-15
C2500	vout#277	vbottom<7>#748	2.21768e-17
C2501	vout#226	vbottom<6>#177	2.94458e-17
C2502	vssa#652	vssa#138	4.18664e-15
C2503	vbottom<5>#128	vbottom<2>	3.53752e-17
C2504	XI10/vbsl#15	sample#15	1.81414e-16
C2505	vout#22	vbottom<6>#392	2.21768e-17
C2506	vssa#766	vbottom<7>#762	3.64851e-17
C2507	vssa#768	vssa#138	5.23195e-16
C2508	vssa#823	vssa#502	2.3635e-15
C2509	vout#27	vbottom<7>#631	2.94458e-17
C2510	vout#151	vbottom<7>#294	2.32389e-15
C2511	vout#128	vout#108	3.65289e-17
C2512	vssa#100	ctl<3>#10	2.35049e-17
C2513	vbottom<5>#11	ctl<5>#8	2.77681e-18
C2514	vout#104	vout#115	4.03581e-17
C2515	vout#51	vout#33	4.03581e-17
C2516	vout#30	vout#92	4.18065e-17
C2517	vout#96	vbottom<5>#56	2.21768e-17
C2518	vout#56	vbottom<2>#19	2.94458e-17
C2519	vout#39	vout#45	7.38425e-17
C2520	vout#207	vout#222	3.49788e-17
C2521	vssa#312	vref	9.70776e-17
C2522	vout#90	vssa#138	4.93331e-16
C2523	vout#179	vbottom<0>	1.96695e-17
C2524	vout#262	vbottom<7>#366	2.25845e-17
C2525	vout#122	vbottom<5>#210	3.43058e-17
C2526	vout#24	vbottom<7>#628	2.31737e-15
C2527	vref#62	vref#61	2.49999e-17
C2528	vssa#753	vssa#489	2.21539e-17
C2529	vbottom<7>#501	vbottom<7>#483	2.94976e-17
C2530	vout#13	vssa#523	1.21671e-17
C2531	vbottom<7>#786	vref	2.59381e-16
C2532	vout#205	vssa#138	6.46314e-16
C2533	vout#199	vout#205	4.03581e-17
C2534	vout#39	vbottom<2>#14	1.41249e-17
C2535	vssa#219	sample	2.81887e-17
C2536	vbottom<0>	vbottom<3>#23	3.57673e-17
C2537	vbottom<6>#126	vbottom<6>#137	2.95212e-17
C2538	vssa#770	vssa#278	2.25248e-15
C2539	vout#177	vbottom<4>#83	2.57588e-17
C2540	vout#32	vbottom<2>#36	2.99808e-17
C2541	vout#87	vout#119	3.58176e-17
C2542	vout#19	vssa#138	8.65019e-16
C2543	vout#81	vout#93	4.18065e-17
C2544	vout#31	vbottom<6>#192	2.70367e-17
C2545	vssa#809	vssa#541	2.21768e-17
C2546	vout#125	vout#105	3.58176e-17
C2547	vbottom<4>#61	vssa#138	4.36317e-15
C2548	vbottom<6>#373	vbottom<5>#14	3.00037e-16
C2549	vssa#783	vbottom<7>#92	3.64851e-17
C2550	vbottom<1>#22	vssa#138	3.30367e-15
C2551	vssa#211	vssa#148	1.42244e-17
C2552	vssa#811	vssa#812	3.49973e-17
C2553	vout#62	vssa#138	7.32054e-16
C2554	vssa#511	vssa#210	2.70576e-15
C2555	vout#124	vout#161	3.58176e-17
C2556	vout#27	vout#19	4.03581e-17
C2557	vout#154	vbottom<7>#279	2.94458e-17
C2558	vout#32	vbottom<4>#89	2.94458e-17
C2559	vbottom<5>#134	vbottom<5>#15	3.00597e-17
C2560	vbottom<7>#789	vbottom<6>#15	1.29243e-16
C2561	vssa#309	vref	9.70776e-17
C2562	vout#142	vbottom<6>#189	3.02283e-17
C2563	vssa#799	vssa#138	7.55178e-16
C2564	vout#146	vout#123	3.58176e-17
C2565	vout#173	vssa#604	3.40614e-17
C2566	vout#182	vout#158	3.49973e-17
C2567	vssa#812	vref	1.2927e-16
C2568	vbottom<7>#783	vref	2.56061e-16
C2569	vssa#282	vssa#138	4.1279e-15
C2570	vout#169	vbottom<7>#186	2.25978e-15
C2571	vbottom<7>#646	net3#11	2.93809e-16
C2572	vout#111	vssa#138	6.24623e-16
C2573	vout#202	vout#153	4.18065e-17
C2574	vout#200	vout#183	3.58176e-17
C2575	vssa#819	sample	2.63903e-17
C2576	vout#129	vbottom<6>#109	2.67924e-17
C2577	vout#113	vbottom<7>#550	2.37108e-15
C2578	vssa#782	vref	1.25441e-16
C2579	XI10/net2#19	XI10/enb#38	2.60822e-17
C2580	vout#110	vssa#138	7.86881e-16
C2581	vout#216	vbottom<7>#234	2.70367e-17
C2582	vbottom<7>#270	vssa#138	4.63139e-15
C2583	XI10/vbsh#20	vref	1.58969e-16
C2584	vout#78	vbottom<7>#555	4.75203e-17
C2585	vout#34	vbottom<3>#20	2.12705e-17
C2586	vout#50	vbottom<1>#13	1.80349e-17
C2587	vout#222	vout#231	3.49788e-17
C2588	vssa#45	vssa#1	1.08924e-17
C2589	XI10/vbsl#17	XI10/vbsl	3.68181e-16
C2590	vout#90	vbottom<7>#678	2.12705e-17
C2591	vout#187	vout#130	4.18065e-17
C2592	vout#77	vssa#138	4.85604e-16
C2593	vout#220	vbottom<7>#777	2.57588e-17
C2594	vout#19	vbottom<7>#628	2.94458e-17
C2595	vbottom<1>#11	vbottom<1>#9	1.14167e-17
C2596	vout#234	vout#241	3.58176e-17
C2597	vssa#306	vref	8.51168e-17
C2598	vout#253	vout#259	3.49973e-17
C2599	vout#254	vssa#462	3.40614e-17
C2600	XI10/vbsh#29	XI10/vbsh#22	2.27983e-17
C2601	XI10/enb#29	XI10/net2#35	5.77088e-18
C2602	vout#236	vssa#138	6.76427e-16
C2603	sample#12	vref	2.96002e-17
C2604	vbottom<7>#89	vssa#138	4.51244e-15
C2605	vssa#766	vssa#450	2.21539e-17
C2606	vssa#92	ctl<6>	2.27124e-16
C2607	vout#25	vout#31	3.58176e-17
C2608	vout#152	vbottom<7>#297	2.42745e-15
C2609	vout#121	vbottom<7>#687	2.21768e-17
C2610	vbottom<7>#780	vref	2.60565e-16
C2611	vout#55	vbottom<3>#26	2.21768e-17
C2612	vout#129	vssa#138	7.98825e-16
C2613	vout#65	vbottom<5>#183	4.15297e-17
C2614	XI10/enb#16	vref	4.5038e-17
C2615	vbottom<6>#198	vssa#138	4.85631e-15
C2616	vout#96	vbottom<5>#69	2.37165e-17
C2617	vout#17	vbottom<7>#897	2.21768e-17
C2618	vout#239	vout#226	4.03581e-17
C2619	vout#213	vbottom<6>#137	1.13838e-17
C2620	vout#272	vssa#138	6.99543e-16
C2621	vout#101	vbottom<7>#497	3.43058e-17
C2622	vout#233	vbottom<7>#724	2.2191e-17
C2623	vssa#814	vssa#526	2.21768e-17
C2624	vout#271	vout#274	3.49788e-17
C2625	vout#244	vbottom<3>#12	1.36583e-17
C2626	vout#268	vbottom<7>#969	3.51869e-17
C2627	vout#87	vbottom<5>#15	2.42676e-17
C2628	vout#197	vout#215	3.49973e-17
C2629	vout#136	vbottom<6>#207	2.68949e-17
C2630	vout#98	vbottom<6>#15	2.42676e-17
C2631	vbottom<7>#178	vssa#138	4.6507e-15
C2632	vssa#758	vssa#480	2.31023e-17
C2633	vout#107	vbottom<6>#389	2.94458e-17
C2634	vout#56	vbottom<4>#28	5.87804e-17
C2635	vout#121	vbottom<7>#478	3.43058e-17
C2636	vout#98	vbottom<6>#376	2.94458e-17
C2637	vssa#303	vref	9.70776e-17
C2638	vbottom<7>#703	vbottom<7>#969	3.11358e-17
C2639	vout#5	XI10/enb#37	6.10757e-17
C2640	vout#70	vbottom<6>#210	2.38365e-15
C2641	vout#82	vout#110	3.96617e-17
C2642	vssa#807	vssa#138	4.48055e-16
C2643	vout#161	vbottom<6>#367	2.94458e-17
C2644	vout#197	vbottom<7>#672	3.43058e-17
C2645	vout#251	vbottom<7>#375	2.42764e-15
C2646	vbottom<7>#777	vref	2.62927e-16
C2647	vout#109	vbottom<3>#53	2.21768e-17
C2648	vout#105	vbottom<6>#411	2.94458e-17
C2649	vout#117	vbottom<6>#129	1.31519e-17
C2650	vout#131	vbottom<6>#417	2.94458e-17
C2651	vout#106	vbottom<6>#406	2.94458e-17
C2652	vbottom<7>#783	vbottom<5>#13	3.42436e-16
C2653	vout#197	vssa#138	5.60782e-16
C2654	vout#117	vbottom<6>#71	2.21768e-17
C2655	vssa#824	vssa#751	3.61561e-17
C2656	XI10/vbsh#37	XI10/vbsl#15	2.77926e-15
C2657	vout#201	vbottom<7>#98	2.43751e-15
C2658	vout#156	vssa#138	6.79158e-16
C2659	vout#145	vbottom<7>#459	1.15045e-17
C2660	vssa#790	vssa#596	7.85832e-17
C2661	vout#58	vbottom<5>#14	1.80129e-17
C2662	vout#27	vout#33	3.58176e-17
C2663	vout#69	vout#68	7.4616e-17
C2664	vout#249	vbottom<7>#83	2.43454e-15
C2665	vssa#757	vbottom<7>#13	3.23222e-17
C2666	vout#265	vbottom<7>#74	2.43454e-15
C2667	vout#91	vout#101	4.18065e-17
C2668	vout#101	vout#78	3.49973e-17
C2669	vssa#754	vssa#138	5.81135e-16
C2670	vout#277	vbottom<7>#360	2.26006e-17
C2671	vssa#300	vref	9.70776e-17
C2672	vout#148	vbottom<7>#178	2.94458e-17
C2673	vout#18	vbottom<7>#669	2.57707e-17
C2674	vbottom<5>#14	vbottom<5>#15	6.99239e-16
C2675	vout#64	vout#49	3.65289e-17
C2676	vbottom<7>#690	vssa#138	4.51236e-15
C2677	vssa#766	vssa#765	3.49664e-17
C2678	vout#30	vssa#138	8.13618e-16
C2679	vbottom<7>#774	vref	2.56213e-16
C2680	vout#198	vbottom<7>#242	3.43058e-17
C2681	vssa#816	vssa#526	2.21768e-17
C2682	vout#188	vbottom<7>#783	2.24922e-15
C2683	vout#215	vssa#508	5.90217e-17
C2684	vout#143	vbottom<7>#501	5.90278e-17
C2685	vout#271	vbottom<7>#363	2.42764e-15
C2686	vout#146	vssa#138	7.86881e-16
C2687	sample#14	vref	8.77797e-17
C2688	vssa#805	vout#221	4.05119e-17
C2689	vout#125	vbottom<7>#282	2.94458e-17
C2690	vout#40	vbottom<2>#19	3.58269e-17
C2691	vout#179	vout#119	4.03581e-17
C2692	vbottom<5>#38	vssa#138	4.56909e-15
C2693	vbottom<7>#497	vbottom<7>#478	2.94976e-17
C2694	vssa#801	vssa#632	2.21768e-17
C2695	vout#130	vbottom<5>#50	5.90278e-17
C2696	vout#212	vout#224	3.58176e-17
C2697	vout#93	vbottom<5>#152	2.21768e-17
C2698	vout#155	vssa#138	5.05433e-17
C2699	vout#185	vout#175	3.49674e-17
C2700	vssa#803	vssa#644	2.36483e-15
C2701	XI10/net2#19	vref	1.05876e-17
C2702	vbottom<6>#186	vbottom<0>	3.15011e-16
C2703	vout#69	vbottom<7>#514	2.38876e-15
C2704	vssa#797	vssa#798	3.49674e-17
C2705	vssa#817	vssa#818	3.49973e-17
C2706	vout#275	vout#270	3.96617e-17
C2707	vbottom<1>#11	vssa#108	2.91855e-17
C2708	vout#130	vssa#138	6.76427e-16
C2709	vssa#297	vref	7.61607e-17
C2710	vout#167	vbottom<6>#334	2.21768e-17
C2711	vbottom<0>	vbottom<3>#15	1.97916e-16
C2712	vbottom<6>#44	vssa#138	4.57657e-15
C2713	vout#216	vout#221	3.96617e-17
C2714	XI10/net2#17	vref	2.51337e-16
C2715	vssa#822	vssa#208	1.37238e-16
C2716	vssa#93	vssa#92	4.38474e-17
C2717	vssa#763	vssa#462	2.36704e-15
C2718	vout#171	vssa#138	6.44838e-16
C2719	vbottom<7>#771	vref	1.30225e-16
C2720	vout#141	vbottom<4>#15	2.08699e-17
C2721	vbottom<5>#113	vssa#138	3.92977e-15
C2722	vout#67	vbottom<6>#14	1.82824e-17
C2723	vout#230	vbottom<6>#361	3.02268e-17
C2724	vout#203	vbottom<6>#180	2.94458e-17
C2725	XI10/enb#21	vref	4.82865e-17
C2726	vout#156	vbottom<7>#483	2.21768e-17
C2727	vout#246	vssa#138	7.55189e-16
C2728	vout#222	vbottom<7>#387	2.42764e-15
C2729	vout#247	vbottom<7>#715	2.43454e-15
C2730	vout#21	vssa#489	3.40614e-17
C2731	vssa#784	vssa#321	2.36317e-15
C2732	vout#236	vout#223	4.18065e-17
C2733	vout#191	vbottom<7>#264	4.14203e-17
C2734	vout#176	vssa#138	6.93332e-16
C2735	vout#101	vbottom<7>#684	2.21768e-17
C2736	vout#60	vbottom<5>#149	3.43058e-17
C2737	vout#40	vbottom<1>#22	2.2974e-17
C2738	vout#172	vbottom<7>#154	2.90578e-17
C2739	vssa#820	sample	5.28117e-17
C2740	vbottom<6>#95	vssa#138	4.85388e-15
C2741	vbottom<6>#134	vbottom<6>#252	4.05397e-17
C2742	vout#153	vout#187	3.49973e-17
C2743	XI10/vbsh#29	vout#7	2.06035e-17
C2744	vssa#624	vssa#138	4.4388e-15
C2745	XI10/enb#31	vref	1.39608e-16
C2746	vout#96	vout#84	3.56638e-17
C2747	vout#111	vout#58	4.03581e-17
C2748	vbottom<6>#4	vssa#93	1.89594e-17
C2749	vssa#781	vbottom<7>#86	3.64851e-17
C2750	vssa#294	vref	9.70776e-17
C2751	vssa#755	vssa#483	2.21539e-17
C2752	vssa#217	vssa#327	1.69362e-17
C2753	vout#216	vout#205	3.49973e-17
C2754	vssa#101	vssa#1	4.4397e-17
C2755	vdda#6	vref	5.04283e-17
C2756	vout#32	vout#41	3.58176e-17
C2757	vbottom<7>#774	vbottom<4>#13	3.35575e-16
C2758	ctl<0>#10	ctl<0>#8	2.72711e-17
C2759	vssa#309	vssa#138	4.38716e-15
C2760	vout#186	vout#139	4.18065e-17
C2761	vout#95	vout#75	3.96617e-17
C2762	vbottom<7>#634	vbottom<6>#15	3.13411e-16
C2763	vssa#776	vssa#138	5.74265e-16
C2764	vout#141	vbottom<3>#53	2.36627e-15
C2765	vbottom<1>#14	vssa#138	8.06666e-17
C2766	vout#64	vout#86	3.96591e-17
C2767	vssa#462	vbottom<4>#13	3.22838e-16
C2768	vssa#760	vbottom<3>#15	3.98085e-17
C2769	vout#76	vout#42	3.96281e-17
C2770	vbottom<6>#373	vbottom<0>	2.16547e-17
C2771	vout#231	vbottom<7>#381	2.25845e-17
C2772	vout#48	vbottom<5>#189	2.88088e-17
C2773	vout#80	vbottom<6>#216	2.43458e-15
C2774	vssa#526	vssa#138	4.29745e-15
C2775	vout#122	vbottom<6>#222	2.43458e-15
C2776	vout#64	vbottom<4>#35	3.18649e-17
C2777	vout#193	vbottom<2>	1.44225e-17
C2778	vssa#783	vssa#138	5.84708e-16
C2779	vssa#779	vssa#778	3.49788e-17
C2780	vout#212	vout#204	3.96617e-17
C2781	vout#246	vbottom<6>#174	2.31737e-15
C2782	vssa#797	vbottom<7>#186	3.64851e-17
C2783	vout#227	vbottom<7>#666	3.43029e-17
C2784	vssa#822	vssa#508	2.2188e-17
C2785	vbottom<7>#774	net3#11	3.53752e-17
C2786	vin#11	vref	1.12416e-16
C2787	vbottom<4>#25	vssa#138	4.51244e-15
C2788	vout#59	vbottom<6>#213	1.94308e-16
C2789	vout#119	vbottom<6>#373	2.30681e-15
C2790	vbottom<7>#943	vbottom<7>#896	3.20787e-17
C2791	vssa#291	vref	9.70776e-17
C2792	vout#224	vbottom<3>#12	6.65049e-17
C2793	vout#132	vbottom<7>#789	2.77798e-17
C2794	vssa#96	ctl<5>	2.27124e-16
C2795	vout#53	vout#60	4.18065e-17
C2796	vout#60	vssa#138	5.02922e-16
C2797	vssa#788	vssa#368	2.63025e-17
C2798	XI10/enb#38	XI10/net2#17	3.8208e-16
C2799	vout#92	vbottom<5>#146	2.21818e-17
C2800	vssa#777	vssa#297	2.25845e-17
C2801	vout#96	vbottom<6>#134	4.18114e-17
C2802	vout#154	vbottom<6>#417	2.31085e-15
C2803	vout#109	vbottom<1>#22	2.96455e-17
C2804	vout#50	vbottom<4>#86	2.94458e-17
C2805	vout#51	vbottom<6>#15	2.00864e-17
C2806	vout#46	vbottom<5>#15	2.00864e-17
C2807	vssa#813	vref	8.90351e-17
C2808	XI10/vbsl#19	vdda#21	7.25131e-17
C2809	vssa#794	vout#172	4.05119e-17
C2810	vout#206	vssa#138	6.44838e-16
C2811	ctl<2>#10	vssa#113	1.42509e-17
C2812	vssa#33	vssa#34	2.08377e-17
C2813	vssa#794	vssa#612	2.3665e-17
C2814	vssa#49	vssa#50	2.15015e-17
C2815	vbottom<7>#783	vbottom<3>#15	2.97023e-16
C2816	vout#115	vbottom<5>#206	2.70367e-17
C2817	vbottom<5>#106	vssa#138	4.29588e-15
C2818	vout#177	vout#203	3.58176e-17
C2819	vout#159	vbottom<6>#321	2.94458e-17
C2820	vssa#807	vssa#544	2.63025e-17
C2821	vout#224	vssa#761	4.05119e-17
C2822	XI10/vbsh#35	vref	2.89952e-16
C2823	vout#252	vout#241	4.03581e-17
C2824	vout#31	vssa#138	7.55157e-16
C2825	vbottom<3>#53	vbottom<4>#17	3.11898e-17
C2826	vssa#778	vssa#306	2.25845e-17
C2827	vout#86	vbottom<2>#22	2.94458e-17
C2828	vout#81	vssa#138	6.7607e-16
C2829	vout#252	vbottom<6>#361	2.70367e-17
C2830	vssa#781	vref	1.25441e-16
C2831	vssa#823	vssa#824	3.49973e-17
C2832	vout#50	vbottom<2>#32	2.62403e-17
C2833	vout#23	vbottom<6>#201	2.49217e-15
C2834	vssa#288	vref	9.70776e-17
C2835	vout#29	vbottom<7>#897	3.85443e-17
C2836	vout#126	vbottom<7>#285	2.94458e-17
C2837	XI10/enb#29	vref	1.15029e-16
C2838	vout#184	vbottom<7>#210	2.90578e-17
C2839	vssa#816	vbottom<7>#555	3.64851e-17
C2840	vout#125	vbottom<6>#411	2.31085e-15
C2841	vout#22	vbottom<6>#195	2.67924e-17
C2842	XI10/vbsh#35	XI10/vbsh#37	1.8497e-16
C2843	vout#180	vbottom<7>#696	3.43058e-17
C2844	vout#177	vssa#138	5.46905e-16
C2845	vout#222	vout#194	4.18065e-17
C2846	vssa#368	vssa#596	3.4882e-17
C2847	vbottom<6>#13	vssa#138	1.76334e-16
C2848	vbottom<7>#68	vssa#138	4.51244e-15
C2849	vbottom<7>#178	vbottom<7>#186	4.05222e-17
C2850	vssa#138	vbottom<3>#13	6.30309e-16
C2851	XI10/enb#27	vref	1.934e-16
C2852	XI10/net2#21	XI10/vbsh	6.40318e-18
C2853	vout#87	vbottom<6>#192	3.02268e-17
C2854	vssa#819	vssa#210	3.44888e-16
C2855	vout#219	vbottom<5>#122	2.94458e-17
C2856	vout#237	vbottom<4>#13	5.84854e-17
C2857	vout#106	vssa#138	7.86881e-16
C2858	vout#128	vout#127	4.03581e-17
C2859	vout#23	vout#181	4.18065e-17
C2860	vout#268	vbottom<6>#44	3.43058e-17
C2861	vout#121	vbottom<7>#693	2.21768e-17
C2862	vout#120	vout#133	4.18065e-17
C2863	vout#61	vbottom<5>#146	2.38365e-15
C2864	vout#163	vbottom<6>#80	3.35576e-17
C2865	vbottom<6>#177	vssa#138	4.05001e-15
C2866	vout#250	vbottom<6>#50	2.43454e-15
C2867	vbottom<6>#189	vbottom<5>#15	4.23995e-17
C2868	XI10/net2#21	vref	1.44812e-16
C2869	vout#163	vbottom<6>#74	3.43058e-17
C2870	vout#82	vbottom<5>#191	2.31085e-15
C2871	vssa#210	sample#15	6.44615e-16
C2872	vout#249	vout#238	4.18065e-17
C2873	vbottom<6>#361	vbottom<4>	2.94929e-16
C2874	vout#254	vssa#138	5.85247e-16
C2875	vout#232	vbottom<5>#41	2.43454e-15
C2876	vout#272	vbottom<7>#762	2.94458e-17
C2877	vout#183	vbottom<7>#267	3.19307e-17
C2878	vbottom<6>#379	vref	1.11069e-16
C2879	vssa#285	vref	8.08288e-17
C2880	vout#179	vout#204	3.58176e-17
C2881	vssa#763	vbottom<7>#771	3.64851e-17
C2882	vbottom<7>#718	vssa#138	4.51244e-15
C2883	vout#251	vssa#138	6.66904e-16
C2884	vout#161	vbottom<5>#125	2.94458e-17
C2885	vbottom<3>#59	net3	3.6738e-17
C2886	vout#90	vout#100	4.18065e-17
C2887	vout#30	vbottom<5>#143	5.87834e-17
C2888	vout#162	vssa#138	7.22754e-16
C2889	vssa#755	vbottom<7>#795	3.64851e-17
C2890	vout#177	vbottom<3>#53	2.94458e-17
C2891	vout#181	vbottom<6>#396	2.2111e-17
C2892	vbottom<7>#381	vssa#138	4.53336e-15
C2893	vout#228	vbottom<7>#95	2.2191e-17
C2894	vssa#814	vssa#532	2.21768e-17
C2895	vout#249	vbottom<7>#381	3.43058e-17
C2896	vout#126	vbottom<6>#406	2.31737e-15
C2897	vout#158	vbottom<7>#447	2.42319e-15
C2898	vout#34	vout#32	3.57086e-17
C2899	vout#278	vssa#138	6.7638e-16
C2900	vssa#117	vssa#116	4.38474e-17
C2901	vbottom<6>#399	vssa#138	4.50461e-15
C2902	vbottom<6>#370	vbottom<0>#11	4.03218e-17
C2903	vbottom<2>#36	vbottom<3>#16	1.373e-17
C2904	vout#278	vbottom<7>#360	3.43058e-17
C2905	vout#228	vbottom<7>#89	2.21768e-17
C2906	vssa#760	vssa#474	2.31023e-17
C2907	vout#278	vout#274	4.18065e-17
C2908	vssa#788	vssa#790	3.61262e-17
C2909	vout#76	vbottom<7>#786	2.57588e-17
C2910	vbottom<1>#22	net3	1.09185e-16
C2911	vout#142	vbottom<0>	3.93799e-17
C2912	vout#142	vbottom<5>#128	2.94458e-17
C2913	vout#153	vbottom<5>#53	2.43454e-15
C2914	vbottom<7>#218	vssa#138	4.6507e-15
C2915	vout#260	vout#251	4.18065e-17
C2916	vbottom<6>#376	vref	1.95478e-16
C2917	vssa#282	vref	9.70776e-17
C2918	vbottom<6>#71	vssa#138	4.51987e-15
C2919	vbottom<5>#110	vbottom<4>	1.79839e-16
C2920	vbottom<6>#183	vbottom<3>#13	3.53752e-17
C2921	vout#146	vbottom<6>#308	2.94458e-17
C2922	vout#202	vbottom<6>#65	2.43454e-15
C2923	vout#133	vssa#517	5.90217e-17
C2924	vssa#792	vssa#600	2.36483e-15
C2925	vout#84	vbottom<5>#183	2.67924e-17
C2926	vbottom<2>#36	vbottom<0>	1.08294e-16
C2927	vout#139	vbottom<6>#80	2.47649e-15
C2928	vbottom<7>#11	vbottom<7>#2	1.61457e-17
C2929	vssa#821	sample	5.28117e-17
C2930	vout#59	vout#70	8.27234e-17
C2931	vout#53	vbottom<5>#146	1.64895e-17
C2932	vout#211	vbottom<7>#226	2.70367e-17
C2933	vbottom<5>#146	vssa#138	4.37301e-15
C2934	vout#275	vbottom<7>#748	3.85504e-17
C2935	vssa#785	vssa#784	3.49973e-17
C2936	vout#216	vssa#648	3.40614e-17
C2937	vbottom<7>#669	vssa#138	4.52362e-15
C2938	vout#144	vssa#138	7.35693e-16
C2939	vbottom<4>#22	vbottom<4>#17	3.10487e-17
C2940	vout#255	vssa#306	5.90247e-17
C2941	vbottom<6>#15	vssa#138	4.03387e-16
C2942	vout#36	vbottom<1>#13	1.85146e-17
C2943	vssa#785	vout#201	4.18065e-17
C2944	vbottom<7>#780	vbottom<1>#11	2.78974e-16
C2945	vbottom<1>#11	vbottom<1>#2	1.37749e-17
C2946	vssa#759	vbottom<3>#15	2.95773e-17
C2947	vout#74	vout#109	3.49973e-17
C2948	vout#125	vout#154	3.96617e-17
C2949	vbottom<2>#36	vbottom<1>#13	1.81872e-16
C2950	vssa#813	vbottom<7>#501	3.64851e-17
C2951	vout#223	vbottom<5>#113	3.43058e-17
C2952	vout#158	vssa#138	6.7607e-16
C2953	vbottom<5>#9	ctl<5>#10	1.29754e-17
C2954	vout#30	vbottom<4>#98	2.41978e-17
C2955	vssa#38	vssa#1	1.08924e-17
C2956	vout#118	vout#153	3.49973e-17
C2957	vout#74	vbottom<3>#59	2.43533e-15
C2958	vout#45	vout#36	4.02085e-17
C2959	vout#18	vbottom<7>#663	1.15045e-17
C2960	vssa#657	vref	1.89139e-16
C2961	vssa#786	vbottom<7>#101	3.64851e-17
C2962	vout#87	vbottom<5>#131	2.94458e-17
C2963	vssa#505	vssa#208	1.41438e-15
C2964	vout#18	vbottom<7>#614	4.64242e-17
C2965	vout#89	vbottom<7>#569	2.05082e-17
C2966	vout#247	vbottom<6>#56	3.43058e-17
C2967	vout#112	vbottom<7>#519	2.21768e-17
C2968	vout#169	vssa#620	3.40614e-17
C2969	vout#178	vbottom<6>#417	2.94458e-17
C2970	vout#56	vbottom<4>#35	4.18053e-17
C2971	vout#42	vssa#138	5.9509e-16
C2972	vout#187	vbottom<5>#47	2.21768e-17
C2973	vbottom<6>#373	vref	2.6045e-16
C2974	vout#185	vout#201	3.49973e-17
C2975	vout#248	vbottom<7>#771	2.94458e-17
C2976	vout#231	vbottom<7>#387	2.26006e-17
C2977	vbottom<5>#197	vssa#138	4.63783e-15
C2978	vssa#758	vbottom<5>#13	4.132e-17
C2979	vout#144	vbottom<7>#675	5.90217e-17
C2980	vout#12	vssa#210	9.53959e-17
C2981	vout#170	vbottom<7>#178	2.25978e-15
C2982	vout#36	vssa#138	4.01374e-16
C2983	vout#106	vbottom<6>#258	2.31737e-15
C2984	vssa#120	ctl<4>	2.29932e-16
C2985	vout#269	vbottom<7>#71	2.43454e-15
C2986	vssa#278	vref	1.80301e-16
C2987	vout#197	vbottom<7>#587	2.21768e-17
C2988	vssa#781	vssa#309	2.21768e-17
C2989	vout#124	vbottom<6>#183	2.94458e-17
C2990	vout#24	vbottom<6>#393	2.94458e-17
C2991	vbottom<4>#83	vssa#138	3.48763e-15
C2992	vbottom<0>#18	vbottom<2>	4.2386e-17
C2993	vout#210	vout#215	4.18065e-17
C2994	vout#178	vssa#138	7.86881e-16
C2995	vout#272	vbottom<7>#969	2.3835e-15
C2996	vssa#782	vssa#312	2.21768e-17
C2997	vssa#761	vssa#760	3.49664e-17
C2998	vout#127	vbottom<7>#288	2.94458e-17
C2999	vbottom<6>#2	vbottom<6>	2.68293e-17
C3000	vout#118	vout#73	4.18065e-17
C3001	vout#152	vbottom<6>#80	2.94458e-17
C3002	vout#228	vssa#318	5.90247e-17
C3003	vout#13	vssa#520	1.7125e-17
C3004	vdda#19	vref	3.55363e-17
C3005	vout#46	vbottom<5>#134	2.94458e-17
C3006	vout#262	vbottom<7>#712	3.43058e-17
C3007	vbottom<6>#392	vssa#138	4.90695e-15
C3008	vbottom<0>#11	ctl<0>#10	2.82355e-18
C3009	vout#152	vbottom<7>#139	4.60469e-17
C3010	vout#264	vout#256	4.18065e-17
C3011	vbottom<4>#73	vssa#138	4.57123e-15
C3012	vssa#770	vssa#446	2.63296e-17
C3013	vbottom<6>#370	vref	2.60601e-16
C3014	vout#153	vssa#138	6.76427e-16
C3015	vout#158	vout#166	4.18065e-17
C3016	vout#173	vout#172	3.96617e-17
C3017	vssa#812	vssa#535	2.36349e-15
C3018	vssa#652	vref	7.25476e-17
C3019	vout#245	vout#233	4.18065e-17
C3020	vout#240	vout#247	3.49973e-17
C3021	vout#168	vbottom<7>#270	3.19307e-17
C3022	vout#207	vbottom<7>#390	2.42764e-15
C3023	vout#146	vout#159	4.03581e-17
C3024	vssa#596	vssa#138	4.65627e-15
C3025	vout#28	vout#35	3.58176e-17
C3026	vout#266	vout#270	3.58176e-17
C3027	vssa#793	vssa#138	7.55195e-16
C3028	vssa#96	ctl<5>#10	2.35049e-17
C3029	vout#101	vbottom<7>#537	5.90278e-17
C3030	vssa#480	vbottom<7>#14	6.79731e-17
C3031	vout#46	vout#31	4.03581e-17
C3032	vout#26	vout#136	4.18065e-17
C3033	vout#226	vbottom<5>#106	2.37822e-15
C3034	vssa#757	vssa#477	2.08759e-17
C3035	vssa#805	vbottom<7>#250	3.64851e-17
C3036	vout#242	vbottom<7>#83	2.21768e-17
C3037	vout#219	vout#161	4.03581e-17
C3038	vout#140	vbottom<5>#59	3.43058e-17
C3039	vssa#288	vssa#138	4.40804e-15
C3040	vout#149	vbottom<7>#170	2.94458e-17
C3041	vout#40	vbottom<1>#18	2.37369e-17
C3042	vout#118	vbottom<5>#56	2.43454e-15
C3043	vout#259	vssa#138	6.76431e-16
C3044	vssa#520	vout#12	2.08768e-16
C3045	vssa#201	vssa#138	2.72568e-16
C3046	XI10/vbsh#34	XI10/vbsh#33	5.6223e-17
C3047	vout#177	vbottom<4>#82	2.30182e-15
C3048	vout#236	vbottom<6>#59	2.2191e-17
C3049	vout#266	vout#258	4.03581e-17
C3050	vout#62	vout#71	4.18065e-17
C3051	vout#281	vbottom<7>#56	2.32062e-15
C3052	vout#194	vssa#138	6.81761e-16
C3053	vbottom<7>#279	vssa#138	4.63783e-15
C3054	vout#190	vbottom<7>#696	2.21768e-17
C3055	vout#270	vssa#456	3.40614e-17
C3056	sample#14	sample#10	3.43804e-17
C3057	vbottom<7>#519	vssa#138	4.51049e-15
C3058	vout#112	vssa#526	5.90278e-17
C3059	vout#42	vbottom<7>#792	2.25881e-15
C3060	vout#31	vbottom<5>#137	2.94458e-17
C3061	vout#272	vbottom<7>#356	5.09007e-17
C3062	vbottom<6>#367	vref	2.62927e-16
C3063	vssa#767	vssa#138	5.81135e-16
C3064	vssa#648	vref	8.41646e-17
C3065	vssa#508	vssa#210	2.70576e-15
C3066	vbottom<5>#125	vbottom<2>	2.81951e-16
C3067	vssa#798	vssa#628	2.3665e-17
C3068	vout#123	vout#137	4.03581e-17
C3069	vout#128	vbottom<6>#95	4.14172e-17
C3070	vout#147	vbottom<6>#411	2.94458e-17
C3071	vout#177	vbottom<5>#110	5.63997e-17
C3072	vout#48	vbottom<4>#101	2.32664e-15
C3073	vout#100	vssa#138	3.90555e-16
C3074	vout#182	vout#190	4.18065e-17
C3075	vbottom<7>#95	vssa#138	4.51244e-15
C3076	vout#195	vbottom<4>#17	1.37163e-17
C3077	vssa#782	vssa#318	2.21768e-17
C3078	vout#63	vbottom<4>#83	2.94458e-17
C3079	vout#142	vbottom<6>#370	2.94458e-17
C3080	vout#252	vout#258	3.58176e-17
C3081	vout#113	vout#144	3.58176e-17
C3082	vssa#814	vref	1.10041e-16
C3083	vssa#765	vssa#456	2.34524e-15
C3084	vout#209	vssa#138	6.60016e-16
C3085	vssa#474	vbottom<5>#13	3.22792e-16
C3086	vssa#800	vssa#801	3.49674e-17
C3087	vout#66	vbottom<2>#22	2.30871e-15
C3088	vbottom<6>#204	vssa#138	4.3898e-15
C3089	vout#259	vbottom<7>#712	2.2191e-17
C3090	vssa#805	vssa#648	2.21768e-17
C3091	vout#143	vout#121	3.49973e-17
C3092	vout#234	vbottom<6>#177	2.31209e-15
C3093	vout#185	vssa#327	4.64178e-17
C3094	vout#107	vbottom<6>#252	2.32389e-15
C3095	vbottom<3>#20	vbottom<0>	7.78525e-17
C3096	vout#18	vssa#138	8.31805e-16
C3097	vout#272	vbottom<7>#658	2.70367e-17
C3098	vbottom<6>#364	vref	2.60601e-16
C3099	vbottom<5>#131	vbottom<5>#15	1.67852e-17
C3100	vout#105	vout#131	3.96617e-17
C3101	vout#42	vssa#483	3.40614e-17
C3102	vout#62	vbottom<5>#189	2.37105e-15
C3103	vssa#644	vref	8.41646e-17
C3104	vout#71	vssa#138	6.76452e-16
C3105	vout#71	vout#53	3.49973e-17
C3106	vout#40	vout#39	8.86363e-17
C3107	vssa#824	vssa#210	2.99166e-16
C3108	vout#91	vbottom<7>#514	8.05014e-17
C3109	vssa#751	vssa#495	2.24421e-15
C3110	vout#102	vbottom<6>#204	2.68899e-17
C3111	vout#247	vout#253	3.49973e-17
C3112	vout#152	vout#139	3.65289e-17
C3113	vout#5	XI10/enb#38	2.29356e-17
C3114	vssa#800	vssa#138	7.46321e-16
C3115	vout#143	vbottom<7>#693	2.43458e-15
C3116	vout#109	vbottom<4>#15	2.42834e-17
C3117	vout#204	vbottom<7>#780	2.92015e-17
C3118	vout#108	vout#107	4.03581e-17
C3119	vout#207	vout#163	4.18065e-17
C3120	vssa#780	vref	1.25441e-16
C3121	vssa#771	vssa#201	3.49862e-17
C3122	vout#249	vssa#309	5.90247e-17
C3123	vssa#796	vssa#616	2.36483e-15
C3124	vout#58	vssa#138	6.57935e-16
C3125	vssa#822	sample	5.28117e-17
C3126	vout#238	vout#245	3.49788e-17
C3127	vout#218	vbottom<7>#721	5.90278e-17
C3128	vbottom<2>#32	vssa#138	3.47026e-15
C3129	vout#101	vbottom<7>#690	2.21768e-17
C3130	vout#94	vssa#138	7.7122e-16
C3131	vout#128	vbottom<7>#291	2.94458e-17
C3132	vout#104	vbottom<5>#202	2.70367e-17
C3133	vout#261	vbottom<6>#47	2.2191e-17
C3134	vbottom<6>#361	vref	1.30225e-16
C3135	vbottom<6>#180	vbottom<4>#14	3.08697e-16
C3136	vssa#640	vref	7.51603e-17
C3137	vref#62	vref	2.58555e-17
C3138	vout#34	vbottom<3>#26	1.72204e-17
C3139	vout#127	vbottom<6>#389	2.31737e-15
C3140	vout#160	vbottom<7>#273	3.19307e-17
C3141	ctl_dum#10	vssa#1	1.98481e-18
C3142	vbottom<6>#321	vssa#138	4.63139e-15
C3143	vout#68	vssa#138	4.85571e-16
C3144	vout#156	vssa#532	5.90278e-17
C3145	vout#133	vbottom<7>#578	2.42321e-15
C3146	vssa#797	vout#169	4.05119e-17
C3147	vbottom<0>#11	vssa#104	2.91855e-17
C3148	vbottom<7>#696	vssa#138	4.51236e-15
C3149	vout#223	vssa#138	6.76427e-16
C3150	vbottom<4>#9	ctl<4>#8	8.77383e-18
C3151	vssa#147	vssa#138	2.54139e-16
C3152	vout#58	vbottom<5>#15	1.21806e-17
C3153	vout#152	vout#151	4.03581e-17
C3154	vout#128	vssa#138	7.7122e-16
C3155	vout#12	sample#15	2.06983e-16
C3156	vout#97	vbottom<4>#25	2.21768e-17
C3157	vbottom<7>#360	vssa#138	4.51414e-15
C3158	vout#63	vout#50	3.96617e-17
C3159	vout#148	vbottom<6>#406	2.94458e-17
C3160	vout#115	vbottom<5>#155	2.21768e-17
C3161	vssa#781	vssa#315	2.21768e-17
C3162	vref#59	vref	2.58555e-17
C3163	vbottom<5>#44	vssa#138	4.51244e-15
C3164	vout#42	vssa#756	4.05119e-17
C3165	vout#266	vssa#138	7.70841e-16
C3166	vout#90	vbottom<7>#684	1.6331e-17
C3167	vbottom<7>#550	vssa#138	4.47432e-15
C3168	vssa#756	vbottom<7>#13	2.42029e-17
C3169	vbottom<6>#373	vssa#138	3.36992e-15
C3170	vout#185	vbottom<7>#117	2.37165e-17
C3171	vout#46	vbottom<6>#195	3.19307e-17
C3172	vssa#636	vref	8.41646e-17
C3173	vout#51	vbottom<6>#379	2.94458e-17
C3174	vssa#450	vssa#138	4.46276e-15
C3175	vout#167	vbottom<7>#264	5.90278e-17
C3176	vbottom<7>#762	vssa#138	4.62744e-15
C3177	vout#20	vbottom<6>#198	2.94458e-17
C3178	vout#165	vbottom<7>#596	8.04732e-17
C3179	vssa#779	vssa#138	5.86e-16
C3180	vssa#776	vssa#294	2.25845e-17
C3181	vout#266	vbottom<7>#655	2.70367e-17
C3182	vout#109	vbottom<3>#59	2.2191e-17
C3183	vout#157	vout#189	3.49973e-17
C3184	vbottom<2>#11	vdda#30	2.21636e-16
C3185	vbottom<6>#50	vssa#138	4.51244e-15
C3186	vout#224	vout#220	3.96617e-17
C3187	vssa#93	vssa#1	4.4397e-17
C3188	vout#186	vbottom<7>#393	2.42367e-15
C3189	vout#67	vbottom<6>#15	1.21806e-17
C3190	vout#130	vbottom<4>#25	2.43454e-15
C3191	vout#173	vbottom<7>#146	2.90578e-17
C3192	vbottom<6>#2	vref#41	3.77308e-17
C3193	vssa#819	vssa#517	2.2188e-17
C3194	vout#273	vbottom<7>#68	2.43454e-15
C3195	vssa#786	vssa#138	5.13751e-16
C3196	vref#56	vref	2.58555e-17
C3197	vbottom<0>#9	vbottom<0>#11	1.17466e-17
C3198	vbottom<5>#125	vssa#138	3.39051e-15
C3199	vout#158	vbottom<6>#334	3.43058e-17
C3200	vout#231	vout#213	4.18065e-17
C3201	vout#32	vbottom<4>#95	5.41617e-17
C3202	vout#269	vout#262	4.18065e-17
C3203	vout#28	vbottom<4>#92	2.42509e-15
C3204	vout#13	vssa#138	9.32899e-17
C3205	vout#193	vbottom<6>#364	3.02268e-17
C3206	vout#161	vbottom<2>	1.7461e-17
C3207	vssa#794	vssa#604	2.21768e-17
C3208	vout#239	vbottom<5>#38	2.37401e-15
C3209	vbottom<7>#514	vbottom<7>#497	3.60301e-17
C3210	vssa#813	vssa#138	5.45673e-16
C3211	vout#231	vout#238	3.49788e-17
C3212	vout#242	vbottom<7>#89	2.2191e-17
C3213	vssa#100	ctl<3>	2.27124e-16
C3214	vout#33	vout#42	3.58176e-17
C3215	vssa#632	vref	6.52991e-17
C3216	vssa#632	vssa#138	4.46906e-15
C3217	vout#262	vbottom<7>#372	2.26006e-17
C3218	vout#213	vbottom<7>#724	2.94458e-17
C3219	vout#49	vref	3.57313e-17
C3220	vout#173	vout#151	3.58176e-17
C3221	vssa#753	vssa#138	4.74481e-16
C3222	vssa#762	vssa#468	2.31023e-17
C3223	vout#280	vbottom<7>#59	2.44234e-15
C3224	vout#278	vout#280	3.49973e-17
C3225	vout#215	vbottom<7>#605	2.38869e-15
C3226	vssa#315	vssa#138	4.38716e-15
C3227	vssa#100	vssa#1	1.11589e-17
C3228	vout#111	vbottom<6>#186	2.94458e-17
C3229	vref#53	vref	3.47682e-17
C3230	vout#64	vbottom<4>#61	2.69709e-17
C3231	vout#121	vout#101	3.49973e-17
C3232	vout#237	vbottom<3>#12	1.80349e-17
C3233	vout#92	vssa#138	6.81445e-16
C3234	vout#66	vref	4.30687e-17
C3235	vbottom<6>#379	vbottom<6>#15	3.00597e-17
C3236	vssa#164	vssa#138	2.52526e-16
C3237	vout#196	vbottom<7>#202	2.90578e-17
C3238	vout#155	vbottom<5>#13	3.75842e-17
C3239	vssa#532	vssa#138	4.31142e-15
C3240	vout#165	vssa#819	4.18065e-17
C3241	vout#81	vbottom<5>#155	5.90278e-17
C3242	vout#159	vssa#138	7.71215e-16
C3243	vout#145	vbottom<6>#321	2.70367e-17
C3244	vref#50	vref	2.58555e-17
C3245	vout#157	vbottom<7>#672	2.21768e-17
C3246	vssa#756	vssa#755	3.49664e-17
C3247	vout#149	vout#127	3.58176e-17
C3248	vout#238	vbottom<7>#378	2.25845e-17
C3249	vout#141	vbottom<4>#17	1.6257e-17
C3250	vout#265	vbottom<7>#372	3.43058e-17
C3251	vssa#772	vout#280	4.18065e-17
C3252	vout#21	vbottom<7>#623	2.2194e-17
C3253	vout#98	vssa#138	5.6933e-16
C3254	vssa#822	vbottom<7>#614	3.64851e-17
C3255	vbottom<7>#497	vssa#138	4.54669e-15
C3256	vbottom<7>#643	vbottom<0>#11	3.15028e-16
C3257	vout#258	vbottom<6>#358	2.94458e-17
C3258	vssa#628	vref	8.41646e-17
C3259	vssa#474	vbottom<0>#11	4.09287e-17
C3260	vout#57	vout#44	4.18065e-17
C3261	vout#25	vbottom<5>#137	2.42509e-15
C3262	vout#61	vbottom<4>#98	3.43058e-17
C3263	vbottom<4>#31	vssa#138	4.52976e-15
C3264	vout#178	vbottom<7>#276	3.19307e-17
C3265	vout#129	vbottom<7>#294	4.15297e-17
C3266	vout#35	vbottom<5>#134	2.31703e-15
C3267	vout#270	vssa#765	4.05119e-17
C3268	vout#74	vssa#138	6.32434e-16
C3269	vbottom<7>#162	vssa#138	4.6507e-15
C3270	vout#104	vbottom<5>#210	4.14203e-17
C3271	vout#258	vbottom<7>#652	2.70367e-17
C3272	vssa#796	vbottom<7>#178	3.64851e-17
C3273	vout#100	vbottom<7>#555	1.6331e-17
C3274	vout#58	vbottom<5>#131	2.30986e-15
C3275	vout#93	vbottom<5>#210	2.21768e-17
C3276	vout#207	vbottom<7>#92	5.90278e-17
C3277	vout#170	vssa#138	6.44838e-16
C3278	vssa#779	vbottom<7>#80	3.64851e-17
C3279	vssa#468	net3#11	3.17552e-16
C3280	vout#159	vbottom<6>#440	4.14203e-17
C3281	vout#115	vout#93	3.49973e-17
C3282	vout#59	vbottom<7>#533	1.23006e-17
C3283	ctl<2>#10	vbottom<2>#9	1.38337e-17
C3284	vout#113	vbottom<6>#207	3.43058e-17
C3285	vssa#815	vbottom<7>#537	3.64851e-17
C3286	vout#117	vbottom<6>#91	3.56909e-17
C3287	vout#111	vbottom<5>#128	2.30029e-15
C3288	vout#67	vbottom<6>#376	2.30986e-15
C3289	vssa#817	vssa#520	2.3856e-15
C3290	vout#182	vbottom<6>#440	3.43058e-17
C3291	vout#234	vssa#138	7.2873e-16
C3292	vssa#785	vssa#327	2.21768e-17
C3293	vout#51	vbottom<7>#789	2.94458e-17
C3294	vssa#824	vssa#502	2.21831e-17
C3295	vout#16	vssa#502	5.87834e-17
C3296	vssa#821	vssa#505	2.21831e-17
C3297	vout#170	vout#169	3.96617e-17
C3298	vout#275	vbottom<7>#765	2.70367e-17
C3299	vout#21	vbottom<7>#795	2.70367e-17
C3300	vssa#772	vssa#771	3.49973e-17
C3301	vssa#823	sample	5.28117e-17
C3302	vout#118	vssa#138	6.76052e-16
C3303	vout#241	vbottom<6>#364	2.57588e-17
C3304	vout#137	vbottom<6>#308	2.70367e-17
C3305	vout#276	vbottom<7>#65	2.43454e-15
C3306	vssa#624	vref	8.41646e-17
C3307	vssa#89	vssa#88	4.38474e-17
C3308	vbottom<1>#2	vbottom<1>	2.68293e-17
C3309	vout#57	vbottom<1>#13	3.99846e-17
C3310	vout#124	vbottom<5>#125	2.30029e-15
C3311	vout#206	vbottom<7>#218	2.70367e-17
C3312	vout#120	vbottom<7>#678	2.43457e-15
C3313	vssa#759	vssa#471	2.08759e-17
C3314	vout#278	vbottom<7>#62	2.43454e-15
C3315	vssa#480	vbottom<6>#13	3.17101e-16
C3316	vout#189	vbottom<6>#399	3.43058e-17
C3317	vout#272	vbottom<7>#703	2.28788e-17
C3318	vout#273	vout#276	3.49973e-17
C3319	vbottom<1>#4	vssa#109	1.89594e-17
C3320	vssa#760	vbottom<7>#780	2.04841e-17
C3321	vout#269	vssa#138	6.7639e-16
C3322	vbottom<7>#74	vssa#138	4.51244e-15
C3323	vssa#138	vout#12	1.14813e-16
C3324	vssa#754	vssa#489	2.34524e-15
C3325	vout#245	vbottom<7>#378	2.42764e-15
C3326	vout#221	vbottom<7>#250	2.33599e-15
C3327	vssa#792	vssa#793	3.49674e-17
C3328	vbottom<3>#13	net3	1.08975e-15
C3329	vout#252	vbottom<6>#174	2.94458e-17
C3330	vout#164	vbottom<5>#47	5.90278e-17
C3331	vout#111	vbottom<0>	3.87599e-17
C3332	vout#203	vbottom<5>#122	2.30681e-15
C3333	vout#228	vssa#138	6.7639e-16
C3334	vbottom<6>#370	vbottom<0>	2.7469e-16
C3335	vout#20	vbottom<7>#669	5.87834e-17
C3336	vbottom<7>#614	vssa#138	4.38549e-15
C3337	vout#81	vbottom<4>#73	3.43058e-17
C3338	vssa#820	vssa#511	2.3635e-15
C3339	vout#253	vbottom<7>#709	2.21768e-17
C3340	vbottom<7>#780	vbottom<3>#15	2.31451e-16
C3341	vssa#620	vref	8.41646e-17
C3342	vref#41	vref	3.47682e-17
C3343	vout#120	vbottom<7>#587	1.14983e-17
C3344	vssa#771	vssa#138	5.79642e-16
C3345	vout#137	vbottom<6>#334	5.09068e-17
C3346	vout#79	vout#113	3.49973e-17
C3347	vssa#815	vref	1.11527e-16
C3348	vout#149	vout#148	4.03581e-17
C3349	vout#275	vbottom<7>#969	2.94458e-17
C3350	vssa#776	vssa#775	3.49788e-17
C3351	vout#248	vbottom<7>#649	2.57588e-17
C3352	vbottom<7>#724	vssa#138	4.23327e-15
C3353	vout#65	vbottom<4>#31	3.65573e-17
C3354	vout#69	vssa#138	5.02959e-16
C3355	vout#23	vbottom<6>#399	5.87834e-17
C3356	vout#210	vout#18	3.49973e-17
C3357	vout#253	vbottom<7>#369	5.90217e-17
C3358	vout#274	vbottom<7>#356	2.25845e-17
C3359	vbottom<6>#367	vbottom<3>#12	3.53752e-17
C3360	vout#265	vout#257	4.18065e-17
C3361	vbottom<4>#83	vbottom<3>#13	3.53752e-17
C3362	vbottom<4>#11	ctl<4>#8	2.78004e-18
C3363	vout#30	vbottom<3>#20	2.94458e-17
C3364	vssa#821	vssa#208	1.37238e-16
C3365	vout#211	vssa#138	6.28807e-16
C3366	vbottom<7>#387	vssa#138	4.53336e-15
C3367	vout#250	vbottom<7>#709	5.90278e-17
C3368	vout#219	vbottom<6>#180	2.30681e-15
C3369	XI10/vbsh#29	XI10/vbsl#19	2.89609e-15
C3370	vout#80	vbottom<5>#152	3.43058e-17
C3371	vssa#779	vref	1.08223e-16
C3372	vout#22	vssa#138	8.05469e-16
C3373	vout#33	vout#24	4.03581e-17
C3374	vout#178	vout#154	3.58176e-17
C3375	vout#213	vbottom<7>#384	5.90217e-17
C3376	vbottom<6>#406	vssa#138	4.63139e-15
C3377	vbottom<7>#186	vbottom<7>#194	4.05222e-17
C3378	vout#147	vbottom<7>#279	2.70367e-17
C3379	vssa#616	vref	8.41646e-17
C3380	vssa#802	vssa#644	2.3665e-17
C3381	ctl<4>#10	vref	1.97055e-16
C3382	vout#49	vout#66	3.96617e-17
C3383	vbottom<7>#789	vssa#138	3.48874e-15
C3384	vout#150	vbottom<7>#162	2.94458e-17
C3385	vout#93	vssa#138	6.76452e-16
C3386	vssa#800	vssa#632	2.36483e-15
C3387	vout#171	vbottom<7>#170	2.25978e-15
C3388	vout#187	vbottom<5>#53	2.2191e-17
C3389	vout#139	vbottom<7>#297	4.18053e-17
C3390	vbottom<3>#12	net3#11	1.09051e-15
C3391	vout#274	vbottom<7>#703	3.43029e-17
C3392	ctl_dum#10	vref	2.316e-16
C3393	vout#220	vbottom<3>#15	6.57421e-17
C3394	vout#36	vbottom<0>#18	2.34886e-15
C3395	vout#123	vbottom<6>#321	3.19307e-17
C3396	vbottom<6>#14	vbottom<6>#15	4.29885e-16
C3397	vssa#777	vssa#303	2.25845e-17
C3398	vout#53	vbottom<5>#152	2.16626e-17
C3399	vbottom<5>#152	vssa#138	4.51243e-15
C3400	vout#41	vbottom<4>#89	2.31209e-15
C3401	vout#18	vbottom<7>#1008	5.8336e-17
C3402	vbottom<7>#675	vssa#138	4.51243e-15
C3403	vout#16	vssa#493	3.56342e-17
C3404	vout#95	vssa#138	6.27044e-16
C3405	vbottom<1>#11	vdda#30	2.21636e-16
C3406	vout#212	vbottom<3>#12	2.34729e-17
C3407	vbottom<3>#16	vssa#138	9.64874e-16
C3408	ctl<2>#10	vref	1.97471e-16
C3409	vout#270	vbottom<7>#762	2.90578e-17
C3410	vssa#112	ctl<2>	2.2553e-16
C3411	vbottom<3>#56	vssa#138	3.94024e-15
C3412	vbottom<4>#89	vbottom<0>	4.23995e-17
C3413	vout#134	vbottom<7>#690	3.43058e-17
C3414	vbottom<7>#596	vbottom<7>#587	3.6031e-17
C3415	vout#17	vbottom<7>#623	2.55534e-15
C3416	vout#105	vssa#138	7.86881e-16
C3417	vbottom<7>#587	vssa#138	4.44331e-15
C3418	vout#89	vssa#816	4.18065e-17
C3419	vssa#803	vssa#804	3.49674e-17
C3420	vout#66	vbottom<3>#29	4.95413e-17
C3421	vssa#798	vssa#620	2.21768e-17
C3422	vssa#612	vref	7.0184e-17
C3423	XI10/vbsh#20	XI10/net2#21	3.24632e-17
C3424	ctl<1>#10	vref	1.86851e-16
C3425	vout#239	vout#246	3.58176e-17
C3426	vout#218	vout#229	3.49973e-17
C3427	vout#90	vbottom<7>#569	5.08519e-17
C3428	vout#43	vbottom<3>#23	2.40582e-16
C3429	vout#264	vbottom<7>#706	2.43454e-15
C3430	vout#237	vbottom<7>#646	2.57588e-17
C3431	vout#244	vssa#138	1.10319e-17
C3432	vout#136	vbottom<5>#140	3.43058e-17
C3433	vout#243	vbottom<6>#50	2.21768e-17
C3434	vout#255	vbottom<7>#77	2.21768e-17
C3435	vout#39	net3#17	5.64308e-17
C3436	vout#267	vout#259	4.18065e-17
C3437	vbottom<5>#206	vssa#138	4.69827e-15
C3438	vout#19	vbottom<6>#393	2.42509e-15
C3439	vbottom<6>#4	vssa#1	1.57337e-17
C3440	XI10/vbsh#35	XI10/vbsl#15	2.91091e-15
C3441	ctl<0>#10	vref	1.55743e-16
C3442	vout#240	vssa#138	6.76431e-16
C3443	vssa#767	vssa#450	2.34524e-15
C3444	vout#166	vout#143	3.49973e-17
C3445	vssa#804	vbottom<7>#242	3.64851e-17
C3446	vout#257	vbottom<7>#369	2.25845e-17
C3447	vout#94	vbottom<5>#197	2.70367e-17
C3448	vout#229	vbottom<6>#59	2.43454e-15
C3449	vout#19	vout#18	3.71123e-17
C3450	vbottom<4>#89	vssa#138	4.05511e-15
C3451	vout#121	vout#134	4.18065e-17
C3452	vout#152	vssa#138	8.38773e-16
C3453	ctl<3>#10	vref	2.60327e-16
C3454	vout#46	vout#67	3.58176e-17
C3455	vout#60	vout#59	7.4616e-17
C3456	vout#200	vssa#636	3.40614e-17
C3457	vssa#775	vssa#291	2.25845e-17
C3458	vssa#144	vref	6.83304e-15
C3459	vout#141	vout#177	3.58176e-17
C3460	vout#116	vbottom<6>#308	3.19307e-17
C3461	vout#64	vbottom<2>#19	2.94458e-17
C3462	vssa#782	vbottom<7>#89	3.64851e-17
C3463	vssa#800	vout#192	4.05119e-17
C3464	vout#132	vssa#477	3.40614e-17
C3465	vbottom<7>#11	ctl<7>#8	2.76359e-18
C3466	vout#170	vout#148	3.58176e-17
C3467	vout#274	vssa#138	6.66882e-16
C3468	vbottom<6>#91	vbottom<6>#80	2.95221e-17
C3469	vssa#608	vref	8.41646e-17
C3470	ctl<5>#10	vref	2.25477e-16
C3471	vout#110	vout#86	3.58176e-17
C3472	vbottom<3>#56	net3	1.00229e-16
C3473	vout#74	vref	2.97833e-17
C3474	vout#263	vbottom<7>#768	2.25978e-15
C3475	vout#61	vout#70	4.18065e-17
C3476	vout#40	net3#17	2.35088e-15
C3477	vout#139	vbottom<6>#95	2.37165e-17
C3478	vssa#788	vssa#786	3.61561e-17
C3479	vout#26	vbottom<5>#137	2.21768e-17
C3480	vssa#502	vssa#208	1.41438e-15
C3481	vssa#604	vssa#138	4.4388e-15
C3482	vssa#824	sample	3.03213e-17
C3483	ctl<6>#10	vref	2.60018e-16
C3484	vbottom<6>#180	vbottom<3>#13	2.81937e-16
C3485	vout#231	vbottom<7>#86	5.90278e-17
C3486	vout#40	vref	9.00137e-17
C3487	vout#97	vbottom<4>#31	2.21768e-17
C3488	vbottom<7>#637	vbottom<6>#14	3.00037e-16
C3489	vbottom<6>#269	vssa#138	4.63783e-15
C3490	vout#185	vbottom<7>#98	2.21768e-17
C3491	vout#183	vout#159	3.58176e-17
C3492	vout#58	vbottom<6>#189	2.94458e-17
C3493	vout#44	vbottom<3>#26	2.39278e-15
C3494	vbottom<2>#19	vssa#138	3.79312e-15
C3495	vout#208	vout#164	4.18065e-17
C3496	vssa#294	vssa#138	4.40804e-15
C3497	vout#219	vbottom<3>#13	1.50913e-17
C3498	vout#157	vssa#138	6.76447e-16
C3499	ctl<7>#10	vref	2.25493e-16
C3500	vout#31	vbottom<6>#198	5.09007e-17
C3501	vssa#138	vbottom<7>#14	2.27039e-16
C3502	vout#66	vout#57	3.65289e-17
C3503	vout#57	vref	1.23098e-16
C3504	vout#148	vbottom<7>#282	2.70367e-17
C3505	vbottom<3>#12	vssa#468	1.00228e-16
C3506	vbottom<4>#17	vbottom<4>#15	2.45272e-16
C3507	vout#212	vbottom<7>#643	2.57588e-17
C3508	vout#109	vout#141	3.49973e-17
C3509	vssa#765	vssa#764	3.49664e-17
C3510	vout#87	vbottom<6>#373	2.94458e-17
C3511	vout#111	vout#142	3.58176e-17
C3512	vout#166	vssa#138	6.76415e-16
C3513	vout#232	vout#214	4.18065e-17
C3514	vbottom<7>#288	vssa#138	4.63139e-15
C3515	vout#156	vbottom<7>#519	8.05014e-17
C3516	vout#210	vbottom<7>#666	2.37497e-17
C3517	XI10/net2#35	XI10/vbsh	4.15375e-18
C3518	vssa#604	vref	8.41646e-17
C3519	vout#194	vbottom<6>#129	1.13838e-17
C3520	vout#279	vssa#450	3.40614e-17
C3521	vout#238	vbottom<7>#724	3.43058e-17
C3522	vssa#785	vssa#321	2.21768e-17
C3523	vout#36	vbottom<3>#23	4.18365e-17
C3524	vout#56	vbottom<3>#62	2.41949e-15
C3525	vbottom<7>#649	vbottom<4>#13	3.35575e-16
C3526	XI10/vbsl#11	XI10/net2#17	1.26941e-17
C3527	sample#14	sample#12	1.01e-17
C3528	vbottom<7>#792	vbottom<7>#15	2.82861e-17
C3529	vout#29	vssa#138	6.29101e-16
C3530	vbottom<2>#32	vbottom<1>#13	3.6792e-17
C3531	XI10/vbsh#34	XI10/vbsl#17	1.12478e-16
C3532	vout#178	vout#160	4.03581e-17
C3533	vssa#113	vssa#112	4.38474e-17
C3534	vout#219	vout#230	3.58176e-17
C3535	vssa#368	vssa#138	3.94349e-15
C3536	vbottom<3>#11	ctl<3>#10	5.67367e-18
C3537	vout#34	vssa#138	4.78612e-16
C3538	vbottom<7>#101	vssa#138	4.52582e-15
C3539	vout#81	vbottom<5>#206	2.21768e-17
C3540	vout#28	vbottom<5>#134	2.94458e-17
C3541	vssa#92	ctl<6>#10	2.35049e-17
C3542	vbottom<7>#4	vssa#89	1.89594e-17
C3543	vout#164	vbottom<3>#56	3.23564e-17
C3544	vbottom<4>#82	vssa#138	3.51401e-15
C3545	vout#160	vssa#138	7.86881e-16
C3546	vbottom<6>#189	vbottom<3>#16	3.00037e-16
C3547	vout#254	vbottom<7>#774	2.57588e-17
C3548	vssa#138	vref	4.55752e-13
C3549	vbottom<6>#210	vssa#138	4.37301e-15
C3550	vssa#811	vssa#538	2.36349e-15
C3551	vout#92	vout#102	4.18065e-17
C3552	vout#208	vbottom<5>#44	2.21768e-17
C3553	vout#137	vout#115	3.58176e-17
C3554	XI10/vbsh#33	XI10/vbsl	2.01013e-17
C3555	vbottom<2>#32	net3	1.07879e-16
C3556	vout#93	vout#71	3.49973e-17
C3557	vbottom<4>#82	vbottom<3>#13	2.814e-16
C3558	vout#179	vssa#138	1.45673e-17
C3559	vssa#600	vref	6.57392e-17
C3560	vout#19	vout#24	3.58176e-17
C3561	vbottom<4>#89	vref	1.23606e-16
C3562	vout#100	vbottom<7>#681	3.43058e-17
C3563	vout#232	vbottom<6>#53	5.90278e-17
C3564	vout#23	vout#22	3.57086e-17
C3565	vssa#764	vssa#462	2.3666e-17
C3566	XI10/vbsh#33	XI10/vbsl#19	1.36618e-17
C3567	vout#54	vbottom<4>#95	2.12705e-17
C3568	vout#238	vbottom<7>#384	2.26006e-17
C3569	vbottom<4>#89	vbottom<3>#16	2.98759e-16
C3570	vout#97	vssa#138	6.76418e-16
C3571	vout#143	vout#156	4.18065e-17
C3572	vbottom<7>#202	vssa#138	4.6507e-15
C3573	vout#264	vout#268	3.49973e-17
C3574	vssa#505	vssa#210	2.70576e-15
C3575	vout#204	vout#220	3.58176e-17
C3576	vout#132	vbottom<6>#13	1.43315e-17
C3577	vout#184	vout#192	3.96617e-17
C3578	vout#260	vssa#303	5.90247e-17
C3579	vout#69	vbottom<7>#684	5.15868e-17
C3580	vout#204	vbottom<7>#640	3.02268e-17
C3581	vout#270	vout#263	3.96617e-17
C3582	vssa#778	vssa#777	3.49788e-17
C3583	vssa#794	vssa#138	7.55178e-16
C3584	vssa#818	vssa#210	3.44888e-16
C3585	vout#240	vbottom<7>#718	2.43454e-15
C3586	vout#118	vbottom<6>#68	5.90278e-17
C3587	vssa#756	vssa#483	2.43917e-15
C3588	vssa#820	vssa#821	3.49973e-17
C3589	vbottom<6>#258	vssa#138	4.63139e-15
C3590	vbottom<3>#12	vbottom<2>#11	1.08281e-16
C3591	vout#188	vbottom<3>#15	1.28413e-17
C3592	vbottom<3>#11	vssa#100	2.92053e-17
C3593	vout#18	vbottom<7>#623	2.37497e-17
C3594	vout#94	vbottom<5>#206	4.14172e-17
C3595	vout#250	vssa#138	6.76061e-16
C3596	vssa#200	vssa#138	3.44428e-16
C3597	vout#92	vbottom<6>#207	5.97243e-17
C3598	vout#205	vout#190	3.49973e-17
C3599	vout#41	vbottom<5>#131	2.94458e-17
C3600	vout#48	vbottom<5>#149	5.15868e-17
C3601	vssa#596	vref	8.41646e-17
C3602	vout#140	vssa#138	6.81149e-16
C3603	vbottom<1>#4	vref	3.1804e-17
C3604	vout#172	vssa#608	3.40614e-17
C3605	vbottom<4>#86	vref	2.60601e-16
C3606	vbottom<6>#134	vssa#138	4.32851e-15
C3607	vout#243	vout#250	3.49973e-17
C3608	vout#226	vout#203	4.03581e-17
C3609	vssa#766	vssa#138	5.81501e-16
C3610	sample#9	vssa#6	1.10385e-17
C3611	vout#113	vbottom<7>#533	2.21768e-17
C3612	vbottom<7>#777	vbottom<1>#11	3.86904e-17
C3613	vout#119	vout#67	4.03581e-17
C3614	vout#71	vbottom<5>#149	2.21768e-17
C3615	vssa#816	vref	1.86895e-16
C3616	vout#42	vout#29	3.96617e-17
C3617	vout#149	vbottom<7>#285	2.70367e-17
C3618	vout#75	vbottom<4>#86	2.30029e-15
C3619	vbottom<7>#703	vssa#138	4.30855e-15
C3620	vout#112	vbottom<7>#687	3.43058e-17
C3621	vssa#761	vssa#465	2.08759e-17
C3622	vout#86	vbottom<4>#48	2.69709e-17
C3623	vssa#778	vref	1.25441e-16
C3624	vssa#810	vssa#138	5.6726e-16
C3625	vbottom<7>#366	vssa#138	4.53336e-15
C3626	vout#209	vbottom<7>#250	2.4819e-15
C3627	XI10/vbsh#20	XI10/net2#15	5.27648e-18
C3628	vbottom<5>#113	vbottom<4>#15	2.81427e-17
C3629	vout#155	vbottom<7>#637	3.02268e-17
C3630	vssa#108	ctl<1>	1.99171e-16
C3631	vout#60	vbottom<6>#213	2.39278e-15
C3632	vbottom<5>#50	vssa#138	4.51244e-15
C3633	vout#131	vout#110	3.58176e-17
C3634	vout#124	vbottom<2>	1.80349e-17
C3635	vbottom<0>#11	vdda#30	2.32594e-16
C3636	vout#205	vbottom<7>#264	2.70367e-17
C3637	vbottom<4>#83	vref	2.62927e-16
C3638	vout#227	vssa#138	5.60769e-16
C3639	XI10/enb#29	XI10/net2#32	2.79209e-16
C3640	vssa#774	vssa#288	2.25845e-17
C3641	vssa#791	vssa#600	2.3665e-17
C3642	vout#169	vbottom<7>#194	2.70367e-17
C3643	vbottom<6>#379	vssa#138	4.21056e-15
C3644	vbottom<7>#569	vbottom<7>#555	1.64615e-17
C3645	vout#149	vbottom<6>#389	2.94458e-17
C3646	vssa#456	vssa#138	4.46276e-15
C3647	vout#84	vout#73	3.65289e-17
C3648	vout#164	vbottom<4>#22	2.37849e-15
C3649	vbottom<7>#768	vssa#138	4.62744e-15
C3650	vout#80	vssa#138	6.76452e-16
C3651	vbottom<3>#4	vref	3.1804e-17
C3652	XI10/enb#38	XI10/net2#32	2.05304e-17
C3653	vbottom<4>#82	vref	2.00385e-16
C3654	vout#220	vssa#760	4.05119e-17
C3655	XI10/enb#38	XI10/net2#14	3.03171e-18
C3656	vbottom<6>#56	vssa#138	4.51244e-15
C3657	vout#49	vbottom<2>#19	2.35978e-15
C3658	vout#75	vbottom<5>#128	2.94458e-17
C3659	vout#218	vbottom<5>#50	3.43058e-17
C3660	vout#214	vbottom<5>#106	2.21768e-17
C3661	vbottom<5>#106	vbottom<4>	3.19319e-16
C3662	vssa#801	vssa#138	7.55173e-16
C3663	vout#244	vbottom<7>#771	2.77798e-17
C3664	vbottom<5>#131	vssa#138	3.59127e-15
C3665	vout#204	vout#155	4.03581e-17
C3666	vout#241	vbottom<6>#177	2.94458e-17
C3667	vssa#784	vssa#783	3.49973e-17
C3668	vout#161	vbottom<6>#183	2.30029e-15
C3669	vbottom<7>#652	vssa#138	4.04992e-15
C3670	vout#35	vssa#138	7.21848e-16
C3671	vbottom<4>#82	vbottom<4>	2.92025e-17
C3672	vbottom<6>#440	vssa#138	4.56915e-15
C3673	vout#161	net3	3.39548e-17
C3674	XI10/net2#19	XI10/net2#14	2.49701e-17
C3675	vbottom<5>#4	vref	3.1804e-17
C3676	ctl<4>#10	vssa#120	2.71322e-17
C3677	vout#216	vbottom<7>#242	2.35792e-15
C3678	vssa#819	sample#15	2.64214e-17
C3679	vout#104	vssa#138	7.17954e-16
C3680	vout#161	vbottom<3>#13	1.62809e-17
C3681	vbottom<7>#267	vssa#138	4.63139e-15
C3682	vout#179	vbottom<6>#367	2.57588e-17
C3683	vssa#771	vssa#770	3.45968e-17
C3684	vout#183	vout#191	4.03581e-17
C3685	vbottom<6>#177	vbottom<4>#14	4.23995e-17
C3686	vout#200	vbottom<7>#210	2.70367e-17
C3687	vout#98	vbottom<7>#634	3.02268e-17
C3688	vssa#640	vssa#138	4.45629e-15
C3689	vout#184	vout#160	3.58176e-17
C3690	vssa#818	vssa#514	2.21831e-17
C3691	XI10/enb#29	XI10/enb#14	2.90164e-17
C3692	vbottom<1>#13	vbottom<2>	2.10989e-15
C3693	vssa#772	vssa#282	2.21768e-17
C3694	vout#176	vbottom<6>#65	2.21768e-17
C3695	vout#59	vssa#138	4.85604e-16
C3696	vout#45	vbottom<1>#22	2.28895e-15
C3697	vssa#321	vssa#138	4.38716e-15
C3698	vout#195	vssa#138	6.68642e-16
C3699	vout#107	vout#84	3.65289e-17
C3700	vbottom<6>#4	vref	3.1804e-17
C3701	vssa#817	vbottom<7>#569	3.64851e-17
C3702	vout#130	vout#74	4.18065e-17
C3703	vout#164	vref	1.47067e-17
C3704	vout#225	vbottom<6>#126	2.94458e-17
C3705	vssa#538	vssa#138	4.37433e-15
C3706	vout#93	vout#103	4.18065e-17
C3707	vout#175	vbottom<7>#101	3.36843e-17
C3708	vout#207	vbottom<6>#91	3.43058e-17
C3709	vbottom<7>#533	vbottom<7>#514	1.64615e-17
C3710	vout#127	vssa#138	7.86881e-16
C3711	vout#52	vout#61	8.27234e-17
C3712	vssa#773	vssa#285	2.25845e-17
C3713	vout#52	vbottom<5>#146	2.43234e-16
C3714	vout#115	vout#122	4.18065e-17
C3715	vbottom<7>#643	vbottom<3>#15	3.49222e-17
C3716	vout#153	vout#97	4.18065e-17
C3717	vssa#795	vssa#796	3.49674e-17
C3718	vout#150	vbottom<7>#288	2.70367e-17
C3719	vout#109	vref	2.59116e-17
C3720	vout#95	vbottom<5>#125	2.94458e-17
C3721	vout#258	vssa#138	7.86881e-16
C3722	vout#139	vout#163	3.49974e-17
C3723	XI10/net2#21	vdda#24	4.82219e-17
C3724	vbottom<7>#4	vref	3.1804e-17
C3725	vout#58	vout#35	4.03076e-17
C3726	vout#255	vssa#138	6.7639e-16
C3727	vssa#802	vssa#636	2.21768e-17
C3728	vout#51	vbottom<7>#631	3.19307e-17
C3729	vout#241	vout#230	4.03581e-17
C3730	vout#75	vbottom<0>	3.87599e-17
C3731	vout#256	vbottom<6>#47	2.43751e-15
C3732	vssa#824	vbottom<7>#896	3.64851e-17
C3733	vout#224	vbottom<7>#777	2.25142e-15
C3734	vout#185	vssa#138	6.78306e-16
C3735	vout#98	vbottom<5>#13	1.87785e-17
C3736	vout#36	vref	7.80294e-17
C3737	vout#47	vbottom<4>#98	2.43234e-16
C3738	vout#151	vbottom<7>#154	2.94458e-17
C3739	vssa#804	vssa#648	2.36483e-15
C3740	vssa#217	vssa#164	7.79041e-17
C3741	vout#35	vbottom<6>#192	2.94458e-17
C3742	vssa#795	vbottom<7>#170	3.64851e-17
C3743	vssa#774	vssa#138	5.63017e-16
C3744	vout#163	vout#194	3.49974e-17
C3745	vssa#777	vssa#776	3.49788e-17
C3746	vbottom<6>#428	vssa#138	4.63139e-15
C3747	vbottom<7>#519	vbottom<7>#501	3.60301e-17
C3748	vout#189	vbottom<7>#596	4.75233e-17
C3749	ctl<1>#10	ctl<0>#10	5.26935e-17
C3750	vout#34	vref	9.65058e-17
C3751	vssa#803	vout#211	4.05119e-17
C3752	vbottom<7>#483	vbottom<7>#250	3.60301e-17
C3753	vout#122	vbottom<7>#459	5.90278e-17
C3754	vout#102	vbottom<6>#210	2.21818e-17
C3755	vout#230	vbottom<6>#367	2.57588e-17
C3756	vout#248	vbottom<6>#361	2.94458e-17
C3757	vout#181	vbottom<6>#402	2.29057e-17
C3758	vbottom<6>#376	vbottom<6>#15	1.67852e-17
C3759	vout#199	vbottom<7>#267	2.70367e-17
C3760	vout#267	vbottom<7>#366	2.42764e-15
C3761	vout#127	vout#107	3.58176e-17
C3762	vout#203	vbottom<4>#82	2.94458e-17
C3763	vout#180	vssa#535	5.90278e-17
C3764	vout#119	vout#155	3.58176e-17
C3765	vout#33	vbottom<7>#628	3.19307e-17
C3766	vout#217	vbottom<7>#95	2.43454e-15
C3767	vout#75	vout#41	4.03581e-17
C3768	vout#37	vbottom<6>#379	2.31703e-15
C3769	vout#235	vbottom<7>#86	2.21768e-17
C3770	vout#102	vssa#138	7.24975e-16
C3771	vout#30	vout#28	3.57086e-17
C3772	vout#112	vout#89	3.49973e-17
C3773	vbottom<7>#80	vssa#138	4.51244e-15
C3774	vssa#163	vssa#138	3.37279e-16
C3775	vbottom<3>#11	vbottom<3>#9	1.1885e-17
C3776	vssa#783	vssa#782	3.49973e-17
C3777	vout#72	vbottom<5>#202	2.94458e-17
C3778	vssa#778	vbottom<7>#77	3.64851e-17
C3779	vssa#823	vssa#499	2.21831e-17
C3780	vssa#211	vssa#144	2.65824e-17
C3781	vout#177	vbottom<5>#122	2.94458e-17
C3782	vout#223	vout#195	4.18065e-17
C3783	vout#167	vssa#138	7.16007e-16
C3784	vout#63	vbottom<2>#36	2.62403e-17
C3785	vssa#760	vssa#759	3.49664e-17
C3786	vout#194	vout#213	3.49974e-17
C3787	vbottom<6>#189	vssa#138	3.46704e-15
C3788	vbottom<6>#9	ctl<6>#10	2.16576e-17
C3789	vout#81	vbottom<5>#175	2.42319e-15
C3790	vout#154	vout#131	3.58176e-17
C3791	vout#101	vout#112	4.18065e-17
C3792	vssa#823	vssa#210	3.44888e-16
C3793	vssa#757	vbottom<7>#789	3.64851e-17
C3794	vout#51	vssa#138	7.30405e-16
C3795	vout#69	vbottom<7>#497	2.16626e-17
C3796	vssa#164	vssa#163	3.48573e-17
C3797	vout#190	vout#166	3.49973e-17
C3798	vssa#795	vssa#616	2.3665e-17
C3799	vout#95	vout#124	3.58176e-17
C3800	vout#172	vbottom<7>#162	2.25978e-15
C3801	vout#159	vout#137	3.58176e-17
C3802	vdda#6	vdda	2.998e-17
C3803	vout#40	vssa#138	4.41632e-16
C3804	vout#206	vout#211	3.96617e-17
C3805	XI10/vbsl#11	XI10/enb#31	4.95344e-17
C3806	vout#22	vbottom<6>#201	2.50498e-17
C3807	vout#122	vbottom<6>#334	2.21768e-17
C3808	vout#205	vout#209	4.03581e-17
C3809	vout#151	vbottom<7>#291	2.70367e-17
C3810	vout#115	vbottom<6>#321	2.94458e-17
C3811	vout#95	vbottom<4>#83	2.30029e-15
C3812	vout#213	vbottom<6>#126	2.35835e-15
C3813	vbottom<5>#9	ctl<5>#8	8.6888e-18
C3814	vout#169	vssa#138	6.44838e-16
C3815	vbottom<7>#393	vssa#138	4.51626e-15
C3816	vout#104	vbottom<6>#308	2.94458e-17
C3817	vout#181	vout#189	4.18065e-17
C3818	vout#220	vbottom<7>#783	2.77798e-17
C3819	vout#187	vbottom<6>#62	5.90278e-17
C3820	vssa#792	vout#174	4.05119e-17
C3821	vout#255	vbottom<7>#83	2.2191e-17
C3822	vssa#779	vssa#306	2.36319e-15
C3823	vssa#758	vssa#477	2.38809e-15
C3824	vout#219	vssa#138	3.23905e-16
C3825	vout#274	vout#268	4.18065e-17
C3826	vbottom<4>#86	vbottom<1>#13	2.81951e-16
C3827	vout#55	vbottom<4>#73	2.94458e-17
C3828	vout#230	vbottom<3>#12	1.80349e-17
C3829	vssa#104	ctl<0>	1.98308e-16
C3830	vout#86	vout#66	3.58176e-17
C3831	vbottom<6>#417	vssa#138	4.63783e-15
C3832	vout#103	vbottom<6>#219	2.43458e-15
C3833	vbottom<6>#376	vbottom<5>#15	3.15028e-16
C3834	vbottom<3>#23	vssa#138	4.11029e-15
C3835	vbottom<7>#646	vbottom<1>#11	3.86904e-17
C3836	vssa#483	vssa#138	3.88569e-15
C3837	vbottom<7>#795	vssa#138	4.62744e-15
C3838	vout#266	vbottom<6>#44	2.94458e-17
C3839	vout#73	vssa#138	8.04731e-16
C3840	vbottom<7>#242	vssa#138	1.46901e-14
C3841	vout#220	vssa#471	2.37383e-17
C3842	vout#110	vout#94	4.03581e-17
C3843	vout#218	vbottom<6>#59	2.21768e-17
C3844	vout#195	vbottom<5>#44	5.90278e-17
C3845	vssa#817	vref	1.74722e-16
C3846	vbottom<3>#11	vdda#30	2.32594e-16
C3847	vbottom<5>#13	vbottom<5>#15	1.88447e-17
C3848	vout#123	vbottom<6>#275	2.70367e-17
C3849	vout#189	vbottom<7>#672	2.43457e-15
C3850	vssa#803	vbottom<7>#234	3.64851e-17
C3851	vout#235	vbottom<7>#92	2.2191e-17
C3852	vbottom<1>#18	vssa#138	3.55487e-15
C3853	sample#14	XI10/enb#16	6.75635e-17
C3854	vssa#777	vref	1.25441e-16
C3855	vbottom<7>#681	vssa#138	4.37301e-15
C3856	vbottom<7>#194	vbottom<7>#202	4.05222e-17
C3857	vin#10	vssa#84	1.3176e-17
C3858	vout#262	vssa#138	6.66904e-16
C3859	vout#193	net3#11	3.14807e-17
C3860	vbottom<1>#13	vssa#138	1.03251e-15
C3861	vout#138	vbottom<6>#275	2.94458e-17
C3862	vout#186	vbottom<7>#139	2.65279e-17
C3863	vout#214	vbottom<5>#113	2.2191e-17
C3864	vssa#776	vssa#300	2.25845e-17
C3865	vout#144	vbottom<7>#550	2.94458e-17
C3866	vout#16	vbottom<7>#943	1.10504e-16
C3867	vbottom<3>#62	vssa#138	4.24122e-15
C3868	vssa#783	vssa#318	2.36774e-15
C3869	vssa#765	vbottom<7>#765	3.64851e-17
C3870	sample#9	vref	2.20551e-17
C3871	vout#207	vssa#138	6.66904e-16
C3872	vout#258	vout#263	3.58176e-17
C3873	vout#268	vbottom<7>#360	5.81669e-17
C3874	vout#97	vout#130	3.49973e-17
C3875	vbottom<6>#364	vbottom<3>#12	2.81951e-16
C3876	vout#19	vbottom<6>#392	2.67924e-17
C3877	vout#255	vout#260	3.49973e-17
C3878	vout#140	vbottom<6>#137	1.31519e-17
C3879	vout#206	vout#191	3.58176e-17
C3880	vssa#751	vssa#493	2.63298e-17
C3881	vout#20	vbottom<6>#393	2.29007e-17
C3882	vout#110	vbottom<5>#202	3.19307e-17
C3883	vout#260	vbottom<7>#74	2.21768e-17
C3884	vout#281	vssa#138	5.86086e-16
C3885	sample#10	vref	2.23762e-17
C3886	vbottom<7>#447	vssa#138	4.51049e-15
C3887	vbottom<6>#358	vssa#138	4.63139e-15
C3888	vout#176	vbottom<6>#71	2.2191e-17
C3889	vout#133	vssa#818	4.18065e-17
C3890	vssa#753	vssa#495	2.52128e-17
C3891	vout#60	vout#69	4.18065e-17
C3892	vout#274	vbottom<7>#363	2.26006e-17
C3893	vout#78	vssa#138	5.02922e-16
C3894	vbottom<7>#146	vssa#138	4.63533e-15
C3895	vout#191	vbottom<7>#270	2.70367e-17
C3896	ctl<5>#10	ctl<5>#8	2.72821e-17
C3897	vout#225	vbottom<7>#381	5.90217e-17
C3898	vssa#766	vssa#456	2.3666e-17
C3899	vout#112	vbottom<7>#555	8.05014e-17
C3900	vbottom<7>#649	vbottom<3>#12	2.81951e-16
C3901	vout#205	vbottom<7>#242	2.50383e-15
C3902	vssa#818	sample#15	5.28117e-17
C3903	XI10/net2#14	vref	1.75479e-17
C3904	vssa#774	vout#276	4.18065e-17
C3905	vssa#793	vssa#604	2.36483e-15
C3906	vbottom<4>#95	vssa#138	4.51635e-15
C3907	vssa#217	vssa#163	1.45488e-17
C3908	vout#215	vssa#821	4.18065e-17
C3909	vout#16	vbottom<7>#614	2.41978e-17
C3910	vout#216	vssa#138	5.75911e-16
C3911	vbottom<7>#640	vbottom<0>#11	4.23995e-17
C3912	vssa#471	vbottom<0>#11	2.83481e-16
C3913	vout#258	vout#248	4.03581e-17
C3914	vssa#771	vout#281	4.11102e-17
C3915	XI10/net2#13	vref	1.63895e-17
C3916	vout#198	vbottom<7>#250	2.41086e-15
C3917	vdda#19	vdda#5	4.37283e-17
C3918	vout#257	vbottom<7>#715	3.43058e-17
C3919	vbottom<7>#631	vssa#138	4.63149e-15
C3920	vout#152	vbottom<7>#294	2.67924e-17
C3921	vout#20	vssa#138	8.16616e-16
C3922	vout#49	vbottom<4>#48	4.15297e-17
C3923	vssa#817	vout#12	2.66578e-17
C3924	vout#174	vbottom<7>#117	3.85473e-17
C3925	vout#79	vbottom<7>#514	1.6331e-17
C3926	vout#73	vbottom<4>#28	2.21768e-17
C3927	vout#203	vbottom<3>#13	1.80349e-17
C3928	XI10/enb#13	vref	1.33651e-17
C3929	vssa#782	vssa#781	3.49973e-17
C3930	vout#103	vssa#138	6.76415e-16
C3931	vout#37	vbottom<6>#392	4.14172e-17
C3932	vout#70	vbottom<7>#533	5.08519e-17
C3933	vout#46	vbottom<6>#376	2.94458e-17
C3934	vssa#612	vssa#138	4.46427e-15
C3935	vssa#465	net3#11	5.17515e-17
C3936	vout#146	vbottom<6>#434	3.19307e-17
C3937	vssa#483	vbottom<7>#13	2.94549e-16
C3938	vout#167	vbottom<6>#434	2.70367e-17
C3939	vout#116	vbottom<6>#269	2.70367e-17
C3940	vssa#763	vssa#459	2.21539e-17
C3941	vssa#784	vout#217	4.18065e-17
C3942	XI10/enb#14	vref	2.23313e-17
C3943	vout#86	vout#72	4.03581e-17
C3944	vout#188	vbottom<7>#780	2.57588e-17
C3945	vssa#753	vbottom<7>#896	3.8058e-17
C3946	vout#256	vout#246	4.03581e-17
C3947	vssa#786	vssa#327	2.31304e-15
C3948	vssa#300	vssa#138	4.40804e-15
C3949	vout#31	vout#22	4.03581e-17
C3950	vout#254	vbottom<4>#13	1.97224e-17
C3951	vout#100	vssa#817	4.18065e-17
C3952	vbottom<7>#13	vssa#138	1.41686e-16
C3953	vout#75	vssa#138	6.24284e-16
C3954	vbottom<4>#14	vssa#138	6.14143e-16
C3955	vout#232	vbottom<5>#110	3.43058e-17
C3956	vout#106	vbottom<5>#183	2.94458e-17
C3957	vout#135	vbottom<7>#447	2.21768e-17
C3958	vssa#815	vssa#523	2.21768e-17
C3959	vout#230	vbottom<4>#14	2.39285e-17
C3960	vout#54	vout#30	3.49973e-17
C3961	vout#17	vbottom<7>#663	4.91449e-17
C3962	XI10/enb#15	vref	2.38522e-17
C3963	vout#142	vbottom<6>#186	2.30029e-15
C3964	vout#71	vbottom<5>#155	2.21768e-17
C3965	vbottom<3>#15	vbottom<1>#11	1.08281e-16
C3966	vout#241	vout#248	3.58176e-17
C3967	vout#131	vssa#138	7.86881e-16
C3968	vbottom<7>#297	vssa#138	4.57666e-15
C3969	vout#161	vout#142	3.96617e-17
C3970	vbottom<6>#4	vssa#22	2.32965e-17
C3971	vout#159	vbottom<6>#428	2.70367e-17
C3972	vbottom<4>#61	vbottom<4>#73	4.05222e-17
C3973	vbottom<4>#86	vbottom<0>	3.15028e-16
C3974	vssa#810	vssa#541	2.36349e-15
C3975	vout#84	vout#83	4.03581e-17
C3976	vout#138	vbottom<6>#428	3.19307e-17
C3977	XI10/net2#15	vref	2.43174e-17
C3978	vout#124	net3	3.87599e-17
C3979	vout#29	vssa#755	4.05119e-17
C3980	vssa#770	vssa#768	3.61262e-17
C3981	vout#229	vssa#138	6.76427e-16
C3982	vdda#5	vref	2.11572e-17
C3983	vout#245	vbottom<7>#80	5.90278e-17
C3984	vbottom<7>#652	vref	1.30288e-16
C3985	vout#78	vbottom<7>#681	1.64895e-17
C3986	vssa#499	vssa#208	1.32372e-15
C3987	vssa#771	vssa#278	2.40403e-17
C3988	vout#151	vssa#138	7.86515e-16
C3989	vout#230	vbottom<6>#180	2.94458e-17
C3990	vbottom<5>#11	vssa#96	2.92389e-17
C3991	vout#26	vout#25	3.57086e-17
C3992	vout#146	vbottom<6>#423	2.70367e-17
C3993	vssa#820	vssa#208	1.37238e-16
C3994	ctl<4>#8	vref	3.45458e-17
C3995	vbottom<6>#216	vssa#138	4.51243e-15
C3996	vssa#780	vssa#309	2.36317e-15
C3997	vout#154	vbottom<6>#269	2.94458e-17
C3998	vout#251	vout#240	4.18065e-17
C3999	vout#153	vbottom<4>#28	3.43058e-17
C4000	vout#268	vssa#138	6.74802e-16
C4001	vout#154	vbottom<6>#423	3.19307e-17
C4002	vout#137	vbottom<5>#210	2.94458e-17
C4003	vout#193	vbottom<3>#12	2.292e-17
C4004	vout#213	vbottom<6>#68	3.43058e-17
C4005	vout#25	vbottom<6>#195	2.94458e-17
C4006	vout#196	vssa#624	3.40614e-17
C4007	XI10/enb#30	XI10/vbsl#11	1.5052e-16
C4008	vbottom<6>#364	vbottom<4>#13	2.2986e-17
C4009	vout#136	vout#144	4.18065e-17
C4010	vout#204	vbottom<3>#15	2.20446e-17
C4011	vout#162	vbottom<7>#297	2.36882e-17
C4012	vout#77	vbottom<7>#569	1.23006e-17
C4013	vout#223	vbottom<5>#41	2.21768e-17
C4014	vssa#780	vssa#138	5.7257e-16
C4015	vout#18	vbottom<7>#666	2.4463e-15
C4016	vbottom<5>#2	vbottom<5>	2.68388e-17
C4017	vbottom<7>#634	vbottom<6>#14	2.68607e-17
C4018	vout#235	vssa#315	5.90247e-17
C4019	vout#88	vref	4.6348e-17
C4020	vout#157	vbottom<7>#678	2.21818e-17
C4021	vbottom<3>#12	vssa#465	1.72022e-17
C4022	vout#220	vout#188	3.96617e-17
C4023	vout#253	vbottom<6>#53	3.43058e-17
C4024	vout#36	vout#34	3.69493e-17
C4025	vout#260	vbottom<7>#375	3.43058e-17
C4026	vout#238	vout#225	4.18065e-17
C4027	ctl<2>#8	vref	3.45458e-17
C4028	vout#211	vbottom<7>#234	2.25978e-15
C4029	vout#131	vbottom<6>#264	2.70367e-17
C4030	vout#63	vbottom<3>#53	4.32005e-17
C4031	vout#84	vbottom<5>#69	2.42745e-15
C4032	vout#183	vbottom<7>#273	2.70367e-17
C4033	vout#221	vssa#652	3.40614e-17
C4034	vbottom<7>#649	vref	2.60624e-16
C4035	vssa#88	ctl<7>#10	2.35049e-17
C4036	vout#170	vbottom<7>#186	2.70367e-17
C4037	vssa#807	vssa#809	3.61561e-17
C4038	vbottom<7>#789	vbottom<7>#15	1.58452e-17
C4039	vout#165	vssa#138	5.63486e-16
C4040	vbottom<7>#59	vssa#138	4.85765e-15
C4041	ctl<1>#8	vref	3.45448e-17
C4042	vbottom<3>#53	net3	7.72172e-17
C4043	vbottom<7>#15	vssa#138	1.61947e-16
C4044	vssa#755	vssa#754	3.49664e-17
C4045	vbottom<5>#11	ctl<5>#10	3.43339e-18
C4046	vbottom<6>	vref#41	3.12455e-17
C4047	vssa#820	vbottom<7>#596	3.64851e-17
C4048	vout#257	vbottom<7>#375	2.26006e-17
C4049	vout#110	vbottom<4>#61	2.94458e-17
C4050	vout#94	vbottom<6>#275	2.94458e-17
C4051	vout#253	vbottom<7>#715	2.2191e-17
C4052	vout#221	vssa#809	4.11102e-17
C4053	vout#180	vssa#138	6.76436e-16
C4054	vout#166	vbottom<7>#696	2.43458e-15
C4055	vout#86	vbottom<5>#197	2.94458e-17
C4056	vout#95	vbottom<2>	1.80349e-17
C4057	vbottom<7>#555	vssa#138	4.38595e-15
C4058	vout#132	vbottom<7>#786	2.24922e-15
C4059	vout#139	vout#129	3.56638e-17
C4060	ctl<0>#8	vref	3.45458e-17
C4061	vout#131	vbottom<6>#275	3.19307e-17
C4062	vssa#657	vssa#138	3.74815e-15
C4063	vout#225	vbottom<7>#721	2.21768e-17
C4064	vout#100	vssa#520	5.36458e-17
C4065	vout#190	vbottom<7>#264	3.43058e-17
C4066	vout#192	vbottom<7>#202	2.70367e-17
C4067	vbottom<1>#4	vssa#38	2.32965e-17
C4068	vout#175	vout#174	3.96617e-17
C4069	vout#24	vout#29	3.58176e-17
C4070	vout#21	vssa#138	5.73247e-16
C4071	vout#242	vssa#312	5.90247e-17
C4072	vout#140	vbottom<6>#114	3.59352e-17
C4073	vout#208	vbottom<5>#50	2.2191e-17
C4074	vout#76	vbottom<6>#13	1.38946e-17
C4075	vout	vref	6.07774e-15
C4076	vssa#799	vssa#632	2.3665e-17
C4077	vbottom<4>#45	vssa#138	2.86397e-16
C4078	vssa#502	vssa#210	2.70576e-15
C4079	vbottom<3>#59	vref	1.20131e-16
C4080	vbottom<7>#709	vssa#138	4.51244e-15
C4081	vout#54	vssa#138	4.93331e-16
C4082	vout#144	vbottom<6>#402	2.36841e-15
C4083	vout#229	vout#236	3.49973e-17
C4084	vbottom<7>#646	vref	2.6295e-16
C4085	vout#221	vout#209	3.49973e-17
C4086	vbottom<5>#11	vdda#30	1.13164e-16
C4087	vout#194	vout#140	4.18376e-17
C4088	vin	vref	4.22237e-15
C4089	vout#120	vout#157	3.49973e-17
C4090	vout#168	vssa#138	7.86881e-16
C4091	vout#110	vbottom<6>#269	2.94458e-17
C4092	ctl<5>#8	vref	3.45448e-17
C4093	vout#265	vssa#300	5.90247e-17
C4094	vbottom<7>#372	vssa#138	4.53336e-15
C4095	vbottom<6>#186	vbottom<3>#16	2.68607e-17
C4096	vout#49	net3#17	2.94458e-17
C4097	vout#276	vbottom<7>#363	3.43058e-17
C4098	vssa#798	vssa#799	3.49674e-17
C4099	vbottom<7>#780	vbottom<2>#11	3.86904e-17
C4100	vout#212	net3#11	3.87599e-17
C4101	vbottom<5>#56	vssa#138	4.51245e-15
C4102	vdda	vref	8.6194e-15
C4103	vout#119	vssa#138	5.6966e-16
C4104	vout#263	vssa#764	4.05119e-17
C4105	vout#103	vbottom<7>#497	1.15045e-17
C4106	vbottom<6>#389	vssa#138	4.90277e-15
C4107	vssa#818	vref	1.10096e-16
C4108	vout#279	vbottom<7>#748	2.32591e-15
C4109	vout#35	vbottom<4>#92	2.94458e-17
C4110	vssa#462	vssa#138	3.89917e-15
C4111	vbottom<4>#86	vbottom<3>#16	2.68607e-17
C4112	vout#96	vbottom<6>#71	5.87804e-17
C4113	vout#56	vssa#138	8.61418e-16
C4114	vout#134	vbottom<7>#519	2.42319e-15
C4115	sample	vref	3.75133e-15
C4116	vout#121	vbottom<7>#537	1.15045e-17
C4117	vbottom<7>#14	vbottom<7>#15	1.62162e-16
C4118	vout#141	vbottom<2>#32	2.99146e-17
C4119	vout#40	vbottom<2>#14	6.08318e-17
C4120	vout#54	vbottom<4>#101	1.6331e-17
C4121	vbottom<6>#62	vssa#138	4.51244e-15
C4122	ctl<7>#8	vref	3.45448e-17
C4123	vout#39	vbottom<2>	1.59697e-17
C4124	vbottom<3>#56	vref	9.61055e-17
C4125	vout#235	vbottom<7>#387	3.43058e-17
C4126	vssa#797	vssa#620	2.36483e-15
C4127	vssa#795	vssa#138	7.43413e-16
C4128	vssa#776	vref	1.09998e-16
C4129	vout#124	vbottom<3>#13	2.34729e-17
C4130	vssa#520	vssa#208	1.20476e-15
C4131	vbottom<7>#643	vref	2.60624e-16
C4132	vout#39	vref	4.72215e-17
C4133	vout#73	vout#97	3.49973e-17
C4134	vout#152	vbottom<7>#146	4.15297e-17
C4135	vout#271	vbottom<7>#360	2.25845e-17
C4136	ctl_dum	vref	1.66796e-16
C4137	vbottom<5>#137	vssa#138	4.57705e-15
C4138	vssa#807	vssa#652	2.63025e-17
C4139	vout#197	vssa#511	5.90217e-17
C4140	vssa#109	vssa#108	4.38474e-17
C4141	vout#82	vbottom<6>#264	2.94458e-17
C4142	vssa#755	vssa#489	2.3666e-17
C4143	vout#233	vout#218	4.18065e-17
C4144	vout#136	vbottom<6>#204	2.39012e-15
C4145	vbottom<7>#658	vssa#138	4.63149e-15
C4146	vout#239	vssa#138	7.15958e-16
C4147	vssa#760	vssa#471	2.39615e-15
C4148	vout#274	vout#277	3.49788e-17
C4149	vout#236	vout#243	3.49973e-17
C4150	vout#166	vbottom<7>#501	1.15045e-17
C4151	vssa#822	vssa#505	2.3635e-15
C4152	ctl<7>	vref	1.68682e-16
C4153	vout#190	vbottom<7>#242	2.45676e-15
C4154	vssa#817	sample#15	2.63903e-17
C4155	vout#96	vssa#138	8.04731e-16
C4156	vbottom<7>#276	vssa#138	4.63139e-15
C4157	vbottom<3>#15	vbottom<0>#11	1.09015e-15
C4158	vbottom<7>#501	vssa#138	4.54669e-15
C4159	vout#280	vout#277	4.03581e-17
C4160	vout#50	vbottom<0>	4.17185e-17
C4161	vbottom<6>#13	vbottom<6>#15	1.87536e-17
C4162	vbottom<5>#189	vssa#138	4.47621e-15
C4163	vssa#648	vssa#138	4.4388e-15
C4164	vout#73	vbottom<4>#35	2.37165e-17
C4165	vout#43	vbottom<3>#26	1.9333e-16
C4166	vout#243	vbottom<6>#56	2.2191e-17
C4167	vout#125	vbottom<6>#264	2.94458e-17
C4168	vbottom<6>#373	vbottom<3>#15	3.00037e-16
C4169	vout#105	vbottom<6>#269	2.70367e-17
C4170	vbottom<1>#9	ctl<1>#10	1.43752e-17
C4171	vout#127	vout#126	4.03581e-17
C4172	ctl<6>	vref	1.68682e-16
C4173	vssa#765	vssa#138	5.81501e-16
C4174	vbottom<3>#53	vref	6.02146e-17
C4175	vbottom<5>#183	vssa#138	4.8874e-15
C4176	vout#119	vbottom<6>#370	2.57588e-17
C4177	vout#165	vout#197	3.49973e-17
C4178	vssa#327	vssa#138	4.12533e-15
C4179	vout#266	vbottom<7>#765	2.94458e-17
C4180	vbottom<7>#640	vref	2.60491e-16
C4181	vbottom<5>#122	vbottom<4>#14	3.08017e-16
C4182	vssa#777	vssa#138	5.63017e-16
C4183	XI10/vbsh#34	vref	3.22385e-16
C4184	vout#168	vbottom<7>#276	2.70367e-17
C4185	vout#107	vbottom<6>#134	3.19307e-17
C4186	vout#150	vbottom<6>#109	2.94458e-17
C4187	ctl<5>	vref	1.68682e-16
C4188	vssa#544	vssa#138	4.12315e-15
C4189	vssa#782	vout#235	4.18065e-17
C4190	vout#104	vbottom<5>#175	8.05014e-17
C4191	vout#133	vbottom<7>#569	2.21768e-17
C4192	vout#71	vout#80	4.18065e-17
C4193	vout#280	vout#281	3.49788e-17
C4194	vssa#784	vssa#138	5.7258e-16
C4195	vssa#785	vbottom<7>#98	3.64851e-17
C4196	vout#165	vbottom<7>#587	2.38869e-15
C4197	vbottom<2>#19	vbottom<2>#22	1.0998e-17
C4198	vssa#813	vssa#529	2.21768e-17
C4199	vssa#146	vssa#147	2.22866e-17
C4200	vout#102	vbottom<7>#550	4.95444e-17
C4201	vout#68	vbottom<7>#514	1.32702e-16
C4202	XI10/vbsh#33	vref	2.16384e-16
C4203	vout#76	vbottom<7>#792	2.78839e-17
C4204	vout#73	vout#65	3.56638e-17
C4205	ctl<4>	vref	1.66796e-16
C4206	vssa#795	vout#171	4.05119e-17
C4207	vout#57	vbottom<1>#18	2.44483e-15
C4208	vbottom<2>	vbottom<2>#36	4.45701e-17
C4209	vbottom<7>#789	vbottom<6>#13	2.10758e-16
C4210	vbottom<4>#13	vref	1.61239e-15
C4211	vout#222	vbottom<7>#89	5.90278e-17
C4212	vbottom<7>#550	vbottom<7>#533	3.6031e-17
C4213	ctl<3>	vref	1.68682e-16
C4214	vssa#780	vbottom<7>#83	3.64851e-17
C4215	vssa#795	vssa#608	2.21768e-17
C4216	vout#91	vssa#138	6.79158e-16
C4217	vbottom<7>#186	vssa#138	4.65312e-15
C4218	vout#155	vbottom<3>#15	1.67883e-17
C4219	ctl_dum#10	vssa#116	2.71322e-17
C4220	vout#199	vbottom<7>#234	2.94458e-17
C4221	vout#50	vout#32	4.17761e-17
C4222	vssa#777	vbottom<7>#74	3.64851e-17
C4223	vout#62	vbottom<5>#152	5.90278e-17
C4224	vbottom<7>#637	vref	2.5939e-16
C4225	vssa#802	vssa#138	7.50447e-16
C4226	vssa#116	vssa#1	1.11589e-17
C4227	ctl<2>	vref	1.69921e-16
C4228	vout#252	vbottom<6>#358	2.31737e-15
C4229	vout#80	vout#60	3.49973e-17
C4230	vout#82	vbottom<5>#197	2.70367e-17
C4231	vin#10	XI10/net2#19	3.44878e-18
C4232	vbottom<6>#13	vref	1.07066e-15
C4233	vout#25	vssa#138	8.61259e-16
C4234	vout#55	vbottom<2>#22	3.43058e-17
C4235	vssa#213	vssa#138	1.67251e-16
C4236	vout#213	vbottom<6>#114	2.27271e-17
C4237	vout#180	vbottom<7>#250	2.21768e-17
C4238	ctl<1>	vref	1.34552e-16
C4239	vout#262	vout#253	4.18065e-17
C4240	vout#176	vbottom<6>#137	1.15136e-17
C4241	vout#40	vbottom<3>#59	4.71962e-17
C4242	vbottom<7>#786	vbottom<6>#14	7.14612e-17
C4243	vout#115	vssa#138	7.16007e-16
C4244	vout#154	vout#138	4.03581e-17
C4245	vout#91	vbottom<7>#497	2.38868e-15
C4246	vout#180	vbottom<7>#483	2.42319e-15
C4247	ctl<0>	vref	1.33242e-16
C4248	vout#241	vbottom<4>	1.48421e-17
C4249	ctl<4>#10	ctl<4>#8	2.72711e-17
C4250	vbottom<7>#640	vbottom<3>#15	3.00037e-16
C4251	vout#70	vbottom<6>#207	2.12705e-17
C4252	vout#26	vbottom<5>#143	2.41978e-17
C4253	vout#247	vbottom<7>#372	5.90217e-17
C4254	vout#24	vout#17	4.03581e-17
C4255	vout#193	vbottom<6>#370	2.57588e-17
C4256	vssa#794	vbottom<7>#162	3.64851e-17
C4257	vout#53	vout#52	7.4616e-17
C4258	vout#52	vssa#138	4.85604e-16
C4259	vbottom<7>#13	vref	6.89275e-16
C4260	vout#166	vout#180	4.18065e-17
C4261	vout#106	vbottom<6>#264	2.70367e-17
C4262	vbottom<7>#634	vref	1.22478e-16
C4263	vout#173	vbottom<7>#154	2.25978e-15
C4264	vout#114	vbottom<7>#478	2.42319e-15
C4265	XI10/enb#38	XI10/vbsl#11	9.61551e-17
C4266	vbottom<7>#146	vbottom<7>#154	4.05222e-17
C4267	vout#141	vssa#138	5.56802e-16
C4268	vbottom<7>#86	vssa#138	4.51244e-15
C4269	vssa#148	vssa#138	3.33867e-16
C4270	vssa#775	vssa#297	2.25845e-17
C4271	vout#201	vout#217	3.49973e-17
C4272	vout#128	vbottom<6>#109	2.32389e-15
C4273	vout#265	vbottom<7>#71	2.21768e-17
C4274	vbottom<5>#128	vbottom<1>#13	2.81951e-16
C4275	vbottom<6>#137	vssa#138	5.15472e-16
C4276	vout#225	vout#233	3.49973e-17
C4277	ctl<1>	ctl<0>	3.87605e-17
C4278	vout#58	vbottom<4>#89	2.94458e-17
C4279	vout#126	vssa#138	7.86881e-16
C4280	vbottom<5>#131	vbottom<0>	4.23995e-17
C4281	vout#156	vout#134	3.49973e-17
C4282	vbottom<5>#125	net3	2.93809e-16
C4283	vssa#11	XI10/net2#5	1.35458e-17
C4284	vref#74	vref#87	4.37471e-17
C4285	vdda#22	sample#1	1.85584e-17
C4286	vref#47	vref	3.47682e-17
C4287	vssa#49	ctl<4>#3	1.00811e-17
C4288	vbottom<5>#2	vref#44	3.77308e-17
C4289	XI10/net2	XI10/vbsh	1.76435e-17
C4290	vdda#16	vref	5.08205e-17
C4291	vssa#121	ctl<4>#3	3.00008e-18
C4292	vref#91	ctl<4>#3	2.90505e-18
C4293	ctl<1>#10	ctl<1>#3	1.7687e-18
C4294	XI10/vbsh#7	vdda#16	1.11886e-16
C4295	vref#56	ctl<2>#1	2.14062e-18
C4296	XI10/enb	XI10/vbsh	8.06581e-18
C4297	XI10/vbsh#19	XI10/net2#25	4.33838e-17
C4298	vbottom<6>	ctl<6>#1	1.05245e-17
C4299	XI10/net30	vdda#27	4.83047e-17
C4300	vref#81	vref#47	1.13285e-17
C4301	vref#71	ctl<3>#1	8.01288e-19
C4302	vssa#65	ctl<0>#1	2.18653e-18
C4303	vdda#22	vdda	4.8403e-17
C4304	vssa#120	vssa#77	1.14091e-17
C4305	net3	vssa#177	1.87383e-16
C4306	XI10/enb#38	vout#3	1.22755e-17
C4307	vssa#117	ctl_dum#1	1.24892e-18
C4308	vbottom<7>#640	vssa#188	3.36964e-15
C4309	ctl<2>#10	vssa#71	1.98481e-18
C4310	ctl<4>#10	vssa#77	1.98481e-18
C4311	vssa#19	vssa#53	1.08924e-17
C4312	vout#188	vssa#188	4.94974e-16
C4313	net3#2	vref#89	3.47223e-17
C4314	ctl<0>#10	vssa#65	1.98481e-18
C4315	vssa#1	ctl_dum#3	9.06566e-18
C4316	vssa#105	vssa#65	4.36473e-17
C4317	XI10/enb#16	vssa#7	6.12423e-17
C4318	vssa#19	ctl<7>#3	1.00811e-17
C4319	vref#62	ctl<4>#1	2.14062e-18
C4320	vssa#22	ctl<6>#3	7.94052e-18
C4321	XI10/net30	XI10/net30#2	3.27586e-17
C4322	vbottom<3>#2	vref#47	3.77308e-17
C4323	vin#7	XI10/vbsl#4	1.0021e-16
C4324	XI10/enb#24	XI10/enb#23	3.57646e-17
C4325	vref#71	vref#81	4.37471e-17
C4326	ctl<7>#10	ctl<7>#3	1.7687e-18
C4327	XI10/enb#21	XI10/vbsl#4	4.19192e-17
C4328	XI10/enb#34	vssa#11	6.1566e-18
C4329	vssa#27	vssa#59	1.08924e-17
C4330	vbottom<7>#4	vssa#53	1.57337e-17
C4331	vssa#760	vssa#183	1.90452e-16
C4332	vssa#3	vout#3	5.09772e-17
C4333	vssa#39	ctl<1>#3	2.14062e-18
C4334	XI10/net30#8	vdda#1	3.71349e-17
C4335	XI10/net30#8	vdda#27	4.83838e-17
C4336	XI10/enb#30	XI10/enb#3	6.41275e-18
C4337	XI10/enb#16	sample#3	9.94897e-18
C4338	vssa#1	vssa#75	2.82682e-17
C4339	vref#81	vbottom<3>#2	1.84644e-17
C4340	vbottom<6>#183	vssa#177	3.39026e-15
C4341	XI10/enb#30	vssa#11	5.14788e-18
C4342	vref#50	vbottom<0>#2	3.77308e-17
C4343	sample#10	sample#1	1.10805e-17
C4344	vssa#223	vssa#197	1.83321e-16
C4345	vout#219	vssa#178	3.00578e-16
C4346	vref#65	ctl<7>#1	1.2896e-17
C4347	XI10/vbsh#21	XI10/vbsh#20	3.55932e-17
C4348	vbottom<5>	ctl<5>#1	1.05245e-17
C4349	XI10/vbsl#7	XI10/enb#3	3.29039e-17
C4350	vbottom<0>#6	vssa#65	1.57337e-17
C4351	vbottom<2>#11	vbottom<2>#2	1.61759e-17
C4352	vssa#65	ctl<0>#3	9.06566e-18
C4353	XI10/net2#25	XI10/enb	3.25632e-17
C4354	vbottom<6>#4	vssa#23	3.63144e-17
C4355	vref#81	ctl<3>#3	2.90505e-18
C4356	vout#3	XI10/net2#3	4.98159e-17
C4357	vout#161	vssa#177	5.14601e-16
C4358	vin#3	XI10/net2#14	6.05256e-18
C4359	XI10/vbsh#22	vdda#22	1.13852e-16
C4360	ctl<4>#10	ctl<4>#3	1.05076e-18
C4361	XI10/enb#21	XI10/enb#3	1.61902e-17
C4362	vssa#112	vssa#71	1.14091e-17
C4363	XI10/net30#8	vdda#19	1.04812e-17
C4364	vssa#16	XI10/net30	9.85819e-17
C4365	XI10/net2#29	vdda#27	4.00279e-17
C4366	vssa#1	ctl<6>#1	2.18653e-18
C4367	ctl<1>#1	ctl<1>#3	1.23111e-18
C4368	XI10/net2#29	vdda#1	3.21335e-17
C4369	vbottom<4>#11	vref#91	2.85898e-17
C4370	vbottom<0>#2	vref#49	3.12455e-17
C4371	vref#58	net3#2	3.12455e-17
C4372	XI10/net2#21	XI10/net2	1.00545e-17
C4373	vssa#178	vbottom<3>#13	6.37396e-17
C4374	XI10/enb#38	vin#3	8.44069e-18
C4375	vref#81	ctl<3>#1	1.2896e-17
C4376	vssa#41	vbottom<2>#6	5.96109e-17
C4377	vbottom<2>#6	vssa#71	1.57337e-17
C4378	vbottom<7>#777	vssa#177	3.19848e-15
C4379	vref#44	vssa#27	1.0102e-17
C4380	vssa#468	vssa#177	3.14627e-15
C4381	XI10/enb#13	XI10/vbsl#4	1.10794e-17
C4382	vref#72	ctl<0>#1	8.01288e-19
C4383	vssa#93	ctl<6>#3	3.00008e-18
C4384	vssa#757	vssa#194	2.43528e-16
C4385	vbottom<2>#11	vref#87	2.53225e-17
C4386	XI10/enb#34	XI10/vbsl#7	9.13621e-17
C4387	XI10/vbsl	vdda#22	3.7805e-16
C4388	vssa#16	vref	5.5797e-16
C4389	XI10/vbsh#4	XI10/enb#29	7.49678e-17
C4390	vref#66	vref#65	4.37471e-17
C4391	vssa#183	vbottom<0>#11	7.03738e-16
C4392	vref#87	ctl<2>#3	2.90505e-18
C4393	XI10/enb#37	vssa#16	1.58782e-16
C4394	XI10/net2#32	vdda#27	4.768e-17
C4395	vssa#188	vbottom<5>#13	7.87e-16
C4396	XI10/net30	vref	4.51138e-17
C4397	vout#155	vssa#188	5.14601e-16
C4398	XI10/net30#8	vref	4.82375e-17
C4399	vref#87	ctl<2>#1	1.2896e-17
C4400	vbottom<2>#2	vref#87	3.47223e-17
C4401	vbottom<3>	ctl<3>#1	1.05245e-17
C4402	vref#79	vref#44	1.13285e-17
C4403	vdda#22	vref	2.9464e-16
C4404	vbottom<0>#6	ctl<0>#3	1.00811e-17
C4405	XI10/net2#29	vref	4.86184e-17
C4406	vin#3	XI10/net2#3	4.84975e-17
C4407	vbottom<0>#11	vref#83	2.64116e-17
C4408	vssa#19	vref	3.41661e-17
C4409	vbottom<4>#2	vbottom<4>#3	1.70984e-17
C4410	XI10/net30#8	XI10/net30#5	3.23797e-17
C4411	vssa#101	ctl<3>#3	3.00008e-18
C4412	XI10/enb#30	XI10/vbsl#7	9.88862e-17
C4413	vout#230	vssa#178	6.06369e-16
C4414	vref#56	vbottom<2>#2	3.77308e-17
C4415	XI10/vbsh#19	XI10/enb	3.38293e-17
C4416	vref#75	vref#89	4.37471e-17
C4417	XI10/enb#24	vdda	2.81069e-17
C4418	vbottom<7>#780	vssa#183	3.20093e-15
C4419	vout#220	vssa#183	3.63325e-16
C4420	vssa#477	vssa#191	3.3392e-15
C4421	XI10/vbsl#17	vdda#22	5.98298e-17
C4422	vssa#59	ctl<5>#1	2.18653e-18
C4423	vssa#23	vref	2.84719e-17
C4424	vbottom<4>#6	vssa#77	1.57337e-17
C4425	vref#44	vref#45	1.52325e-17
C4426	vssa#177	vbottom<2>#11	6.93721e-16
C4427	XI10/net2#25	XI10/net2#23	2.03693e-17
C4428	sample#14	vdda#22	1.50266e-17
C4429	XI10/vbsl#11	XI10/vbsh#19	3.78811e-17
C4430	vbottom<1>#13	vssa#183	1.92787e-16
C4431	vssa#177	vref	5.54125e-15
C4432	vssa#197	vssa#138	7.79337e-16
C4433	XI10/vbsh#19	XI10/enb#29	3.75535e-17
C4434	vin#3	XI10/net2#19	2.91349e-17
C4435	vssa#97	vssa#59	4.35723e-17
C4436	vssa#27	vref	3.41661e-17
C4437	vssa#183	vref	4.99364e-15
C4438	vin#10	vin#3	2.23913e-17
C4439	XI10/net30#8	XI10/net2#29	1.06248e-16
C4440	vdda#27	vref	5.94151e-16
C4441	vbottom<5>#11	vref#79	2.84842e-17
C4442	XI10/enb#23	vdda#22	1.51611e-17
C4443	vssa#188	vref	3.25902e-15
C4444	vref#41	ctl<6>#1	1.26651e-17
C4445	vin#10	vssa#3	2.75423e-16
C4446	vssa#104	vssa#65	1.14091e-17
C4447	vbottom<3>#15	vssa#183	4.80167e-16
C4448	vref#47	ctl<3>#1	1.26651e-17
C4449	vssa#31	vref	3.41661e-17
C4450	vssa#191	vref	2.21912e-15
C4451	vssa#109	ctl<1>#3	3.00008e-18
C4452	vssa#191	vbottom<6>#13	5.06908e-16
C4453	vssa#194	vref	1.13752e-15
C4454	vbottom<3>#4	vssa#31	5.96109e-17
C4455	XI10/vbsl#4	XI10/net2#5	3.37769e-17
C4456	vssa#761	vssa#177	1.90452e-16
C4457	XI10/enb#24	vdda#22	4.19398e-17
C4458	XI10/vbsh#21	XI10/vbsh#7	8.6815e-17
C4459	vref#53	ctl<1>#1	1.26651e-17
C4460	vssa#1	ctl<3>#1	2.18653e-18
C4461	XI10/vbsl#4	XI10/vbsl#2	1.31098e-17
C4462	vbottom<0>#6	vref	3.1804e-17
C4463	vref#79	vbottom<5>#2	1.84644e-17
C4464	vref#72	vref#83	4.37471e-17
C4465	XI10/net2#17	XI10/vbsl#4	1.13105e-17
C4466	XI10/enb#38	XI10/net2#3	5.9312e-18
C4467	vref#65	vref	4.05633e-17
C4468	vref#59	net3#2	3.77308e-17
C4469	vbottom<7>#783	vssa#188	3.4601e-15
C4470	ctl<2>#10	ctl<2>#3	1.05076e-18
C4471	sample#1	vdda	1.96823e-17
C4472	vref#66	vref	1.51525e-15
C4473	XI10/enb#13	XI10/enb#3	8.07741e-18
C4474	vssa#160	vssa#138	7.56504e-16
C4475	vssa#205	vssa#495	3.08912e-17
C4476	vssa#39	vref	2.84719e-17
C4477	vssa#41	vssa#71	1.08924e-17
C4478	vssa#11	XI10/vbsl#7	1.0238e-16
C4479	vbottom<6>#370	vssa#183	3.49007e-15
C4480	vref#49	ctl<0>#1	1.05245e-17
C4481	net3#2	ctl_dum#1	1.26651e-17
C4482	vbottom<6>#364	vssa#178	3.48659e-15
C4483	vbottom<2>#6	vref	3.1804e-17
C4484	vref#83	vref#49	1.13285e-17
C4485	vref#81	vbottom<3>	1.62579e-17
C4486	vref#85	vbottom<1>	1.62579e-17
C4487	vssa#59	ctl<5>#3	9.06566e-18
C4488	XI10/enb#14	XI10/enb	1.58127e-17
C4489	vbottom<6>#186	vssa#183	1.46998e-15
C4490	vref#87	vref#55	1.13285e-17
C4491	vref#79	vbottom<5>	1.62579e-17
C4492	XI10/vbsl#4	vref	4.30066e-17
C4493	vssa#117	ctl_dum#3	3.00008e-18
C4494	vbottom<3>#4	ctl<3>#3	1.00811e-17
C4495	net3#6	vref	3.1804e-17
C4496	XI10/vbsh#19	XI10/vbsh#4	9.2999e-17
C4497	vssa#97	ctl<5>#1	1.24892e-18
C4498	vbottom<4>#11	vbottom<4>#2	1.93929e-17
C4499	vssa#183	vbottom<0>	2.10837e-16
C4500	vssa#89	ctl<7>#1	1.24892e-18
C4501	vbottom<6>#4	ctl<6>#3	1.00811e-17
C4502	vout#237	vssa#178	6.06369e-16
C4503	vref#77	ctl<6>#3	2.90505e-18
C4504	vref#65	vref#38	1.13285e-17
C4505	vref#89	vref#58	1.13285e-17
C4506	vref#77	vbottom<6>	1.62579e-17
C4507	vbottom<1>#4	ctl<1>#3	1.00811e-17
C4508	vref#73	ctl<1>#1	8.01288e-19
C4509	ctl<2>#1	ctl<2>#3	1.23111e-18
C4510	ctl<5>#1	ctl<5>#3	1.23111e-18
C4511	vbottom<6>#2	ctl<6>#1	2.14062e-18
C4512	XI10/enb#27	vssa#16	1.3617e-16
C4513	XI10/vbsh#21	XI10/net2	2.91305e-17
C4514	vssa#105	ctl<0>#1	1.24892e-18
C4515	vssa#31	ctl<3>#3	1.00811e-17
C4516	vssa#77	ctl<4>#1	2.18653e-18
C4517	vssa#11	XI10/enb#3	3.43723e-17
C4518	vssa#7	vssa#6	2.7396e-17
C4519	XI10/net2#25	XI10/vbsh	5.77816e-18
C4520	vbottom<4>#6	vref	3.1804e-17
C4521	vbottom<3>#2	ctl<3>#1	2.14062e-18
C4522	XI10/net2#32	XI10/net2#29	1.79815e-17
C4523	vref#91	vref#61	1.13285e-17
C4524	vbottom<7>#786	vssa#191	3.37492e-15
C4525	vssa#45	ctl_dum#3	1.00811e-17
C4526	vssa#113	vbottom<2>#6	1.89594e-17
C4527	net3#6	vssa#117	1.89594e-17
C4528	XI10/enb#21	XI10/net2#5	4.75754e-18
C4529	vref#62	vbottom<4>#2	3.77308e-17
C4530	vbottom<7>#649	vssa#178	3.48659e-15
C4531	vdda#27	XI10/enb	8.1146e-18
C4532	vref#69	vref#77	4.37471e-17
C4533	vref#65	vbottom<7>	1.62579e-17
C4534	vssa#49	vbottom<4>#6	5.96109e-17
C4535	vbottom<4>#6	vssa#121	1.89594e-17
C4536	vbottom<1>#2	ctl<1>#1	2.14062e-18
C4537	XI10/net2#25	XI10/net2#35	8.60878e-17
C4538	vbottom<3>#15	vssa#188	8.77959e-16
C4539	vssa#105	vbottom<0>#6	1.89594e-17
C4540	vssa#113	ctl<2>#1	1.24892e-18
C4541	vssa#1	ctl<6>#3	9.06566e-18
C4542	vssa#7	sample#9	1.14028e-17
C4543	vref#77	vref	4.05849e-17
C4544	vbottom<5>#4	vssa#59	1.57337e-17
C4545	vref#85	vref#53	1.13285e-17
C4546	vbottom<7>#646	vssa#177	3.48763e-15
C4547	vdda#16	XI10/net2	3.43255e-17
C4548	XI10/enb#30	vdda#22	9.14752e-18
C4549	vout#204	vssa#183	6.04158e-16
C4550	XI10/net2#29	XI10/net2#27	1.32704e-17
C4551	vssa#96	vssa#59	1.14091e-17
C4552	vref#83	ctl<0>#3	2.90505e-18
C4553	vssa#758	vssa#191	3.14467e-16
C4554	vssa#205	vssa#208	6.75004e-16
C4555	XI10/net2#35	vdda#27	4.60263e-17
C4556	vssa#465	vssa#178	3.34985e-15
C4557	vssa#121	vssa#77	4.36473e-17
C4558	vref#59	ctl_dum#1	2.14062e-18
C4559	vref#79	vref	4.0593e-17
C4560	vssa#178	net3#11	1.03547e-16
C4561	vref#77	ctl<6>#1	1.2896e-17
C4562	vref#77	vref#41	1.13285e-17
C4563	vbottom<1>	ctl<1>#1	1.05245e-17
C4564	vref#65	vbottom<7>#2	1.84644e-17
C4565	sample#9	sample#3	1.13504e-17
C4566	vssa#16	vout#7	6.42512e-17
C4567	vssa#1	ctl<1>#1	2.18653e-18
C4568	XI10/vbsh#4	XI10/vbsh#2	1.49221e-17
C4569	vssa#121	ctl<4>#1	1.24892e-18
C4570	vref#81	vref	4.05849e-17
C4571	sample#12	vssa#7	8.26667e-17
C4572	vref#61	vbottom<4>#2	3.12455e-17
C4573	vbottom<4>#6	ctl<4>#3	1.00811e-17
C4574	XI10/vbsh#19	XI10/net2#35	5.49308e-17
C4575	vbottom<7>#4	vssa#19	5.96109e-17
C4576	vref#83	ctl<0>#1	1.2896e-17
C4577	vout#224	vssa#177	3.63325e-16
C4578	vref#44	vbottom<5>	3.12455e-17
C4579	vssa#1	vssa#57	1.55682e-17
C4580	vref#83	vref	4.05849e-17
C4581	vssa#471	vssa#183	3.14627e-15
C4582	vref#69	ctl<6>#1	8.01288e-19
C4583	XI10/enb#27	XI10/enb#5	9.79392e-18
C4584	vssa#16	XI10/enb#5	3.59516e-17
C4585	vbottom<1>#4	vssa#39	3.63144e-17
C4586	vssa#53	ctl<7>#1	2.18653e-18
C4587	XI10/vbsh#19	XI10/vbsh	4.12785e-17
C4588	vbottom<2>#2	vbottom<2>#3	1.70984e-17
C4589	vref#85	vref	4.05849e-17
C4590	vssa#3	vin#3	4.80308e-17
C4591	vdda#16	XI10/net2#21	3.95481e-17
C4592	vout#244	vssa#178	4.94974e-16
C4593	vref#76	vref#91	4.37471e-17
C4594	XI10/vbsh#4	XI10/vbsh	1.69223e-17
C4595	ctl<0>#10	ctl<0>#3	1.05076e-18
C4596	vssa#215	vssa#149	1.8739e-16
C4597	vbottom<1>#2	vref#85	1.84644e-17
C4598	sample#15	vssa#7	2.09549e-17
C4599	vref#89	ctl_dum#3	2.90505e-18
C4600	vref#47	vref#48	1.52325e-17
C4601	vref#89	ctl_dum#1	1.2896e-17
C4602	XI10/enb#13	XI10/net2#5	3.11803e-18
C4603	vssa#89	vssa#53	4.35723e-17
C4604	vref#87	vref	4.05849e-17
C4605	net3#6	vssa#1	1.57337e-17
C4606	vssa#77	ctl<4>#3	9.06566e-18
C4607	XI10/net2#25	XI10/net2#32	1.80214e-17
C4608	vbottom<6>#180	vssa#178	1.46921e-15
C4609	vout#193	vssa#178	1.74215e-17
C4610	XI10/net30#8	vdda#5	2.95113e-18
C4611	vssa#178	vbottom<3>#12	7.06856e-16
C4612	XI10/vbsh#21	XI10/vbsh	6.32071e-17
C4613	vref#77	vbottom<6>#2	1.84644e-17
C4614	XI10/enb#5	vref	2.53271e-17
C4615	vref#89	vref	4.05849e-17
C4616	vssa#27	ctl<5>#3	1.00811e-17
C4617	vdda#1	vref	1.07835e-17
C4618	vssa#194	vbottom<7>#14	6.7502e-17
C4619	vssa#177	vbottom<2>	3.75156e-16
C4620	XI10/vbsl#7	XI10/enb#21	3.46546e-17
C4621	XI10/vbsl#19	vdda#22	1.64671e-17
C4622	vssa#480	vssa#194	3.21823e-15
C4623	XI10/enb#3	vref	2.18699e-17
C4624	vref#91	vref	4.05849e-17
C4625	XI10/enb#34	XI10/vbsl#4	7.4672e-17
C4626	vssa#205	vssa#138	4.63031e-17
C4627	vssa#39	vssa#38	2.15194e-17
C4628	vbottom<2>#6	vbottom<2>#5	1.02415e-17
C4629	vssa#7	vssa#11	3.48356e-17
C4630	vbottom<0>#6	vbottom<0>#5	1.02415e-17
C4631	vssa#1	ctl<3>#3	9.06566e-18
C4632	vref#73	vref#85	4.37471e-17
C4633	vin#3	vout#3	8.22055e-17
C4634	vref#55	ctl<2>#1	1.05245e-17
C4635	XI10/net2#5	vref	1.03542e-17
C4636	net3#6	net3#5	1.02415e-17
C4637	vssa#31	vssa#30	1.22903e-17
C4638	XI10/net2#3	vref	1.07543e-17
C4639	XI10/vbsl#11	XI10/vbsh#21	1.25549e-17
C4640	vbottom<4>#6	vbottom<4>#5	1.02415e-17
C4641	XI10/net30	XI10/enb#5	3.1773e-17
C4642	vssa#88	vssa#53	1.14091e-17
C4643	vref#38	vref#39	1.52325e-17
C4644	vssa#27	vssa#26	1.22903e-17
C4645	vssa#53	ctl<7>#3	9.06566e-18
C4646	XI10/net2#19	XI10/net2#5	9.38554e-18
C4647	sample#3	vref	1.02547e-17
C4648	vssa#3	XI10/net2#3	4.19455e-17
C4649	vssa#194	vbottom<7>#13	1.92845e-16
C4650	XI10/enb#15	XI10/enb#5	1.59645e-17
C4651	vssa#3	vref	8.06017e-17
C4652	vssa#89	ctl<7>#3	3.00008e-18
C4653	net3#11	vref#89	2.85898e-17
C4654	vssa#23	vssa#22	2.15194e-17
C4655	vout#179	vssa#183	6.06369e-16
C4656	vssa#1	ctl_dum#1	2.18653e-18
C4657	vdda#6	sample#1	1.78995e-17
C4658	vssa#7	vref	2.12903e-16
C4659	net3#6	ctl_dum#3	1.00811e-17
C4660	vssa#71	ctl<2>#1	2.18653e-18
C4661	XI10/enb#29	XI10/enb	9.0405e-18
C4662	XI10/vbsh#7	XI10/vbsh	2.97372e-17
C4663	vssa#16	XI10/enb#15	4.64946e-18
C4664	XI10/vbsh#21	vdda#16	4.79179e-17
C4665	XI10/enb#24	XI10/enb#31	8.93678e-18
C4666	ctl<7>#1	vref	3.34386e-18
C4667	vssa#1	vssa#63	2.13405e-17
C4668	vssa#19	vssa#18	1.22903e-17
C4669	vbottom<1>#11	vref#85	2.53225e-17
C4670	vssa#97	ctl<5>#3	3.00008e-18
C4671	vbottom<4>#13	vssa#178	6.96011e-16
C4672	vout#3	vref	1.74831e-17
C4673	vbottom<5>#4	vssa#27	5.96109e-17
C4674	vref#83	vbottom<0>#2	3.47223e-17
C4675	vdda#19	vdda#1	1.1268e-17
C4676	XI10/net30#8	XI10/net30	2.22415e-17
C4677	vout#132	vssa#191	4.03206e-16
C4678	vssa#762	vssa#178	3.17076e-16
C4679	ctl<6>#1	vref	3.34386e-18
C4680	vssa#191	vbottom<6>#14	5.40402e-17
C4681	vout#212	vssa#177	6.04158e-16
C4682	vbottom<7>#11	vref#65	2.80377e-17
C4683	vin#3	vref	2.41941e-17
C4684	vin#11	vin#7	2.53542e-17
C4685	vssa#113	vssa#71	4.36473e-17
C4686	vbottom<7>#643	vssa#183	3.49007e-15
C4687	ctl<5>#1	vref	3.34386e-18
C4688	vref#70	vref#79	4.37471e-17
C4689	XI10/vbsh#4	XI10/net2#25	9.88763e-17
C4690	vin#7	vref	5.19733e-17
C4691	ctl<3>#1	vref	3.34386e-18
C4692	vout#212	vssa#178	1.74215e-17
C4693	vssa#11	vref	1.8807e-16
C4694	XI10/vbsl#7	XI10/vbsl#5	1.02519e-17
C4695	net3#11	net3#2	1.93929e-17
C4696	vref#70	ctl<5>#1	8.01288e-19
C4697	ctl<0>#1	vref	3.34386e-18
C4698	vin#3	XI10/net2#17	2.6146e-17
C4699	vref#79	ctl<5>#3	2.90505e-18
C4700	vssa#759	vssa#188	3.1393e-16
C4701	vbottom<3>#11	vref#81	2.64116e-17
C4702	vref#91	vbottom<4>#2	3.47223e-17
C4703	XI10/net30#8	XI10/enb#5	3.43399e-18
C4704	vssa#38	ctl<1>#3	7.94052e-18
C4705	ctl<1>#1	vref	3.34386e-18
C4706	vssa#105	ctl<0>#3	3.00008e-18
C4707	XI10/vbsh#7	XI10/net2	3.37543e-17
C4708	vssa#16	vout#8	3.31045e-16
C4709	vbottom<3>#12	vssa#177	4.80167e-16
C4710	ctl<2>#1	vref	3.34386e-18
C4711	vssa#16	vssa#13	1.14699e-17
C4712	vref#58	ctl_dum#1	1.05245e-17
C4713	ctl_dum#1	vref	3.34386e-18
C4714	ctl<5>#10	ctl<5>#3	1.7687e-18
C4715	vref#38	ctl<7>#1	1.26651e-17
C4716	vref#44	ctl<5>#1	1.26651e-17
C4717	vssa#23	ctl<6>#3	2.14062e-18
C4718	ctl<4>#1	vref	3.34386e-18
C4719	vssa#45	net3#6	5.96109e-17
C4720	XI10/net2#14	XI10/net2#5	1.32463e-17
C4721	vssa#178	vref	5.02212e-15
C4722	vdda#27	XI10/enb#5	1.47727e-17
C4723	vssa#221	vssa#205	1.77102e-16
C4724	vbottom<5>#13	vssa#191	4.29672e-16
C4725	ctl<7>#3	vref	3.31619e-18
C4726	vssa#1	ctl<1>#3	9.06566e-18
C4727	vbottom<0>#2	ctl<0>#1	1.26651e-17
C4728	vssa#188	vbottom<5>#14	5.40402e-17
C4729	vdda#16	XI10/vbsh	2.02586e-17
C4730	XI10/vbsl#7	vref	2.03689e-17
C4731	XI10/enb#23	sample#1	1.37218e-17
C4732	vref#47	vssa#31	1.0102e-17
C4733	vbottom<6>#11	vref#77	2.85898e-17
C4734	vssa#49	vssa#77	1.08924e-17
C4735	ctl<6>#3	vref	3.31619e-18
C4736	vbottom<0>#11	vbottom<0>#2	1.72483e-17
C4737	vbottom<2>#2	vref#55	3.12455e-17
C4738	vbottom<1>#11	vssa#183	7.91522e-16
C4739	vin#7	XI10/net2#5	3.35702e-17
C4740	vref#79	ctl<5>#1	1.2896e-17
C4741	vbottom<7>#2	vref#38	3.77308e-17
C4742	vssa#11	XI10/enb#21	5.1914e-18
C4743	vdda#22	vdda#6	7.27456e-17
C4744	vssa#149	vssa#138	7.526e-16
C4745	ctl<5>#3	vref	3.31619e-18
C4746	vout#204	vssa#188	1.21422e-17
C4747	vref#85	ctl<1>#3	2.90505e-18
C4748	vbottom<2>#2	ctl<2>#1	1.26651e-17
C4749	vbottom<7>	ctl<7>#1	1.05245e-17
C4750	vssa#71	ctl<2>#3	9.06566e-18
C4751	vref#47	vbottom<3>	3.12455e-17
C4752	XI10/net2#17	XI10/net2#3	1.25141e-17
C4753	XI10/enb#34	vin#7	5.13116e-18
C4754	ctl<3>#3	vref	3.31619e-18
C4755	vssa#113	ctl<2>#3	3.00008e-18
C4756	vref#75	ctl_dum#1	8.01288e-19
C4757	vbottom<4>#14	vssa#178	2.34798e-16
C4758	XI10/vbsl#11	XI10/enb#24	5.3246e-18
C4759	ctl<0>#3	vref	3.31619e-18
C4760	vssa#31	vssa#1	1.08924e-17
C4761	vdda#6	XI10/enb#24	4.76665e-17
C4762	vbottom<2>#6	ctl<2>#3	1.00811e-17
C4763	vref#85	ctl<1>#1	1.2896e-17
C4764	XI10/vbsh#19	vref	2.29769e-16
C4765	ctl<1>#3	vref	3.31619e-18
C4766	vssa#213	vssa#160	1.77401e-16
C4767	vref#38	vref	3.47809e-17
C4768	XI10/vbsh#7	vref	1.8939e-17
C4769	vssa#16	vdda#27	3.25655e-17
C4770	vbottom<4>#2	ctl<4>#1	1.26651e-17
C4771	ctl<2>#3	vref	3.31619e-18
C4772	net3#11	vssa#177	7.88851e-16
C4773	vssa#1	vssa#69	2.13405e-17
C4774	net3#2	net3#3	1.70984e-17
C4775	XI10/vbsh#21	vref	7.75487e-17
C4776	ctl_dum#3	vref	3.31619e-18
C4777	vssa#474	vssa#188	3.3355e-15
C4778	vbottom<0>#2	vbottom<0>#3	1.70984e-17
C4779	vout#142	vssa#183	3.00583e-16
C4780	vssa#93	ctl<6>#1	1.24892e-18
C4781	vbottom<5>#4	ctl<5>#3	1.00811e-17
C4782	vssa#33	ctl<0>#3	1.00811e-17
C4783	vref#38	vssa#19	1.0102e-17
C4784	vout#224	vssa#178	1.03879e-17
C4785	vbottom<7>#11	vref#66	2.59346e-16
C4786	vssa#33	vssa#65	1.08924e-17
C4787	ctl<4>#3	vref	3.31619e-18
C4788	vssa#101	ctl<3>#1	1.24892e-18
C4789	vbottom<7>#774	vssa#178	3.47965e-15
C4790	ctl<0>#1	ctl<0>#3	1.23111e-18
C4791	vbottom<7>#4	ctl<7>#3	1.00811e-17
C4792	vbottom<7>#2	ctl<7>#1	2.14062e-18
C4793	vssa#41	ctl<2>#3	1.00811e-17
C4794	vbottom<6>#13	vssa#194	2.03966e-16
C4795	ctl<4>#1	ctl<4>#3	1.23111e-18
C4796	vbottom<7>	vref#38	3.12455e-17
C4797	vbottom<5>#2	ctl<5>#1	2.14062e-18
C4798	vref#44	vref	3.47708e-17
C4799	vout#193	vssa#177	6.06364e-16
C4800	XI10/net2#15	XI10/net2	1.2239e-17
C4801	vssa#7	vssa#84	3.63212e-17
C4802	XI10/net2#13	XI10/net2#3	9.76583e-18
C4803	XI10/enb#38	XI10/vbsl#4	5.21596e-17
C4804	ctl<7>#1	ctl<7>#3	1.23111e-18
C4805	XI10/vbsh#33	vdda#22	3.12499e-17
C4806	XI10/vbsh#4	XI10/enb	3.36026e-17
C4807	vref#61	ctl<4>#1	1.05245e-17
C4808	vref#65	ctl<7>#3	2.90505e-18
C4809	vssa#33	vbottom<0>#6	5.96109e-17
C4810	vssa#109	ctl<1>#1	1.24892e-18
C4811	vref#50	ctl<0>#1	2.14062e-18
C4812	vbottom<6>#367	vssa#177	3.48763e-15
C4813	vref#91	ctl<4>#1	1.2896e-17
C4814	XI10/net30	vdda#1	3.43399e-18
C4815	vout#5	vin#3	8.7319e-18
C4816	vin#11	vssa#3	8.59117e-18
C4817	vout#177	net3	6.10983e-18
C4818	vout#203	net3	6.10983e-18
C4819	vout#219	net3	6.10983e-18
C4820	vout#230	net3#11	6.10983e-18
C4821	vout#237	net3#11	6.10983e-18
C4822	vout#244	net3#11	6.10983e-18
C4823	vout#111	vbottom<2>	6.10983e-18
C4824	vout#142	vbottom<2>	6.10983e-18
C4825	vout#204	vbottom<2>#11	7.60326e-18
C4826	vout#220	vbottom<2>#11	7.60326e-18
C4827	vout#36	vbottom<2>	8.47652e-18
C4828	vout#95	vbottom<1>#13	6.10983e-18
C4829	vout#124	vbottom<1>#13	6.10983e-18
C4830	vout#161	vbottom<1>#13	6.10983e-18
C4831	vout#212	vbottom<1>#11	7.60326e-18
C4832	vout#224	vbottom<1>#11	7.60326e-18
C4833	vout#45	vbottom<1>#13	8.58529e-18
C4834	vssa#116	net3#9	9.7504e-18
C4835	vout#87	vbottom<0>	6.0061e-18
C4836	vout#41	vbottom<0>	6.0061e-18
C4837	vout#155	vbottom<0>#11	6.53657e-18
C4838	vout#188	vbottom<0>#11	6.53657e-18
C4839	XI10/enb#24	sample#1	4.07257e-18
C4840	vssa#104	vbottom<0>#9	9.7504e-18
C4841	vin#11	XI10/net2#5	1.96018e-18
C4842	XI10/vbsh#33	XI10/enb#31	3.63132e-18
C4843	XI10/net2#35	XI10/enb#14	2.00269e-18
C4844	XI10/net2#35	XI10/enb	2.52669e-18
C4845	ctl<1>	vssa	7.75672e-19
C4846	sample	vssa	2.44714e-18
C4847	vdda	vssa	3.94463e-18
C4848	vref	vssa	1.45994e-15
C4849	XI10/vbsh	vssa	2.1379e-18
C4850	XI10/enb#5	vssa	4.6904e-19
C4851	vdda#1	vssa	2.81126e-18
C4852	XI10/enb#3	vssa	1.42067e-18
C4853	XI10/net2#5	vssa	7.30132e-19
C4854	XI10/net2#3	vssa	1.91873e-18
C4855	sample#3	vssa	1.24468e-17
C4856	XI10/enb	vssa	1.43122e-18
C4857	sample#1	vssa	7.98587e-19
C4858	ctl<7>#1	vssa	8.01288e-19
C4859	ctl<2>#1	vssa	8.01288e-19
C4860	ctl<4>#1	vssa	8.01288e-19
C4861	ctl<7>#3	vssa	7.45882e-19
C4862	ctl<6>#3	vssa	7.45882e-19
C4863	ctl<5>#3	vssa	7.45882e-19
C4864	ctl<3>#3	vssa	7.45882e-19
C4865	ctl<0>#3	vssa	7.45882e-19
C4866	ctl<1>#3	vssa	7.45882e-19
C4867	ctl<2>#3	vssa	7.45882e-19
C4868	ctl_dum#3	vssa	7.45882e-19
C4869	ctl<4>#3	vssa	7.45882e-19
C4870	vout#13	vssa	6.92709e-18
C4871	XI10/vbsh#29	vssa	5.77684e-18
C4872	vbottom<3>#15	vssa	9.37115e-18
C4873	vbottom<3>#12	vssa	1.42704e-17
C4874	vbottom<7>#15	vssa	1.26448e-17
C4875	vbottom<7>#14	vssa	1.17816e-17
C4876	vbottom<6>#15	vssa	2.62258e-17
C4877	vbottom<6>#14	vssa	1.18208e-17
C4878	vbottom<5>#15	vssa	2.66145e-17
C4879	vbottom<5>#14	vssa	1.70032e-17
C4880	vbottom<4>	vssa	1.57476e-17
C4881	vbottom<4>#14	vssa	2.186e-17
C4882	vbottom<3>#16	vssa	1.45941e-17
C4883	vbottom<3>#13	vssa	1.43069e-17
C4884	vbottom<2>	vssa	1.96425e-17
C4885	vbottom<0>	vssa	1.25043e-17
C4886	vbottom<4>#17	vssa	1.46216e-17
C4887	vbottom<4>#15	vssa	1.09906e-17
C4888	vbottom<1>#13	vssa	1.80431e-17
C4889	vbottom<1>#14	vssa	4.26673e-18
C4890	net3	vssa	1.51038e-17
C4891	vbottom<2>#14	vssa	6.2371e-18
C4892	XI10/vbsl	vssa	1.54422e-17
C4893	vbottom<7>#11	vssa	7.47462e-18
C4894	vbottom<6>#11	vssa	7.58433e-18
C4895	vbottom<5>#11	vssa	7.56238e-18
C4896	vbottom<3>#11	vssa	1.45159e-17
C4897	vbottom<0>#11	vssa	2.24034e-17
C4898	vbottom<1>#11	vssa	2.49247e-17
C4899	vbottom<2>#11	vssa	2.26948e-17
C4900	net3#11	vssa	1.58827e-17
C4901	vbottom<4>#11	vssa	7.58433e-18
C4902	XI10/vbsl#11	vssa	1.22532e-17
C4903	XI10/enb#38	vssa	3.95187e-18
C4904	vout#5	vssa	3.52949e-18
C4905	vin#10	vssa	1.07569e-17
C4906	XI10/enb#13	vssa	4.56516e-19
C4907	XI10/net2#14	vssa	3.65286e-19
C4908	sample#10	vssa	5.96808e-18
C4909	vbottom<7>#4	vssa	3.76887e-18
C4910	vbottom<6>#4	vssa	3.76887e-18
C4911	vbottom<5>#4	vssa	3.76887e-18
C4912	vbottom<3>#4	vssa	3.76887e-18
C4913	vbottom<1>#4	vssa	3.76887e-18
C4914	ctl<0>#10	vssa	7.75672e-19
C4915	vref#38	vssa	1.07029e-17
C4916	vbottom<7>#2	vssa	5.10925e-18
C4917	vref#41	vssa	2.09146e-17
C4918	vbottom<6>#2	vssa	5.09943e-18
C4919	vref#44	vssa	1.07907e-17
C4920	vbottom<5>#2	vssa	5.1014e-18
C4921	vref#47	vssa	9.9955e-18
C4922	vbottom<3>#2	vssa	6.95e-18
C4923	vbottom<0>#2	vssa	8.53182e-18
C4924	vref#50	vssa	1.33357e-17
C4925	vref#53	vssa	1.9689e-17
C4926	vbottom<1>#2	vssa	6.91918e-18
C4927	vbottom<2>#2	vssa	8.424e-18
C4928	vref#56	vssa	1.3003e-17
C4929	net3#2	vssa	5.63512e-18
C4930	vref#59	vssa	1.40012e-17
C4931	vbottom<4>#2	vssa	5.63512e-18
C4932	vref#62	vssa	1.40012e-17
C4933	XI10/net2#29	vssa	4.6904e-19
C4934	XI10/net2#25	vssa	2.37695e-19
C4935	XI10/enb#29	vssa	2.1379e-18
C4936	XI10/vbsh#4	vssa	2.30362e-18
C4937	vdda#6	vssa	1.31031e-17
C4938	XI10/vbsl#4	vssa	4.09365e-18
C4939	sample#14	vssa	5.10874e-18
C4940	sample#12	vssa	3.50097e-18
C4941	vout#29	vssa	3.06214e-21
C4942	vout#42	vssa	4.96244e-18
C4943	vout#76	vssa	1.82635e-17
C4944	vout#132	vssa	1.16541e-17
C4945	vout#188	vssa	1.25925e-17
C4946	vout#220	vssa	1.20882e-17
C4947	vout#224	vssa	3.34724e-18
C4948	vout#244	vssa	3.59368e-18
C4949	vout#254	vssa	3.91563e-18
C4950	vout#16	vssa	3.06214e-21
C4951	vout#51	vssa	5.18246e-18
C4952	vout#98	vssa	9.39455e-18
C4953	vout#155	vssa	1.23419e-17
C4954	vout#204	vssa	5.0084e-18
C4955	vout#212	vssa	3.34724e-18
C4956	vout#237	vssa	3.59368e-18
C4957	vout#248	vssa	3.91563e-18
C4958	vout#272	vssa	3.06214e-21
C4959	vout#227	vssa	3.06214e-21
C4960	vout#37	vssa	9.78382e-18
C4961	vout#67	vssa	5.18246e-18
C4962	vout#119	vssa	9.91832e-18
C4963	vout#179	vssa	1.53773e-17
C4964	vout#193	vssa	1.85691e-17
C4965	vout#230	vssa	3.59368e-18
C4966	vout#241	vssa	1.25589e-17
C4967	vout#268	vssa	3.06214e-21
C4968	vout#215	vssa	3.06214e-21
C4969	vout#20	vssa	3.06214e-21
C4970	vout#46	vssa	5.18246e-18
C4971	vout#87	vssa	5.36974e-18
C4972	vout#142	vssa	9.37133e-18
C4973	vout#161	vssa	1.75336e-17
C4974	vout#219	vssa	6.57585e-18
C4975	vout#234	vssa	8.02482e-18
C4976	vout#264	vssa	3.06214e-21
C4977	vout#197	vssa	3.06214e-21
C4978	vout#181	vssa	3.06214e-21
C4979	vout#23	vssa	3.06214e-21
C4980	vout#35	vssa	9.78076e-18
C4981	vout#58	vssa	6.0061e-18
C4982	vout#226	vssa	6.0061e-18
C4983	vout#259	vssa	3.06214e-21
C4984	vout#165	vssa	3.06214e-21
C4985	vout#144	vssa	3.06214e-21
C4986	vout#26	vssa	3.26897e-21
C4987	vout#75	vssa	6.10983e-18
C4988	vout#214	vssa	1.9188e-20
C4989	vout#253	vssa	3.06214e-21
C4990	vout#133	vssa	3.06214e-21
C4991	vout#113	vssa	3.06214e-21
C4992	vout#92	vssa	3.06214e-21
C4993	vout#30	vssa	3.06214e-21
C4994	vout#32	vssa	8.82501e-18
C4995	vout#50	vssa	1.60813e-17
C4996	vout#63	vssa	1.59535e-17
C4997	vout#141	vssa	1.70728e-17
C4998	vout#195	vssa	1.356e-17
C4999	vout#247	vssa	3.06214e-21
C5000	vout#100	vssa	7.26569e-18
C5001	vout#34	vssa	3.93513e-18
C5002	vout#109	vssa	9.9711e-18
C5003	vout#164	vssa	1.05824e-17
C5004	vout#240	vssa	3.06214e-21
C5005	vout#89	vssa	9.64445e-18
C5006	vout#78	vssa	4.06346e-18
C5007	vout#60	vssa	4.06346e-18
C5008	vout#57	vssa	5.78745e-18
C5009	vout#40	vssa	1.37538e-17
C5010	vout#74	vssa	3.75088e-18
C5011	vout#233	vssa	3.06214e-21
C5012	vout#66	vssa	1.82771e-19
C5013	vout#49	vssa	6.05433e-18
C5014	vout#56	vssa	2.75593e-19
C5015	vout#225	vssa	3.06214e-21
C5016	vout#73	vssa	2.69468e-19
C5017	vout#213	vssa	3.06214e-21
C5018	vout#96	vssa	2.69468e-19
C5019	vout#194	vssa	3.06214e-21
C5020	vout#117	vssa	2.69468e-19
C5021	vout#163	vssa	3.06214e-21
C5022	vout#139	vssa	2.75593e-19
C5023	vout#162	vssa	2.75593e-19
C5024	vout#185	vssa	2.60282e-19
C5025	vbottom<7>	vssa	5.35688e-19
C5026	vbottom<6>	vssa	5.35688e-19
C5027	vbottom<5>	vssa	5.35688e-19
C5028	vbottom<3>	vssa	1.58179e-18
C5029	vref#49	vssa	6.76176e-18
C5030	vbottom<1>	vssa	1.50481e-18
C5031	vref#55	vssa	6.68593e-18
C5032	vref#58	vssa	6.91343e-18
C5033	vref#61	vssa	6.91343e-18
C5034	vbottom<2>#22	vssa	5.20155e-18
C5035	vbottom<4>#48	vssa	2.75593e-19
C5036	vbottom<3>#23	vssa	5.78745e-18
C5037	vbottom<3>#53	vssa	3.90119e-18
C5038	vbottom<3>#56	vssa	8.37816e-18
C5039	vbottom<3>#59	vssa	7.45075e-18
C5040	vbottom<4>#98	vssa	5.78132e-18
C5041	vbottom<4>#101	vssa	6.5193e-18
C5042	vbottom<5>#110	vssa	7.20093e-18
C5043	vbottom<5>#146	vssa	5.78438e-18
C5044	vbottom<5>#149	vssa	6.5193e-18
C5045	vbottom<5>#183	vssa	2.69468e-19
C5046	vbottom<6>#109	vssa	2.69468e-19
C5047	vbottom<6>#198	vssa	3.06214e-21
C5048	vbottom<6>#207	vssa	3.26897e-21
C5049	vbottom<6>#210	vssa	5.78438e-18
C5050	vbottom<6>#213	vssa	6.5193e-18
C5051	vbottom<6>#252	vssa	2.69468e-19
C5052	vbottom<6>#367	vssa	5.51078e-18
C5053	vbottom<6>#402	vssa	3.06214e-21
C5054	vbottom<7>#555	vssa	5.95308e-21
C5055	vbottom<7>#569	vssa	4.10098e-18
C5056	vbottom<7>#533	vssa	4.06346e-18
C5057	vbottom<7>#146	vssa	2.75593e-19
C5058	vbottom<7>#294	vssa	2.75593e-19
C5059	vbottom<7>#360	vssa	3.06214e-21
C5060	vbottom<7>#363	vssa	3.06214e-21
C5061	vbottom<7>#366	vssa	3.06214e-21
C5062	vbottom<7>#369	vssa	3.06214e-21
C5063	vbottom<7>#372	vssa	3.06214e-21
C5064	vbottom<7>#375	vssa	3.06214e-21
C5065	vbottom<7>#378	vssa	3.06214e-21
C5066	vbottom<7>#381	vssa	3.06214e-21
C5067	vbottom<7>#384	vssa	3.06214e-21
C5068	vbottom<7>#387	vssa	3.06214e-21
C5069	vbottom<7>#390	vssa	3.06214e-21
C5070	vbottom<7>#393	vssa	3.06214e-21
C5071	vbottom<7>#623	vssa	3.06214e-21
C5072	vbottom<7>#637	vssa	1.84706e-18
C5073	vbottom<7>#640	vssa	6.39536e-18
C5074	vbottom<7>#672	vssa	3.06214e-21
C5075	vbottom<7>#675	vssa	3.06214e-21
C5076	vbottom<7>#678	vssa	3.06214e-21
C5077	vbottom<7>#681	vssa	5.78438e-18
C5078	vbottom<7>#684	vssa	6.5193e-18
C5079	vbottom<7>#786	vssa	6.37305e-18
C5080	vbottom<7>#789	vssa	1.84706e-18
C5081	XI10/vbsh#33	vssa	7.13503e-18
C5082	vout#39	vssa	1.58289e-17
C5083	vout#43	vssa	1.23006e-17
C5084	vout#47	vssa	1.23006e-17
C5085	vout#52	vssa	1.23006e-17
C5086	vout#68	vssa	1.23006e-17
C5087	vin#11	vssa	3.42661e-18
C5088	XI10/enb#31	vssa	4.07363e-18
C5089	XI10/net2#32	vssa	5.47921e-18
C5090	vdda#22	vssa	2.09994e-17
C5091	vref#66	vssa	8.01288e-19
C5092	vref#74	vssa	8.01288e-19
C5093	vref#76	vssa	8.01288e-19
C5094	vref#81	vssa	3.06474e-18
C5095	vref#83	vssa	3.06474e-18
C5096	vref#85	vssa	3.0925e-18
C5097	vref#87	vssa	3.0925e-18
C5098	vbottom<6>#9	vssa	9.7504e-18
C5099	vbottom<5>#9	vssa	9.8038e-18
C5100	vbottom<3>#9	vssa	1.06601e-17
C5101	vbottom<0>#9	vssa	1.78721e-18
C5102	vbottom<1>#9	vssa	1.06735e-17
C5103	vbottom<2>#9	vssa	1.06735e-17
C5104	vbottom<4>#9	vssa	9.7504e-18
C5105	sample#15	vssa	1.13575e-19
C5106	vout#3	vssa	7.08088e-18
C5107	vin#3	vssa	2.06647e-18
C5108	vin#7	vssa	6.31825e-18
C5109	XI10/enb#24	vssa	2.46626e-18
C5110	vbottom<0>#6	vssa	3.76887e-18
C5111	vbottom<2>#6	vssa	3.76887e-18
C5112	net3#6	vssa	3.76887e-18
C5113	vbottom<4>#6	vssa	3.76887e-18
C5114	vbottom<4>#13	vssa	4.14795e-18
*
*
.ENDS cdac_8b
*
