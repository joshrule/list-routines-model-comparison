
string=$(echo $1 | sed "s/\ //g" | sed "s/\[//g" | sed "s/\]//g")
grep "\[$string\]" metagol.csv | cut -f 3 -d , | uniq
