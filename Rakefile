#! /usr/bin/ruby # <-- this causes the editor to color the syntax
#
# Journey to Ramaze is the official Ramaze documentation and is written in
# O'Reilly Media, Inc. style AsciiDoc format. This Rakefile builds the final
# document formats from the AsciiDoc inputs (texts, images, and icons).
#
# authors: Michael J. Welch, Ph.D. <mjwelchphd@gmail.com>
#   & Michael Fellinger <m.fellinger@gmail.com>
#
# This Rakefile requires the following packages be installed:
#   asciidoc, sass, and calibre
#
# This Rakefile requires the following Gems to be installed:
#   ramaze, innate, rack, rake, rcodetools

require 'rake/clean'

task :default => 'build:html'

RUBY     = ENV['RUBY']
clean = clobber = []

ASCIIDOCS = ['stylesheets/asciidoc.css', 'javascripts/asciidoc.js']
clean += ASCIIDOCS

ASCDOC_CSS = 'stylesheets/asciidoc.css'
file ASCDOC_CSS do
  sh("cp", "/etc/asciidoc/stylesheets/asciidoc.css", "stylesheets/asciidoc.css")
end

ASCDOC_JS = 'javascripts/asciidoc.js'
file ASCDOC_JS do
  sh("cp", "/etc/asciidoc/javascripts/asciidoc.js", "javascripts/asciidoc.js")
end

rule('.xmp' => ['.rb']) do |t|
  xmp_invocation = "xmpfilter --annotations -r ramaze #{t.source}"
  puts xmp_invocation
  original_source = File.read(t.source).strip
  xmp_source = `#{xmp_invocation}`.strip
  fail("XMP failed for #{t.source}") if xmp_source == original_source
  File.open(t.name, 'w'){|xmp| xmp.write(xmp_source) }
end

CHAPTER_FILES = Dir['chapter/*.txt']

XMP_FILES = []
CHAPTER_FILES.each do |chapter_file|
  File.open(chapter_file){|cf| cf.grep(/^include::.*\.xmp/) }.each do |line|
    XMP_FILES <<  'chapter/' + line[/^include::(.*\.xmp)/, 1]
  end
end
desc "Make Journey to Ramaze XMP files only (for testing)"
task :"xmp-only" => XMP_FILES

rule '.css' => '.sass' do |t|
  sh 'sass', '--style', 'compressed', t.source, t.name
end

CSS_FILES = Dir['stylesheets/*.sass'].collect { |f| f.ext('css') }
clean += XMP_FILES + CSS_FILES

def a2x(format,source)
puts "call: a2x #{format} #{source}"
  opts = ["a2x",
    "--asciidoc-opts=--conf-file=custom.conf",
    "--asciidoc-opts=--section-numbers",
    "--asciidoc-opts=--verbose",
    "--doctype=book",
    "--format=#{format}",
    "--icons",
    "--no-xmllint",
    "--verbose"]
  opts << "--fop" if format=="pdf"
  opts << source
  sh(*opts)
end

JTR_TXT  = "journey_to_ramaze.txt"
JTR_XML  = "journey_to_ramaze.xml"
JTR_EPUB = 'journey_to_ramaze.epub'
JTR_MOBI = 'journey_to_ramaze.mobi'

file JTR_XML => [ASCDOC_CSS, ASCDOC_JS, *XMP_FILES, *CSS_FILES, *CHAPTER_FILES, JTR_TXT] do
  a2x("docbook",JTR_TXT)
end
clean += [JTR_XML, 'docbook-xsl.css']

namespace :build do
  formats = {
  # name           format      temp file(s)   output(s)
    :chunked =>  [ "chunked",  [],            ["chunked"]   ],
    :epub =>     [ "epub",     ["epub.d"],    ["epub"]      ],
    :html =>     [ "xhtml",    [],            ["html"]      ],
    :htmlhelp => [ "htmlhelp", [],            ["htmlhelp"]  ],
    :manpage =>  [ "manpage",  [],            ["hhc","hhp"] ],
    :pdf =>      [ "pdf",      ["fo"],        ["pdf"]       ],
    :tex =>      [ "tex",      [],            ["tex"]       ],
    :text =>     [ "text",     ["text.html"], ["text"]      ]
  }

  formats.each do |key,values|
    format, clean_list, clobber_list = values
    target = "journey_to_ramaze.#{key}"
    file target => JTR_XML do
      a2x(format, JTR_XML)
    end
    desc "Make Journey to Ramaze in #{format} format"
    task key.to_s => target
    clean_list.each { |ext| clean << "journey_to_ramaze.#{ext}" }
    clobber_list.each { |ext| clobber << "journey_to_ramaze.#{ext}" }
  end

  file JTR_MOBI => JTR_EPUB do |t|
    sh 'ebook-convert', t.source, t.name, '--mobi-keep-original-images',
      '--mobi-file-type=new', '--base-font-size=12', '--smarten-punctuation'
  end
  desc "Make Journey to Ramaze in mobi format"
  task :mobi => JTR_MOBI
  clobber << JTR_MOBI

  CLEAN.include(Dir[*clean])
  CLOBBER.include(Dir[*clobber])
end
