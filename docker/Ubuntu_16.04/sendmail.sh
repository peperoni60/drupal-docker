#!/usr/bin/env bash

umask 000
dir="/sendmail"
new="${dir}"
numberfile="${dir}/email_numbers"

if [ ! -f ${numberfile} ]; then
    echo "0" > ${numberfile}
fi
emailNumber=`cat ${numberfile}`
emailNumber=$((${emailNumber} + 1))
echo ${emailNumber} > ${numberfile}
name="${new}/letter_${emailNumber}.eml"
while IFS= read line
do
    echo "${line}" >> ${name}
done
/bin/true