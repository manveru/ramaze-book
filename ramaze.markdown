CSS: ruby.css
LaTeX_use_listings: true
html_use_syntax: true
use_numbered_headers: true

# Ramaze

## Michael Fellinger

Ramaze is a simple but powerful web application development framework. This book is an in-depth walk-through of Ramaze's features and behaviour.

* This list will contain the toc (it doesn't matter what you write here)
{:toc}


# Introduction


## About Ramaze

Ramaze is a modular web application framework. It provides you with just about everything you need to make your daily web development simple and fun. Making programming fun is a concept popularized by the Ruby programming language.

Ramaze is written in Ruby. This document assumes at least basic knowledge about Ruby. If you do not know what Ruby is yet, visit [ruby] and find out; but beware, it may change your life.

[ruby]: http://ruby-lang.org "ruby-lang.org"

### Important Links

Naturally, since Ramaze is an open source web framework, most help can be found online (apart from reading the source code itself). So here are some links to provide more information on all the topics covered in this book.

[Ramaze] provides further documentation, screencasts, links and news.

[Ramaze google group] hosts the mailing list for discussion with the developers and users of the framework.

[ramaze]: http://ramaze.net (ramaze.net)
[Ramaze google group]: http://ramaze.googlegroups.com (ramaze.googlegroups.com)

## About the author

Michael Fellinger (a.k.a. manveru) is the creator and core developer of the Ramaze framework.

His programming language of choice is, as you might have guessed already, Ruby.

Michael has been living in Tokyo, Japan since 2006, but is Austrian by birth.


# Ramaze

As mentioned above, Ramaze is a web application framework. It features a readable open source codebase licensed under the Ruby license (optionally GPL version 2).

The strengths of Ramaze, as described by its users, are a free style of development, affording all the benefits of the underlying Ruby programming language. It gets out of your way as you do things, helping you along as you require it.

## Installation Prerequisites

* [ruby]
* [rubygems]
* [rack]
* [ramaze]

[rubygems]: http://rubygems.org "rubygems.org"
[rack]: http://rack.rubyforge.org "rack.rubyforge.org"

## Installing a specific version

Installing Ramaze should be very simple on most systems. Following are several installation methods.

### On Windows

(forthcoming)

### On OSX

(forthcoming)

### On Linux

Issue your package manager to install a package commonly called "rubygems"

### ArchLinux

    $ pacman -S rubygems

### Debian or Ubuntu

    $ apt-get install rubygems

### Gentoo

    $ emerge rubygems

Now that you have rubygems installed, I strongly recommend that you take the following steps to permit you to install gems in your own personal space in the filesystem (your home directory), as opposed to using root privileges to install gems. This will simplify further diving into the Ruby ecosystem.

Simply add following lines to your ~/.bashrc or ~/.zshrc:

    export RUBYOPT=-rubygems
    export GEM_HOME="$HOME/.gems"
    export GEM_PATH="$GEM_HOME"
    export PATH="$HOME/.gems/bin:$PATH"
{:lang=sh}

Once you have done that you can simply run

    gem install ramaze
{:lang=sh}

and Ramaze will be installed.

Manual Installation of Rubygems

### Download and install from http://rubygems.org

Visit [rubyforge rubygems] and download the latest version as a tgz file. 

[rubyforge rubygems]: http://rubyforge.org/frs/?group_id=126 "rubyforge.org"

## Installing the development version of Ramaze

Ramaze is developed in a git repository, so if you want to see and use the latest source code, you can simply get your own copy. Since all our commits are checked by the spec (test) suite before they get into the official repository, the repository version of Ramaze is generally safe for production use, and even recommended over the public releases since recent security and code flaws have been fixed.

Installing the gem is only recommended if you want to have a version of Ramaze that ,,just works'', or if you only have the ability to use Ramaze through the gem (a possibility on some system setups).

### Getting the development version without using git

You can download a tarball directly from github, the location of our Ramaze repository is at [github ramaze] and the tarball is located at [github ramaze tarball].

[github ramaze]: http://github.com/manveru/ramaze
[github ramaze tarball]: http://github.com/manveru/ramaze/tarball/master

### Getting git

Git is available on most Linux distributions and OSX. Visit [git] for download links and installation instructions. At the time of this writing, git is not officially supported on Windows, but unofficial binaries are available for download from the git website.

[git]: http://git.or.cz

### Getting the development version using git

Cloning the repository (getting your own copy) is really simple once you have installed git.

    $ git clone git://github.com/manveru/ramaze
{:lang=sh}

Setting up your environment after installation

Now that you have the latest version of Ramaze, you have to tell Ruby how to find it. One of the simplest ways is to add a file named ,,ramaze.rb'' to your `site_ruby` directory.

    $ echo 'export RUBYLIB="/path/to/ramaze/lib/:$RUBYLIB"' >> ~/.bashrc
{:lang=sh}

This way, everytime you say ,,require 'ramaze''' in your code, it will first require the ramaze.rb in the `site_ruby` directory, which in turn requires the ramaze.rb from your development version.

# Basic Usage

## Hello, World!

A short introductory example is always "Hello world". In Ramaze this looks like following.

    require 'rubgems'
    require 'ramaze'

    class MainController < Ramaze::Controller
      def index
        "Hello, World!"
      end
    end

    Ramaze.start
{:lang=ruby}

First we require rubygems, the package managing wrapper that allows us to require the ramaze library and framework. Next we define a Controller and method that will show up when accessing ,,http://localhost:7000/'', 7000 being the default port of Ramaze.

Configuration

Configuration is mainly done using the Ramaze::Global singleton. It's an instance of Option::Holder, containing a rather large list of options and their defaults. Every option is documented in minimal style and the defaults should make clear in most cases how to set these options.

Configuration can be done three different ways: using environment variables, command-line arguments, or directly in your source code.

Let's look at the three variations of how to set your port. First, in your source code:


    Ramaze::Global.port = 8080

    Ramaze::Global.setup do |g|
      g.port = 8080
    end

    Ramaze.start :port => 8080
{:lang=ruby}

now by commandline arguments:

    $ ruby start.rb --port 8080
{:lang=sh}

and finally using an environment variable:

    $ RAMAZE_PORT=8080 ruby start.rb
{:lang=sh}

Application with multiple files

The convention for larger applications consists of a basic directory structure. Using this structure is optional; you can specify different directories with special commands.


    /
      start.rb
      ramaze.ru
      public/
        favicon.ico
        robots.txt
      model/
        user.rb
      controller/
        main.rb
        user.rb
      view/
        index.xhtml
        user/
          index.xhtml
          view.xhtml
          new.xhtml

Although it is up to you to decide whether you want to follow this layout, it is recommended so that it's easier for other people to jump right into your code and understand things.

Some details about the directory conventions

There are two special cases you should be aware of before starting. /public and /view are defaults in Ramaze, set in `Ramaze::Global.public_root` and `Ramaze::Global.view_root` respectively. They are relative to Ramaze::Global.root.

To illustrate this, see following example:


    Ramaze::Global.root        # => '/home/manveru/demo'
    Ramaze::Global.view_root   # => '/home/manveru/demo/view'
    Ramaze::Global.public_root # => '/home/manveru/demo/public'
{:lang=ruby}

In practical terms this means that templates are found in the /view directory while static files are served from /public.

The rest of the conventions are not explicitly understood by Ramaze. This entails that, for example, in the file of your application which contains ,,Ramaze.start'' (typically a file called start.rb), you will have to manually require your other .rb files.



# Ramaze::Controller

## What, exactly, is a Controller anyway?

The first thing you will encounter when starting out with Ramaze is the Controller. This is because the Controller is the central structure in most web applications and for that reason you should know as much as possible about it.

To start out, let's take a look at the basic structure of a usual Controller with a hello world example.

    class MainControler < Ramaze::Controller
      def index
        'Hello, World!'
      end
    end
{:lang=ruby}

So we have a class MainController that inherits from Ramaze::Controller, I won't go into details yet what exactly this inheritance means, but it basically integrates your new class into your application.

What you see next is a method called index, containing a simple String.

To fully understand this snippet we will have to understand the concept of mapping in Ramaze. If you are familiar with other web frameworks, you will know about routing, and for those of you who don't, let me explain routing real quick, since it's the principle applied here as well.

So routing basically means, when you get a request from a client to `/user/songs`, the routing will see if you have defined any routes matching this path and executes whatever you specified as the result.

What Ramaze does with mapping is a little bit more sophisticated in order to lift work off the shoulders of the programmer and only make him do manual routing to refine the results of this automatic procedure.

So given a Controller named UserController, Ramaze will route to it with the path `/user`, UserNameController would be put at `/user_name` and so on. In this case we have picked the only exception, that is MainController and is mapped at `/` by default.

We will see in the next example how to change this default mapping, since defaults may be good, but nothing beats configurability when needed.

## Remapping

In order to change the default mapping, you can simply use the `Controller::map(path, [path2, ...])` method. This also allows you to map one Controller on multiple paths.


    class MainController < Ramaze::Controller
      map '/article'

      def index
        "Hello, World!"
      end
    end
{:lang=ruby}

This example simply shows how you can use the map method, but let's see a nicer way to do the same using the default mapping.


    class ArticleController < Ramaze::Controller
      def index
        "Hello, World!"
      end
    end
{:lang=ruby}

So instead of defining a Controller that is by default mapped to,,/'' and remapping to,,/article'', we can just name it ArticleController and Ramze will take the part of your classes name before,,Controller'' and convert it to a mapping by doing a simple snake case transformation.

Sticking to this kind of defaults makes your code a lot more readable, as people know which Controller will map to which URL without even checking first.

## Controller class methods

### Controller::startup

### Controller::map

### Controller::at

### Controller::layout

### Controller::template

### `Controller::check_path`

### Controller::engine

### Controller::current

### Controller::handle

### `Controller::relevant_ancestors`

### Controller::render



# Ramaze::Current



# Ramaze::Trinity



# Ramaze::Session

Sessions are an essential part of most dynamic web applications and so Ramaze makes it very simple to use them. We will see how to use the automated sessions, handle cookies manually and change the backend where session information is stored on the serverside.

## What are sessions

Although I said that they are essential, some people may not yet be familiar with sessions and what use cases exist for them, so let's take a look at a simple application using sessions first.


    require 'ramaze'

    class MainController < Ramaze::Controller
      HELLO = {
        'en' => "Hello, world!",
        'de' => "Hallo Welt!",
        'it' => "Ciao, mondo!",
      }

      def index
        language = HELLO.keys.sort_by{ rand }.first
        session[:language] = language
        redirect Rs(:greet)
      end

      def greet
        HELLO[session[:language]]
      end
    end
{:lang=ruby}


In this, we select a random language key that we then set in our session. The browser that hits the index action will from now on always have this language associated to it and you can see it in your controller and templates inside the session object.

Now a few details on how this works exactly.



On every request, as we mentioned in the chapter about Ramaze::Current already, a Session is initialized and put into `Ramaze::STATE[:session]`. This makes it possible to access the session during the whole request. The initialization will set a cookie in the current response, setting the key `_ramaze_session_id` with a unique value representing the key to the data stored on the server.

Cookies are basically a part of the response headers, a simple string that is being sent back and forth during the request/response cycle. Everytime a browser sends a request it will also send the cookie in the header with it, that way we can look up which data belongs to that browser.

In Ramaze this data is stored in a cache, at the time of writing the two most commonly used ones are MemcachedCache and MemoryCache.



Although they may sound similar, they are quite different concepts, MemoryCache equals a Ruby Hash, it doesn't put any restrains on the kind or amount of data stored, which can become problematic for larger applications. MemcachedCache on the other hand utilizes the MemCache library to communicate with an (usually) local memcache daemon that handles caching of key/value pairs in namespaces. It allows you to control the way caching happens very well, one commonly used option is to put a limit on the overall amount of data stored. However, old data is thrown away if your application tries to cache more data than allowed.

There is a third way which was contributed recently, to utilize the Sequel ORM and use a relational database for storage, which gives both control and persistence as old data is never thrown away unless explicitly ordered to do so.

# Configuration

A number of options lets you decide how to use sessions and their behaviour.

To disable them, simply assign:

    Ramaze::Global.sessions = false
{:lang=ruby}

This will give you some speedup and less data being transferred between server and client, it does not affect the ability to manually set cookies in the response.

To change the backend for the session cache only (as opposed to it for all caches in your Ramaze, we talk about that in the Ramaze::Cache section) do following:

    Ramaze::Global.cache_alternative[:sessions] = Ramaze::MemcachedCache
{:lang=ruby}

Please make sure you have the memcached server running before starting an application with this setting.



# Ramaze::Request

# Ramaze::Response

# Ramaze::Helper

Helpers are modules for inclusion into controllers or other classes.

## Using a helper


    class MainController < Ramaze::Controller
      helper :formatting

      def index
        number_format(rand)
      end
    end
{:lang=ruby}


## Rules for helpers

Methods are private.

How to create your own helper

Creating helpers is simple.


    module Ramaze
      module Helper
        module SimleyHelper
          FACES = {
            ':)' => '/smilies/smile.gif'
            ';)' => '/smilies/twink.gif'
          }
          REGEX = Regexp.union(*FACES.keys)

          def smile(string)
            string.gsub(REGEX){ FACES[$1] }
          end
        end
      end
    end
{:lang=ruby}


### Exposing methods to routing

By adding an helper module to the Ramaze::Helper::LOOKUP Set it's possible to add the module to the lookup for methods together with the Ramaze::Controller. Conflicts of method names in Helper and Controller will prefer the Controller, following the same rules as Ruby inheritance. 


    module Ramaze
      module Helper
        module Locale
          LOOKUP << self

          def locale(name)
            session[:LOCALE] = name
          end
        end
      end
    end
{:lang=ruby}


In this example we expose the public method Locale#locale (Ruby methods are public by default). So in your application your can just use the helper and when the client visits the /locale/en route the session will reflect this choice.

Please note that this code doesn't include a `redirect_referrer` call since we may be using it within our own codebase in the middle of a method.

---

# Ramaze::Action

Action is one of the core parts of Ramaze, a recipe for rendering combinations of controllers, methods and templates.

## What is an Action

An Action, at the lowest level, is a Struct with following members:

### `Action#method`

Refers to the name of the method to be invoked before a template is evaluated.

The return value of the method is kept as the result of Action#render if there is no Action#template.

### `Action#params`

The parameter are part of the `#__send__` to Action#method. You can visualize this as:

    if method = action.method
      action.instance.__send__(method, *action.params)
    end
{:lang=ruby}

In Lisp/Scheme terms, they are being applied.

Please note that the params are given as Strings due to the fact that they are extracted from the URI of the HTTP method and so Ramaze has no chance of determining what kind of Object this should represent.

### Action#template

If there is a template found during the procedure of finding a fitting Action for the given request, this member is set to the relative path from your Global.view_root or Controller.view_root directory. The template is evaluated unless the templating engine is set to :None and the result of this evaluation is set as the response.body.

### Action#controller

Points to the controller this Action operates on, also see Action#instance.

### Action#path

A String represenation of the Action without params, generally it's the name of the method or (if no method but a template found) the name of the template without extension. It's used for different kinds of hooks.

### Action#binding

The binding to the `Action#instance`, obtained by doing an `instance_eval{ binding }` on it. This is only done when the binding hasn't been set yet.

### Action#engine

Refers to the templating engine that this Action is passed to when `Action#render` is called.

### Action#instance

Instance of the Controller, lazily obtained through `Action#controller.new` on access of this member. Note that this is also invoked as a dependency of `Action#binding`.

## Create an Action

Creating an Action can be verbose and is usually not required outside the direct proximity within the codeflow.

    action = Ramaze::Action(:controller => MainController)
{:lang=ruby}


## Render an Action

We did all this just to render an Action, so let's do that already.

    class MainController < Ramaze::Controller
      def index
        "Hello, World!"
      end
    end

    Ramaze::Action(:controller => MainController, :method => :index).render
    # => "Hello, World!"
{:lang=ruby}

# Ramaze::Template

## Engines

## Ezamar

Ezamar is the default templating engine shipped with Ramaze, it's a very simple implementation but offers you most things you will demand from templating.

One of the advantages of Ezamar is quite fast execution based on the optimized String interpolation in Ruby.

Also, your templates will work out of the box, you don't have to install anything besides Ramaze.

### Syntax

Output is done by using `#{}` syntax, the last expression inside the parenthesis is interpolated in the final template.

The PI (Processing Instruction) is `<?r ?>`, r standing for Ruby, In future more PIs may become available.

To summarize:

Syntax | Description |
-------|-------------|
`#{ (expr) }`   | Interpolates like in normal Ruby String and shows in result. |
`<?r (expr) ?>` | Only execute; `<exression>` is sourrounded by semicolon. |

## Usage

As an example, let's see hello world using all basic features of this engine.

    <html>
      <head><title>Hello, World!</title></head>
      <body>
        <h1>Hello, World!</h1>
        <?r 10.times do |i| ?>
          <p>#{ordinal(i)} times i've said hello</p>
        <?r end ?>
      </body>
    </html>
{:lang=ezamar}

## Erubis

Erubis is an implementation of eRuby, giving you the well known ERB syntax.
It is very fast, around three times faster than ERB and even 10% faster than eruby.

Other features are

* Multi-language support (Ruby/PHP/C/Java/Scheme/Perl/Javascript)
* Auto escaping support
* Auto trimming spaces around `<% %>`
* Embedded pattern changeable (default `<% %>`)
* Enable to handle Processing Instructions (PI) as embedded pattern (ex. `<?rb ... ?>`)
* Context object available and easy to combine eRuby template with YAML datafile
* Print statement available
* Easy to extend and customize in subclass

Erubis is implemented in pure Ruby, so it works on most implemenations of the language. According to their dependencies it requires Ruby 1.8 or higher.

### Syntax

Erubis provides you default ERB syntax, PIs are inside `<% %>`, output is done by `<%= %>`

Summary:

Syntax           | Description                         |
-----------------|-------------------------------------|
`<% (expr) %>`   | Execute expression, ignore result   |
`<%= (expr) %>`  | Interpolate last expressions result |
`<?rb (expr) %>` | Execute expression, ignore result   |

### Usage

    <html>
      <head><title>Hello, World!</title></head>
      <body>
        <h1>Hello, World!</h1>
        <% 10.times do |i| %>
          <p><%= ordinal(i) %> times i've said hello</p>
        <% end %>
      </body>
    </html>
{:lang=erubis}

## Haml

Haml is a templating engine for (X)HTML, designed to make it both easier and more pleasant to code your documents.

It attempts to eliminate redundancy, reflecting the underlying structure that the document represents, and providing elegant, easily understandable but powerful syntax.

It's closely related to the Sass templating engine also supported by Ramaze.

### Syntax

Haml syntax is more involved as it replaces conventional HTML tags completely and providing its own indentation-based alternative.

The way to create tags can be shortly summarized with

    %tagname{ :attr1 => 'value1', :attr2 => 'value2' } Contents
{:lang=haml}

# Equivalent in HTML:

    <tagname attr1='value1' attr2='value2'>Contents</tagname>
{:lang=html}

There are shortcuts, especially for the `<div>` tag:

    #foo Bar
{:lang=haml}

# Equivalent in HTML:

    <div id='foo'>Bar</div>
{:lang=html}

To nest tags, just adjust their indentation:

    #foo Bar
      #bar Foo
{:lang=haml}

# in HTML:

    <div id='foo'>Bar
      <div id='bar'>Foo</div>
    </div>
{:lang=html}

Which already shows you how this can be a very powerful way to write your templates.

An example embedding Ruby code:

    %p Date/Time:
      - now = DateTime.now
      %strong= now
      - if now > DateTime.parse('December 31, 2006')
        = 'Happy new ' + 'year!'
{:lang=haml}

As you can see, lines prefixed with '-' are executed but their results are not shown in the result, contrary to that, lines starting with '=' are executed and their result is interpolated in the template.

Haml doesn't only omit ending tags by indentation but the same mechanism also helps to the 'end' statements in embedded Ruby code. This way the HTML and Ruby languages are connected in their side-effects, providing you with a quite terse but still readable and DRY syntax to write your templates in.

There are downsides to this approach, as it's not possible to control how exactly the final document is generated, but Haml is gaining momentum in the Ruby community very fast despite that fact, as it's simply not important for most applications on the web.

### Usage

    %html
      %head
        %title Hello, World!
      %body
        %h1 Hello, World!
        - 10.times do |i|
          %p= "#{ordinal(i)} times i've said hello"
{:lang=haml}


## Sass

Haml is a templating engine for CSS, designed to make it both easier and more pleasant to create styles for your documents.

It attempts to eliminate redundancy, reflecting the underlying structure that CSS represents, and providing elegant, easily understandable but powerful syntax.

It's closely related to the Haml templating engine also supported by Ramaze.

### Syntax
### Usage

## Amrita2
..
## Liquid
..
## Markaby
..
## Nagoro
...
## None
...
## RedCloth
...
## Remarkably
Tagz
...
Tenjin
...
XSLT
...

## How to create your own engine

# Ramaze::Adapter

Ramaze::Adapter is the module that contains and controls the various servers Ramaze runs on.

Adapters generally inherit from Ramaze::Adapter::Base, but are not instantiated, so singleton methods are used instead.

## Adapter::startup

The control flow in the Adapter module is largely decided by Global configuration. Adapter::startup is called by Ramaze::start as Adapter is one of the elements in `Ramaze.trait[:essentials]`.

Depending on the object assigned to Global.adapter

## How to create your own adapter

As usual, you might eventually end up having to create your own Adapter, either because there's none yet for the Server you are using or because you want a very particular set of options that you cannot supply otherwise. Fortunately this is a very simple thing to do, thanks to Rack and our Adapter::Base.

We will take a look at one of the existing adapters for Mongrel first.

    module Ramaze
      module Adapter
        class Mongrel < Base
          def self.startup(host, port)
            @server = ::Mongrel::HttpServer.new(host, port)
            @server.register('/', ::Rack::Handler::Mongrel.new(self))
            @server.run
          end
        end
      end
    end
{:lang=ruby}

What we do here is putting a subclass of Ramaze::Adapter::Base into Ramaze::Adapter, so later Ramaze will be able to automatically find it (we will come to that later), but also because it is good practice.

This adapter only defines one method, ::startup. The host and port options from Global are passed to it when Adapter::startup invokes this method. If your adapter does not need these paramters it's common practice to default the parameters to nil, we'll see an example for this later as well when we come to discussing the CGI/Fcgi adapters.

Next we set the class instance variable @server, Adapters are not being initialized, we're only using singleton methods since there usually will only be one adapter active at a time.

Next we register the ,,/'' path of the server with a Rack::Handler, what this exactly means is that the handler will take care of the nasty details and incompatibilities between different servers, providing a common interface to work with in Ramaze. ,,/'' means that it will handle every request, if you would define another path this would be handled separatly, usually you will want Ramaze to handle all requests.

Last, but not least we call `@server.run`, in Mongrel this means that it will return a new Thread in which the requests are handled.
This is an essential detail, because `Adapter::startup` has to return a Thread.
The reason for having a separate thread is to be able to run things in parallel, for example tests or specs.
Whether or not the returned thread is called `#join` upon depends on the `Global.run_loose` option, which is false by default for normal applications, but defaults to true when you `require 'ramaze/spec/helper'`.

So let's see another adapter that uses one additional method.

    require 'thin'
    require 'rack/handler/thin'

    module Ramaze
      module Adapter
        class Thin < Base
          # start server on given host and port.
          def self.startup(host, port)
            @server = ::Thin::Server.new(host, port, self)
            ::Thin::Logging.silent = true
            @server.timeout = 3

            Thread.new{ @server.start }
          end

          def self.shutdown
            @server.stop
          end
        end
      end
    end
{:lang=ruby}

Thin is a server written in Ruby and C and follows an event based approach instead of a simple threaded TCPSocket.

What that means is that it won't spawn a Thread by default but work in the Thread::main scope, so this needs a bit of special care. It also uses a completely different API from Mongrel, although its parser is based on the Mongrel one.

Again we subclass Adapter::Base, define a method ::startup on it that takes host and port and define the @server variable, setting a couple of custom options and then create a new Thread in which we call @server.start, which would normally block further execution until an event like a browser request is received.

We also define the ::shutdown method, calling @server.stop, which will gracefully shut down the server, finishing any requests pending but not accepting new ones until all connections are closed.
