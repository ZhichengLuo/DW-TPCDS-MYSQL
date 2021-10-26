#!/bin/bash
# autor: ZhichengLuo
# email: zcsysu@163.com

if [ $#  -lt 2 ]; then
    echo "USAGE: ./load_data.sh <DATABASE> <DATA_DIR>"
    echo "ERROR: parameter missing"
    exit 1
fi

DATABASE=$1
DATA_DIR=$2

cd $DATA_DIR

count=1
total=`ls *.dat | wc -l`

sudo mysql -uroot -e "SET global FOREIGN_KEY_CHECKS=0;"
sudo mysql -uroot -e "SET global autocommit=0;"

ls *.dat | while read file; do
    table=`basename $file .dat | sed -e 's/_[0-9]_[0-9]//'`
    echo "($count/$total) `date +"%D %T"` `ls -sh $file` to $table"
    # 因为mysqlimport
    pipe=$table.pipe$count 
    rm -f $pipe
    mkfifo $pipe
    LANG=C && sed -e 's_^|_\\N|_g' -e 's_||_|\\N|_g' -e 's_||_|\\N|_g' $file > $pipe &
    let count++
done

ls *.pipe* | xargs mysqlimport --local $DATABASE \
                --use-threads=8 \
                --default-character-set=latin1 \
                --fields-terminated-by='|' \
                --replace \
                --silent 

ls *.pipe* | xargs rm -r

sudo mysql -uroot -e "SET global FOREIGN_KEY_CHECKS=1;"
sudo mysql -uroot -e "SET global autocommit=1;"
