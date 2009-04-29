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

HTML and PDF versions are available at
[book.ramaze.net](http://book.ramaze.net)

## Writing Style

I'm trying to keep the book more or less formal, as I don't have enough time to
write too much, so every topic will be handled in a short and concise way.

The AsciiDoc should follow a readable format:

* Keep lines within 80 characters.
* Don't use text formatting where it is not necessary.
* Use tables sparingly, only for strictly tabular data.
* Use the same style guidelines as the Ramaze source for code.
* Utilize XMP to show return values in code, this ensures it is actually
  working and unifies the style as well.
* Keep the length of return values in code short, XMP doesn't wrap lines.
* Links should be referenced from the attribute entry definitions in
  /chapter/attributes.txt if possible.
* Don't put a header over everything.
  Headers disturb the text flow and introduce too much whitespace, try to find
  the appropriate header for things first.
* Reuse header names between chapters, but don't use the same header in the same
  chapter too often.
* Use proper terminology, we need to stick with one name for one thing.
  Sometimes you might feel the need to coin a new term, make sure you research
  the concepts behind it first, you will often find it used prior in other
  projects, that gives us also more historical things to write about.
  If you introduce a new term, make sure you reference it in the glossary so we
  can keep track of them.

### Formatting conventions

For files or directories, use 'helper/smiley_helper.rb'.
For methods, classes, modules, or similar, use `FooController`.
For tiny code snippets use `helper :foo`.
If the code is more than fits comfortably inline (3-4 tokens), or is longer than
one line, put it into a separate code block, show output if possible, switching
between reading a book and trying stuff in IRB is not comfortable.

## Todo

There is still a lot of work to be done, the subject is in dire need of proper
documentation and there are a lot of topics to be covered.
Since I'm a native German speaker and learned English mostly over the interwebs,
my English skills are somewhat mediocre as well, so I appreciate any
improvements, be it grammar, spelling, or wording.

Since this is a technical topic, I try to use US English, please keep this in
mind. If you find writing the Queen's English more comfortable I won't be
opposed to it, but we will have to edit every couple of months.

If you would like to contribute with your own writing, please keep in sync with
the Github repository.
It helps if you notify me when you plan on spending some time on a particular
topic, so I don't touch it (to avoid spending too much time on merging the
changes).

I will not keep a formal todo-list just yet, the gaps are still obvious and
wide.
I will concentrate on core topics for the near future:

* Controllers
* Views
* Layouts
* Actions
* Sessions
* Introductory Tutorial
* Configuration
* Helpers
* Templating engines


## Building

This book is written in AsciiDoc format, this allows for a number of target
formats.
The Rakefile contains instructions to build following formats:

* Asciidoc XHTML (preferred, asciidoc -> docbook -> xhtml looks ugly)
* Chunked HTML
* DVI
* HTMLhelp
* Manpage
* PDF
* PS
* TeX
* Text
* XHTML

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
