import shutil
from  requests import get
from bs4 import BeautifulSoup
import subprocess


ROOT="/home/neil/.cache/comic"
XKCD=ROOT+"/xkcd"
GOOSE=ROOT+"/goose"

## COMIC dictionary fields:
#top level key is comic name
#path should point to the top level of the directory for that comic
#url should be the base of the url for the comic 
#end indicates what comes after the comic number (usually a /)
COMICS={'xkcd':{'path':XKCD,'baseUrl':"https://xkcd.com/",'end':'/'},'abstrusegoose':{'path':GOOSE,'baseUrl':"https://abstrusegoose.com/",'end':''}}

## To add more comics:
#Add the appropriate values to the above dictionary
#Modify the getImageUrl function so that the appropriate img tag can be found


def checkExists(url):
    r=get(url)
    if r.status_code==200:
        return r 
    return False

def getImageUrl(soup):
    getWord=['imgs.xkcd.com/comics/','abstrusegoose.com/strips/']
    for n in soup.find_all('img'):
        for m in getWord:
            if m in str(n['src']):
                return str(n['src'])
    return None


def getImage(imageUrl,path):
    if(imageUrl[0:2]=='//'):
        imageUrl='http:'+imageUrl
    r=get(imageUrl)
    if r.status_code == 200:
        with open(path, 'wb') as f:
            for chunk in r:
                f.write(chunk)
        return 1
    else:
        print("Something went wrong getting the image")
        exit()
        return 0

def getNew():
    for comic in COMICS:
        lastViewedPath = COMICS[comic]['path']+'/prevComic' #path to file containing last viewed comic number
        with open(lastViewedPath,'r') as f:
                lastViewed = int(f.readline().strip())
        
        newNum=str(1+int(lastViewed)) 
        url=COMICS[comic]['baseUrl']+newNum+COMICS[comic]['end']
        exists=checkExists(url)
        if(exists!=False):
            imageUrl=getImageUrl(BeautifulSoup(exists.text,'html.parser'))
            break

    imagePath=f"{COMICS[comic]['path']}/archive/{newNum}.png"
    image=getImage(imageUrl,imagePath)
    # If you get to this point and getting the image failed then exit and notify user
    if not image:
        exit()
    display(imagePath)
    with open(lastViewedPath,'w') as f:
        f.seek(0)
        f.write(newNum)
        f.truncate()

def display(imagePath):
    displayProcess = subprocess.run(["sxiv", "-g", "850x600+255+70", imagePath])
    # print("The exit code was: %d" % displayProcess.returncode)

getNew()