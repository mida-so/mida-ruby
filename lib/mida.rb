require 'json'
require 'net/http'
require 'uri'

class Mida
  attr_reader :public_key, :host, :user_id, :enabled_features

  def initialize(public_key, options = {})
    raise ArgumentError, "You must pass your Mida project key" unless public_key

    @public_key = public_key
    @host = 'https://api.mida.so'
    @user_id = nil
    @enabled_features = []
    @max_cache_size = options[:max_cache_size] || 50000
    @feature_flag_cache = {}
  end

  def get_experiment(experiment_key, distinct_id)
    raise ArgumentError, "You must pass your Mida experiment key" unless experiment_key
    raise ArgumentError, "You must pass your user distinct ID" unless distinct_id || @user_id

    data = {
      key: @public_key,
      experiment_key: experiment_key,
      distinct_id: distinct_id || @user_id
    }

    headers = { 'Content-Type' => 'application/json' }
    headers['User-Agent'] = "mida-ruby/#{Mida::VERSION}" unless defined?(Rails)

    uri = URI("#{@host}/experiment/query")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.path, headers)
    request.body = data.to_json

    response = http.request(request)

    if response.is_a?(Net::HTTPSuccess)
      json = JSON.parse(response.body)
      json['version']
    else
      raise "HTTP Request failed: #{response.code} #{response.message}"
    end
  end

  def set_event(event_name, distinct_id, properties = {})
    raise ArgumentError, "You need to set an event name" unless event_name
    raise ArgumentError, "You must pass your user distinct ID" unless distinct_id || @user_id

    data = {
      key: @public_key,
      name: event_name,
      distinct_id: distinct_id || @user_id,
      properties: properties.to_json
    }

    headers = { 'Content-Type' => 'application/json' }
    headers['User-Agent'] = "mida-ruby/#{Mida::VERSION}" unless defined?(Rails)

    uri = URI("#{@host}/experiment/event")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.path, headers)
    request.body = data.to_json

    response = http.request(request)

    raise "HTTP Request failed: #{response.code} #{response.message}" unless response.is_a?(Net::HTTPSuccess)
  end

  def set_attribute(distinct_id, properties = {})
    raise ArgumentError, "You must pass your user distinct ID" unless distinct_id || @user_id
    raise ArgumentError, "You must pass your user properties" unless properties.is_a?(Hash)

    data = properties.merge(id: distinct_id || @user_id)

    headers = { 'Content-Type' => 'application/json' }
    headers['User-Agent'] = "mida-ruby/#{Mida::VERSION}" unless defined?(Rails)

    uri = URI("#{@host}/track/#{@public_key}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.path, headers)
    request.body = data.to_json

    response = http.request(request)

    raise "HTTP Request failed: #{response.code} #{response.message}" unless response.is_a?(Net::HTTPSuccess)
  end

  def cached_feature_flag
    cache_key = "#{@public_key}:#{@user_id}"
    @feature_flag_cache[cache_key] || []
  end

  def feature_enabled?(key)
    @enabled_features = cached_feature_flag
    @enabled_features.include?(key)
  end

  def on_feature_flags(distinct_id = nil)
    cached_items = cached_feature_flag.size
    reload_feature_flags(distinct_id)
    true
  end

  def reload_feature_flags(distinct_id = nil)
    data = {
      key: @public_key,
      user_id: distinct_id
    }

    headers = { 'Content-Type' => 'application/json' }
    headers['User-Agent'] = "mida-ruby/#{Mida::VERSION}" unless defined?(Rails)

    uri = URI("#{@host}/feature-flag")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.path, headers)
    request.body = data.to_json

    response = http.request(request)

    if response.is_a?(Net::HTTPSuccess)
      @enabled_features = JSON.parse(response.body)
      cache_key = "#{@public_key}:#{@user_id}"
      @feature_flag_cache[cache_key] = @enabled_features

      if @feature_flag_cache.size > @max_cache_size
        @feature_flag_cache.shift
      end
    else
      raise "HTTP Request failed: #{response.code} #{response.message}"
    end
  end
end