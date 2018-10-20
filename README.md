# RSSPodder

RSSPodder is a simple bash command-line tool based on concept of other similar
tools like [bashpodder](http://lincgeek.org/bashpodder) and
[CatchPodder](https://github.com/tjadowski/catchpodder.git). It downloads new or
incompleted web sites from RSS/Atom feeds.

RSSPodder need xsltproc package and some standard Unix command-line tools like
wget and md5sum for example (see source).

CODE:

- [https://github.com/tjadowski/rsspodder.git](https://github.com/tjadowski/rsspodder.git)

CONTRIBUTING

Patches are welcome. Please use patch command and send it (them) to [jadowski@protonmail.com](mailto:jadowski@protonmail.com).

ISSUES:

- please update BUGS and TODO section of this README

TODO:

1. [ ] - RSSPodd#01: export OPML file
2. [ ] - RSSPodd#02: add parallel support for sync and download options
3. [ ] - RSSPodd#03: add debug and override wget parameters options
4. [ ] - RSSPodd#04: more detailed and strict verbose parameters
5. [ ] - RSSPodd#05: save sites with all assets, not only html text
6. [ ] - RSSPodd#06: port to NetBSD

BUGS:

1. [x] - RSSPodd#07: some sites are saved in gziped form
2. [ ] - RSSPodd#08: software doesn't detect other MIME from text/html
3. [ ] - RSSPodd#09: unnecessary retry of 403 HTTP status

CHANGELOG:

- 03/31/2018 - Imported old repo, changed links and contact details
- 20/10/2018 - Fixed RSSPodd#07
 
LICENSE:

 Copying and distribution of this file, with or without modification,
 are permitted in any medium without royalty provided the copyright
 notice and this notice are preserved.  This file is offered as-is,
 without any warranty.
