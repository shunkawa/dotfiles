#!/usr/bin/env python

# get_lectures.py ---

# Copyright (C) 2015 Ruben Maher <r@rkm.id.au>

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

import os, sys, re, feedparser, urllib.request, time
from datetime import datetime

topics = ["comp3742"]
year = 2015
semester = "s2"
destdir = "/home/eqyiel/doc/flinders"  # don't use a trailing forward slash


def go(feedtype):
    target = "http://video.flinders.edu.au/lectureResources/%s/%s_%d.xml" \
             % (feedtype, topic.upper(), year)
    feed = feedparser.parse(target)
    get(parse(feed, feedtype), feedtype)


def parse(feed, feedtype):
    items = []
    for entry in feed.entries:
        # Get the date from the name so we can call the file something more
        # sensible than "165025_adsl.mp4"
        day, dd, mm, yy = re.search("(\S{3}), (\d{2}) (\S{3}) (\d{4})",
                                    entry.title[2:]).groups()
        mm = time.strptime(mm, "%b")
        mm = datetime.fromtimestamp(time.mktime(mm)).strftime("%m")
        # Also append the file's id number, because there may be more than
        # one lecture per day per topic, and there is no information in the
        # feed about what time the lecture occurred.
        id = re.search("(\d{6})", entry.id).groups()[0]
        topic = feed.feed.title.lower()
        filetype = "mp4" if feedtype == "vod" else "mp3"
        filename = "%s_%s-%s-%s-%s_%s.%s" % (topic, yy, mm, dd,
                                             day.lower(), id, filetype)
        items.append([topic, filename, entry.id])
    return items


def get(items, feedtype):
    for item in items:
        topic, filename, url = item
        if feedtype == "vod":
            path = "%s/%s_%s_%d/vod" % (destdir, topic, semester, year)
        else:
            path = "%s/%s_%s_%d/pod" % (destdir, topic, semester, year)
        if not os.path.isdir(path):
            try:
                os.makedirs(path)
            except OSError:
                print("Couldn't create directory in %s!" % destdir)
                exit(1)
        try:
            req = urllib.request.urlopen(url)
        except urllib.error.HTTPError as e:
            print("%s: %s" % (e, url))
            continue
        # File doesn't exist, or the file we have on disk is smaller than the
        # Content-Length reported.
        if not os.path.isfile("%s/%s" % (path, filename)):
            print("%s: file doesn't exist, downloading!" % filename)
            download(req, path, filename)
        elif os.stat("%s/%s" % (path, filename)).st_size < \
        int(req.info().get("Content-Length")):
            print("%s: file we have is smaller (%d < %d), downloading!" %
                  (filename, os.stat("%s/%s" % (path, filename)).st_size,
                   int(req.info().get("Content-Length"))))
            download(req, path, filename)
        else:
            print("%s: file exists, not retrieving." % filename)


def download(req, path, filename):
    buffer = 4096  # bytes
    current = 0
    size = int(req.info().get("Content-Length"))
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
    for topic in topics:
        go("vod")
        go("pod")
