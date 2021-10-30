#!/bin/bash
# autor: YanjianZhang

searchdir='query_templates_mysql'
for entry in "$searchdir"/*
	do
		# echo $entry
		
		# replace _LIMIT
		sed -i 's/\[_LIMITA\]//' $entry
		sed -i 's/\[_LIMITB\]//' $entry
		sed -i 's/\[_LIMITC\]/limit %d/' $entry
		# preprocessing: make two blank into one

		# sed -ri 's/  / /' $entry

		# mofidy the date adding function
		sed -ri "s/\(cast[ ]?\('(.+)' as date\) [ ]?\+ [ ]?([[:digit:]]+) days\)/date_add(cast('\1' as date), interval \2 day)/" $entry
		
		# modify the date deleting fucntion
		sed -ri "s/\(cast[ ]?\('(.+)' as date\) [ ]?\- [ ]?([[:digit:]]+) days\)/date_sub(cast('\1' as date), interval \2 day)/" $entry
		
		# to process group by, we concate the columns in different line into one line, and make a regex match
		sed -ri '/group by/{$!N;s/(.+)\n *,(.+)/\1,\2/
			$!N;s/(.+)\n *,(.+)/\1,\2/
			$!N;s/(.+)\n *,(.+)/\1,\2/
			s/group by [ ]?rollup[ ]?\(([^\)]+)\)/group by \1 with rollup/}' $entry
		
		# replace except with 'and not exists'
		sed -ri '/\)/{$!N;s/\) *\n *except/ and not exists/}' $entry
		
		# replace two || with concat
		sed -ri "s/,(.+) \|\| ', ' \|\| (.+) as/,concat(\1, ', ', \2) as/" $entry
	       	
		# replace one || with concat
		sed -ri "s/'(.+)' \|\| (.+) as/concat('\1', ifnull(\2, '')) as/" $entry
		
		# replace type int into signed
	       	sed -ri	"s/as int/as signed/" $entry	
		
		# remove the blank before cast
		sed -ri "s/cast +/cast/" $entry

		# remove the blank before sum
		sed -ri "s/sum +/sum/" $entry
		
		# replace full outer join with left join union right join (we use perl instead of sed for the need of look ahead function)
		# perl -i -p -e 'm/^select((?:(?!select)[\s\S])+)full outer join(.*)on((?:(?!\))[\s\S])+\))$/select \1 left join \2 on \3 union select \1 right join \2 on \3/' $entry

		# queries generated from query8.tpl
		sed -ri '/intersect/{$!N;s/intersect\n *select ca_zip/and substr(ca_zip,1,5) in (select ca_zip/}' $entry		
		sed -ri '/having count/{s/having count\(\*\) > 10\)A1\)A2\) V1/having count(*) > 10)A1))A2) V1/}' $entry
		
		# queries generated from query14.tpl
		sed -ri '/intersect/{$!N;s/intersect *\n *select ics.i_brand_id/and exists (select ics.i_brand_id/}' $entry
		sed -ri '/intersect/{$!N;s/intersect *\n *select iws\.i_brand_id/) and exists (select iws.i_brand_id/}' $entry
		sed -ri '/d_year between/{$!N;s/and d3\.d_year between ([[:digit:]]+) AND ([[:digit:]]+) \+ 2\) *\n *where i_brand_id = brand_id/and d3.d_year between \1 AND \2 + 2)) temp where i_brand_id = brand_id/}' $entry
		sed -ri 's/and d3\.d_year between ([[:digit:]]+) AND ([[:digit:]]+) \+ 2\) x/and d3.d_year between \1 AND \2 + 2)) x/' $entry
		
		# queries generated from query38.tpl
		sed -ri '/intersect/{$!N;$!N;s/intersect *\n *select distinct c_last_name, c_first_name, d_date *\n *from catalog_sales, date_dim, customer/and exists (select distinct c_last_name, c_first_name, d_date from catalog_sales, date_dim, customer/}' $entry
		sed -ri '/intersect/{$!N;$!N;s/intersect *\n *select distinct c_last_name, c_first_name, d_date *\n *from web_sales, date_dim, customer/) and exists (select distinct c_last_name, c_first_name, d_date from web_sales, date_dim, customer/}' $entry
		sed -ri '/and d_month_seq between/{$!N;s/and d_month_seq between ([[:digit:]]+) and ([[:digit:]]+) \+ 11 *\n *\) hot_cust/and d_month_seq between \1 and \2 + 11)) hot_cust/}' $entry
		# queries generated from query2.tpl,query23.tpl,query49.tpl
		sed -ri 's/from catalog_sales\)\),/from catalog_sales) temp),/' $entry
		sed -ri 's/group by c_customer_sk\)\),/group by c_customer_sk) temp),/' $entry
		sed -ri 's/and ws_bill_customer_sk in \(select c_customer_sk from best_ss_customer\)\)/and ws_bill_customer_sk in (select c_customer_sk from best_ss_customer)) temp/' $entry
		sed -ri 's/group by c_last_name,c_first_name\)/group by c_last_name,c_first_name) temp/' $entry
		sed -ri '/store\.currency_rank <= 10/{$!N;$!N;s/store\.currency_rank <= 10 *\n *\) *\n *\)/store.currency_rank <= 10)) temp/}' $entry
		
		# queris generated from query87.tpl
		sed -ri 's/\) cool_cust/))) cool_cust/' $entry	
				
		# queries generated from query30.tpl
		sed -ri 's/c\_last\_review\_date\_sk/c_last_review_date/' $entry
		
	done
