# Command for wave 1:
ls data | parallel --jobs=25 "./main --chains=4 --threads=2 --time=1m --input=data/{1} > out-1m/{1}" &

ls data | parallel --jobs=25 "./main --chains=4 --threads=2 --time=10m --input=data/{1} > out-10m/{1}" &

