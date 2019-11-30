#!/bin/bash
source /home/jhou4/tools/multicom/tools/PyRosetta.ScientificLinux-r55981.64Bit/SetPyRosettaEnvironment.sh
export LD_LIBRARY_PATH=/home/jhou4/tools/multicom/tools/Python-2.6.8/lib:$LD_LIBRARY_PATH
export PYROSETTA_DATABASE=$PYROSETTA/rosetta_database
export R_LIBS=/home/jhou4/tools/multicom/tools/Fusion/fusion_lib
export PATH=$PATH:/home/jhou4/tools/multicom/tools/Fusion/fusion_lib/phycmap.release/bin
python /home/jhou4/tools/multicom/src/meta/fusioncon/fusion/scripts/Fusion_Abinitio_with_contact.py $*
