# Botscores calculation

library(tweetbotornot2)

token = readRDS("twittertoken.rds")
rtweet::rate_limit(token, "get_timeline")

df = read.csv("data/botscores.csv", colClasses = list(user_id='character'))
ids = read.csv("data/users_ids.csv", colClasses = list(user_id='character'))
ids = ids[!ids$user_id %in% df$user_id,] # Filter out users that have already been checked

print("CSVs loaded")

save = function() {
  df = df[order(-df$n_tweets),] # Order by n_tweets descending
  print(df)
  bots = sum(df$prob_bot > .5, na.rm=T)
  ppl = sum(df$prob_bot < .5, na.rm=T)
  print(sprintf("%d bots, %d ppl, %f%% bots", bots, ppl, bots / ppl * 100))
  
  write.csv(df, "data/botscores.csv", row.names=F)
}

for (i in seq(1, nrow(ids), 10)) {
  tryCatch({
    output = predict_bot(ids$user_id[i:(i+10)], token = token)
    output$n_tweets = ids$n_tweets[i:(i+10)]
    df = rbind(df, output)
  }, error = function(c) {
    print(paste(ids$user_id[i], "failed"))
  })

  ## print iteration update
  print(rtweet::rate_limit(token, "get_timeline"))
  cat(sprintf("%d / %d (%.f%%)\n", i, nrow(ids), i / nrow(ids) * 100))
  if (i %% 100 == 1) {
    save()
  }
}

