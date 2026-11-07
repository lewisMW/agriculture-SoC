# =====================================================================
# stream_out.tcl -- chip GDS + LVS netlists + DEF from a routed Innovus DB
#
#   innovus -stylus -no_gui -batch \
#     -execute "set DB <routed db dir>; set OUT <output dir>" \
#     -files stream_out.tcl < /dev/null
#
# Optional variables (set them in -execute before the script runs):
#   TOP          GDS top-cell name            (default: the design name)
#   EXTRA_GDS    more GDS files to merge      (default: none)
#   MERGE_GDS    replace the automatic merge list entirely
#   LABEL_PORTS  1 = label each supply port (and any unplaced signal port)
#                on the IO-cell pin it connects to: the *_PAD pin, else the
#                pad-ring bus (met5/met4 label, 72/5 or 71/5). Default 1.
#   PDK_ROOT     open PDK               (default /opt/pdk/sky130A)
#   SRAM_ROOT    SRAM macro directory   (default /opt/pdk/sram_macros)
#   MACRO_ROOT   repo hard macros       (default <this dir>/../../macros)
#   CPUS         default 8
#
# Writes into OUT:
#   <TOP>.gds                 merged chip GDS (layer map: sky130_stream.map)
#   <TOP>.pg.v                Verilog with PG ports + physical instances (LVS);
#                             leaf cells (std cells, pads, macros) are not defined
#   <TOP>.pg_nophys.v         Verilog with PG ports, no physical instances
#   <TOP>.def.gz              DEF (floorplan, netlist, routing), reference only
#   masters.txt               master <tab> count <tab> class <tab> merge GDS
#   merge_list.txt            the GDS files given to -merge
#   port_labels.txt           labels added by LABEL_PORTS
#   stream_rename.rpt         write_stream -report_file (renamed cells, if any)
#   STREAM_OUT_OK             written last, only if everything succeeded
# =====================================================================

proc so_die {msg} { puts "STREAM_OUT_ERROR: $msg"; exit 1 }
foreach v {DB OUT} { if {![info exists $v]} { so_die "set $v with -execute" } }
set SD [file dirname [file normalize [info script]]]
if {![file exists $SD/sky130_stream.map] && [info exists ::env(SIGNOFF_DIR)]} { set SD $::env(SIGNOFF_DIR) }
set MAP $SD/sky130_stream.map
if {![file exists $MAP]} { so_die "layer map not found: $MAP" }
foreach {v d} [list PDK_ROOT /opt/pdk/sky130A SRAM_ROOT /opt/pdk/sram_macros \
               MACRO_ROOT [file normalize $SD/../../macros] CPUS 8 LABEL_PORTS 1 EXTRA_GDS {}] {
    if {![info exists $v]} { set $v $d }
}
file mkdir $OUT
set_multi_cpu_usage -local_cpu $CPUS
if {[catch {read_db $DB} e]} { so_die "read_db $DB: $e" }
set design [get_db current_design .name]
if {![info exists TOP]} { set TOP $design }
puts "STREAM_OUT design=$design top=$TOP db=$DB"

# ---- masters used, and which GDS provides each ----------------------
set SC_GDS   $PDK_ROOT/libs.ref/sky130_fd_sc_hd/gds/sky130_fd_sc_hd.gds
set IO_DIR   $PDK_ROOT/libs.ref/sky130_fd_io/gds
set SRAM_GDS $SRAM_ROOT/sky130_sram_8kbyte_1rw_32x2048_8/sky130_sram_8kbyte_1rw_32x2048_8.gds

