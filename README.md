TPCDS-SQL for BDMA Data Warehouses
===
This project is for implementing the power test of [TPC-DS benchmark](http://www.tpc.org/tpcds/) on MySQL. Since TPC-DS does not support the dialect of MySQL, we have modified these templates by script and make them adapted for MySQL.

Requirements
---
- Install MySQL
- Build the binaries of tpcds toolkit, following [How_To_Guide](DSGen-software-code-3.2.0rc1/tools/How_To_Guide-DS-V2.0.0.docx)
  
Usages
---
1. Generate data
   - Serial generation
        ```bash
        ./dsdgen -scale $your_scale_factor -dir $your_data_dir
        ```
   - Parallel generation, using multiple parallel streams
        ```bash
        ./dsdgen -scale $your_scale_factor -dir $your_data_dir -parallel 2 -child 1 &
        ./dsdgen -scale $your_scale_factor -dir $your_data_dir -parallel 2 -child 2 &
        ```
2. Create database. Here we name it as tpcds
    ```bash
    mysql -e "create database $database_name"
    ```
3. Create tables, using [tpcds.sql](DSGen-software-code-3.2.0rc1/tools/tpcds.sql) provided by tpcds toolkit
    ```bash
    mysql -D$database_name < tpcds.sql 
    ```
4. Load data into MySQL
   ```bash
   ./load_data.sh $database_name $your_data_dir
   ```
5. Queries Generation
   ```bash
   ./gen_queries.sh $your_scale_factor $query_dir
   ```
6. Queries Execution
   ```bash
   # output_dir will include the result and error of query execution
   # the slow_query_log will be output in /var/log/mysql

   ./run_queries.sh $database_name $query_dir $output_dir
   ```