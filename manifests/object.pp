# == Define: icinga2::object
#
# Private define resource to used by this module only.
#
# === Parameters
#
# [*ensure*]
#   Set to present enables the object, absent disabled it. Defaults to present.
#
# [*object_name*]
#   Set the icinga2 name of the object. Defaults to title of the define resource.
#
# [*template*]
#   Set to true will define a template otherwise an object.
#   Ignored if apply is set. Defaults to false.
#
# [*apply*]
#   Dispose an apply instead an object if set to 'true'. Value is taken as statement,
#   i.e. 'vhost => config in host.vars.vhosts'. Defaults to false.
#
# [*apply_target*]
#   An object type on which to target the apply rule. Valid values are `Host` and `Service`. Defaults to `Host`.
#
# [*import*]
#   A sorted list of templates to import in this object. Defaults to an empty array.
#
# [*assign*]
#   Array of assign rules.
#
# [*ignore*]
#   Array of ignore rules.
#
# [*attrs*]
#   Hash for the attributes of this object. Keys are the attributes and
#   values are there values. Defaults to an empty Hash.
#
# [*object_type*]
#   Icinga 2 object type for this object.
#
# [*target*]
#   Destination config file to store in this object. File will be declared the
#   first time.
#
# [*order*]
#   String to set the position in the target file, sorted alpha numeric.
#
# === Variables
#
# [*_constants*]
#   Array of all possible bar words included globals, constants
#   and the attribute names of the object.
#
# [*_attrs*]
#   Hash of all atrributes if their values aren't undef.
#
#
define icinga2::object(
  $object_type,
  $target,
  $order,
  $ensure       = present,
  $object_name  = $title,
  $template     = false,
  $apply        = false,
  $apply_target = undef,
  $import       = [],
  $assign       = [],
  $ignore       = [],
  $attrs        = {},
) {

  if defined($caller_module_name) and $module_name != $caller_module_name and $caller_module_name != '' {
    fail("icinga2::object is a private define resource of the module icinga2, you're not permitted to use it.")
  }

  include ::icinga2::params
  require ::icinga2::config

  case $::osfamily {
    'windows': {
      Concat {
        owner => 'Administrators',
        group => 'NETWORK SERVICE',
        mode  => '0770',
      }
    } # windows
    default: {
      Concat {
        owner => $::icinga2::params::user,
        group => $::icinga2::params::group,
        mode  => '0640',
      }
    } # default
  }

  validate_re($ensure, [ '^present$', '^absent$' ],
    "${ensure} isn't supported. Valid values are 'present' and 'absent'.")
  validate_string($object_name)
  validate_bool($template)
  unless is_bool($apply) { validate_re($apply, '^.+\s+(=>\s+.+\s+)?in\s+.+$') }
  if $apply_target { validate_re($apply_target, ['^Host$', '^Service$'],
    "${apply_target} isn't supported. Valid values are 'Host' and 'Service'.") }
  validate_array($import)
  validate_array($assign)
  validate_array($ignore)
  validate_hash($attrs)
  validate_string($object_type)
  validate_absolute_path($target)
  validate_string($order)

  if $object_type == $apply_target {
    fail('The object type must be different from the apply target')
  }

  $_constants = concat(keys($::icinga2::_constants), $::icinga2::params::globals, keys($attrs))
  $_attrs = delete_undef_values(merge($attrs, {
    'assign where' => $assign,
    'ignore where' => $ignore,
  }))

  if !defined(Concat[$target]) {
    concat { $target:
      ensure => present,
      tag    => 'icinga2::config::file',
      warn   => true,
    }
  }

  if $ensure != 'absent' {
    concat::fragment { $title:
      target  => $target,
      content => $::osfamily ? {
        'windows' => regsubst(template('icinga2/object.conf.erb'), '\n', "\r\n", 'EMG'),
        default   => template('icinga2/object.conf.erb'),
      },
      order   => $order,
    }
  }

}
