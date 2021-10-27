#!/bin/bash
# autor: ZhichengLuo
# email: zcsysu@163.com

# The execution time of the queries with the following index exceeded 30 mins under scale factor 1
# So here I choose to skip the generation of these queries
IGNORE_QUERY_INDEX=(10 14 35)

gen_query_for_idx() {
    ./dsqgen \
        -template query$1.tpl \
        -directory ../query_templates \
        -dialect mysql \
        -scale $SCALE_FACTOR \
        -output_dir $OUTPUT_DIR \
        -quiet Y \
    && mv $OUTPUT_DIR/query_0.sql $OUTPUT_DIR/query$1.sql
}

if [ $#  -lt 2 ]; then
    echo "USAGE: ./gen_queries.sh <SCALE_FACTOR> <OUTPUT_DIR>"
    echo "ERROR: parameter missing"
    exit 1
fi

SCALE_FACTOR=$1
OUTPUT_DIR=`realpath $2`

cd ../DSGen-software-code-3.2.0rc1/tools

for((i=1;i<100;i++)); do
    found=0
    for j in "${IGNORE_QUERY_INDEX[@]}"; do
        if [ $j -eq $i ]; then
            found=1
        fi
    done
    if [ $found -eq 1 ]; then
        continue
    fi
    gen_query_for_idx $i
done  
