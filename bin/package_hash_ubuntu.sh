#!/bin/bash

set -e

handoff() {
    echo "package_hash_ubuntu.sh has been kicked off by idol_create.sh..." | tee -a $LOG_OUT;
    echo "package_hash_ubuntu.sh is initiating package hash BATS creation..." | tee -a $LOG_OUT;
    echo "idol name.................."$IDOL_NAME | tee -a $LOG_OUT;
    echo "" | tee -a $LOG_OUT;
}

completion() {
    echo "package_hash_ubuntu.sh has completed for idol "$IDOL_NAME | tee -a $LOG_OUT;
    exit 0;
}

initialize_bats() {
    echo "#!/usr/bin/env bats" >> $OUTPUT_BATS;
    echo "" >> $OUTPUT_BATS;
#    echo "load test_helper" >> $OUTPUT_BATS;
#    echo "fixtures bats" >> $OUTPUT_BATS;
    echo "" >> $OUTPUT_BATS;
}

generate_package_hash() {
    echo "Generating Package Golden Hash for "${IDOL_NAME} >> $LOG_OUT;
    rm -f /tmp/package_hash.txt && touch /tmp/package_hash.txt;
	dpkg --list | awk '{ print $2 }' >> /tmp/package_hash.txt;
	local hashgolden=($(md5sum /tmp/package_hash.txt));
	echo $hashgolden;
}

generate_package_hash_bats() {
    echo "Generating Package Hash Test for "${IDOL_NAME} >> $LOG_OUT;
    echo "@test \"SOFTWARE CHECK - "${IDOL_NAME}" Package HASH\" {" >> $OUTPUT_BATS;
    echo "dpkg --list | awk '{ print $2 }' > /tmp/package_hash.txt" >> $OUTPUT_BATS;
    echo "HASHCHECK=($(md5sum /tmp/package_hash.txt))" >> $OUTPUT_BATS;
    echo "[ $HASHCHECK -eq ${HASHGOLDEN} ]" >> $OUTPUT_BATS;
    echo "}" >> $OUTPUT_BATS;
    echo " " >> $OUTPUT_BATS;
}


HASH_BATS=$1;
IDOL_NAME=$2;
LOG_OUT=$3;

OUTPUT_BATS=$HASH_BATS/package_hash.bats;

#Acknowledge handoff...
handoff;

#Initialize bats and generate package list / package bats.
initialize_bats;
HASHGOLDEN=$(generate_package_hash);
generate_package_hash_bats;

#Acknowledge completion of BATS generation.
completion;
