#!/usr/bin/env python

# flo_scraper.py ---

# Copyright (C) 2015-2016 Ruben Maher <r@rkm.id.au>

# Author: Ruben Maher <r@rkm.id.au>

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 3
# of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

import http.cookiejar as cookielib
from bs4 import BeautifulSoup
from datetime import datetime
import urllib, getpass, os, re, sys, time

semester = "s1"
year = "2016"
filetypes = "pdf|archive|text|powerpoint"  # mime types to look for
destdir = "/home/eqyiel/doc/flinders"  # don't use a trailing forward slash


def get_html_or_file(url):
    try:
        resp = urllib.request.urlopen(url)
        if not re.search("text/html", resp.info().get("Content-Type")):
            return resp.geturl()  # probably some binary file
        else:
            return get_link_to_resource(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        print("%s: %s" % (e, url))
        exit(1)


def get_link_to_resource(s):
    soup = BeautifulSoup(s)
    return soup.find(class_="resourceworkaround").a.get("href")


def get_topics(url):
    try:
        resp = urllib.request.urlopen(url)
        soup = BeautifulSoup(resp.read().decode("utf-8"))
        items = []
        for link in soup.find_all(title=re.compile("%s_%s" %
                                                   (year, semester.upper()))):
            topic_code = re.search("(\w{4})(\d{4})", link.get("title")).group()
            items.append([topic_code, link.get("href")])
        return items
    except urllib.error.HTTPError as e:
        print("%s: %s" % (e, url))
        exit(1)


def get_topic_resources(url):
    try:
        resp = urllib.request.urlopen(url)
        soup = BeautifulSoup(resp.read().decode("utf-8"))
        items = []
        for i in soup.find_all(role="presentation"):
            if re.search(filetypes, str(i)):
                items.append(i.parent.get("href") + "&redirect=0")
        return items
    except urllib.error.HTTPError as e:
        print("%s: %s" % (e, url))
        exit(1)


def get_content_length(req):
    return int(req.info().get("Content-Length"))


def make_directories(path):
    if not os.path.isdir(path):
        try:
            os.makedirs(path)
        except OSError:
            print("Couldn't create directory in %s!" % destdir)
            exit(1)


def get_basename(url):
    return os.path.basename(urllib.parse.urlparse(url).path)


def get_file(topic, url):
        path = "%s/%s_%s_%s/resources" % \
               (destdir, topic.lower(), semester, year)
        make_directories(path)
        try:
            req = urllib.request.urlopen(url)
        except urllib.error.HTTPError as e:
            print("%s: %s" % (e, url))
            exit(1)
        filename = get_basename(url)
        if filename == "handouts4.pdf":
            # Mariusz is not very creative about naming the files >___>
            # t = time.strptime(req.info().get("Date"), "%a, %d %b %Y %X %Z")
            # dt = datetime.fromtimestamp(time.mktime(t))
            # filename = dt.strftime("%F_%H-%M-%S") + ".pdf"
            filename = req.info().get("Etag").strip("\"") + ".pdf"
        fullpath = "%s/%s" % (path, filename)
        if not os.path.isfile(fullpath):
            print("%s: file doesn't exist, downloading!" % filename)
            download(req, path, filename)
        elif os.stat(fullpath).st_size < get_content_length(req):
            print("%s: file we have is smaller (%d < %d)!" %
                  (filename, os.stat(fullpath).st_size,
                   get_content_length(req)))
            download(req, path, filename)
        else:
            print("%s: file exists, not retrieving." % filename)


def download(req, path, filename):
    buffer = 4096  # bytes
    current = 0
    size = get_content_length(req)
    with open("%s/%s" % (path, filename), "wb") as file:
        while True:
            part = req.read(buffer)
            current += len(part)
            if not part:
                sys.stdout.flush()
                sys.stdout.write("\n")
                break
            report(filename, current, size)
            file.write(part)


def report(filename, current, size):
    percent = round(((float(current) / size)) * 100, 2)
    sys.stdout.write("%s: %d/%d bytes (%0.2f%%)\r" %
                     (filename, current, size, percent))


if __name__ == "__main__":
    username = input("username: ")
    password = getpass.getpass("password: ")
    cj = cookielib.CookieJar()
    opener = urllib.request.build_opener(
        urllib.request.HTTPCookieProcessor(cj))
    opener.addheaders = [("User-agent",
                          "Mozilla/5.0 (Windows NT 5.1) "
                          "AppleWebKit/537.36 (KHTML, like Gecko) "
                          "Chrome/28.0.1500.72 "
                          "Safari/537.36")]
    urllib.request.install_opener(opener)
    authentication_url = "https://flo.flinders.edu.au/login/index.php"
    payload = {"username": username, "password": password}
    data = urllib.parse.urlencode(payload)
    req = urllib.request.Request(authentication_url, data.encode("utf-8"))
    links = get_topics(req)
    resources = []
    for link in links:
        resources.append([link[0], get_topic_resources(link[1])])
    for resource in resources:
        for i in resource[1]:
            get_file(resource[0], get_html_or_file(i))
