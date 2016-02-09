from urllib import FancyURLopener
import re
import posixpath
import urlparse 

class MyOpener(FancyURLopener, object):
    version = "Mozilla/5.0 (Linux; U; Android 4.0.3; ko-kr; LG-L160L Build/IML74K) AppleWebkit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30"

myopener = MyOpener()

page = myopener.open('https://www.google.pt/search?q=love&biw=1600&bih=727&source=lnms&tbm=isch&sa=X&tbs=isz:l&tbm=isch')
html = page.read()

for match in re.finditer(r'<a href="http://www\.google\.pt/imgres\?imgurl=(.*?)&amp;imgrefurl', html, re.IGNORECASE | re.DOTALL | re.MULTILINE):
    path = urlparse.urlsplit(match.group(1)).path
    filename = posixpath.basename(path)
    myopener.retrieve(match.group(1), filename)
