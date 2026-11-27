#!/usr/bin/env bash
# =====================================================================
# make_cf_project.sh -- lay a stream-out out as a ChipFoundry project
# directory (the layout of their openframe_user_project template), ready
# for `cf precheck`.
#
# Usage: ./make_cf_project.sh <stream_dir> <project_dir>
#   <stream_dir>   output of run_stream_out.sh (GDS and .pg.flat.v)
#   <project_dir>  created or updated; keep it OUT of any public repository:
#                  the GDS and the gate netlist contain the synthesised design.
#
# What goes where (sources in ../cf):
#   gds/openframe_project_wrapper.gds      the stream GDS with the ADC macro's bus
#                                          texts as [n] (cf_relabel_gds.py)
#   verilog/gl/openframe_project_wrapper.v the flat netlist with power pins and
#                                          physical cells
#   verilog/gl/macros_blackbox.v           port-only modules for the DFFRAM blocks and the
#                                          ADC macro (black boxes in their LVS)
#   verilog/gl/v*_connection.v             empty modules for the connection blocks
#   lvs/openframe_project_wrapper/         lvs_config.json (macros as abstracts,
#                                          EXTRACT_TYPE analog as in the template)
#                                          and a CVC power file that adds the
#                                          macros' outputs as driven inputs (for
#                                          running CVC by hand: cf-precheck 1.3.7
#                                          does not read a project power file)
#   .cf/project.json                       only if absent: the two fields the local
#                                          precheck reads (`cf init` writes the real one)
#
# The PDK copy the precheck uses comes from `cf setup --only-pdk` in the project
# directory. Stream out with PDK_ROOT=<project_dir>/dependencies/pdks/sky130A so
# that the standard-cell layouts are the version their LVS netlists describe
# (five cells differ from older PDK copies, conb_1 among them).
# =====================================================================
set -euo pipefail
SD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ $# -eq 2 ] || { sed -n '2,28p' "$0"; exit 2; }
ST="$(cd "$1" && pwd)"; PRJ="$2"
TOP=openframe_project_wrapper
CF="$SD/../cf"
[ -f "$ST/$TOP.gds" ] && [ -f "$ST/$TOP.pg.flat.v" ] || { echo "no $TOP.gds / $TOP.pg.flat.v in $ST"; exit 2; }
mkdir -p "$PRJ/.cf" "$PRJ/gds" "$PRJ/verilog/gl" "$PRJ/verilog/rtl" "$PRJ/lvs/$TOP"
PRJ="$(cd "$PRJ" && pwd)"

klayout -b -r "$SD/cf_relabel_gds.py" -rd gds="$ST/$TOP.gds" -rd out="$PRJ/gds/$TOP.gds.new"
mv -f "$PRJ/gds/$TOP.gds.new" "$PRJ/gds/$TOP.gds"
ln -f "$ST/$TOP.pg.flat.v" "$PRJ/verilog/gl/$TOP.v" 2>/dev/null || cp -f "$ST/$TOP.pg.flat.v" "$PRJ/verilog/gl/$TOP.v"
cp -f "$CF/macros_blackbox.v" "$PRJ/verilog/gl/"
for c in vccd1_connection vssd1_connection; do
    printf 'module %s ();\nendmodule\n' "$c" > "$PRJ/verilog/gl/$c.v"
done
cp -f "$SD/../rtl/$TOP.v" "$SD/../rtl/CF_gpio_config.v" "$PRJ/verilog/rtl/"
cp -f "$CF/lvs_config.json" "$CF/cvc.power.$TOP" "$PRJ/lvs/$TOP/"
[ -f "$PRJ/.cf/project.json" ] || cp "$CF/project.json" "$PRJ/.cf/project.json"
echo "project directory ready: $PRJ"
[ -d "$PRJ/dependencies/pdks/sky130A" ] || echo "note: no PDK there yet: run  cf setup --only-pdk --project-root $PRJ"
