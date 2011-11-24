#! /usr/bin/env python
# -*- coding: utf-8 -*-

import re
import urllib2
import yaml

prog = re.compile('.*(mms://[^&"]*).*')

def fetchMMS(id):
    url = 'http://hichannel.hinet.net/player/radio/mediaplay.jsp?radio_id=%d' % id
    opener = urllib2.build_opener()
    opener.addheaders = [('User-agent', 'Windows Media Player')]
    page = opener.open(url)
    while 1:
        line = page.readline()
        if line:
            result = prog.match(line)
            if result:
                return result.group(1)
        else:
            break

def genYAML(data):
    if 'category' in data:
        if 'title' in data: print 'title: ' + data['title'].encode('utf-8')
        if 'url' in data: print 'url: ' + data['url']
        print 'category:'
        for category in data['category']:
            print '- category: ' + category['title'].encode('utf-8')
            print '  channel:'
            for channel in category['channel']:
                print "  - title: %s" % channel['title'].encode('utf-8')
                print "    id: %d" % channel['id']
                if 'url' in channel:
                    print "    url: %s" % channel['url']
                else:
                    print "    url: %s" % fetchMMS(channel['id'])

def genJSON(data):
    if 'category' in data:
        print '({'
        if 'title' in data: print '\t"title": "%s",' % (data['title'].encode('utf-8'))
        if 'url' in data: print '\t"url": "%s",' % (data['url'])
        print '\t"category": ['
        for category in data['category']:
            print '\t\t{'
            print '\t\t\t"title": "%s",' % (category['title'].encode('utf-8'))
            print '\t\t\t"channel": ['
            for channel in category['channel']:
                print '\t\t\t\t{'
                print '\t\t\t\t\t"title": "%s",' % (channel['title'].encode('utf-8'))
                print '\t\t\t\t\t"id": "%d",' % (channel['id'])
                if 'url' in channel:
                    print '\t\t\t\t\t"url": "%s"' % (channel['url'])
                else:
                    print '\t\t\t\t\t"url": "%s"' % (fetchMMS(channel['id']))
                print '\t\t\t\t},'
            print '\t\t\t]'
            print '\t\t},'
        print '\t]'
        print '})'

def main():
    file = open('hichannel.yaml')
    data = yaml.load(file)
    file.close()
    genJSON(data)

if __name__ == '__main__':
    main()
