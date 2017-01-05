$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require_relative './../lib/mushin'

require 'minitest/autorun'
require 'minitest/spec'
require 'minitest/pride'

# Set logging level to debug for testing
$log.level = Logger::DEBUG

require 'ssd'

module Sample

  class TBP < Mushin::Test::Sample::Ext; end
  class SSD < Mushin::Test::Sample::Ext; end

  class ExtA < Mushin::Test::Sample::Ext
    def initialize(ext, opts = {}, params= {})
      @ext 	= ext 
      @opts    	= opts 
      @params  	= params 
    end

    def call(env)
      env ||= Hash.new 
      env[:ExtA_params] 	= @params[:seeders]
      env[:ExtA_opts] 		= @opts[:ssd_path]
      @ext.call(env)
    end
  end

  class ExtB < Mushin::Test::Sample::Ext
    def initialize(ext, opts = {}, params= {})
      @ext 	= ext 
      @opts    	= opts 
      @params  	= params 
    end

    def call(env)
      env ||= Hash.new 
      p "XXXXXXXXX #{self}, params: #{@params}  opts: #{@opts} XXXXXXXXXXXXXX"

      env[:ExtB_opts] 		= @opts[:ssd_path]
      env[:ExtB_params] 	= @params[:seeders]
      @ext.call(env)
    end
  end

  class RUTracker < Mushin::Test::Sample::Ext 
  end
  class Mongodb < Mushin::Test::Sample::Ext; end

  class TPBBotA < Mushin::Test::Sample::Ext; 
    def call(env)
      # create event only if needed
      #Mushin::ES::Event.new do 
      #  id = nil
      #  timestamp = nil
      #  version  = nil
      #  type = nil
      #  title = nil
      #  data = nil
      #end

      super

      # create event only if needed
      #Mushin::ES::Event.new do 
      #  id = nil
      #  timestamp = nil
      #  version  = nil
      #  type = nil
      #  title = nil
      #  data = nil
      ##end
    end
  end

  class TPBBotB < Mushin::Test::Sample::Ext; end

  class RUTrackerBotA < Mushin::Test::Sample::Ext; end
  class RUTrackerBotB < Mushin::Test::Sample::Ext; end

end
