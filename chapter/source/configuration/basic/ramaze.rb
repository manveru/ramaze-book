options = Ramaze.options

options.get(:cache) # =>
options.get(:layouts) # =>
options.get(:middleware_compiler) # =>
options.get(:prefix) # =>
options.get(:publics) # =>
options.get(:roots) # =>
options.get(:started) # =>
options.get(:trap) # =>
options.get(:views) # =>

setup = options.get(:setup)
setup[:doc] # =>
setup[:value] # =>

mode = options.get(:mode)
mode[:doc] # =>
mode[:value] # =>
