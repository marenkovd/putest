module Putest
  # Validates file format with specific command
  #
  # @param [String] moduledir module directory to validate
  # @param [String] wildcard filename wildcard to validate
  # @param [String] command validation command path
  # @param [String] marker substituion marker for filename
  # @return [Hash] Hash with test :result, :raw_data, :time, :examples, :failures

  def self.validate_smth(moduledir, wildcard, command, marker='$ARG$')
    currentTest =  {}
    currentTest[:result] == nil
    currentTest[:raw_data] = []
    currentTest[:examples] = 0
    currentTest[:failures] = 0
    started_at = Time.now

    Dir.chdir(moduledir)
    @logger.debug("In #{moduledir}: ")

    @logger.info("Running validation for | #{wildcard} | with | #{command} | where marker is #{marker}" )

    Dir[wildcard].each do |file|
      currentTest[:examples] += 1

      IO.popen(command.sub(marker, file),  :err=>[:child, :out]) do |io|
        tmp = io.readlines.map(&:chomp)
        currentTest[:raw_data] << tmp
        @logger.debug(tmp)
      end

      if $?.exitstatus != 0
        currentTest[:failures] += 1
        currentTest[:result] = :Fail if currentTest[:result] == nil
        @logger.error("#{file} : FAIL")
      else
        @logger.debug("#{file} : OK")
      end
    end

    currentTest[:result] = :Success if currentTest[:result] == nil
    currentTest[:time] = (Time.now - started_at).round(2)
    return currentTest
  end
end
