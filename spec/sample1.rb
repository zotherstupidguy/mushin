#require 'mushin'
require_relative './../lib/mushin'
#$log.level = Logger::WARN
module Sample

  class TBP < Mushin::Test::Sample::Ext; end
  class SSD < Mushin::Test::Sample::Ext; end
  class SSDS < Mushin::Test::Sample::Ext
    def call(env)
      env ||= Hash.new 
      env[:shit] = "coool"
      super
      env[:superman_real_nameA] = "fouad"
      return env
    end
  end

  class SSDA < Mushin::Test::Sample::Ext
    def call(env)
      env ||= Hash.new 
      env[:nana] = "nana_what"
      super
      env[:superman_real_nameB] = "where are you now"
      return env
    end
  end


  class RUTracker < Mushin::Test::Sample::Ext; end
  class Mongodb < Mushin::Test::Sample::Ext; end


  class Domain < Mushin::Domain
    # execution model 
    context 'torrent_bots' do 
      construct 'tpb' do
	use ext: Sample::TBP, params: {}, opts: {"search_results" => :search_result_max}
	use ext: Sample::SSD, params: {}, opts: {"ssd_path"=> :storage_path}
	use ext: Sample::SSD, params: {}, opts: {"ssd_path"=> :storage_path}
	use ext: Sample::SSD, params: {}, opts: {"ssd_path"=> :storage_path}
      end
      construct 'rutracker' do
	use ext: Sample::RUTracker, params: {"search_results" => :search_result_max}
	use ext: Sample::Mongodb, params: {"search_results" => :search_result_max}
      end
    end

    # query model 
    query do
      construct 'torrents' do
	use ext: Sample::SSDS, params: {"seeders" => :seeders}, opts: {"ssd_path"=> :keyword}
	use ext: Sample::SSDA, params: {"seeders" => :seeders}, opts: {"ssd_path"=> :keyword}
      end

      construct 'torrentsB' do
	use ext: Sample::SSDS, params: {"seeders" => :seeders}, opts: {"ssd_path"=> :keyword}
	use ext: Sample::SSDA, params: {"seeders" => :seeders}, opts: {"ssd_path"=> :keyword}
      end

    end
  end

  class App
    def initialize
      params = {}
      params[:secret] = "8888"

      domain = Domain.new do
	torrent_bots do
	  tpb search_result_max: "20", storage_path:"crazypath_here"
	  rutracker search_result_max: params[:secret]
	end

	query do 
	  torrents keyword: "shit", seeders: "30"
	  torrentsB keyword: "nononononon", seeders: "30"
	end

      end

      p "kil"
      p domain.torrents 
      p "ok this is the value that i want #{domain.torrentsB}"
      p "kil"

      #return domain.query :some_key # query somthing specific from the virtual domain datastore
      return domain.store # returns the whole virtual domain datastore
    end
  end
end

Sample::App.new
