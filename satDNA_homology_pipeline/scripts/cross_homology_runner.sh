currentDate=`date`
currentDate=`tr ' :' '_' <<<"$currentDate"`
cat $1
cat $1 | parallel
		
mkdir temp_${currentDate}
		
cat *.blast.hits > $2



mv *.blast.commands *.blast.hits temp_${currentDate} 
