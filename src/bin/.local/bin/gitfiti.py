#!/usr/bin/env python
#
# Eric Romano's gitfiti with customisations.
#
# Copyright (c) 2013 Eric Romano (@gelstudios)
# released under The MIT license (MIT) http://opensource.org/licenses/MIT
#
"""
gitfiti

noun : Carefully crafted graffiti in a github commit history calendar

"""

import datetime
import math
import itertools
import urllib.request
import json
import os
import stat

KYUBEY = [
[0,0,0,0,0,0,0,0,1,0,0,0,0,0,1,2,0,0,0,0,0,0,0,0,0,0,0,
 0,0,0,0,0,0,0,0,0,1,2,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0],
[0,0,1,0,0,0,0,0,2,0,0,0,0,2,0,4,4,0,0,0,0,0,0,0,0,0,0,
 0,0,0,0,0,0,0,0,2,0,4,4,0,0,0,0,2,0,0,0,0,1,0,0,0,0,0],
[0,2,0,0,0,0,0,0,3,0,0,0,1,0,0,4,4,2,0,0,0,0,0,0,0,0,0,
 0,0,0,0,0,0,0,1,0,0,4,4,2,0,0,0,3,0,0,0,0,1,1,0,0,0,0],
[0,2,0,0,0,0,0,0,4,1,0,0,2,3,3,4,4,3,0,0,0,0,0,0,0,0,0,
 0,0,0,0,0,0,0,2,3,3,4,4,3,0,0,0,4,1,0,0,0,0,1,1,0,0,0],
[1,1,0,0,0,0,0,2,1,2,0,0,1,4,4,4,4,1,0,0,0,0,0,0,0,0,0,
 0,0,0,0,0,0,0,1,4,4,4,4,1,0,0,2,1,2,0,0,0,0,0,1,0,0,0],
[2,0,0,0,0,0,2,1,0,1,2,0,0,1,3,3,1,0,0,0,3,1,0,0,1,3,3,
 1,0,0,1,3,0,0,0,1,3,3,1,0,0,2,1,0,1,2,0,0,0,0,0,1,0,0],
[2,0,0,0,0,1,1,0,0,0,1,1,0,0,0,0,0,0,0,0,1,3,4,4,3,1,1,
 3,4,4,3,1,0,0,0,0,0,0,0,0,1,1,0,0,0,1,1,0,0,0,0,0,1,0]]

def get_calendar(username, base_url='https://github.com/'):
    """retrieves the github commit calendar data for a username"""
    base_url = base_url + 'users/' + username
    try:        
        url = base_url + '/contributions'
        page = urllib.request.urlopen(url)
    except (urllib.error.HTTPError,urllib.error.URLError) as e:
        print ("There was a problem fetching data from {0}".format(url))
        print (e)
        raise SystemExit
    return page.readlines()

def max_commits(input):
    """finds the highest number of commits in one day"""
    output = set()
    for line in input:
        for day in line.decode('utf-8').split():
            if "data-count=" in day:
                commit = day.split('=')[1]
                commit = commit.strip('"')
                output.add(int(commit))
    output = list(output)
    output.sort()
    output.reverse()
    return output[0]

def multiplier(max_commits):
    """calculates a multiplier to scale github colors to commit history"""
    m = max_commits/4.0
    if m == 0: return 1
    m = math.ceil(m)
    m = int(m)
    return m

def get_start_date():
    """returns a datetime object for the first sunday after one year ago today
    at 12:00 noon"""
    d = datetime.datetime.today()
    date = datetime.datetime(d.year-1, d.month, d.day, 12)
    weekday = datetime.datetime.weekday(date)
    while weekday < 6:
        date = date + datetime.timedelta(1)
        weekday = datetime.datetime.weekday(date)
    return date

def date_gen(start_date, offset=0):
    """generator that returns the next date, requires a datetime object as
    input. The offset is in weeks"""
    start = offset * 7
    for i in itertools.count(start):
        yield start_date + datetime.timedelta(i)

def values_in_date_order(image, multiplier=1):
    height = 7
    width = len(image[0])
    for w in range(width):
        for h in range(height):
            yield image[h][w]*multiplier

def commit(content, commitdate):
    template = ("""echo {0} >> kyubey\n"""
    """GIT_AUTHOR_DATE={1} GIT_COMMITTER_DATE={2} """
    """git commit -a -m "kyubey" > /dev/null\n""")
    return template.format(content, commitdate.isoformat(), 
            commitdate.isoformat())

def fake_it(image, start_date, username, repo, token, offset=0, multiplier=1,
            git_url='git@github.com'):
    template = (
        '#!/bin/bash\n'
        'DIR=$(mktemp -d)\n'
        'cd $DIR\n'
        'REPO={0}\n'
        'git init\n'
        'curl -X DELETE -H \'Authorization: token {5}\''
        ' https://api.github.com/repos/eqyiel/kyubey\n'
        'curl -H \'Authorization: token {5}\''
        ' https://api.github.com/user/repos -d \'{4}\'\n'
        'touch kyubey\n'
        'git add kyubey\n'
        '{1}\n'
        'git reflog expire --expire=now --all\n'
        'git gc --prune=now\n'
        'git remote add origin {2}:{3}/$REPO.git\n'
        'git push --force -u origin master\n'
        'cd ../\n'
        'rm -rf $DIR\n'
    )
    strings = []
    for value, date in zip(values_in_date_order(image, multiplier),
            date_gen(start_date, offset)):
        for i in range(value):
            strings.append(commit(i, date))
    return template.format(repo, "".join(strings), git_url, username,
                           json.dumps({'name':'kyubey',
                                       'description':'／人◕ ‿‿ ◕人＼'}), token)

def main():
    username = "eqyiel"
    git_base = "https://github.com/"
    cal = get_calendar(username)
    token = os.popen("pass oauth/kyubey").read().split('\n')[0]
    output = fake_it(KYUBEY, get_start_date(), username, "kyubey",
                     token, 0, multiplier(max_commits(get_calendar(username))))
    dest = (os.getenv("XDG_CACHE_HOME") or (os.getenv("HOME") + "/.cache")) + "/gitfiti"
    if not os.path.exists(dest):
        os.mkdir(dest)
    dest += "/gitfiti.sh"
    fd = os.fdopen(os.open(dest, os.O_WRONLY | os.O_CREAT, 0o600), 'w')
    fd.write(output)
    st = os.stat(dest)
    os.chmod(dest, st.st_mode | 0o111)
    fd.close()
    os.system(dest)

if __name__ == '__main__':
    main()
