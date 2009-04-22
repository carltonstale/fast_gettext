#! /usr/bin/ruby
=begin
  string.rb - Extension for String.

  Copyright (C) 2005,2006 Masao Mutoh

  You may redistribute it and/or modify it under the same
  license terms as Ruby.
=end

# Extension for String class. This feature is included in Ruby 1.9 or later.
begin
  raise unless ("a %{x}" % {:x=>'b'}) == 'a b'
rescue ArgumentError
  class String
    alias :_fast_gettext_old_format_m :% # :nodoc:

    # call-seq:
    #  %(hash)
    #
    #  Default: "%s, %s" % ["Masao", "Mutoh"]
    #  Extended:
    #     "%{firstname}, %{lastname}" % {:firstname=>"Masao",:lastname=>"Mutoh"} == "Masao Mutoh"
    #     with field type such as d(decimal), f(float), ...
    #     "%<age>d, %<weight>.1f" % {:age => 10, :weight => 43.4} == "10 43.4"
    # This is the recommanded way for Ruby-GetText
    # because the translators can understand the meanings of the msgids easily.
    def %(args)
      if args.kind_of? Hash
        ret = dup
        # %{something} type
        args.each {|key, value| ret.gsub!(/\%\{#{key}\}/, value.to_s)}

        # %<..>d type
        args.each {|key, value|
          ret.gsub!(/\%<#{key}>([ #\+-0\*]?\d*\.?\d*[bBdiouxXeEfgGcps])/){
            sprintf("%#{$1}", value)
          }
        }
        ret.gsub(/%%/, "%")
        ret
      else
        ret = gsub(/%([{<])/, '%%\1')
        ret._fast_gettext_old_format_m(args)
      end
    end
  end
end
