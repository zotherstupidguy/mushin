require_relative 'spec_helper'

describe "domain" do
  # Runs codes before each expectation
  describe 'domain object' do
    before do
      $log.level = Logger::WARN
      $log.level = Logger::INFO

      @domainklass = Class.new do

	using Mushin::Domain

	context "torrent_bots" do
	  construct "tpb" do
	    use ext: Sample::TPBBotA, params: {"tpbbot_a__param1" => :search_result_max} #, opts: {"botA_opts1"=> :shit}
	    use ext: Sample::TPBBotB, params: {"tpbbot_b__param1" => :search_result_max} #, opts: {"botA_opts1"=> :shit}
	  end

	  construct 'rutracker' do
	    use ext: Sample::RUTrackerBotA, params: {"rutrackerbot_a_params1" => :search_result_max}
	    use ext: Sample::RUTrackerBotB, params: {"rutrackerbot_b_params1" => :search_result_max}
	  end

	end

	context 'query' do
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
    end

    it "is initialized with a block that includes the nexted functions defined in its domainklass" do
      @domainObj = @domainklass.new do 
	self.methods.must_include :torrent_bots
	torrent_bots do
	  self.methods.must_include :tpb
	end
      end
    end

    it "carrys out CQRS Command" do
      @domainObj = @domainklass.new do 
	torrent_bots do
	  tpb search_result_max: "20", storage_path:"x/y/z"
	  rutracker search_result_max: "20", storage_path:"x/y/z"
	end
      end
    end


    it "carrys out CQRS Query" do
      @domainObj = @domainklass.new do 
	query do

	end
      end
      @domainObj.store.must_be_kind_of Hash
      #TODO actually store thing in a real db
    end

    # Runs code after each expectation
    after do
      @appdomain = nil 
    end
  end

end
