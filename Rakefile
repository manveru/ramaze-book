require 'rake'

desc 'build all'
task 'build' => ['build:css', 'build:markdown'] do
end

namespace :build do
  desc 'build markdown'
  task :markdown do
    sh 'maruku', 'ramaze.markdown'
  end

  desc 'build css'
  task :css do
    require 'sass'

    Dir['public/css/*.sass'].each do |sass|
      sass = File.expand_path(sass)
      out = File.join(
        File.dirname(sass),
        File.basename(sass, File.extname(sass)) + '.css'
      )

      sass = Sass::Engine.new(File.read(sass))

      File.open(out, 'w+') do |css|
        css.write sass.render
      end
    end
  end
end
