module Mushin
  # 1- an access method :context is defined in DSLBuilder(thats a module avialable as class methods to the domain class of the application.
  # 2- the :context takes a name, &block and pass instance_eval it aganist an object created from DSLBuilder::Context
  # 3- DSLBuilder::Context initialize takes a context_name say "torrent_bots" and create an app_context_klass and creates an access method with the :context_name inside DSL 
  #
  module DSLBuilder
    class Context
      attr_accessor :context_name
      # defines a DSL::Klass of type Context based on :name
      # Supplies the defined DSL::Klass with a method of the construct
      def initialize context_name, &block
	@context_name = context_name.capitalize

	app_context_klass = Class.new(Object) do
	  def initialize &block
	    instance_eval &block
	  end
	end
	# creates a context klass dynamically
	DSL.const_set(context_name.capitalize, app_context_klass) unless DSL.const_defined?(context_name.capitalize)
	# creates an access method inside DSL for the dynamically created context klass
	DSL.send(:define_method, context_name) do |&block|
	  DSL.const_get(context_name.capitalize).new &block unless context_name.nil?
	end

	instance_eval &block
      end

      # access method for DSLBuilder::Construct klass inside a context object &block
      def construct name, &block
	app_context_klass = DSL.const_get(@context_name)
	Construct.new(name, app_context_klass, &block) #.instance_eval &block
      end
    end

    class Construct
      attr_accessor :name, :stack, :app_context_klass
      def initialize name, app_context_klass, &block
	@name 	= name.capitalize
	@middlewares = []
	@stack 	= Mushin::Stack.new
	@app_context_klass = app_context_klass

	instance_eval &block
	$log.info "middlewares after instance_eval"
	$log.info  middlewares = @middlewares

	app_construct_klass = Class.new(Object) do
	  @@stack = Mushin::Stack.new
	  @@env = {}
	  @@ext_set = middlewares
	  $log.info "@@ext_set"
	  $log.info @@ext_set

	  attr_accessor :env
	  def initialize env = {}
	    @env = env
	    #p "merging #{@@env} with #{env_updates} for the result of #{env_updates.merge @@env}"
	    #p "domaindsl construct is ready to activate calling the stack with #{env}"
	  end
	end # end of app_construct_klass 

	DSL.const_set(name.capitalize, app_construct_klass) unless DSL.const_defined?(name.capitalize)
	# Reopens most recent context klass and add method `def construct_name params; app_construct_class.new(params)`
	# access method for DSL::Construct dynamic klass inside a context object &block
	DSL.const_get(@app_context_klass.to_s).send(:define_method, name) do |env|
	  # 1. populate :symbols inside opts and params with values from env
	  @@ext_set.each do |ext|
	    ext[:params].each do |key, value|
	      env.each do |env_key, env_value|
		if env_key.to_sym == value then
		  ext[:params][key] = env_value
		end
	      end
	    end

	    ext[:opts].each do |key, value|
	      env.each do |env_key, env_value|
		if env_key.to_sym == value then
		  ext[:opts][key] = env_value
		end
	      end
	    end
	    $log.info ext 
	  end
	  # 2. insert 
	  @@ext_set.each do |ext|
	    @@stack.insert_before 0, ext[:ext], ext[:opts], ext[:params]
	  end
	  # 3. call the stack
	  @@stack.call

	  DSL.const_get(name.capitalize).new env
	end
	#p DSL.constants
      end

      def use ext:, opts: {}, params: {}
	@middlewares << {:ext => ext, :opts => opts, :params => params}
	#p @middlewares
	#	@stack.insert_before 0, ext, opts, params
	#@stack.call
	#@stack = Use.new(ext, opts, params, @stack)
      end
    end

    def context name, &block
      Context.new(name, &block) #.instance_eval &block
    end
  end

  module DSL
  end
end

#self.singleton_class.send :remove_method, construct_key.to_sym
#self.singleton_class.send :remove_method, context_key.to_sym
#self.singleton_class.send :undef, context_key.to_sym
#


# tree is a set
# each context is a set
# each construct is a hash where construct_name is key, and [ext, params, opts] are array
#tree = [{:torrent_bots => [{:tpb => [["TPB", "params hash", "opts hash"], ["SSD", "params hash", "opts hash"]}]


=begin
  module DSL
    refine Class do
    end
  end

	    if  Mushin::DSL.const_defined? @context_keyword.capitalize then
	      Mushin::DSL.const_set "#{@context_keyword.capitalize}", Module.new do 
		send :define_method, :build_dsl do |dsl_tree= @dsl_tree, &block|
		  p "passed the tree to the dsl_module #{dsl_tree}"
		  #p dsl_tree
		end
	      end
	    else
	      p "prepend the module here"
	    end

=end
=begin
module DSL
    def self.included base
      base.class_eval do
	#attr_accessor :keyword_array 
	def initialize &block
	  #@keyword_array = []
	  instance_eval &block
	end
      end
      minis.each do |m| 
	p m
	p m
	p m
	p m
	base.send :include, m
      end
    end

    def self.minis
      constants.collect {|const_name| const_get(const_name)}.select {|const| const.class == Module}
    end
    end
=end

#NOTE can be Module.new("Mushin::DSL" + context_keyword.capitalize) to differeniate the minidsls dynamically added to an object in testing
#dsl_module = Module.new(Mushin::DSL) do 
#end
#p context_keyword = @context_keyword 
#p construct_keyword = @construct_keyword 

=begin
def self.included base
  base.class_eval do
    attr_accessor :keyword_array 
    def initialize &block
      @keyword_array = []
      instance_eval &block
    end
  end
end
=end

=begin
	      #define_method construct_keyword do |&block|
	      #self.extend dsl
	      #	instance_eval &block
	      #      end

	      dsl.send :define_method, construct_keyword do |&block|
		p "inside the instance construct #{self}"
		p self
		p self
	      end

	      define_method context_keyword do |&block|
		p "inside the instance context #{self} with context_keyword #{context_keyword}"
		instance_eval &block # self is the dsl module
	      end
=end

#dsl.send :define_method, @context_keyword do |&block|
#  p self
#  instance_eval &block
#end

#dsl.send 
#self.class.send :define_method, @construct_keyword do |&block|
#  instance_eval &block
#end

# alias_method + refinment + dynamically created module that is included(maybe that wouldn't be passed)
=begin
  module DSL
    def self.included base
      base.class_eval do
	def initialize &block
	  instance_eval &block
	end
      end
    end
  end
=end
#define_method @context_keyword do |&block|
#self.send :include, Mushin::DSL #self.send :prepend, Mushin::DSL
=begin
Mushin::DSL.send :define_method, @context_keyword do |&block|
	    p "inside the domain obj"
	    #self.class.send :define_method, construct_keyword do |&block|
	    #end
	    p self 
	    p construct_keyword
	    p "....."
	    instance_eval &block
	  end
=end
#p "context #{@context_keyword} is defined in Mushin::DSL"
#Mushin::DSL.send :remove_method, @context_keyword 
# Foo.instance_eval { undef :color }
# removed_method removes method of receiver class where as undef_method removed all methods from inherited class including receiver class. 
#base.send :prepend, DSL
