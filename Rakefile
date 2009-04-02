require 'rake/clean'
require 'fileutils'

task :default => 'build:xhtml'

JTR_TXT = "journey_to_ramaze.txt"
JTR_XML = "journey_to_ramaze.xml"
SOURCE_FILES = Dir['chapter/*.txt']

formats = %w[chunked htmlhelp manpage pdf text xhtml dvi ps tex]

CLOBBER.include(JTR_XML, *formats)

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
  jtr_dir = format.dup
  jtr_base = "journey_to_ramaze.#{format}"
  jtr_path = File.join(jtr_dir, jtr_base)

  desc "Build #{jtr_path}"
  task "build:#{format}" => jtr_path

  file jtr_path => [jtr_dir, JTR_XML] do
    opts = OPTS + [
      "--destination-dir=#{jtr_dir}",
      "--format=#{format}",
      "-s",
      JTR_XML,
    ]

    sh("a2x", *opts)

    case format
    when 'pdf' # doesn't heed --destination-dir
      FileUtils.mv(jtr_base, jtr_path)
    end
  end

  file(jtr_dir){ FileUtils.mkdir(jtr_dir) }
end
