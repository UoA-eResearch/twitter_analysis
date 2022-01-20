#!/bin/bash
start='2006-11-30'
end='2021-01-14'

start=$(date -d $start +%Y%m%d)
end=$(date -d $end +%Y%m%d)

while [[ $start -lt $end ]]
do
	bd=$(date -d"$end - 1 day" +"%Y-%m-%d")
	ed=$(date -d"$end" +"%Y-%m-%d")
	twarc2 search '"climate change" OR "global warming" OR "sea level rise" OR "climatechange" OR "globalwarming" OR "sealevelrise"' --archive --start-time $bd --end-time $ed data/from_research_API/$bd.jsonl
        end=$(date -d"$end - 1 day" +"%Y%m%d")
done
