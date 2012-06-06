require 'rubygems'
require 'rest_client'
require 'json'
require 'cookie_jar'

class RequestHelper
  include CookieJar

  def initialize(conf)
    @server = conf[:server] || "localhost"
    @username = conf[:username]
    @password = conf[:password]
    @cookies = get_cookies
  end

  def create_vm(options)
    options = options.dup
    update_owner_field(options)
    handle_multi_instances(options)
    handle_custom_request(options)
    handle_location_specs(options)

    begin
      response = RestClient.post("http://#{@server}/vm",
                                 {:vm_request => options},
                                 {:cookies => @cookies, :content_type => 'application/json', :accept => :json})
      result = JSON.parse(response)
      if options[:json]
        puts JSON.pretty_generate(result)
      else
        puts result['message']
      end
    rescue => e
      puts e.inspect
    end
  end

  def perform_action(options)
    action = options['action']
    hosts = options['hosts'] 
    begin
      response = RestClient.post("http://#{@server}/vm/#{action}",
                                 {:id => hosts.first},
                                 {:cookies => @cookies, :content_type => 'application/json', :accept => :json})
      result = JSON.parse(response)
      if options[:json]
        puts JSON.pretty_generate(result)
      else
        puts result['message']
      end
    rescue => e
      puts e.inspect
    end
  end

  private
  def update_owner_field(options)
    if options['owners']
      options['primary_user'] = options['owners'].shift
      options['secondary_user'] = options['owners']
      options.delete('owners')
    else
      options['primary_user'] = @username
    end
  end

  def handle_multi_instances(options)
    if options['instances']
      options['multi_instances'] = true
      options['multi_instances_spec_attributes[optimal_spread]'] = options['optimal_spread']
      options['multi_instances_spec_attributes[minimal_spread]'] = options['minimal_spread']
      options['multi_instances_spec_attributes[num_instances]'] = options['instances']
      options['multi_instances_spec_attributes[start_at]'] = options['start_at']
    end

    options.delete('optimal_spread')
    options.delete('minimal_spread')
    options.delete('start_at')
    options.delete('instances')
  end

  def handle_custom_request(options)
    options['processor_count'] = options.delete('cpu')
  end

  def handle_location_specs(options)
    location_specs = options.delete('location_specs')
    return unless location_specs

    location_specs.each_with_index do |location_spec, index|
      tokens = location_spec.split(':')
      raise "Invalid location specs" if tokens.size != 3
      if tokens[0] != "include" and tokens[0] != "exclude"
        raise "Invalid location specs - modifier must be #{include} or #{exclude} but it's #{tokens[0]} instead" 
      end
      raise "Invalid location specs" unless ['node', 'chassis', 'rack'].include? tokens[1]
      
      options["location_specs_attributes[#{index}][modifier]"] = tokens[0]
      options["location_specs_attributes[#{index}][loc_type]"] = tokens[1]
      options["location_specs_attributes[#{index}][value]"] = tokens[2]
    end
  end
end
