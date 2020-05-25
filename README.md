# Webcomics Scraper
## Purpose
These programs  check for new releases of certain webcomics using webscraping. I wanted a program that would display the latest xkcd comic every time i woke my computer from sleep. I achieved it by triggering this program when the acpi lid close event occurs. 

## The Implementations
The program is implemented in python, and seperately in bash(as a exercise to gain familiarity with bash). The main difference between the two is that the python implementation is written so that it can be easily modified to check for additional comics

## Requirements
+Both implementations use sxiv to display the image but that can be easily changes in the source code
+the Python impoementation requires
..+Python3
..+requests 
..+shutil 
..+BeautifulSoup 
..+subprocess


## Setup

## Directory structure:
```
base_dir
├── comic_1
│    ├── archive
│    │   ├── file1.png
│    │   ├── file2.png
│    │   ├── file3.png
│    └── prevComic
└── comic_2
    ├── archive
    │   ├── file1.png
    │   ├── file2.png
    │   ├── file3.png
    └── prevComic
```
The directory should be created prior to running the program for the first time. The prevComic file should contain the number of the latest post of that comic.

## Constants
Both implementations have certain constants at the beginning of the file that need to be set before use like, base directory comic names,urls,etc

