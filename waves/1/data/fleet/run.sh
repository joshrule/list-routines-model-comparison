ls wave1 | parallel --jobs=25 "./main --chains=8 --threads=8 --time=5m --input=wave1/{1} > out/{1}.out"
