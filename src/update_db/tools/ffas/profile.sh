#!/bin/sh

#inputs: multiple sequence alignment file, output file

 #calculate ffas profiles 
export FFAS=/home/jh7x3/multicom/databases/ffas_dbs/
export PATH=$PATH:/home/jh7x3/multicom/databases/ffas_dbs/soft

#cat 1UCSA.ffas.mu | profil > 1UCSA.ffas 
#profil 1UCSA.ffas.mu > ff_T0579

cat $1 | profil >> $2

