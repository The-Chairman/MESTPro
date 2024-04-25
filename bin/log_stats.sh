#!/bin/bash
pw=${2:-80}

header=$(awk -vpw=$pw 'BEGIN {s=sprintf("%"pw"s","");gsub(/ /,"=",s);print s}')
dots=$(awk -vpw=$pw 'BEGIN {s=sprintf("%"pw"s","");gsub(/ /,".",s);print s}')

echo $header
echo "$1"
echo $header
for n in $(find $1 -name *.log -or -name *.error | sort)
do
    bn=$(basename $n)
    lc=$(wc -l $n  | awk -F' ' '{print $1'} )
    echo "$bn"${dots:(( ${#bn} + ${#lc}))}$lc   
done