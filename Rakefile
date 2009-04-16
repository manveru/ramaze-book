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

CLOBBER.include('chapter/source/**/*.xmp', JTR_XML)

OPTS = [
  "--asciidoc-opts=--conf-file=custom.conf",
  "--asciidoc-opts=--verbose",
  "--doctype=book",
  '--copy',
  '--icons',
  '--verbose',
]

file JTR_XML => [JTR_TXT, *CHAPTER_FILES] do
  sh('asciidoc', '-v', '-b', 'docbook', '-d', 'book', '-f', 'custom.conf', JTR_TXT)
end

namespace :build do
  # the formats going over docbook format
  formats.each do |format|
    jtr_dir = "#{format}/"
    jtr_base = "journey_to_ramaze.#{format}"
    jtr_path = File.join(jtr_dir, jtr_base)
    CLOBBER.include(jtr_dir)

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

  # the asciidoc-xhtml

  jtr_scripts = File.expand_path('javascripts')
  jtr_styles  = File.expand_path('stylesheets')
  jtr_css = 'stylesheets/xhtml11.css'
  jtr_dir = 'asciidoc-xhtml/'
  jtr_base = 'journey_to_ramaze.html'
  jtr_path = File.join(jtr_dir, jtr_base)

  jtr_depends = [jtr_dir, JTR_TXT, jtr_css] + CHAPTER_FILES + XMP_FILES

  CLOBBER.include(jtr_dir, File.join(jtr_styles, '**/*.css'))

  file(jtr_dir){ mkdir(jtr_dir) }
  file jtr_path => jtr_depends do
    sh('asciidoc',
       '--attribute', "scriptsdir=#{jtr_scripts}",
       '--attribute', "stylesdir=#{jtr_styles}",
       '--attribute', 'toc',
       '--backend', 'xhtml11',
       '--doctype', 'book',
       '--out-file', jtr_path,
       '--section-numbers',
       '--unsafe',
       '--verbose',
       JTR_TXT)
  end

  desc 'Build prettier HTML directly with asciidoc'
  task 'asciidoc-xhtml' => jtr_path
end

namespace :xmp do
  xmp_invocation = [
    RUBY,
    'xmpfilter.rb',
    '--annotations',
    '-r', 'ramaze',
    '--interpreter', RUBY
  ]

  rule('.xmp' => ['.rb']) do |t|
    source_file = t.source
    xmp_file = t.name

    invocation = (xmp_invocation + [source_file]).join(' ')

    puts "Converting #{source_file} to xmp => #{xmp_file}"
    puts invocation
    original_source = File.read(source_file).strip
    xmp_source = `#{invocation}`.strip

    fail("XMP failed for #{source_file}") if xmp_source == original_source

    File.open(xmp_file, 'w+'){|xmp| xmp.write(xmp_source) }
  end

  CHAPTER_FILES.each do |chapter_file|
    File.open(chapter_file){|cf| cf.grep(/^include::.*\.xmp/) }.each do |line|
      xmp = 'chapter/' + line[/^include::(.*\.xmp)/, 1]
      rb = xmp.sub(/\.xmp$/, '.rb')
      file(chapter_file => xmp)
    end
  end
end

rule('.css' => ['.sass']) do |t|
  sh('sass',
     '--style', 'compressed', # nested, compact, compressed, expaned
     t.source,
     t.name)
end
