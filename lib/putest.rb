require 'logger'
require 'active_support/core_ext/hash/deep_merge'

require 'putest/runners'
require 'putest/version'
require 'putest/rspec'
require 'putest/validate'

#Test puppet modules with dynamic environments
#
# Test data hash format:
#
#   {
#     :result => :Fail or :Success,
#     :time => duration in seconds,
#     :examples => number of subtests,
#     :failures => number of failed subtests,
#     ..
#   }
#
#Aggregated results are nested hashes per environment/module with test data
#
module Putest
  @logger=Logger.new(STDOUT)
  @logger.level = Logger::INFO

  #Module logger accessor
  def self.logger
    @logger
  end

  #Set debug logger level
  def self.setverbose
    @logger.level = Logger::DEBUG
  end


  # Analyze and report test results
  #
  # @param [Hash] result Nested hash with test data
  #
  # @return [Boolean] false on failed tests
  #
  def self.report(result)
    is_ok = true
    @logger.warn('Failed tests:')
    result.each_pair do |env, modules|
      modules.each_pair do |mod, tests|
        tests.each_pair do |name, res|
          if res[:result] == :Fail
            is_ok = false
            @logger.warn("  #{env}-#{mod}-#{name}:")
            res.each { |log| @logger.warn(log) }
          end
        end
      end
    end
    @logger.warn('Summary:')
    result.each_pair do |env, modules|
      @logger.warn("  Environment: #{env}")
      modules.each_pair do |mod, tests|
        @logger.warn("    Module: #{mod}")
        tests.each_pair do |name, res|
          @logger.warn("      #{name}: #{res[:result]} | #{res[:time]} sec | #{res[:examples]}/#{res[:failures]}")
        end
      end
    end
    return is_ok
  end


  # Main method for running test
  #
  # @param [String] modpath module-dir path
  # @param [String] env environment name
  # @param [String] puppetmod module name

  # @return [Boolean] false on failed tests
  #

  def self.run_test(modpath, env, puppetmod)
    result = {}
    if puppetmod == nil
      if env == nil
        @logger.debug('Testing all modules in all environments')
        result.deep_merge!  self.run_env_all(modpath)
      else
        @logger.debug("Testing all modules in #{env}")
        result.deep_merge! self.run_env(modpath, env)
      end
    else
      if env == nil
        @logger.debug("Testing #{puppetmod} in all environments")
        result.deep_merge! self.run_module_all(modpath, puppetmod)
      else
        @logger.debug("Testing #{puppetmod} in #{env}")
        result.deep_merge! self.run_module(modpath, env, puppetmod)
      end
    end
    return self.report(result)
  end
end
