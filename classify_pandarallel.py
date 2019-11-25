#!/usr/bin/env python3

import numpy as np # linear algebra
import pandas as pd # data processing, CSV file I/O (e.g. pd.read_csv)
import glob
from pandarallel import pandarallel
from tqdm.auto import tqdm
tqdm.pandas()
from bs4 import BeautifulSoup
from vaderSentiment.vaderSentiment import SentimentIntensityAnalyzer
import os
pandarallel.initialize(progress_bar=True, nb_workers=12, shm_size_mb=4000)

os.makedirs("classified", exist_ok=True)
analyzer = SentimentIntensityAnalyzer()
files = glob.glob("data/climate_tweets*.csv")
#print(files)
pd.set_option('display.max_colwidth', -1)

def classify(row):
    soup = BeautifulSoup(row.html, "lxml")
    s = []
    for child in soup.find("p").children:
        if child.name == None:
            s.append(child)
        elif child.name == "img":
            s.append(child["alt"])
        else:
            s.append(child.text)
    text_with_emoji = " ".join(s)
    row["text_with_emoji"] = text_with_emoji
    vs = analyzer.polarity_scores(text_with_emoji)
    for k,v in vs.items():
        row[k] = v
    return row

for f in tqdm(files):
    df = pd.read_csv(f, sep=";")
    df = df.parallel_apply(classify, axis=1)
    print("Complete - writing csv")
    new_filename = "classified/" + os.path.splitext(os.path.basename(f))[0] + ".csv"
    df.to_csv(new_filename, sep=";", index=False)
