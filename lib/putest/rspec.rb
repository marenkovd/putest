require 'bundler'
require 'rspec-puppet'

module Putest
  # Runs rakefile spec test
  #
  # IMPORTANT: Also runs rspec-puppet-init and bundle install in module directory. Takes a lot of time - so use bundle/gem cache
  # @param [String] moduledir module directory to validate
  # @return [Hash] Hash with test :result, :raw_data, :time, :examples, :failures
  def self.run_rake_spec(moduledir)
    currentTest =  {}
    currentTest[:result] == nil
    currentTest[:raw_data] = []
    started_at = Time.now

    Dir.chdir(moduledir)
    @logger.debug("In #{moduledir}: ")

    @logger.info('Running rspec-puppet-init')
    IO.popen('rspec-puppet-init',  :err=>[:child, :out]) do |io|
      tmp = io.readlines.map(&:chomp)
      currentTest[:raw_data] << tmp
      @logger.debug(tmp)
    end

    @logger.info('Running rake spec within bundle')
    Bundler.with_clean_env do
      IO.popen('bundle install --path vendor/bundle && bundle exec rake spec',
               :err=>[:child, :out]) do |io|
        tmp = io.readlines.map(&:chomp)
        currentTest[:raw_data] << tmp
        @logger.debug(tmp)
      end
      if $?.exitstatus != 0
        currentTest[:result] = :Fail
        @logger.error('Rake spec failure')
      end
    end

    @logger.info('Checking examples and failures')
    currentTest[:raw_data].select do | str |
      mtch = str.to_s.match('(\d+) examples, (\d+) failures')
      unless mtch.nil?
        currentTest[:examples] = mtch[1]
        logger.debug("Total/Failed:  #{mtch[1]}/#{mtch[2]}")
        currentTest[:failures] = mtch[2]
        break
      end
    end

    currentTest[:time] = (Time.now - started_at).round(2)
    currentTest[:result] = :Success if currentTest[:result] == nil
    return currentTest
  end
end