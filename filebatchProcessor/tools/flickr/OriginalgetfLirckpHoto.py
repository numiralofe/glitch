import sys
import random
import urllib
from PIL import Image
from BeautifulSoup import BeautifulStoneSoup

total = len(sys.argv)
cmdargs = str(sys.argv)
 
def find_an_image(keyword):
    keyword  = str(sys.argv[1])
    print keyword
    #response = urllib.urlopen('http://api.flickr.com/services/feeds/photos_public.gne?tags=' + keyword + '&lang=us-us&format=rss_200')
    response = urllib.urlopen('http://api.flickr.com/services/feeds/photos_public.gne?tags=' + keyword + '&lang=us-us&format=rss_800')
    soup = BeautifulStoneSoup(response)
    image_list = []
 
    for image in soup.findAll('media:content'):
        image_url = dict(image.attrs)['url']
        image_list.append(image_url)
 
    return random.choice(image_list)
   
def download_an_image(image_url):
    filename = image_url.split('/')[-1]
    urllib.urlretrieve(image_url, filename)
   
    return filename
 
def get_random_start_and_end_points_in_file(file_data):
    start_point = random.randint(2500, len(file_data))
    end_point = start_point + random.randint(0, len(file_data) - start_point)
 
    return start_point, end_point
 
def splice_a_chunk_in_a_file(file_data):
    start_point, end_point = get_random_start_and_end_points_in_file(file_data)
    section = file_data[start_point:end_point]
    repeated = ''
 
    for i in range(1, random.randint(1,5)):
        repeated += section
 
    new_start_point, new_end_point = get_random_start_and_end_points_in_file(file_data)
    file_data = file_data[:new_start_point] + repeated + file_data[new_end_point:]
    return file_data
   
def glitch_an_image(local_image):
    file_handler = open(local_image, 'r')
    file_data = file_handler.read()
    file_handler.close()
 
    for i in range(1, random.randint(1,5)):
        file_data = splice_a_chunk_in_a_file(file_data)
 
    file_handler = open(local_image, 'w')
    file_handler.write(file_data)
    file_handler.close
 
    return local_image
 
if __name__ == '__main__':
    image_url = find_an_image('art')
    local_image = download_an_image(image_url)
    image_glitch_file = glitch_an_image(local_image)
 
    print image_glitch_file
