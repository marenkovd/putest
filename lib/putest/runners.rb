module Putest
  # Runs tests for specific module
  #
  # IMPORTANT: Also runs rspec-puppet-init and bundle install in module directory
  # IMPORTANT: Also populates rspec fixtures from modules installed in the same environment
  # @param [String] modpath modules_dir path
  # @param [String] env environment name
  # @param [String] mod module name
  # @return [Hash] Nested hash with test data
  #   as follows
  #     result = {}
  #     result[env] = {}
  #     result[env][mod] = Test Data
  def self.run_module(modpath, env, mod)

    result = {}
    result[env] = {}
    result[env][mod] = {}

    moduleres = result[env][mod]
    moduledir = "#{modpath}/#{env}/modules/#{mod}"
    unless Dir.exist?(moduledir)
      @logger.warn("No module #{mod} in #{env}")
      return result
    end
    Dir.chdir(moduledir)
    @logger.debug("In #{moduledir}: ")

    @logger.debug('Running validation scripts')

    moduleres[:validateManifests] = validate_smth(moduledir, 'manifests/**/*.pp', 'puppet parser validate --noop $ARG$')
    moduleres[:validateRuby] = validate_smth(moduledir, 'lib/**/*.rb', 'ruby -c $ARG$')
    moduleres[:validateTemplate] = validate_smth(moduledir, 'templates/**/*.erb', "erb -P -x -T '-' $ARG$ | ruby -c")

    if File.exists?('Gemfile') and File.exists?('Rakefile')
      @logger.debug('Gemfile and Rakefile found. Running rspec tests')
      if File.exists?('Gemfile.lock')
        @logger.info('Deleteing Gemfile.lock')
        File.delete('Gemfile.lock')
      end
      @logger.info('Populate puppet fixtures before raking')
      Dir["#{modpath}/#{env}/modules/*"].each do |depmod|
        fixture = "#{moduledir}/spec/fixtures/modules/#{File.basename(depmod)}"
        logger.debug("#{depmod} -> #{fixture}")
        unless Dir.exist?(fixture)
          FileUtils.mkpath("#{moduledir}/spec/fixtures/modules") unless Dir.exist?("#{moduledir}/spec/fixtures/modules")
          File.symlink(depmod, fixture)
        end
      end
      moduleres[:rakeSpec] = run_rake_spec(moduledir)
    else
      @logger.warn('No Gemfile or Rakefile found')
    end
    return result

  end

  # Runs tests for specific environment
  #
  # Basically deep-merges results of {run_module}
  # @param [String] path modules_dir path
  # @param [String] env environment name
  #
  # @return [Hash] Nested hash with test data
  #   as follows
  #     result = {}
  #     result[env] = {}
  #     result[env][mod] = Test Data
  def self.run_env(path, env)
    result = {}
    @logger.info("Current environment: #{env}")
    modulepath = path + '/' + env + '/modules/*'
    @logger.info("Searching for modules in #{modulepath}")
    Dir.glob(modulepath).each do |puppetmodule|
      currentModule = File.basename(puppetmodule)
      @logger.info("Find module: #{currentModule}")
      result.deep_merge! self.run_module(path, env, currentModule)
    end
    return result
  end

  # Runs tests for all environments
  #
  # Basically deep-merges results of {run_env}
  # @param [String] modpath modules_dir path
  #
  # @return [Hash] Nested hash with test data
  #   as follows
  #     result = {}
  #     result[env] = {}
  #     result[env][mod] = Test Data
  def self.run_env_all(modpath)
    result = {}
    Dir.glob(modpath + "/*").each do |env|
      currentEnv = File.basename(env)
      @logger.info("Find env: #{currentEnv}")
      result.deep_merge! self.run_env(modpath, currentEnv)
    end
    return result

  end

  # Runs tests for all environments
  #
  # Basically deep-merges results of {run_module}
  # @param [String] modpath modules_dir path
  # @param [String] puppetmod module name
  #
  # @return [Hash] Nested hash with test data
  #   as follows
  #     result = {}
  #     result[env] = {}
  #     result[env][mod] = Test Data
  def self.run_module_all(modpath, puppetmod)
    result = {}
    @logger.info("Testing module #{puppetmod} in all environments")
    Dir.glob(modpath + "/*").each do |env|
      currentEnv = File.basename(env)
      @logger.info("Find env: #{currentEnv}")
      result.deep_merge! self.run_module(modpath, currentEnv, puppetmod)
    end
    return result
  end
end