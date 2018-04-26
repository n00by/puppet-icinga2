require File.join(File.dirname(__FILE__), '../../..', 'puppet_x/icinga2/utils.rb')

module Puppet::Parser::Functions
  newfunction(:icinga2_attributes, :type => :rvalue) do |args|
    raise Puppet::ParseError, 'Must provide at least one argument.' if args.length > 3

    if args[1]
      indent = args[1]
    else
      indent = 0
    end

    if args[2]
      constants = args[2]
    else
      constants = lookupvar('::icinga2::_constants').keys.concat(lookupvar('::icinga2::params::globals'))
    end

    Puppet::Icinga2::Utils.attributes(args[0], constants, indent)
  end
end
