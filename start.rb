require 'ramaze'
require 'maruku'
require 'rake'

class MainController < Ramaze::Controller
  helper :aspect

  before_all do
    sh 'rake', 'build:css'
  end

  def index(chapter = nil)
    chapter ||= :head
    @name = chapter.to_s.gsub(/\W+/, '-')
    @file = __DIR__/"chapter/#@name.mkd"
    @html = compile(@file).to_html_document
  end

  private

  def compile(file)
    content = [
      'section/header.mkd', 'section/links.mkd', file
    ].map{|f| File.read(f) }.join("\n\n")

    # puts content
    Maruku.new(content)
  end

  def section(name)
    File.read("section/#{name}.mkd".downcase)
  end

  def use(name)
    File.read("chapter/#{name}.mkd".downcase)
  end
end

Ramaze.start :adapter => :mongrel
