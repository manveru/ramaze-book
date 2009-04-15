encoded = Ramaze::Helper::CGI.url_encode('Innate & Ramaze')
encoded # =>

decoded = Ramaze::Helper::CGI.url_decode(encoded)
decoded # =>