array set cnt {}
foreach bc [get_db insts .base_cell.name] { incr cnt($bc) }
set merge {}
proc so_add {f} { upvar merge merge; if {[lsearch -exact $merge $f] < 0} { lappend merge $f } }
set unknown {}
set fh [open $OUT/masters.txt w]
foreach m [lsort [array names cnt]] {
    set src ""
    if {[string match sky130_fd_sc_hd__* $m] || [string match sky130_ef_sc_hd__* $m]} {
        set src $SC_GDS
    } elseif {[string match sky130_ef_io__* $m] && [file exists $IO_DIR/$m.gds]} {
        # cells with a GDS of their own: gpiov2_pad_wrapped, the connect /
        # disconnect slices. The wrapper instantiates sky130_ef_io__gpiov2_pad
        # (sky130_ef_io.gds), which instantiates sky130_fd_io__* cells
        # (sky130_fd_io.gds), so those two always come along.
        set src $IO_DIR/$m.gds
        so_add $IO_DIR/sky130_ef_io.gds; so_add $IO_DIR/sky130_fd_io.gds
    } elseif {[regexp {^sky130_ef_io__(analog|esd)_} $m]} {
        set src $IO_DIR/sky130_ef_io__analog.gds
        so_add $IO_DIR/sky130_fd_io.gds
    } elseif {[string match sky130_ef_io__* $m]} {
        set src $IO_DIR/sky130_ef_io.gds
        so_add $IO_DIR/sky130_fd_io.gds
    } elseif {[string match sky130_fd_io__* $m]} {
        set src $IO_DIR/sky130_fd_io.gds
    } elseif {$m eq "sky130_sram_8kbyte_1rw_32x2048_8"} {
        set src $SRAM_GDS
    } elseif {[file exists $MACRO_ROOT/sar_afe/$m.gds]} {
        # sar_afe, sar_afe_r, sar_afe_b: subcells prefixed <cell>__, no clashes
        set src $MACRO_ROOT/sar_afe/$m.gds
    } elseif {[llength [glob -nocomplain $MACRO_ROOT/*/$m.gds]]} {
        set src [lindex [glob $MACRO_ROOT/*/$m.gds] 0]
    } else {
        foreach g $EXTRA_GDS { if {[string match *$m* [file tail $g]]} { set src $g } }
    }
    if {$src eq ""} { lappend unknown $m } else { so_add $src }
    puts $fh "$m\t$cnt($m)\t[get_db [get_db base_cells $m] .class]\t$src"
}
close $fh
foreach g $EXTRA_GDS { so_add $g }
if {[info exists MERGE_GDS]} { set merge $MERGE_GDS }
if {[llength $unknown] && ![info exists MERGE_GDS]} {
    so_die "no GDS known for masters: $unknown (pass EXTRA_GDS or MERGE_GDS)"
}
foreach f $merge { if {![file readable $f]} { so_die "merge GDS not readable: $f" } }
set fh [open $OUT/merge_list.txt w]; puts $fh [join $merge \n]; close $fh
puts "STREAM_OUT merge list ([llength $merge] files):\n  [join $merge "\n  "]"

