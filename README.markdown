# Ramaze, the book

The offical book for the [Ramaze web application framework](http://ramaze.net).

## General information

A work in progress to create a compilation of:

* frequently asked questions
* meta-information
* best practices
* in-depth discussions
* anything else...

This is a community effort, initiated by Michael 'manveru' Fellinger, Ramaze
developer and passionate Rubyist.

The source is kept in a git repository at
[github](http://github.com/manveru/ramaze-book)

## Building

This book is written in AsciiDoc format, this allows for a number of target
formats.
The Rakefile contains instructions to build following formats:

* chunked html
* dvi
* htmlhelp
* manpage
* pdf
* ps
* tex
* text
* xhtml

If you invoke `rake`, the default being built is xhtml, see `rake -T` for a
list of all possible tasks.

See below for instructions on how to install the required dependencies on
different distributions.

To get proper syntax highlighting you will need to install
[GNU source-highlight](http://www.gnu.org/software/src-highlite/).
This usually is available in repositories.

You will also need the DocBook XML scheme 4.5 and DocBook XML stylesheets
installed.

The dblatex package is required for generation of pdf, tex, ps, and dvi.

### Installation of dependencies
#### ArchLinux

    pacman -S asciidoc dblatex source-highlight
