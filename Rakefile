require 'rake/clean'
require 'fileutils'

task :default => 'build:xhtml'

JTR_TXT = "journey_to_ramaze.txt"
JTR_XML = "journey_to_ramaze.xml"
SOURCE_FILES = Dir['chapter/*.txt']
formats = %w[chunked htmlhelp manpage pdf text xhtml dvi ps tex]

OPTS = [
  "--asciidoc-opts=--conf-file=custom.conf",
  "--asciidoc-opts=--verbose",
  "--doctype=book",
  '--icons',
  '--copy',
  '--verbose',
]

file JTR_XML => [JTR_TXT, *SOURCE_FILES] do
  sh('asciidoc', '-v', '-b', 'docbook', '-d', 'book', '-f', 'custom.conf', JTR_TXT)
end

formats.each do |format|
  dest = format.dup
  jtr_file = "#{dest}/journey_to_ramaze.#{format}"

  desc "Build #{jtr_file}"
  task "build:#{format}" => jtr_file

  file jtr_file => [dest, JTR_XML] do
    opts = OPTS + [
      "--destination-dir=#{dest}",
      "--format=#{format}",
      "-s",
      JTR_XML,
    ]

    sh("a2x", *opts)
  end

  file(dest){ FileUtils.mkdir(dest) }
  CLOBBER.include(dest)
end

CLOBBER.include('journey_to_ramaze.xml')
