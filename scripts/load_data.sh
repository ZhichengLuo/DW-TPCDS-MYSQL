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

# Diable FOREIGN_KEY_CHECKS to speed up the data loading. After loading is done, it will be set back.
sudo mysql -uroot -e "SET global FOREIGN_KEY_CHECKS=0;"

ls *.dat | while read file; do
    table=`basename $file .dat | sed -e 's/_[0-9]_[0-9]//'`
    echo "($count/$total) `date +"%D %T"` `ls -sh $file` to $table"

    # Utilize named pipe to avoid unnecessary temporary files on disk
    pipe=$table.pipe
    rm -f $pipe
    mkfifo $pipe
    # Replace empty string to '\N' as MySQL doesn't convert empty string into NULL values 
    LANG=C && sed -e 's_^|_\\N|_g' -e 's_||_|\\N|_g' -e 's_||_|\\N|_g' $file > $pipe & \
    mysql --local-infile -D$DATABASE -e \
        "load data local infile '$pipe' replace into table $table character set latin1 fields terminated by '|'"
    
    rm -f $pipe
    let count++
done

sudo mysql -uroot -e "SET global FOREIGN_KEY_CHECKS=1;"
