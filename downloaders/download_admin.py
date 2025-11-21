#!/usr/bin/env python3
"""
Simple Python downloader + extractor for admin-scripts.zip
Usage: python3 download_admin.py
"""
import sys
from pathlib import Path
import urllib.request
import zipfile

URL = 'https://github.com/french2012/99-nights/raw/main/admin-scripts.zip'
OUT = Path('admin-scripts.zip')
DIR = Path('admin-scripts')

def main():
    print('Downloading', URL)
    try:
        urllib.request.urlretrieve(URL, OUT)
    except Exception as e:
        print('Download failed:', e, file=sys.stderr)
        sys.exit(1)

    print('Extracting', OUT, 'to', DIR)
    try:
        with zipfile.ZipFile(OUT, 'r') as z:
            z.extractall(DIR)
    except Exception as e:
        print('Extraction failed:', e, file=sys.stderr)
        sys.exit(2)

    print('Done. Files are in', DIR / 'roblox-dev-admin')

if __name__ == '__main__':
    main()
