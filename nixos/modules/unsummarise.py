from morss import crawler, feeds, Options, FeedFormat, FeedGather
from sys import stdin
from os import environ

for var in ['LIM_ITEM', 'LIM_TIME', 'MAX_TIME']:
    environ[var] = '-1'
environ['MAX_ITEM'] = '50'

url = 'http://example.com'
options = Options(indent=True)
data = stdin.buffer.read()
enc = crawler.detect_encoding(data)
rss = feeds.parse(data, url=url, encoding=enc)
rss = rss.convert(feeds.FeedXML)
rss = FeedGather(rss, url, options)
out = FeedFormat(rss, options, 'unicode')
print(out)
