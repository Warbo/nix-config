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

# Add <description> to items, if they don't already have one
import xml.etree.ElementTree as ET

root = ET.fromstring(out)
for item in root.findall('.//item'):
    if item.find('description') is None:
        # Find the link text
        link_elem = item.find('link')
        link_text = link_elem.text if link_elem is not None and link_elem.text \
            else "No description"

        # Create and add description element
        description = ET.SubElement(item, 'description')
        description.text = f"Link: {link_text}"

print(ET.tostring(root, encoding='unicode'))
