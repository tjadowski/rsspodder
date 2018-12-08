#!/bin/bash
# copyright by tomasz jadowski (jadowski at @protonmail dot com) # 2016-2018
# see README.md
# Thanks for patches for:
# - Milosz Galazka (https://sleeplessbeastie.eu)
#--------
# LICENSE
#--------------------------------------------------------------------
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.
#---------------------------------------------------------------------

datadir=$(pwd)
metadir=$datadir/.rsspodder
siteslog=$metadir/sites.log
program="RSSPodder (https://github.com/tjadowski/rsspodder.git)"

if command -v md5sum &>/dev/null; then
    md5program=md5sum
elif command -v md5 &>/dev/null;then
    md5program=md5
else
    echo "I can't detect a program for MD5 hash calculation!"
    exit 1
fi

function verify_environment {
    if ! command -v xsltproc &>/dev/null; then
        echo "Please install xsltproc package"
        echo "Debian/Ubuntu: sudo apt-get install xsltproc"
        echo "RHEL/CentOS: sudo yum install libxslt"
        exit 1
    fi
}

function main {
    verify_environment
    case $1 in
        "download")
            download new.log $2
            cleanup new.log
            ;;
        "sync")
            sync $2
            ;;
        "init")
            init $2
            ;;
        "import")
            import $2
            ;;
        "archive")
            archive
            ;;
        "help" | "usage" | *)
            usage;;
    esac
}

function cleanup {
    log=$1

    echo "Clean up ..."
    # Move dynamically created log file to permanent log file:
    cat $metadir/$log > temp.log
    cat $siteslog >> temp.log
    sort temp.log | uniq > $siteslog
    rm temp.log
    find $metadir -name '*.html' -size 0 -exec rm {} \;
}

function usage {
    echo $program
    echo
    echo "Usage: $0 init | sync | download | help"
    echo "                                                "
    echo "     init <url> - init with site RSS feed"
    echo "     import <file> - import opml file with RSS feeds"
    echo "     sync - sync all sites RSS feeds"
    echo "     download - download new or incomplete web sites"
    echo "     archive - archive old (downloaded) web sites"
    echo "                                                "
}
function downloader {
    url=$1
    output=$2
    cert=$3

    gzipped=`curl -H "Accept-Encoding: gzip" --silent --head --url $url -A "$program" | grep "Content-Encoding: gzip" | wc -c`
    if [ $gzipped == '24' ]; then
      echo "Site is gzipped: $url"
      curl -L -H "Accept-Encoding: gzip" --silent --url $url --connect-timeout 15 --retry 10 --retry-delay 2 -A "$program" -o temp.gz
      gunzip temp.gz
      mv temp $output
    else
      curl -L --silent --url $url --connect-timeout 15 --retry 10 --retry-delay 2 -A "$program" -o $output
    fi
}

function get_urls {
    grep -v \# $metadir/urls
}

function get_sitedir {
    url=$1

    sitedir=$(echo "$url" | awk -F'/' {'print $3'})
    host=$(echo "$sitedir" | awk -F'.' {'print $2'})
    if [ $host == 'feedburner' ]; then
        sitedir=$(echo "$url" | awk -F'/' {'print $4'})
    fi
    if [ $host == 'feedblitz' ]; then
        sitedir=$(echo "$url" | awk -F'/' {'print $4'})
    fi
    if [ $host == 'infoq' ]; then
        sitedir='InfoQ-'$(echo "$url" | awk -F'/' {'print $5'})
    fi
    if [ $sitedir == 'medium.com' ]; then
        sitedir='Medium-'$(echo "$url" | awk -F'/' {'print $5'})
    fi
    if [ $sitedir == 'feedpress.me' ]; then
        sitedir=$(echo "$url" | awk -F'/' {'print $4'})
    fi
    if [ $sitedir == 'planet.mozilla.org' ]; then
        sitedir=$(echo "$url" | awk -F'/' {'print $4'})
    fi
    if [ $sitedir == 'feeds.mekk.waw.pl' ]; then
        sitedir=$(echo "$url" | awk -F'/' {'print $4'})
    fi
    if [ $sitedir == 'www.fsf.org' ]; then
        sitedir='FSF-'$(echo "$url" | awk -F'/' {'print $7'})
    fi
    if [ $host == 'redhat' ]; then
        sitedir='RedHat-'$(echo "$url" | awk -F'/' {'print $5'})
    fi

    echo $sitedir
}

function init {
    url=$1

    sitedir=$metadir/$(get_sitedir $url)

    if [ -d $sitedir ]; then
        rm -rf $sitedir
    fi
    mkdir -p $sitedir
    touch $sitedir/feed

    echo "$url" >> $metadir/urls
}

function import {

    urls=$(xsltproc parse_opml.xsl $1 2> /dev/null)
    for url in $urls
        do
            echo "Added $url to RSS feed file"
            init $url
        done
}


function sync {
    urls=$(get_urls)
    log=$metadir/deleted_feed.log
    cert=$1

    if [ -f $log ]; then
        rm -f $log
    fi

    for url in $urls
        do
            sitedir=$metadir/$(get_sitedir $url)
            feed=$sitedir/feed
            if [ -f $feed ]; then
                echo "$(date +%s) Start syncing feed from $url"
                downloader $url $feed $cert
            else
                echo $url >> $log
            fi
        done
}

function archive {
    urls=$(get_urls)

    for url in $urls
        do
            sitedir=$metadir/$(get_sitedir $url)
            archivedir=$datadir/$(get_sitedir $url)
            if [ -d $sitedir ]; then
                if test x"`find $sitedir -name '*.html'`" != x ; then
                    echo "Start archive into $archivedir"
                    mkdir -p $archivedir
                    mv $sitedir/*.html $archivedir
                fi
            fi
        done
}

function download {
    logfile=$metadir/$1
    cert=$2

    touch $siteslog

    # Delete any temp file:
    if [ -f $logfile ]; then
        rm -f $logfile
    fi
    touch $logfile

    cd $(dirname $0)
    urls=$(get_urls)
    for site in $urls
        do
            sitedir=$metadir/$(get_sitedir $site)
            feed=$sitedir/feed
            if [ -f $feed ]; then
                # Read the feed
                echo "Read data from $feed"
                rss=$(xsltproc parse_rss.xsl $feed 2> /dev/null)
                atom=$(xsltproc parse_atom.xsl $feed 2> /dev/null)
                for url in $rss$atom
                    do
                        filename=$(echo "$url" | $md5program | awk {'print $1'})
                        if ! grep "$filename" $siteslog > /dev/null ; then
                            #Fix blog.golang.org rss
                            if [[ $url =~ ^// ]]; then
                                url=$(echo "$url" | cut -c 3-)
                            fi
                            if [[ $url =~ ^/ ]]; then
                                url=$(echo "$site" | awk -F '/' '{ print $1"//"$3}')$url
                            fi
                            echo "$(date +%s) Download site from $url"
                            output=$sitedir/$filename.html
                            downloader $url $output $cert
                            if [ -s $output ]; then
                                echo $filename >> $logfile
                            fi
                        fi
                    done
            fi
        done
}

main $@
