require 'rake/clean'
require 'fileutils'
require 'open3'

task :default => 'build:asciidoc-xhtml'

JTR_TXT  = "journey_to_ramaze.txt"
JTR_XML  = "journey_to_ramaze.xml"
CHAPTER_FILES = Dir['chapter/*.txt']
SOURCE_FILES = FileList['chapter/source/**/*.rb']
XMP_FILES = FileList['chapter/source/**/*.xmp']

formats = %w[chunked htmlhelp manpage pdf text xhtml dvi ps tex]

CLOBBER.include(JTR_XML, formats + XMP_FILES)

OPTS = [
  "--asciidoc-opts=--conf-file=custom.conf",
  "--asciidoc-opts=--verbose",
  "--doctype=book",
  '--icons',
  '--copy',
  '--verbose',
]

file JTR_XML => [JTR_TXT, *CHAPTER_FILES] do
  sh('asciidoc', '-v', '-b', 'docbook', '-d', 'book', '-f', 'custom.conf', JTR_TXT)
end

namespace :build do
  formats.each do |format|
    jtr_dir = "#{format}/"
    jtr_base = "journey_to_ramaze.#{format}"
    jtr_path = File.join(jtr_dir, jtr_base)

    desc "Build #{jtr_path}"
    task format => jtr_path

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

    file(jtr_dir){ mkdir(jtr_dir) }
  end

  jtr_dir = 'asciidoc-xhtml/'
  jtr_base = 'journey_to_ramaze.html'
  jtr_path = File.join(jtr_dir, jtr_base)
  CLOBBER.include(jtr_dir)

  file(jtr_dir){ mkdir(jtr_dir) }
  file jtr_path => [jtr_dir, JTR_TXT, *CHAPTER_FILES] do
    sh('asciidoc',
       '--verbose',
       '--section-numbers',
       '--attribute', 'toc',
       '--backend', 'xhtml11',
       '--doctype', 'book',
       '--out-file', jtr_path,
       JTR_TXT)
  end

  desc 'Build prettier HTML directly with asciidoc'
  task 'asciidoc-xhtml' => jtr_path
end

namespace :xmp do
  xmp_invocation = [RUBY, 'xmpfilter.rb', '--annotations', '--interpreter', RUBY]

  SOURCE_FILES.each do |source_file|
    xmp_file = source_file.sub(/\.rb$/, '.xmp')

    file xmp_file => [source_file] do
      invocation = (xmp_invocation + [source_file]).join(' ')

      puts "Converting #{source_file} to xmp => #{xmp_file}"
      puts invocation
      original_source = File.read(source_file).strip
      xmp_source = `#{invocation}`.strip

      fail("XMP failed for #{source_file}") if xmp_source == original_source

      File.open(xmp_file, 'w+'){|xmp| xmp.write(xmp_source) }
    end
  end

  CHAPTER_FILES.each do |chapter_file|
    File.open(chapter_file){|cf| cf.grep(/^include::.*\.xmp/) }.each do |line|
      xmp = 'chapter/' + line[/^include::(.*\.xmp)/, 1]
      rb = xmp.sub(/\.xmp$/, '.rb')
      file(chapter_file => xmp)
    end
  end
end
