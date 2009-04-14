class Example < Ramaze::Controller
  map_layouts 'foo', 'bar'
end

Ramaze.start(:started => true)

Ramaze.options.roots # =>
Ramaze.options.layouts # =>
Example.mapping # =>
Example.layout_mappings # =>

Example.possible_paths_for(Example.layout_mappings) # =>