# ---- top-level port labels -------------------------------------------
# The chip's ports have no physical pin shapes (they are pad PAD pins), so
# NAME .../PIN in the map writes nothing. LVS reads only top-level labels
# (text_depth -primary), so put each port name on the met5 shape of the pad
# pin it drives: gpio PAD, or the *_PAD / P_PAD pin of a supply/analog pad.
proc so_pin_pt {inst bpin layers} {
    # {layer {x y}}: centre of the pin's largest rectangle on the first of
    # $layers that has one, in chip coordinates
    foreach want $layers {
        set best ""; set barea -1
        foreach ls [get_db $bpin .physical_pins.layer_shapes] {
            if {[get_db $ls .layer.name] ne $want} continue
            foreach r [get_db $ls .shapes.rect] {
                lassign $r x1 y1 x2 y2
                set a [expr {($x2-$x1)*($y2-$y1)}]
                if {$a > $barea} { set barea $a; set best [list [expr {($x1+$x2)/2.0}] [expr {($y1+$y2)/2.0}]] }
            }
        }
        if {$best eq ""} continue
        set p [get_transform_shapes -inst $inst -local_pt $best]
        if {[llength [lindex $p 0]] == 2} { set p [lindex $p 0] }
        return [list $want $p]
    }
    return ""
}
set nlab 0
set fh [open $OUT/port_labels.txt w]
if {$LABEL_PORTS} {
    # net -> {inst base_pin pin_name}: padpins = the pad-side pins of the IO
    # cells (PAD, P_PAD, *_PAD); padpg = their other supply pins, i.e. the
    # pad-ring buses (VCCD, VSSD, VDDIO, VSWITCH ...), one per IO cell
    array set padpins {}; array set padpg {}
    foreach i [get_db insts -if {.base_cell.name == sky130_*_io__*}] {
        foreach p [get_db $i .pins] {
            set bn [get_db $p .base_name]
            if {![regexp {^(PAD|P_PAD|[A-Z0-9_]+_PAD)$} $bn]} continue
            set n [get_db $p .net.name]
            if {$n ne ""} { lappend padpins($n) [list $i [get_db $p .base_pin] $bn] }
        }
        foreach p [get_db $i .pg_pins] {
            set bn [lindex [split [get_db $p .pg_base_pin.name] /] end]
            set n [get_db $p .net.name]
            if {$n eq ""} continue
            if {[regexp {^(P_PAD|[A-Z0-9_]+_PAD)$} $bn]} {
                lappend padpins($n) [list $i [get_db $p .pg_base_pin] $bn]
            } else {
                lappend padpg($n) [list $i [get_db $p .pg_base_pin] $bn]
            }
        }
    }
    foreach port [get_db ports] {
        set pn [get_db $port .name]
        set n [get_db $port .net.name]
        # A placed signal port already gets its name on 72/5 from the map's
        # "NAME met5/PIN" line (Innovus puts the port at the pad's PAD pin).
        # Supply ports get nothing from Innovus, so label those here.
        set is_pg [expr {$n ne "" && ([get_db $port .net.is_power] || [get_db $port .net.is_ground])}]
        if {!$is_pg && [get_db $port .place_status] in {placed fixed cover}} {
            puts $fh "$pn\tINNOVUS_PIN_LABEL"; continue
        }
        if {$n ne "" && [info exists padpins($n)]} {
            set targets $padpins($n); set how pad_pin
        } elseif {$n ne "" && [info exists padpg($n)]} {
            # a core or ring supply: label its own pad-ring bus (VDD on VCCD,
            # VSS on VSSD, otherwise the bus of the same name) inside the first
            # four IO cells. Other buses Innovus also put on this net (e.g.
            # VCCHIB on VDD) are left to LVS rather than labelled.
            set bus [string map {VDD VCCD VSS VSSD} $pn]
            if {$pn ni {VDD VSS}} { set bus $pn }
            set targets {}
            foreach t $padpg($n) { if {[lindex $t 2] eq $bus} { lappend targets $t } }
            set targets [lrange $targets 0 3]; set how ring_bus
            if {![llength $targets]} { puts $fh "$pn	NO_${bus}_BUS_ON_NET	$n"; continue }
        } else {
            puts $fh "$pn\tNO_IO_PIN\t$n"; continue
        }
        foreach t $targets {
            lassign $t i bp bn
            set lp [so_pin_pt $i $bp {met5 met4 met3}]
            if {$lp eq ""} { puts $fh "$pn\t[get_db $i .name]/$bn\tNO_MET3-5_SHAPE"; continue }
            lassign $lp lay pt
            create_text -label $pn -layer $lay -point $pt -height 2
            incr nlab
            puts $fh "$pn\t[get_db $i .name]/$bn\t$lay\t$pt\t$how"
        }
    }
}
close $fh
puts "STREAM_OUT port labels added: $nlab"

# ---- stream out ------------------------------------------------------
set_db write_stream_virtual_connection false
set_db write_stream_check_map_file true
set_db write_stream_text_size 2
set gds $OUT/$TOP.gds
if {[catch {write_stream $gds -map_file $MAP -lib_name DesignLib -unit 1000 -mode ALL \
        -structure_name $TOP -merge $merge -report_file $OUT/stream_rename.rpt} e]} {
    so_die "write_stream: $e"
}
if {![file exists $gds]} { so_die "write_stream wrote no $gds" }
puts "STREAM_OUT wrote $gds ([file size $gds] bytes)"

# ---- netlists and DEF ------------------------------------------------
if {[catch {write_netlist $OUT/$TOP.pg.v -include_pg -include_phys_insts -exclude_leaf_cells} e]} { so_die "write_netlist pg: $e" }
if {[catch {write_netlist $OUT/$TOP.pg_nophys.v -include_pg -exclude_leaf_cells} e]} { so_die "write_netlist pg_nophys: $e" }
if {[catch {write_def $OUT/$TOP.def.gz -floorplan -netlist -routing} e]} { so_die "write_def: $e" }

set fh [open $OUT/STREAM_OUT_OK w]; puts $fh "[clock format [clock seconds]] $DB"; close $fh
puts "STREAM_OUT_DONE $OUT"
exit 0
