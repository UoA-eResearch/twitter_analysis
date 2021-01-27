# Botscores calculation

library(tweetbotornot2)

token = readRDS("twittertoken.rds")
rtweet::rate_limit(token, "get_timeline")

df = read.csv("data/botscores.csv")

ids = read.csv("data/users_ids.csv")
ids = ids[!ids$user_id %in% df$user_id,] # Filter out users that have already been checked

ids$user_id = as.character(ids$user_id)

print("CSVs loaded")

## convert users vector (user IDs or screen names) a list of 10-user chunks
users <- chunk_users(ids$user_id, n = 10)
print("Chunked user vector created")

## initialize output vector
output <- vector("list", length(users))

for (i in seq_along(output)) {
  ## set oops counter
  oops <- 0L

  ## check rate limit- if < 10 calls remain, sleep until reset
  print(rl <- rtweet::rate_limit(query = "get_timelines", token=token))
  while (rl[["remaining"]] < 10L) {
    ## prevent infinite loop
    oops <- oops + 1L
    if (oops > 3L) {
      stop("rate_limit() isn't returning rate limit data", call. = FALSE)
    }
    cat("Sleeping for", round(max(as.numeric(rl[["reset"]], "mins"), 0.5), 1), "minutes...")
    Sys.sleep(max(as.numeric(rl[["reset"]], "secs"), 30))
    rl <- rtweet::rate_limit(query = "get_timelines", token=token)
  }

  ## get bot estimates
  output[[i]] <- predict_bot(users[[i]], token = token)

  ## print iteration update
  cat(sprintf("%d / %d (%.f%%)\n", i, length(output), i / length(output) * 100))
}

## merge into single data table
output = do.call("rbind", output) # Bind into one dataframe
new_df = merge(output, ids, by="user_id") # Join back n_tweets
df = rbind(df, new_df) # Add back in existing results
df = df[order(-df$n_tweets),] # Order by n_tweets descending
print(df)
bots = sum(df$prob_bot > .5, na.rm=T)
ppl = sum(df$prob_bot < .5, na.rm=T)
print(sprintf("%d bots, %d ppl, %f%% bots", bots, ppl, bots / ppl * 100))

write.csv(df, "data/botscores.csv", row.names=F)
