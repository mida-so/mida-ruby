require 'net/http'
require 'json'
require 'uri'

class Mida
  VERSION = '1.0.0'
  DEFAULT_OPEN_TIMEOUT = 5  # seconds
  DEFAULT_READ_TIMEOUT = 10 # seconds

  attr_reader :public_key, :host, :user_id, :enabled_features, :max_cache_size, :feature_flag_cache

  def initialize(public_key, options = {})
    raise ArgumentError, "You must pass your Mida project key" unless public_key

    @public_key = public_key
    @host = 'https://api.mida.so'
    @user_id = nil
    @enabled_features = []
    @max_cache_size = options[:max_cache_size] || 50000
    @feature_flag_cache = {}
    @open_timeout = options[:open_timeout] || DEFAULT_OPEN_TIMEOUT
    @read_timeout = options[:read_timeout] || DEFAULT_READ_TIMEOUT
  end

  def get_experiment(experiment_key, distinct_id = nil)
    raise ArgumentError, "You must pass your Mida experiment key" unless experiment_key
    raise ArgumentError, "You must pass your user distinct ID" unless distinct_id || @user_id

    data = {
      key: @public_key,
      experiment_key: experiment_key,
      distinct_id: distinct_id || @user_id
    }

    response = post_request("#{@host}/experiment/query", data)
    json = JSON.parse(response.body)
    json['version']
  end

  def set_event(event_name, distinct_id = nil, properties = {})
    raise ArgumentError, "You need to set an event name" unless event_name
    raise ArgumentError, "You must pass your user distinct ID" unless distinct_id || @user_id

    data = {
      key: @public_key,
      name: event_name,
      distinct_id: distinct_id || @user_id,
      properties: properties.to_json
    }

    post_request("#{@host}/experiment/event", data)
  end

  def set_attribute(distinct_id = nil, properties = {})
    raise ArgumentError, "You must pass your user distinct ID" unless distinct_id || @user_id
    raise ArgumentError, "You must pass your user properties" if properties.empty?

    data = properties.merge(id: distinct_id || @user_id)
    post_request("#{@host}/track/#{@public_key}", data)
  end

  # Flags are cached per user so one user's flags are never served to another.
  def cached_feature_flag(distinct_id = nil)
    @feature_flag_cache[feature_flag_cache_key(distinct_id)] || []
  end

  def feature_enabled?(key, distinct_id = nil)
    @enabled_features = cached_feature_flag(distinct_id)
    @enabled_features.include?(key)
  end

  def on_feature_flags(distinct_id = nil)
    reload_feature_flags(distinct_id)
    true
  end

  def reload_feature_flags(distinct_id = nil)
    data = {
      key: @public_key,
      user_id: distinct_id || @user_id
    }

    response = post_request("#{@host}/feature-flag", data)
    @enabled_features = JSON.parse(response.body)
    @feature_flag_cache[feature_flag_cache_key(distinct_id)] = @enabled_features

    if @feature_flag_cache.size > @max_cache_size
      @feature_flag_cache.shift
    end

    true
  end

  private

  def feature_flag_cache_key(distinct_id = nil)
    "#{@public_key}:#{distinct_id || @user_id}"
  end

  def post_request(url, data)
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = @open_timeout
    http.read_timeout = @read_timeout
    http.write_timeout = @read_timeout if http.respond_to?(:write_timeout=)
    request = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
    request['User-Agent'] = "mida-ruby/#{Mida::VERSION}"
    request.body = data.to_json

    response = http.request(request)
    raise StandardError, response.message unless response.is_a?(Net::HTTPSuccess)

    response
  end
end