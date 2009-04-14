class Example < Ramaze::Controller
end

Ramaze.start(:started => true)

Ramaze.options.roots # =>
Ramaze.options.views # =>
Example.mapping # =>
Example.view_mappings # =>

Example.possible_paths_for(Example.view_mappings) # =>
