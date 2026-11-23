"""Post one promo message to X, rotating daily through x_posts.json."""
import datetime
import json
import os
import pathlib
import sys

import tweepy

URL = "https://nikolmichaelidou.github.io/Monster-Energy-TCG/"
MAX_LEN = 280
URL_LEN = 23  # X counts every link as 23 characters

here = pathlib.Path(__file__).parent
posts = json.loads((here / "x_posts.json").read_text(encoding="utf-8"))

index = datetime.datetime.now(datetime.timezone.utc).date().toordinal() % len(posts)
text = posts[index].replace("{url}", URL)
length = len(posts[index].replace("{url}", "")) + URL_LEN
if length > MAX_LEN:
    sys.exit(f"Post {index} is {length} characters, over the {MAX_LEN} limit.")

if os.environ.get("DRY_RUN") == "1":
    print(f"[dry run] post {index}:\n{text}")
    sys.exit(0)

NAMES = ("X_API_KEY", "X_API_SECRET", "X_ACCESS_TOKEN", "X_ACCESS_TOKEN_SECRET")
missing = [n for n in NAMES if not os.environ.get(n)]
if missing:
    sys.exit(f"Missing secrets: {', '.join(missing)}. Add them under Settings > Secrets and variables > Actions.")

client = tweepy.Client(
    consumer_key=os.environ["X_API_KEY"],
    consumer_secret=os.environ["X_API_SECRET"],
    access_token=os.environ["X_ACCESS_TOKEN"],
    access_token_secret=os.environ["X_ACCESS_TOKEN_SECRET"],
)
try:
    response = client.create_tweet(text=text)
except tweepy.TweepyException as exc:
    # Report only the error type and HTTP status, never request details.
    status = getattr(getattr(exc, "response", None), "status_code", "n/a")
    sys.exit(f"X API request failed: {type(exc).__name__} (HTTP {status})")
print(f"Posted {response.data['id']}:\n{text}")
