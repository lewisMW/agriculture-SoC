### Standard cells the tools must not use: the PDK's list of cells with known DRC
### problems (open_pdks: libs.tech/openlane/sky130_fd_sc_hd/drc_exclude.cells).
### Sourced by Genus (../inputs/custom_hdl_file_list.tcl) and by every Innovus
### stage (floorplan.tcl, cts_setup.tcl, route_setup.tcl), after config.tcl.
###
### Found the hard way: ChipFoundry's FEOL deck reported npc.2 (NPC spacing,
### 0.16 um where 0.27 um is needed) wherever a sky130_fd_sc_hd__and2_0 stood
### left of a decap_12. and2_0 is on this list; 200 instances of listed cells
### were in the design, three of them in that position.
###
### The list is the PDK's file when this PDK copy has it, else the copy below
### (ChipFoundry's PDK, open_pdks 3e0e31d).
set _cells {
    sky130_fd_sc_hd__a2111oi_0 sky130_fd_sc_hd__a21boi_0
    sky130_fd_sc_hd__and2_0 sky130_fd_sc_hd__buf_16
    sky130_fd_sc_hd__clkdlybuf4s15_1 sky130_fd_sc_hd__clkdlybuf4s18_1
    sky130_fd_sc_hd__fa_4 sky130_fd_sc_hd__lpflow_bleeder_1
    sky130_fd_sc_hd__lpflow_clkbufkapwr_1 sky130_fd_sc_hd__lpflow_clkbufkapwr_16
    sky130_fd_sc_hd__lpflow_clkbufkapwr_2 sky130_fd_sc_hd__lpflow_clkbufkapwr_4
    sky130_fd_sc_hd__lpflow_clkbufkapwr_8 sky130_fd_sc_hd__lpflow_clkinvkapwr_1
    sky130_fd_sc_hd__lpflow_clkinvkapwr_16 sky130_fd_sc_hd__lpflow_clkinvkapwr_2
    sky130_fd_sc_hd__lpflow_clkinvkapwr_4 sky130_fd_sc_hd__lpflow_clkinvkapwr_8
    sky130_fd_sc_hd__lpflow_decapkapwr_12 sky130_fd_sc_hd__lpflow_decapkapwr_3
    sky130_fd_sc_hd__lpflow_decapkapwr_4 sky130_fd_sc_hd__lpflow_decapkapwr_6
    sky130_fd_sc_hd__lpflow_decapkapwr_8 sky130_fd_sc_hd__lpflow_inputiso0n_1
    sky130_fd_sc_hd__lpflow_inputiso0p_1 sky130_fd_sc_hd__lpflow_inputiso1n_1
    sky130_fd_sc_hd__lpflow_inputiso1p_1 sky130_fd_sc_hd__lpflow_inputisolatch_1
    sky130_fd_sc_hd__lpflow_isobufsrc_1 sky130_fd_sc_hd__lpflow_isobufsrc_16
    sky130_fd_sc_hd__lpflow_isobufsrc_2 sky130_fd_sc_hd__lpflow_isobufsrc_4
    sky130_fd_sc_hd__lpflow_isobufsrc_8 sky130_fd_sc_hd__lpflow_isobufsrckapwr_16
    sky130_fd_sc_hd__lpflow_lsbuf_lh_hl_isowell_tap_1 sky130_fd_sc_hd__lpflow_lsbuf_lh_hl_isowell_tap_2
    sky130_fd_sc_hd__lpflow_lsbuf_lh_hl_isowell_tap_4 sky130_fd_sc_hd__lpflow_lsbuf_lh_isowell_4
    sky130_fd_sc_hd__lpflow_lsbuf_lh_isowell_tap_1 sky130_fd_sc_hd__lpflow_lsbuf_lh_isowell_tap_2
    sky130_fd_sc_hd__lpflow_lsbuf_lh_isowell_tap_4 sky130_fd_sc_hd__mux4_4
    sky130_fd_sc_hd__o21ai_0 sky130_fd_sc_hd__o311ai_0
    sky130_fd_sc_hd__or2_0 sky130_fd_sc_hd__probe_p_8
    sky130_fd_sc_hd__probec_p_8 sky130_fd_sc_hd__xor3_1
    sky130_fd_sc_hd__xor3_2 sky130_fd_sc_hd__xor3_4
    sky130_fd_sc_hd__xnor3_1 sky130_fd_sc_hd__xnor3_2
    sky130_fd_sc_hd__xnor3_4
}
set _f ${sky130_open_dir}/libs.tech/openlane/sky130_fd_sc_hd/drc_exclude.cells
if {[file exists $_f]} { set _fh [open $_f r]; set _cells [read $_fh]; close $_fh }
set _n 0
foreach _c $_cells {
    # Innovus: dont_use on the base cell. Genus: avoid on each library cell.
    set _bc {}
    catch {set _bc [get_db base_cells $_c]}
    if {[llength $_bc] && ![catch {set_db $_bc .dont_use true}]} {
        incr _n [llength $_bc]
    } else {
        foreach _lc [get_db lib_cells -if ".base_name == $_c"] { set_db $_lc .avoid true; incr _n }
    }
}
puts "dont_use.tcl: [llength $_cells] cells on the PDK's DRC-exclude list, $_n library cells marked"
if {$_n == 0} { error "dont_use.tcl: no library cell was marked" }
