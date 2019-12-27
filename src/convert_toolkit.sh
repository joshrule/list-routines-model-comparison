ls -1 *log | parallel "tail -n 23 {} | head -n 21 >{.}.csv"
