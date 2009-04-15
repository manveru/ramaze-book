name = Ramaze::Helper::CGI.url_encode('Innate & Ramaze')
name # =>
uri = URI("http://google.com/search?q=#{name}")
uri # =>
uri.to_s # =>
