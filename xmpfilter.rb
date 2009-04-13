#!/usr/bin/env ruby
# Copyright (c) 2005-2006 Mauricio Fernandez <mfp@acm.org> http://eigenclass.org
#                         rubikitch <rubikitch@ruby-lang.org>
# Use and distribution subject to the terms of the Ruby license.

class XMPFilter
  VERSION = "0.4.0"

  MARKER = "!XMP#{Time.new.to_i}_#{Process.pid}_#{rand(1000000)}!"
  XMP_RE = Regexp.new("^" + Regexp.escape(MARKER) + '\[([0-9]+)\] (=>|~>|==>) (.*)')
  VAR = "_xmp_#{Time.new.to_i}_#{Process.pid}_#{rand(1000000)}"
  WARNING_RE = /.*:([0-9]+): warning: (.*)/

  RuntimeData = Struct.new(:results, :exceptions, :bindings)

  INITIALIZE_OPTS = {:interpreter => "ruby", :options => [], :libs => [],
                     :include_paths => [], :warnings => true,
                     :use_parentheses => true}
  def initialize(opts = {})
    options = INITIALIZE_OPTS.merge opts
    @interpreter = options[:interpreter]
    @options = options[:options]
    @libs = options[:libs]
    @evals = options[:evals] || []
    @include_paths = options[:include_paths]
    @output_stdout = options[:output_stdout]
    @dump = options[:dump]
    @warnings = options[:warnings]
    @parentheses = options[:use_parentheses]

    @postfix = ""
  end

  def add_markers(code, min_codeline_size = 50)
    maxlen = code.map{|x| x.size}.max
    maxlen = [min_codeline_size, maxlen + 2].max
    ret = ""
    code.each do |l|
      l = l.chomp.gsub(/ # (=>|!>).*/, "").gsub(/\s*$/, "")
      ret << (l + " " * (maxlen - l.size) + " # =>\n")
    end
    ret
  end

  def annotate(code)
    idx = 0
    newcode = code.gsub(/^(.*) # =>.*/){|l| prepare_line($1, idx += 1) }
    if @dump
      File.open(@dump, "w"){|f| f.puts newcode}
    end
    stdout, stderr = execute(newcode)
    output = stderr.readlines
    runtime_data = extract_data(output)
    idx = 0
    annotated = code.gsub(/^(.*) # =>.*/) do |l|
      expr = $1
      if /^\s*#/ =~ l
        l
      else
        annotated_line(l, expr, runtime_data, idx += 1)
      end
    end.gsub(/ # !>.*/, '').gsub(/# (>>|~>)[^\n]*\n/m, "");
    ret = final_decoration(annotated, output)
    if @output_stdout and (s = stdout.read) != ""
      ret << s.inject(""){|s,line| s + "# >> #{line}".chomp + "\n" }
    end
    ret
  end

  def annotated_line(line, expression, runtime_data, idx)
    "#{expression} # => " + (runtime_data.results[idx].map{|x| x[1]} || []).join(", ")
  end

  def prepare_line_annotation(expr, idx)
    v = "#{VAR}"
    blocal = "__#{VAR}"
    blocal2 = "___#{VAR}"
    # rubikitch: oneline-ized
# <<EOF.chomp
# ((#{v} = (#{expr}); $stderr.puts("#{MARKER}[#{idx}] => " + #{v}.class.to_s + " " + #{v}.inspect) || begin; $stderr.puts local_variables; local_variables.each{|#{blocal}| #{blocal2} = eval(#{blocal}); if #{v} == #{blocal2} && #{blocal} != %#{expr}.strip; $stderr.puts("#{MARKER}[#{idx}] ==> " + #{blocal}); elsif [#{blocal2}] == #{v}; $stderr.puts("#{MARKER}[#{idx}] ==> [" + #{blocal} + "]") end }; nil rescue Exception; nil end || #{v}))
# EOF
    oneline_ize(<<-EOF).chomp
#{v} = (#{expr})
$stderr.puts("#{MARKER}[#{idx}] => " + #{v}.class.to_s + " " + #{v}.inspect) || begin
  $stderr.puts local_variables
  local_variables.each{|#{blocal}|
    #{blocal2} = eval(#{blocal})
    if #{v} == #{blocal2} && #{blocal} != %#{expr}.strip
      $stderr.puts("#{MARKER}[#{idx}] ==> " + #{blocal})
    elsif [#{blocal2}] == #{v}
      $stderr.puts("#{MARKER}[#{idx}] ==> [" + #{blocal} + "]")
    end
  }
  nil
rescue Exception
  nil
end || #{v}
    EOF

  end
  alias_method :prepare_line, :prepare_line_annotation

  def execute_tmpfile(code)
    stdin, stdout, stderr = (1..3).map do |i|
      fname = "xmpfilter.tmpfile_#{Process.pid}-#{i}.rb"
      at_exit { File.unlink fname }
      File.open(fname, "w+")
    end
    stdin.puts code
    stdin.close
    exe_line = <<-EOF.map{|l| l.strip}.join(";")
      $stdout.reopen('#{stdout.path}', 'w')
      $stderr.reopen('#{stderr.path}', 'w')
      $0.replace '#{stdin.path}'
      ARGV.replace(#{@options.inspect})
      load #{stdin.path.inspect}
      #{@evals.join(";")}
    EOF
    system(*(interpreter_command << "-e" << exe_line))
    [stdout, stderr]
  end

  def execute_popen(code)
    require 'open3'
    stdin, stdout, stderr = Open3::popen3(*interpreter_command)
    stdin.puts code
    @evals.each{|x| stdin.puts x } unless @evals.empty?
    stdin.close
    [stdout, stderr]
  end

  if /win|mingw/ =~ RUBY_PLATFORM && /darwin/ !~ RUBY_PLATFORM
    alias_method :execute, :execute_tmpfile
  else
    alias_method :execute, :execute_popen
  end

  def interpreter_command
    r = [@interpreter, "-w"]
    r << "-d" if $DEBUG
    r << "-I#{@include_paths.join(":")}" unless @include_paths.empty?
    @libs.each{|x| r << "-r#{x}" } unless @libs.empty?
    r
  end

  def extract_data(output)
    results = Hash.new{|h,k| h[k] = []}
    exceptions = Hash.new{|h,k| h[k] = []}
    bindings = Hash.new{|h,k| h[k] = []}
    output.grep(XMP_RE).each do |line|
      result_id, op, result = XMP_RE.match(line).captures
      case op
      when "=>"
        klass, value = /(\S+)\s+(.*)/.match(result).captures
        results[result_id.to_i] << [klass, value]
      when "~>"
        exceptions[result_id.to_i] << result
      when "==>"
        bindings[result_id.to_i] << result unless result.index(VAR)
      end
    end
    RuntimeData.new(results, exceptions, bindings)
  end

  def final_decoration(code, output)
    warnings = {}
    output.join.grep(WARNING_RE).map do |x|
      md = WARNING_RE.match(x)
      warnings[md[1].to_i] = md[2]
    end
    idx = 0
    ret = code.map do |line|
      w = warnings[idx+=1]
      if @warnings
        w ? (line.chomp + " # !> #{w}") : line
      else
        line
      end
    end
    output = output.reject{|x| /^-:[0-9]+: warning/.match(x)}
    if exception = /^-:[0-9]+:.*/m.match(output.join)
      ret << exception[0].map{|line| "# ~> " + line }
    end
    ret
  end

  def oneline_ize(code)
    "((" + code.gsub(/\r?\n|\r/, ';') + "))#{@postfix}\n"
  end

  def debugprint(*args)
    $stderr.puts(*args) if $DEBUG
  end
end # clas XMPFilter

class XMPTestUnitFilter < XMPFilter
  def initialize(opts = {})
    super
    @output_stdout = false
  end

  private
  def annotated_line(line, expression, runtime_data, idx)
    indent =  /^\s*/.match(line)[0]
    assertions(expression.strip, runtime_data, idx).map{|x| indent + x}.join("\n")
  end

  def prepare_line(expr, idx)
    basic_eval = prepare_line_annotation(expr, idx)
    %|begin; #{basic_eval}; rescue Exception; $stderr.puts("#{MARKER}[#{idx}] ~> " + $!.class.to_s); end|
  end

  def assertions(expression, runtime_data, index)
    exceptions = runtime_data.exceptions
    ret = []

    unless (vars = runtime_data.bindings[index]).empty?
      vars.each{|var| ret << equal_assertion(var, expression) }
    end
    if !(wanted = runtime_data.results[index]).empty? || !exceptions[index]
      case (wanted[0][1] rescue 1)
      when "nil"
        ret.concat nil_assertion(expression)
      else
        case wanted.size
        when 1
          ret.concat value_assertions(wanted[0], expression)
        else
          # discard values from multiple runs
          ret.concat(["#xmpfilter: WARNING!! extra values ignored"] +
                     value_assertions(wanted[0], expression))
        end
      end
    else
      ret.concat raise_assertion(expression, exceptions, index)
    end

    ret
  end

  def nil_assertion(expression)
    if @parentheses
      ["assert_nil(#{expression})"]
    else
      ["assert_nil #{expression}"]
    end
  end

  def raise_assertion(expression, exceptions, index)
    ["assert_raise(#{exceptions[index][0]}){#{expression}}"]
  end

  OTHER = Class.new
  def value_assertions(klass_value_txt_pair, expression)
    klass_txt, value_txt = klass_value_txt_pair
    value = eval(value_txt) || OTHER.new
    # special cases
    value = nil if value_txt.strip == "nil"
    value = false if value_txt.strip == "false"
    case value
    when Float
      @parentheses ?  ["assert_in_delta(#{value.inspect}, #{expression}, 0.0001)"] :
                      ["assert_in_delta #{value.inspect}, #{expression}, 0.0001"]
    when Numeric, String, Hash, Array, Regexp, TrueClass, FalseClass, Symbol, NilClass
      @parentheses ?  ["assert_equal(#{value_txt}, #{expression})"] :
                      ["assert_equal #{value_txt}, #{expression}"]
    else
      @parentheses ?  [ "assert_kind_of(#{klass_txt}, #{expression})",
                        "assert_equal(#{value_txt.inspect}, #{expression}.inspect)" ] :
                      [ "assert_kind_of #{klass_txt}, #{expression} ",
                        "assert_equal #{value_txt.inspect}, #{expression}.inspect" ]
    end
  rescue Exception
      return @parentheses ?  [ "assert_kind_of(#{klass_txt}, #{expression})",
                        "assert_equal(#{value_txt.inspect}, #{expression}.inspect)" ] :
                      [ "assert_kind_of #{klass_txt}, #{expression}",
                        "assert_equal #{value_txt.inspect}, #{expression}.inspect" ]
  end

  def equal_assertion(expected, actual)
    @parentheses ?  "assert_equal(#{expected}, #{actual})" : "assert_equal #{expected}, #{actual}"
  end
end

class XMPRSpecFilter < XMPTestUnitFilter
  private
  def execute(code)
    codefile = "xmpfilter.rspec_tmpfile_#{Process.pid}.rb"
    File.open(codefile, "w"){|f| f.puts code}
    path = File.expand_path(codefile)
    at_exit { File.unlink path }
    stdout, stderr = (1..2).map do |i|
      fname = "xmpfilter.rspec_tmpfile_#{Process.pid}-#{i}.rb"
      fullname = File.expand_path(fname)
      at_exit { File.unlink fullname }
      File.open(fname, "w+")
    end
    args = *(interpreter_command << %["#{codefile}"] << "2>" <<
             %["#{stderr.path}"] << ">" << %["#{stdout.path}"])
    system(args.join(" "))
    [stdout, stderr]
  end

  def interpreter_command
    [@interpreter] + @libs.map{|x| "-r#{x}"}
  end

  def nil_assertion(expression)
    @parentheses ?  ["(#{expression}).should_be_nil"] : ["#{expression}.should_be_nil"]
  end

  def raise_assertion(expression, exceptions, index)
    ["lambda{#{expression}}.should_raise #{exceptions[index][0]}"]
  end

  def value_assertions(klass_value_txt_pair, expression)
    klass_txt, value_txt = klass_value_txt_pair
    value = eval(value_txt) || OTHER.new
    # special cases
    value = nil if value_txt.strip == "nil"
    value = false if value_txt.strip == "false"
    case value
    when Float
      @parentheses ?
      ["(#{expression}).should_be_close #{value.inspect}, 0.0001"] :
      ["#{expression}.should_be_close #{value.inspect}, 0.0001"]
    when Numeric, String, Hash, Array, Regexp, TrueClass, FalseClass, Symbol, NilClass
      @parentheses ?
      ["(#{expression}).should_equal #{value_txt}"] :
      ["#{expression}.should_equal #{value_txt}"]
    else
      @parentheses ?
      [ "(#{expression}).should_be_a_kind_of #{klass_txt}",
        "(#{expression}.inspect).should_equal #{value_txt.inspect}" ] :
      [ "#{expression}.should_be_a_kind_of #{klass_txt}",
        "#{expression}.inspect.should_equal #{value_txt.inspect}" ]
    end
  rescue
    return @parentheses ?
      [ "(#{expression}).should_be_a_kind_of #{klass_txt}",
        "(#{expression}.inspect).should_equal #{value_txt.inspect}" ] :
      [ "#{expression}.should_be_a_kind_of #{klass_txt}",
        "#{expression}.inspect.should_equal #{value_txt.inspect}" ]
  end

  def equal_assertion(expected, actual)
    @parentheses ?
    "(#{actual}).should_equal #{expected}" : "#{actual}.should_equal #{expected}"
  end
end

require 'enumerator'
# Common routines for XMPCompletionFilter/XMPDocFilter
module ProcessParticularLine
  def fill_literal!(expr)
    [ "\"", "'", "`" ].each do |q|
      expr.gsub!(/#{q}(.+)#{q}/){ '"' + "x"*$1.length + '"' }
    end
    expr.gsub!(/(%([wWqQxrs])?(\W))(.+?)\3/){
      percent = $2 == 'x' ? '%'+$3 : $1 # avoid executing shell command
      percent + "x"*$4.length + $3
    }
    [ %w[( )], %w[{ }], %w![ ]!, %w[< >] ].each do |b,e|
      rb, re = [b,e].map{ |x| Regexp.quote(x)}
      expr.gsub!(/(%([wWqQxrs])?(#{rb}))(.+)#{re}/){
        percent = $2 == 'x' ? '%'+$3 : $1 # avoid executing shell command
        percent + "x"*$4.length + e
      }
    end
  end

  module ExpressionExtension
    attr_accessor :eval_string
    attr_accessor :meth
  end
  OPERATOR_CHARS = '\|^&<>=~\+\-\*\/%\['
  def set_expr_and_postfix!(expr, column, &regexp)
    expr.extend ExpressionExtension

    @postfix = ""
    expr_orig = expr.clone
    column ||= expr.length
    last_char = expr[column-1]
    expr.replace expr[ regexp[column] ]
    debugprint "expr_orig=#{expr_orig}", "expr(sliced)=#{expr}"
    right_stripped = Regexp.last_match.post_match
    _handle_do_end right_stripped
    aref_or_aset = aref_or_aset? right_stripped, last_char
    debugprint "aref_or_aset=#{aref_or_aset.inspect}"
    set_last_word! expr, aref_or_aset
    fill_literal! expr_orig
    _handle_brackets expr_orig, expr
    expr << aref_or_aset if aref_or_aset
    _handle_keywords expr_orig, column
    debugprint "expr(processed)=#{expr}"
    expr
  end

  def _handle_do_end(right_stripped)
    right_stripped << "\n"
    n_do = right_stripped.scan(/[\s\)]do\s/).length
    n_end = right_stripped.scan(/\bend\b/).length
    @postfix = ";begin" * (n_do - n_end)
  end

  def _handle_brackets(expr_orig, expr)
    [ %w[{ }], %w[( )], %w![ ]! ].each do |left, right|
      n_left  = expr_orig.count(left)  - expr.count(left)
      n_right = expr_orig.count(right) - expr.count(right)
      n = n_left - n_right
      @postfix << ";#{left}" * n if n >= 0
    end
  end

  def _handle_keywords(expr_orig, column)
    %w[if unless while until for].each do |keyw|
      pos = expr_orig.index(/\b#{keyw}\b/)
      @postfix << ";begin" if pos and pos < column # if * xxx

      pos = expr_orig.index(/;\s*#{keyw}\b/)
      @postfix << ";begin" if pos and column < pos # * ; if xxx
    end
  end

  def aref_or_aset?(right_stripped, last_char)
    if last_char == ?[
      case right_stripped
      when /\]\s*=/: "[]="
      when /\]/:     "[]"
      end
    end
  end

  def set_last_word!(expr, aref_or_aset=nil)
    debugprint "expr(before set_last_word)=#{expr}"
    if aref_or_aset
      opchars = ""
    else
      opchars = expr.slice!(/\s*[#{OPERATOR_CHARS}]+$/)
      debugprint "expr(strip opchars)=#{expr}"
    end

    expr.replace(if expr =~ /[\"\'\`]$/      # String operations
                   "''"
                 else
                   fill_literal! expr
                   phrase = current_phrase(expr)
                   if aref_or_aset
                     expr.eval_string = expr[0..-2]
                     expr.meth = aref_or_aset
                   elsif phrase.match( /^(.+)\.(.*)$/ )
                     expr.eval_string, expr.meth = $1, $2
                   elsif opchars != ''
                     expr
                   end
                   debugprint "expr.eval_string=#{expr.eval_string}", "expr.meth=#{expr.meth}"
                   phrase
                 end << (opchars || '')) # ` font-lock hack
    debugprint "expr(after set_last_word)=#{expr}"
  end

  def current_phrase(expr)
    paren_level = 0
    start = 0
    (expr.length-1).downto(0) do |i|
      c = expr[i,1]
      if c =~ /[\)\}\]]/
        paren_level += 1
        next
      end
      if paren_level > 0
        next if c =~ /[, ]/
      else
        break (start = i+1) if c =~ /[ ,\(\{\[]/
      end
      if c =~ /[\(\{\[]/
        paren_level -= 1
        break (start = i+1) if paren_level < 0
      end
    end
    expr[start..-1]
  end

  class RuntimeDataError < RuntimeError; end
  def runtime_data(code, lineno, column=nil)
    newcode = code.to_a.enum_with_index.map{|line, i|
      i+1==lineno ? prepare_line(line.chomp, column) : line
    }.join
    debugprint "newcode", newcode, "-"*80
    stdout, stderr = execute(newcode)
    output = stderr.readlines
    debugprint "stdout", output, "-"*80
    runtime_data = extract_data(output)
    begin
      runtime_data.results[1][0][1..-1].to_s
    rescue
      raise RuntimeDataError, runtime_data.inspect
    end

  end

end

# Nearly 100% accurate completion for any editors!!
#  by rubikitch <rubikitch@ruby-lang.org>
class XMPCompletionFilter < XMPFilter
  include ProcessParticularLine

  # String completion begins with this.
  attr :prefix

  def prepare_line(expr, column)
    set_expr_and_postfix!(expr, column){|c| /^.{#{c}}/ }
    @prefix = expr
    case expr
    when /^\$\w+$/              # global variable
      __prepare_line 'global_variables'
    when /^@@\w+$/              # class variable
      __prepare_line 'Module === self ? class_variables : self.class.class_variables'
    when /^@\w+$/               # instance variable
      __prepare_line 'instance_variables'
    when /^([A-Z].*)::(.*)$/    # nested constants / class methods
      @prefix = $2
      __prepare_line "#$1.constants | #$1.methods(true)"
    when /^[A-Z]\w*$/           # normal constants
      __prepare_line 'Module.constants'
    when /^::(.+)::(.*)$/       # toplevel nested constants
      @prefix = $2
      __prepare_line "::#$1.constants | ::#$1.methods"
    when /^::(.*)/              # toplevel constant
      @prefix = $1
      __prepare_line 'Object.constants'
    when /^(:[^:.]*)$/          # symbol
      __prepare_line 'Symbol.all_symbols.map{|s| ":" + s.id2name}'
    when /\.([^.]*)$/           # method call
      @prefix = $1
      __prepare_line "(#{Regexp.last_match.pre_match}).methods(true)"
    else                        # bare words
      __prepare_line "methods | private_methods | local_variables | self.class.constants"
    end
  end

  def __prepare_line(all_completion_expr)
    v = "#{VAR}"
    idx = 1
    oneline_ize(<<EOC)
#{v} = (#{all_completion_expr}).grep(/^#{Regexp.quote(@prefix)}/)
$stderr.puts("#{MARKER}[#{idx}] => " + #{v}.class.to_s  + " " + #{v}.join(" ")) || #{v}
exit
EOC
  end

  # Array of completion candidates.
  def candidates(code, lineno, column=nil)
    methods = runtime_data(code, lineno, column) rescue ""
    methods.split
  end

  # Completion code for editors.
  def completion_code(code, lineno, column=nil)
    candidates(code, lineno, column).join("\n")
  end
end

class XMPCompletionEmacsFilter < XMPCompletionFilter
  def completion_code(code, lineno, column=nil)
    elisp = "(progn\n"
    elisp <<  "(setq xmpfilter-method-completion-table '("
    begin
      candidates(code, lineno, column).each do |meth|
        elisp << format('("%s") ', meth)
      end
    rescue => err
      return %Q[(error "#{err.message}")]
    end
    elisp << "))\n"
    elisp << %Q[(setq pattern "#{prefix}")\n]
    elisp << %Q[(try-completion pattern xmpfilter-method-completion-table nil)\n]
    elisp << ")"                # /progn
  end
end

# FIXME rubikitch: I do not use vim, so I cannot implement XMPCompletionVimFilter class.
class XMPCompletionVimFilter < XMPCompletionFilter
  def completion_code(code, lineno, column=nil)
    raise NotImplementedError
  end
end


# Call Ri for any editors!!
#  by rubikitch <rubikitch@ruby-lang.org>
class XMPDocFilter < XMPFilter
  include ProcessParticularLine

  def initialize(opts = {})
    super
    @filename = opts[:filename]
    extend UseMethodAnalyzer if opts[:use_method_analyzer]
  end

  def prepare_line(expr, column)
    set_expr_and_postfix!(expr, column){|c|
      withop_re = /^.{#{c-1}}[#{OPERATOR_CHARS}]+/
      if expr =~ withop_re
        withop_re
      else
        /^.{#{c}}[\w#{OPERATOR_CHARS}]*/
      end
    }
    recv = expr

    # When expr already knows receiver and method,
    return(__prepare_line :recv => expr.eval_string, :meth => expr.meth) if expr.eval_string

    case expr
    when /^(?:::)?([A-Z].*)(?:::|\.)(.*)$/    # nested constants / class methods
      __prepare_line :klass => $1, :meth_or_constant => $2
    when /^(?:::)?[A-Z]/               # normal constants
      __prepare_line :klass => expr
    when /\.([^.]*)$/             # method call
      __prepare_line :recv => Regexp.last_match.pre_match, :meth => $1
    when /^(.+)(\[\]=?)$/                   # [], []=
      __prepare_line :recv => $1, :meth => $2
    when /[#{OPERATOR_CHARS}]+$/                   # operator
      __prepare_line :recv => Regexp.last_match.pre_match, :meth => $&
    else                        # bare words
      __prepare_line :recv => "self", :meth => expr
    end
  end

  def __prepare_line(x)
    v = "#{VAR}"
    klass = "#{VAR}_klass"
    flag = "#{VAR}_flag"
    which_methods = "#{VAR}_methods"
    ancestor_class = "#{VAR}_ancestor_class"
    idx = 1
    recv = x[:recv] || x[:klass] || raise(ArgumentError, "need :recv or :klass")
    meth = x[:meth_or_constant] || x[:meth]
    debugprint "recv=#{recv}", "meth=#{meth}"
    if meth
      code = <<-EOC
#{v} = (#{recv})
if Class === #{v}
  #{flag} = #{v}.respond_to?('#{meth}') ? "." : "::"
  #{klass} = #{v}
  #{which_methods} = :methods
else
  #{flag} = "#"
  #{klass} = #{v}.class
  #{which_methods} = :instance_methods
end
#{ancestor_class} = #{klass}.ancestors.delete_if{|c| c==Kernel }.find{|c| c.__send__(#{which_methods}, false).include? '#{meth}' }
$stderr.print("#{MARKER}[#{idx}] => " + #{v}.class.to_s  + " ")

if #{ancestor_class}
  $stderr.puts(#{ancestor_class}.to_s + #{flag} + '#{meth}')
else
  [Kernel, Module, Class].each do |k|
    if (k.instance_methods(false) + k.private_instance_methods(false)).include? '#{meth}'
      $stderr.printf("%s#%s\\n", k, '#{meth}'); exit
    end
  end
  $stderr.puts(#{v}.to_s + '::' + '#{meth}')
end
exit
      EOC
    else
      code = <<-EOC
#{v} = (#{recv})
$stderr.print("#{MARKER}[#{idx}] => " + #{v}.class.to_s  + " ")
$stderr.puts(#{v}.to_s)
exit
      EOC
    end
    oneline_ize(code)
  end


  # Completion code for editors.
  def completion_code(code, lineno, column=nil)
    candidates(code, lineno, column).join("\n")
  end

  # overridable by module
  def _doc(code, lineno, column)
  end

  def doc(code, lineno, column=nil)
    _doc(code, lineno, column) or runtime_data(code, lineno, column).to_s
  end

  module UseMethodAnalyzer
    METHOD_ANALYSIS = "method_analysis"
    def have_method_analysis
      File.file? METHOD_ANALYSIS
    end

    def find_method_analysis
      here = Dir.pwd
      oldpwd = here
      begin
        while ! have_method_analysis
          Dir.chdir("..")
          if Dir.pwd == here
            return nil          # not found
          end
          here = Dir.pwd
        end
      ensure
        Dir.chdir oldpwd
      end
      yield(File.join(here, METHOD_ANALYSIS))
    end

    def _doc(code, lineno, column=nil)
      find_method_analysis do |ma_file|
        methods = open(ma_file, "rb"){ |f| Marshal.load(f)}
        line = File.readlines(@filename)[lineno-1]
        current_method = line[ /^.{#{column}}\w*/][ /\w+[\?!]?$/ ].sub(/:+/,'')
        filename = @filename  # FIXME
        begin
          methods[filename][lineno].grep(Regexp.new(Regexp.quote(current_method)))[0]
        rescue NoMethodError
          raise "doc/method_analyzer:cannot find #{current_method}"
        end

      end
    end
  end

end

# ReFe is so-called `Japanese Ri'.
class XMPReFeFilter < XMPDocFilter
  def doc(code, lineno, column=nil)
    "refe '#{super}'"
  end
end

class XMPRiFilter < XMPDocFilter
  def doc(code, lineno, column=nil)
    "ri '#{super}'"
  end
end

class XMPRiEmacsFilter < XMPDocFilter
  def doc(code, lineno, column=nil)
    begin
      %!(xmpfilter-find-tag-or-ri "#{super}")!
    rescue => err
      return %Q[(error "#{err.message}")]
    end
  end
end

# FIXME rubikitch: I do not use vim, so I cannot implement XMPRiVimFilter class.
class XMPRiVimFilter < XMPRiFilter
  def doc(code, lineno, column=nil)
  end
end

#{{{ Main code
if __FILE__ == $0
  require 'optparse'
  require 'ostruct'

  options = OpenStruct.new
  options.interpreter = "ruby"
  options.options = ""
  options.mode = :annotation
  options.min_codeline_size = 50
  options.libs = []
  options.evals = []
  options.include_paths = []
  options.debug = nil
  options.wd = nil
  options.warnings = true
  options.poetry = false
  options.column = nil
  options.output_stdout = true

  rails_settings = false

  opts = OptionParser.new do |opts|
    opts.banner = "Usage: xmpfilter.rb [options] [inputfile] [-- cmdline args]"

    opts.separator ""
    opts.separator "Modes:"
    opts.on("-a", "--annotations", "Annotate code (default)") do
      options.mode = :annotation
    end
    opts.on("-u", "--unittest", "Complete Test::Unit assertions.") do
      options.mode = :unittest
    end
    opts.on("-s", "--spec", "Complete RSpec expectations.") do
      options.mode = :rspec
      options.interpreter = "spec"
    end
    opts.on("-m", "--markers", "Add # => markers.") do
      options.mode = :marker
    end
    opts.on("-C", "--completion", "List completion candidates.") do
      options.mode = :completion
    end

    opts.on("--completion-emacs", "Generate completion code for Emacs.") do
      options.mode = :completion_emacs
    end
    opts.on("--completion-vim", "Generate completion code for Vim.") do
      options.mode = :completion_vim
    end

    opts.on("-D", "--doc", "Print callee method with class.") do
      options.mode = :doc
    end
    opts.on("--refe", "Refe callee method.") do
      options.mode = :refe
    end
    opts.on("--ri", "Ri callee method.") do
      options.mode = :ri
    end
    opts.on("--ri-emacs", "Generate ri code for emacs.") do
      options.mode = :ri_emacs
    end
    opts.on("--ri-vim", "Generate ri code for vim.") do
      options.mode = :ri_vim
    end


    opts.separator ""
    opts.separator "Completion and documentation options:"
    opts.on("--line=LINE", "Current line number.") do |n|
      options.lineno = n.to_i
    end
    opts.on("--column=COLUMN", "Current column number.") do |n|
      options.column = n.to_i
    end
    opts.on("--use-method-analyzer", "") do |n|
      options.use_method_analyzer = true
    end
    opts.on("--filename=FILENAME") do |n|
      options.filename = File.expand_path n
    end

    opts.separator ""
    opts.separator "Interpreter options:"
    opts.on("-I PATH", "Add PATH to $LOAD_PATH") do |path|
      options.include_paths << path
    end
    opts.on("-r LIB", "Require LIB before execution.") do |lib|
      options.libs << lib
    end
    opts.on("-e EXPR", "--eval=EXPR", "--stub=EXPR", "Evaluate EXPR after execution.") do |expr|
      options.evals << expr
    end

    opts.separator ""
    opts.on("--cd DIR", "Change working directory to DIR.") do |dir|
      options.wd = dir
    end
    opts.on("--debug", "Write transformed source code to xmp-tmp.PID.rb.") do
      options.debug = "xmp-tmp.#{Process.pid}.rb"
    end
    opts.on("-S FILE", "--interpreter FILE", "Use interpreter FILE.") do |interpreter|
      options.interpreter = interpreter
    end
    opts.on("-l N", "--min-line-length N", Integer, "Align markers to N spaces.") do |min_codeline_size|
      options.min_codeline_size = min_codeline_size
    end
    opts.on("--rails", "Setting appropriate for Rails.",
            "(no warnings, find working directory,",
            " Test::Unit assertions)") do
      options.warnings = false
      options.mode = :unittest
      rails_settings = true
    end
    opts.on("--[no-]poetry", "Whether to use extra parentheses.",
            "(default: use them)") do |poetry_p|
      options.poetry = poetry_p
    end
    opts.on("--[no-]warnings", "Whether to add warnings (# !>).",
            "(default: enabled)") {|warnings_p| options.warnings = warnings_p }
    opts.on("-q", "--quiet", "Supress standard output.") do
      options.output_stdout = false
    end
    opts.separator ""
    opts.on("-h", "--help", "Show this message") do
      puts opts
      exit
    end
    opts.on("-v", "--version", "Show version information") do
      puts "xmpfilter.rb #{XMPFilter::VERSION}"
      exit
    end
  end

  if idx = ARGV.index("--")
    extra_opts = ARGV[idx+1..-1]
    ARGV.replace ARGV[0...idx]
  else
    extra_opts = []
  end
  opts.parse!(ARGV)

  if rails_settings && !options.wd
    if File.exist? ARGF.path
      options.wd = File.dirname(ARGF.path)
    elsif File.exist? "test/unit"
      options.wd = "test/unit"
    elsif File.exist? "unit"
      options.wd = "unit"
    end
  end
  targetcode = ARGF.read
  Dir.chdir options.wd if options.wd

  klass = case options.mode
  when :annotation;       XMPFilter
  when :unittest;         XMPTestUnitFilter
  when :rspec;            XMPRSpecFilter
  when :completion;       XMPCompletionFilter
  when :completion_emacs; XMPCompletionEmacsFilter
  when :completion_vim;   XMPCompletionVimFilter
  when :doc;              XMPDocFilter
  when :refe;             XMPReFeFilter
  when :ri;               XMPRiFilter
  when :ri_emacs;         XMPRiEmacsFilter
  when :ri_vim;           XMPRiVimFilter
  else XMPFilter
  end

  xmp = klass.new(:interpreter => options.interpreter, :options => extra_opts,
                  :output_stdout => options.output_stdout,
                  :include_paths => options.include_paths, :libs => options.libs,
                  :evals => options.evals,
                  :use_method_analyzer => options.use_method_analyzer,
                  :filename => options.filename,
                  :dump => options.debug, :warnings => options.warnings,
                  :use_parentheses => !options.poetry)

  case options.mode
  when :marker     : puts xmp.add_markers(targetcode, options.min_codeline_size)
  when :annotation, :unittest, :rspec
    puts xmp.annotate(targetcode)
  when :completion, :completion_emacs, :completion_vim
    puts xmp.completion_code(targetcode, options.lineno, options.column)
  when :doc, :refe, :ri, :ri_emacs, :ri_vim
    puts xmp.doc(targetcode, options.lineno, options.column)
  else
    puts opts
    exit
  end
end
