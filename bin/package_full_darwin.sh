#!/bin/bash

set -e

handoff() {
    echo "package_full_darwin.sh has been kicked off by idol_create.sh..." | tee -a $LOG_OUT;
    echo "package_full_darwin.sh is initiating full package BATS creation..." | tee -a $LOG_OUT;
    echo "idol name.................."$IDOL_NAME | tee -a $LOG_OUT;
    echo "Packages to be processed..."$(ls /Applications | wc -l) | tee -a $LOG_OUT;
    echo "" | tee -a $LOG_OUT;
}

completion() {
    echo "package_full_darwin.sh has completed for idol "$IDOL_NAME | tee -a $LOG_OUT;
}

initialize_bats() {
    echo "#!/usr/bin/env bats" >> $OUTPUT_BATS
    echo "" >> $OUTPUT_BATS
    echo "load test_helper" >> $OUTPUT_BATS
    echo "fixtures bats" >> $OUTPUT_BATS
    echo "" >> $OUTPUT_BATS
}

generate_package_list() {
    rm -f /tmp/package.txt && touch /tmp/package.txt
    ls /Applications/ >> /tmp/packge.txt
}

generate_package_bats() {
    while IFS=, read -r package; do

        PACKAGE=$package

        echo "@test \"SOFTWARE CHECK - "${PACKAGE}"\" {" >> $OUTPUT_BATS
        echo "ls /Applications | grep \""${PACKAGE}"\"" >> $OUTPUT_BATS
        echo "[ \$? -eq 0 ]" >> $OUTPUT_BATS
        echo "}" >> $OUTPUT_BATS
        echo " " >> $OUTPUT_BATS

    done < /tmp/package.txt
}


BASE_DIR=$1;
IDOL_NAME=$2;
LOG_OUT=$3;
BIN_DIR=$BASE_DIR/bin;
LIB_DIR=$BASE_DIR/lib;
TEST_DIR=$BASE_DIR/tests;
MAN_DIR=$BASE_DIR/man;
IDOL_DIR=$TEST_DIR/$IDOL_NAME;

OUTPUT_BATS=$IDOL_DIR/package_full.bats

#Acknowledge handoff...
handoff

#Initialize bats and generate package list / package bats.
initialize_bats
generate_package_list
generate_package_bats

#Acknowledge completion of BATS generation.
completion
