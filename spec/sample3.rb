require_relative './../lib/mushin'

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
      p "XXXXXXXXX #{self}, params: #{@params}  opts: #{@opts} XXXXXXXXXXXXXX"

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

  class Domain
   include Mushin::Domain
    #extend Mushin::Domain
    using Mushin::Domain
    #extend Mushin::Main

    context "torrent_bots" do
      construct "tpb" do
	use ext: Sample::TBP, params: {}, opts: {"search_results" => :search_result_max}
	use ext: Sample::SSD, params: {}, opts: {"ssd_path"=> :storage_path}
      end

      construct "rutracker" do
	use ext: RUTracker, params: {}, opts: {"search_results" => :search_result_max}
      end
    end

    context "query" do
      construct 'torrentsA' do
	use ext: Sample::ExtA, params: {:seeders => :seeders_valueA}, opts: {:ssd_path => :path_valueA}
	use ext: Sample::ExtB, params: {:seeders => :seeders_valueB}, opts: {:ssd_path => :path_valueB, :extra_default_key => :extra_default_value}
      end
      construct 'torrentsB' do
	use ext: Sample::ExtA, params: {:seeders => :seeders_valueA}, opts: {:ssd_path => :path_valueA}
	use ext: Sample::ExtB, params: {:seeders => :seeders_valueB}, opts: {:ssd_path => :path_valueB}
      end
    end
  end

  class App
    mydomain = Domain.new do
      params = {}
      params[:secret] = "8888"

      torrent_bots do
	tpb search_result_max: "20", storage_path:"crazypath_here", store: "ssd"
	rutracker search_result_max: params[:secret]
      end

      query do
	torrentsA  path_valueA: "this is a torrentsA pathvalueA", seeders_valueA: "30torrentA", path_valueB: "this is torrentsA pathvalueB", seeders_valueB: "30torrentB"
	torrentsB  path_valueA: "this is a torrentsB pathvalue", path_valueB: "koko", seeders_valueA: "30torrentA", seeders_valueB: "anna"
	#torrentsB keyword: "torrentsB nononononon", seeders: "30"
      end

      #=begin 
      #TODO it 'must only accepts things for that had been defined'
      #ss do
      #end
      #torrent_bots do
      #TODO it 'must only accepts things for that had been defined'
      #stpb do
      #end
      #tpb "this is good"
      #  tpb search_result_max: "202", storage_path:"crazypath_here2"
      #end

      #TODO it 'should be nested correctly"
      #tpb "this is should be nested and shouldn't be allowed to work"

      #ztorrent_bots do
      #  zrutracker search_result_max: params[:secret2]
      #  #zxy "god"
      #end
      #=end
    end
    #p "inspecting the domain object"
    #p mydomain.methods
    #p mydomain.inspect
    #p mydomain.instance_variable_get("@xyz")
    #p mydomain.store[:love]
    #p mydomain.store[:xyz]
    #p mydomain.store[:torrentsB][:nana]
    #p mydomain.store[:torrentsC]
    #p mydomain.store[:torrentsB]
    p mydomain.store
  end
end
