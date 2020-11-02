#!/bin/bash
for year in {2006..2020}; do
	echo $year;
	time twarc hydrate "tweet_ids/climate_tweets_${year}.csv_tweet_ids.txt" > "hydrated/climate_tweets_${year}.jsonl"
done
