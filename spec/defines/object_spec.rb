require 'spec_helper'

describe('icinga2::object', :type => :define) do
  let(:title) { 'bar' }
  let(:pre_condition) { [
    "class { 'icinga2': }"
  ] }

  on_supported_os.each do |os, facts|
    let :facts do
      facts
    end


    context "#{os} with all defaults and object_type => foo, target => /bar/baz, order => 10" do
      let(:params) { {:object_type => 'foo', :target => '/bar/baz', :order => '10'} }

      it { is_expected.to contain_concat('/bar/baz') }

      it { is_expected.to contain_concat__fragment('bar')
        .with({'target' => '/bar/baz', 'order' => '10'})
        .with_content(/object foo "bar"/)
        .without_content(/assign where/)
        .without_content(/ignore where/) }
    end


    context "#{os} with ensure => absent" do
      let(:params) { {:ensure => 'absent', :object_type => 'foo', :target => '/bar/baz', :order => '10'} }

      it { is_expected.to contain_concat('/bar/baz') }

      it { is_expected.not_to contain_concat__fragment('bar') }
    end


    context "#{os} with ensure => foo (not a valid value)" do
      let(:params) { {:ensure => 'foo', :object_type => 'foo', :target => '/bar/baz', :order => '10'} }

      it { is_expected.to raise_error(Puppet::Error, /foo isn't supported/) }
    end


    context "#{os} with target => bar/baz (not valid absolute path)" do
      let(:params) { {:object_type => 'foo', :target => 'bar/baz', :order => '10'} }

      it { is_expected.to raise_error(Puppet::Error, /"bar\/baz" is not an absolute path/) }
    end


    context "#{os} with template => true" do
      let(:params) { {:template => true, :object_type => 'foo', :target => '/bar/baz', :order => '10'} }

      it { is_expected.to contain_concat__fragment('bar')
        .with_content(/template foo "bar"/) }
    end


    context "#{os} with template => false" do
      let(:params) { {:template => false, :object_type => 'foo', :target => '/bar/baz', :order => '10'} }

      it { is_expected.to contain_concat__fragment('bar')
        .with_content(/object foo "bar"/) }
    end


    context "#{os} with template => foo (not a valid boolean)" do
      let(:params) { {:template => 'foo', :object_type => 'foo', :target => '/bar/baz', :order => '10'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" is not a boolean/) }
    end


    context "#{os} with apply => true" do
      let(:params) { {:apply => true, :object_type => 'foo', :target => '/bar/baz', :order => '10'} }

      it { is_expected.to contain_concat__fragment('bar')
        .with_content(/apply foo "bar"/) }
    end


    context "#{os} with import => [bar, baz], apply => foo in host.vars.bar" do
      let(:params) { {:import => ['bar', 'baz'], :apply => 'foo in host.vars.bar', :apply_target => 'Host', :attrs => {'vars' => 'vars + foo'}, :object_type => 'foo', :target => '/bar/baz', :order => '10'} }

      it { is_expected.to contain_concat__fragment('bar')
        .with_content(/import "bar"/)
        .with_content(/import "baz"/)
        .with_content(/vars = vars \+ foo\n/)
        .with_content(/apply foo for \(foo in host.vars.bar\) to Host/) }
    end


    context "#{os} with apply => foo => config in host.vars.bar" do
      let(:params) { {:apply => 'foo => config in host.vars.bar', :apply_target => 'Host', :attrs => {'vars' => 'vars + foo + config'}, :object_type => 'foo', :target => '/bar/baz', :order => '10'} }

      it { is_expected.to contain_concat__fragment('bar')
        .with_content(/vars = vars \+ foo \+ config\n/)
        .with_content(/apply foo for \(foo => config in host.vars.bar\) to Host/) }
    end


    context "#{os} with apply => foo (not valid expression or boolean)" do
      let(:params) { {:apply => 'foo', :apply_target => 'Host', :object_type => 'foo', :target => '/bar/baz', :order => '10'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" does not match/) }
    end


    context "#{os} with apply_target => 'foo' (not a valid value)" do
      let(:params) { {:apply_target => 'foo', :object_type => 'foo', :target => '/bar/baz', :order => '10'} }

      it { is_expected.to raise_error(Puppet::Error, /foo isn't supported/) }
    end


    context "#{os} with apply_target => 'Service', object_tpye => 'Service' (same value)" do
      let(:params) { {:apply_target => 'Service', :object_type => 'Service', :target => '/bar/baz', :order => '10'} }

      it { is_expected.to raise_error(Puppet::Error, /must be different/) }
    end


    context "#{os} with apply_target => 'Host', object_tpye => 'Service' (same value)" do
      let(:params) { {:apply => true,
                      :apply_target => 'Host',
                      :object_type => 'Service',
                      :target => '/bar/baz',
                      :order => '10'} }

      it { is_expected.to contain_concat__fragment('bar')
        .with_content(/apply Service "bar" to Host/)
      }
    end


    context "#{os} with import => [bar, baz]" do
      let(:params) { {:import => ['bar', 'baz'], :object_type => 'foo', :target => '/bar/baz', :order => '10'} }

      it { is_expected.to contain_concat__fragment('bar')
        .with_content(/import "bar"/)
        .with_content(/import "baz"/) }
    end


    context "#{os} with import => foo (not a valid array)" do
      let(:params) { {:import => 'foo', :object_type => 'foo', :target => '/bar/baz', :order => '10'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" is not an Array/) }
    end


    context "#{os} with assign => [ host.vars.os == bar && host.address, generic-host in host.templates]" do
      let(:params) { {:assign => ['host.vars.os == bar && host.address', 'generic-host in host.templates'], :object_type => 'foo', :target => '/bar/baz', :order => '10'} }

      it { is_expected.to contain_concat__fragment('bar')
        .with_content(/assign where host.vars.os == "bar" && host.address/)
        .with_content(/assign where "generic-host" in host.templates/) }
    end


    context "#{os} with assign => foo (not a valid array)" do
      let(:params) { {:assign => 'foo', :object_type => 'foo', :target => '/bar/baz', :order => '10'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" is not an Array/) }
    end


    context "#{os} with ignore => [ NodeName != baz || !host.display_name]" do
      let(:params) { {:ignore => ['NodeName != baz || !host.display_name'], :object_type => 'foo', :target => '/bar/baz', :order => '10'} }

      it { is_expected.to contain_concat__fragment('bar')
        .with_content(/ignore where NodeName != "baz" \|{2} !host.display_name/) }
    end


    context "#{os} with ignore => foo (not a valid array)" do
      let(:params) { {:ignore => 'foo', :object_type => 'foo', :target => '/bar/baz', :order => '10'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" is not an Array/) }
    end


    context "#{os} with attrs => { vars => {key1 => 4247, key2 => value2} }" do
      let(:params) { {:attrs => { 'vars' => {'key1' => '4247', 'key2' => 'value2'} }, :object_type => 'foo', :target => '/bar/baz', :order => '10'} }

      it { is_expected.to contain_concat__fragment('bar')
        .with_content(/vars.key1 = 4247\n/)
        .with_content(/vars.key2 = "value2"\n/) }
    end


    context "#{os} with attrs => { vars => {foo => {key1 => 4247, key2 => value2}} }" do
      let(:params) { {:attrs => { 'vars' => {'foo' => {'key1' => '4247', 'key2' => 'value2'}} }, :object_type => 'foo', :target => '/bar/baz', :order => '10'} }

      it { is_expected.to contain_concat__fragment('bar')
        .with_content(/vars.foo\["key1"\] = 4247\n/)
        .with_content(/vars.foo\["key2"\] = "value2"\n/) }
    end


    context "#{os} with attrs => { vars => {foo => {bar => {key => 4247, key2 => value2}}} }" do
      let(:params) { {:attrs => { 'vars' => {'foo' => { 'bar' => {'key1' => '4247', 'key2' => 'value2'}}} }, :object_type => 'foo', :target => '/bar/baz', :order => '10'} }

      it { is_expected.to contain_concat__fragment('bar')
        .with_content(/vars.foo\["bar"\] = \{\n\s+key1 = 4247\n\s+key2 = "value2"\n\s+\}\n/) }
    end


    context "#{os} with attrs => { foo => {{ unparsed string }} }" do
      let(:params) { {:attrs => { 'foo' => '{{ unparsed string }}' }, :object_type => 'foo', :target => '/bar/baz', :order => '10'} }

      it { is_expected.to contain_concat__fragment('bar')
        .with_content(/foo = \{{2} unparsed string \}{2}\n/) }
    end
  end
end

describe('icinga2::object', :type => :define) do
  let(:facts) { {
      :kernel => 'Windows',
      :architecture => 'x86_64',
      :osfamily => 'Windows',
      :operatingsystem => 'Windows',
      :operatingsystemmajrelease => '2012 R2',
      :path => 'C:\Program Files\Puppet Labs\Puppet\puppet\bin;
               C:\Program Files\Puppet Labs\Puppet\facter\bin;
               C:\Program Files\Puppet Labs\Puppet\hiera\bin;
               C:\Program Files\Puppet Labs\Puppet\mcollective\bin;
               C:\Program Files\Puppet Labs\Puppet\bin;
               C:\Program Files\Puppet Labs\Puppet\sys\ruby\bin;
               C:\Program Files\Puppet Labs\Puppet\sys\tools\bin;
               C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;
               C:\Windows\System32\WindowsPowerShell\v1.0\;
               C:\ProgramData\chocolatey\bin;',
  } }
  let(:title) { 'bar' }
  let(:pre_condition) { [
      "class { 'icinga2': }"
  ] }

  context "Windows 2012 R2 with all defaults and object_type => foo, target => C:/bar/baz, order => 10" do
    let(:params) { {:object_type => 'foo', :target => 'C:/bar/baz', :order => '10'} }

    it { is_expected.to contain_concat('C:/bar/baz') }

    it { is_expected.to contain_concat__fragment('bar')
      .with({'target' => 'C:/bar/baz', 'order' => '10'})
      .with_content(/object foo "bar"/)
      .without_content(/assign where/)
      .without_content(/ignore where/) }
  end


  context "Windows 2012 R2 with ensure => absent" do
    let(:params) { {:ensure => 'absent', :object_type => 'foo', :target => 'C:/bar/baz', :order => '10'} }

    it { is_expected.to contain_concat('C:/bar/baz') }

    it { is_expected.not_to contain_concat__fragment('bar') }
  end


  context "Windows 2012 R2 with ensure => foo (not a valid value)" do
    let(:params) { {:ensure => 'foo', :object_type => 'foo', :target => 'C:/bar/baz', :order => '10'} }

    it { is_expected.to raise_error(Puppet::Error, /foo isn't supported/) }
  end


  context "Windows 2012 R2 with target => bar/baz (not valid absolute path)" do
    let(:params) { {:object_type => 'foo', :target => 'bar/baz', :order => '10'} }

    it { is_expected.to raise_error(Puppet::Error, /"bar\/baz" is not an absolute path/) }
  end


  context "Windows 2012 R2 with template => true" do
    let(:params) { {:template => true, :object_type => 'foo', :target => 'C:/bar/baz', :order => '10'} }

    it { is_expected.to contain_concat__fragment('bar')
      .with_content(/template foo "bar"/) }
  end


  context "Windows 2012 R2 with template => false" do
    let(:params) { {:template => false, :object_type => 'foo', :target => 'C:/bar/baz', :order => '10'} }

    it { is_expected.to contain_concat__fragment('bar')
      .with_content(/object foo "bar"/) }
  end


  context "Windows 2012 R2 with template => foo (not a valid boolean)" do
    let(:params) { {:template => 'foo', :object_type => 'foo', :target => 'C:/bar/baz', :order => '10'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" is not a boolean/) }
  end


  context "Windows 2012 R2 with apply => true" do
    let(:params) { {:apply => true, :object_type => 'foo', :target => 'C:/bar/baz', :order => '10'} }

    it { is_expected.to contain_concat__fragment('bar')
                            .with_content(/apply foo "bar"/) }
  end


  context "Windows 2012 R2 with import => [bar, baz], apply => foo in host.vars.bar" do
    let(:params) { {:import => ['bar', 'baz'], :apply => 'foo in host.vars.bar', :apply_target => 'Host', :attrs => {'vars' => 'vars + foo'}, :object_type => 'foo', :target => 'C:/bar/baz', :order => '10'} }

    it { is_expected.to contain_concat__fragment('bar')
      .with_content(/import "bar"/)
      .with_content(/import "baz"/)
      .with_content(/vars = vars \+ foo\r\n/)
      .with_content(/apply foo for \(foo in host.vars.bar\) to Host/) }
  end


  context "Windows 2012 R2 with apply => foo => config in host.vars.bar" do
    let(:params) { {:apply => 'foo => config in host.vars.bar', :apply_target => 'Host', :attrs => {'vars' => 'vars + foo + config'}, :object_type => 'foo', :target => 'C:/bar/baz', :order => '10'} }

    it { is_expected.to contain_concat__fragment('bar')
      .with_content(/vars = vars \+ foo \+ config\r\n/)
      .with_content(/apply foo for \(foo => config in host.vars.bar\) to Host/) }
  end


  context "Windows 2012 R2 with apply => foo (not valid expression or boolean)" do
    let(:params) { {:apply => 'foo', :apply_target => 'Host', :object_type => 'foo', :target => 'C:/bar/baz', :order => '10'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" does not match/) }
  end


  context "Windows 2012 R2 with apply_target => 'foo' (not a valid value)" do
    let(:params) { {:apply_target => 'foo', :object_type => 'foo', :target => 'C:/bar/baz', :order => '10'} }

    it { is_expected.to raise_error(Puppet::Error, /foo isn't supported/) }
  end


  context "Windows 2012 R2 with apply_target => 'Service', object_tpye => 'Service' (same value)" do
    let(:params) { {:apply_target => 'Service', :object_type => 'Service', :target => 'C:/bar/baz', :order => '10'} }

    it { is_expected.to raise_error(Puppet::Error, /must be different/) }
  end


  context "Windows 2012 R2 with apply_target => 'Host', object_tpye => 'Service' (same value)" do
    let(:params) { {:apply => true,
                    :apply_target => 'Host',
                    :object_type => 'Service',
                    :target => 'C:/bar/baz',
                    :order => '10'} }

    it { is_expected.to contain_concat__fragment('bar')
                            .with_content(/apply Service "bar" to Host/) }
  end


  context "Windows 2012 R2 with import => [bar, baz]" do
    let(:params) { {:import => ['bar', 'baz'], :object_type => 'foo', :target => 'C:/bar/baz', :order => '10'} }

    it { is_expected.to contain_concat__fragment('bar')
      .with_content(/import "bar"/)
      .with_content(/import "baz"/) }
  end


  context "Windows 2012 R2 with import => foo (not a valid array)" do
    let(:params) { {:import => 'foo', :object_type => 'foo', :target => 'C:/bar/baz', :order => '10'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" is not an Array/) }
  end


  context "Windows 2012 R2 with assign => [ host.vars.os == bar && host.address, generic-host in host.templates]" do
    let(:params) { {:assign => ['host.vars.os == bar && host.address', 'generic-host in host.templates'], :object_type => 'foo', :target => 'C:/bar/baz', :order => '10'} }

    it { is_expected.to contain_concat__fragment('bar')
      .with_content(/assign where host.vars.os == "bar" && host.address/)
      .with_content(/assign where "generic-host" in host.templates/) }
  end


  context "Windows 2012 R2 with assign => foo (not a valid array)" do
    let(:params) { {:assign => 'foo', :object_type => 'foo', :target => 'C:/bar/baz', :order => '10'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" is not an Array/) }
  end


  context "Windows 2012 R2 with ignore => [ NodeName != baz || !host.display_name ]" do
    let(:params) { {:ignore => ['NodeName != baz || !host.display_name'], :object_type => 'foo', :target => 'C:/bar/baz', :order => '10'} }

    it { is_expected.to contain_concat__fragment('bar')
      .with_content(/ignore where NodeName != "baz" \|{2} !host.display_name/) }
  end


  context "Windows 2012 R2 with ignore => foo (not a valid array)" do
    let(:params) { {:ignore => 'foo', :object_type => 'foo', :target => 'C:/bar/baz', :order => '10'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" is not an Array/) }
  end


  context "Windows 2012 R2 with attrs => { vars => {key1 => 4247, key2 => value2} }" do
    let(:params) { {:attrs => { 'vars' => {'key1' => '4247', 'key2' => 'value2'} }, :object_type => 'foo', :target => 'C:/bar/baz', :order => '10'} }

    it { is_expected.to contain_concat__fragment('bar')
      .with_content(/vars.key1 = 4247\r\n/)
      .with_content(/vars.key2 = "value2"\r\n/) }
  end


  context "Windows 2012 R2 with attrs => { vars => {foo => {key1 => 4247, key2 => value2}} }" do
    let(:params) { {:attrs => { 'vars' => {'foo' => {'key1' => '4247', 'key2' => 'value2'}} }, :object_type => 'foo', :target => 'C:/bar/baz', :order => '10'} }

    it { is_expected.to contain_concat__fragment('bar')
      .with_content(/vars.foo\["key1"\] = 4247\r\n/)
      .with_content(/vars.foo\["key2"\] = "value2"\r\n/) }
  end


  context "Windows 2012 R2 with attrs => { vars => {foo => {bar => {key => 4247, key2 => value2}}} }" do
    let(:params) { {:attrs => { 'vars' => {'foo' => { 'bar' => {'key1' => '4247', 'key2' => 'value2'}}} }, :object_type => 'foo', :target => 'C:/bar/baz', :order => '10'} }

    it { is_expected.to contain_concat__fragment('bar')
      .with_content(/vars.foo\["bar"\] = \{\r\n\s+key1 = 4247\r\n\s+key2 = "value2"\r\n\s+\}\r\n/) }
  end


  context "Windows 2012 R2 with attrs => { foo => {{ unparsed string }} }" do
    let(:params) { {:attrs => { 'foo' => '{{ unparsed string }}' }, :object_type => 'foo', :target => 'C:/bar/baz', :order => '10'} }

    it { is_expected.to contain_concat__fragment('bar')
      .with_content(/foo = \{{2} unparsed string \}{2}\r\n/) }
  end
end
