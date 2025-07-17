#-----------------------------------------------------------------------------
# SoC Labs Environment Setup Script
# A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
#
# Contributors
#
# David Mapstone (d.a.mapstone@soton.ac.uk)
#
# Copyright  2023, SoC Labs (www.soclabs.org)
#-----------------------------------------------------------------------------
#!/bin/bash
OPTIND=1

# Get Root Location of Design Structure
if [ -z $SOCLABS_DESIGN_ROOT ]; then
    # If $SOCLABS_DESIGN_ROOT hasn't been set yet
    SOCLABS_DESIGN_ROOT=`git rev-parse --show-superproject-working-tree`

    if [ -z $SOCLABS_DESIGN_ROOT ]; then
        # If not in a submodule - at root
        SOCLABS_DESIGN_ROOT=`git rev-parse --show-toplevel`
    fi

    # Source Top-Level Sourceme
    source $SOCLABS_DESIGN_ROOT/set_env.sh
else
    # Set Environment Variable for Project Dir
    SEARCH_DIR=`pwd`
    while true
    do
        if [[ -f $SEARCH_DIR"/.slprojroot" ]]; then
            export SOCLABS_PROJECT_DIR=$SEARCH_DIR
            break
        else
            SEARCH_DIR=$SEARCH_DIR/..
        fi
    done

    # If this Repo is root of workspace
    if [ $SOCLABS_PROJECT_DIR = $SOCLABS_DESIGN_ROOT ]; then
        echo "Design Workspace: $SOCLABS_DESIGN_ROOT" 
        export SOCLABS_DESIGN_ROOT
    fi

    # Add in location for socsim scripts
    export SOCLABS_SOCSIM_PATH=$SOCLABS_PROJECT_DIR/simulate/socsim
    

    # Source dependency environment variable script
    source $SOCLABS_PROJECT_DIR/env/dependency_env.sh

    # Add Scripts to Path
    # "TECH_DIR"
    while read line; do 
        #TODO finish applying this patch!!!!
        # eval PATH="$PATH:\$${line}/flow"
        eval PATH="\"$PATH:\${${line}}/flow\""
        # Fix: Might need to replace the above with this for WSL:
        #PATH="$PATH:${!line}/flow"
    done <<< "$(awk 'BEGIN{for(v in ENVIRON) print v}' | grep TECH_DIR)"

    # "FLOW_DIR"
    while read line; do 
        eval PATH="$PATH:\$${line}/tools"
    done <<< "$(awk 'BEGIN{for(v in ENVIRON) print v}' | grep FLOW_DIR)"

    # "SOCLABS_PROJECT_DIR"
    while read line; do 
        eval PATH="$PATH:\$${line}/flow"
    done <<< "$(awk 'BEGIN{for(v in ENVIRON) print v}' | grep SOCLABS_PROJECT_DIR)"

    export PATH
fi

# Parse Command line options
force=false
while getopts "f" arg; do
    case $arg in
        f) # Force socinit
            force=true
            echo "Forcing Reinitialisation of Project"
            ;;
    esac
done


# Check cloned repository has been initialised
if [ ! -f $SOCLABS_PROJECT_DIR/.socinit ] || [ $force = true ]; then
    echo "Running First Time Repository Initialisation"
    # Source environment variables for all submodules
    cd $SOCLABS_DESIGN_ROOT
    echo $SOCLABS_DESIGN_ROOT
    git submodule update --recursive
    python3 $SOCLABS_SOCTOOLS_FLOW_DIR/bin/subrepo_checkout.py -b projbranch -t $SOCLABS_DESIGN_ROOT
    git restore $SOCLABS_DESIGN_ROOT/.gitmodules
    touch $SOCLABS_PROJECT_DIR/.socinit
    echo "SoC Labs File Initialisation file: This file has been created to show that the project has been initialised" > $SOCLABS_PROJECT_DIR/.socinit
fi
