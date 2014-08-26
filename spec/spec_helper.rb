if RUBY_VERSION > '1.8.7'
  require 'simplecov'
  SimpleCov.start do
    add_filter "/spec/"
  end
end

require 'puppetlabs_spec_helper/module_spec_helper'
