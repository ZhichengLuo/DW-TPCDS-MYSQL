#!/bin/bash
# autor: ZhichengLuo
# email: zcsysu@163.com

if [ $#  -lt 3 ]; then
    echo "USAGE: ./run_queries.sh <DATABASE> <QUERY_DIR> <OUTPUT_DIR>"
    echo "ERROR: parameter missing"
    exit 1
fi

DATABASE=$1
QUERY_DIR=$2
OUTPUT_DIR=$3

mkdir -p $OUTPUT_DIR && mkdir -p $OUTPUT_DIR/res && mkdir -p $OUTPUT_DIR/err && mkdir -p $OUTPUT_DIR/log

sudo mysql -uroot -e "SET GLOBAL slow_query_log = 1;"
sudo mysql -uroot -e "SET GLOBAL long_query_time = 0;"

run_query() {
	query_file=$1
	res_file="$OUTPUT_DIR/res/`basename $query_file .sql`.res"
	err_file="$OUTPUT_DIR/err/`basename $query_file .sql`.err"
	log_file="/var/log/mysql/tpcds-$DATABASE_`basename $query_file .sql`.log"
	
	sudo rm -f $log_file
	:> $log_file
	sudo chown mysql:mysql $log_file
	sudo mysql -uroot -e "SET GLOBAL slow_query_log_file = '$log_file';"

	start=`date +%s.%N`
	sudo mysql -uroot $DATABASE < $query_file > $res_file 2> $err_file
	end=`end +%s.%N`
	runtime=$( echo "$end - $start" | bc -l )
	echo -e "mysql commond runtime: $runtime"
	
	[ -s "$ERROR_FILE" ] && echo -e "\tERROR detected, check $err_file"
	[ -s "$ERROR_FILE" ] || rm -f "$ERROR_FILE"
}

echo "Database: $DATABASE"
echo "QueryDir: $QUERY_DIR"
echo "OutputDir: $OUTPUT_DIR"

QUERY_NUMBER=`ls $QUERY_DIR | grep '.sql' | wc -l`
echo "starting running $QUERY_NUMBER queries"

count=1
ls -v $QUERY_DIR | grep '.sql' | while read file; do
	echo "`date +"%D %T"` ($count/$QUERY_NUMBER) running $file "
	run_query $QUERY_DIR/$file
	let count++
done

sudo mysql -uroot -e "SET GLOBAL slow_query_log = 0;"