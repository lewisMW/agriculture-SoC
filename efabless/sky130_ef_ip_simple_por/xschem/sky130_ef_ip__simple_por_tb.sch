v {xschem version=3.4.6 file_version=1.2}
G {}
K {}
V {}
S {}
E {}
B 2 1030 110 1830 510 {flags=graph
y1=-0.018
y2=3.4
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=0.013956721
x2=0.016872429
divx=5
subdivx=1
xlabmag=1.0
ylabmag=1.0
node="vdd3v3
vdd1v8
porb_h
porb_l
por_l"
color="4 5 6 7 8"
dataset=-1
unitx=1
logx=0
logy=0
hcursor1_y=2.0104818}
T {Testbench for simple POR} 350 40 0 0 0.6 0.6 {}
N 420 340 690 340 { lab=GND}
N 160 280 160 340 { lab=GND}
N 370 280 370 340 { lab=GND}
N 370 180 370 220 { lab=vdd3v3}
N 370 170 370 180 { lab=vdd3v3}
N 490 170 660 170 { lab=vdd3v3}
N 660 170 660 180 { lab=vdd3v3}
N 160 150 160 220 { lab=vdd1v8}
N 420 150 720 150 { lab=vdd1v8}
N 720 150 720 180 { lab=vdd1v8}
N 840 230 880 230 { lab=porb_h}
N 840 260 880 260 { lab=porb_l}
N 840 290 880 290 { lab=por_l}
N 360 170 370 170 { lab=vdd3v3}
N 200 150 210 150 { lab=vdd1v8}
N 160 150 200 150 { lab=vdd1v8}
N 140 150 160 150 { lab=vdd1v8}
N 160 340 210 340 { lab=GND}
N 210 150 420 150 { lab=vdd1v8}
N 210 340 370 340 { lab=GND}
N 370 340 420 340 { lab=GND}
N 370 170 490 170 { lab=vdd3v3}
N 690 340 720 340 {lab=GND}
C {sky130_ef_ip__simple_por.sym} 690 260 0 0 {name=x1}
C {devices/gnd.sym} 600 340 0 0 {name=l1 lab=GND}
C {devices/vsource.sym} 370 250 0 0 {name=V1 value="PWL(0.0 0 100u 0 5m 3.3)"}
C {devices/vsource.sym} 160 250 0 0 {name=V2 value="PWL(0.0 0 300u 0 5.3m 1.8)"}
C {devices/opin.sym} 360 170 0 1 {name=p1 lab=vdd3v3}
C {devices/opin.sym} 140 150 0 1 {name=p2 lab=vdd1v8}
C {devices/opin.sym} 880 230 0 0 {name=p3 lab=porb_h}
C {devices/opin.sym} 880 260 0 0 {name=p4 lab=porb_l}
C {devices/opin.sym} 880 290 0 0 {name=p5 lab=por_l}
C {devices/code_shown.sym} 380 440 0 0 {name=control only_toplevel=false value=".control
tran 1u 20m
plot V(vdd3v3) V(vdd1v8) V(porb_h) V(porb_l) V(por_l)
write simdata.raw
.endc"}
C {code.sym} 220 420 0 0 {name=TT_MODELS only_toplevel=false value="
.lib $PDK_ROOT/$PDK/libs.tech/combined/sky130.lib.spice tt
.include $PDK_ROOT/$PDK/libs.ref/sky130_fd_sc_hvl/spice/sky130_fd_sc_hvl.spice
"}
C {launcher.sym} 1090 580 0 0 {name=h1
descr="Load waves TRAN" 
tclcommand="
xschem raw_read $netlist_dir/simdata.raw tran
"}
