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
echo "start loading data from $total files..."

sudo mysql -uroot -e "SET global FOREIGN_KEY_CHECKS=0;"
sudo mysql -uroot -e "SET global autocommit=0;"

ls *.pipe* | xargs rm -r
echo "generating pipe file..."
ls *.dat | while read file; do
    table=`basename $file .dat | sed -e 's/_[0-9]_[0-9]//'`
    pipe=$table.pipe$count 
    rm -f $pipe
    mkfifo $pipe
    LANG=C && sed -e 's_^|_\\N|_g' -e 's_||_|\\N|_g' -e 's_||_|\\N|_g' $file > $pipe &
    let count++
done

echo "loading using mysqlimport..."
ls *.pipe* | xargs mysqlimport --local $DATABASE \
                --use-threads=8 \
                --default-character-set=latin1 \
                --fields-terminated-by='|' \
                --replace \
                --silent 


sudo mysql -uroot -e "SET global FOREIGN_KEY_CHECKS=1;"
sudo mysql -uroot -e "SET global autocommit=1;"
