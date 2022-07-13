#!/bin/bash
start='2006-11-30'
end='2021-06-21'

start=$(date -d $start +%Y%m%d)
end=$(date -d $end +%Y%m%d)

while [[ $start -lt $end ]]
do
	bd=$(date -d"$end - 1 day" +"%Y-%m-%d")
        ed=$(date -d"$end" +"%Y-%m-%d")
	FILE=data/from_research_API/$bd.jsonl
	if [ -f "$FILE" ]; then
		echo "$FILE exists, skipping"
	else
		echo "$FILE does not exist, running twarc2"
		twarc2 search '"climate change" OR "global warming" OR "sea level rise" OR "climatechange" OR "globalwarming" OR "sealevelrise"' --archive --start-time $bd --end-time $ed $FILE
	fi
        end=$(date -d"$end - 1 day" +"%Y%m%d")
done
