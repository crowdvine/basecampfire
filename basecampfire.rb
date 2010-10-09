#!/usr/bin/env ruby
require 'rubygems'
require 'simple-rss'
require 'open-uri'
require 'tinder'
require 'yaml'
require 'ruby-debug'

class Basecampfire
  
  attr_accessor :config, :basecamp, :campfire, :campfire_room, :guid_cache
  
  class GuidCache
    
    attr_accessor :filename, :guids
    
    def initialize(filename)
      self.filename = File.dirname(__FILE__) + '/' + filename
      load_existing_file or initialize_guids
    end
    
    def load_existing_file
      return false unless File.exist?(filename)
      self.guids = YAML.load File.open(filename)
    end
    
    def initialize_guids
      self.guids = []
    end
    
    def write_back_to_file
      File.open(filename, 'w') { |f| YAML.dump(guids, f) }
    end
    
    def <<(guid)
      self.guids << guid unless seen?(guid)
    end
    alias_method :add!, :<<
    
    def seen?(guid)
      guids.include?(guid)
    end
    
  end

  def self.go!
    new
  end

  def initialize(config_file = nil)
    config_file ||= File.dirname(__FILE__) + '/config.yml'
    read_config config_file
    initialize_cache
    login_campfire
    fetch_basecamp_feed
    walk_items
    write_cache
  end
  
  def read_config(config_file)
    self.config = YAML.load File.open(config_file)
  end
  
  def initialize_cache
    self.guid_cache = GuidCache.new(config['cache_file'])
  end
  
  def fetch_basecamp_feed
    self.basecamp = SimpleRSS.parse open(config['basecamp']['rss_uri'], :http_basic_authentication => [ config['basecamp']['token'], "x" ])
  end
  
  def login_campfire
    campfire = Tinder::Campfire.new config['campfire']['domain'], :token => config['campfire']['token'] 
    campfire.login config['campfire']['token'], 'x'
    self.campfire_room = campfire.find_room_by_name config['campfire']['room']
  end
  
  def walk_items
    basecamp.items.each do |item|
puts item.title
    #  next unless item.title.match(/Todo completed/)
      next if guid_cache.seen?(item.title)
      announce item
    end
  end
  
  def announce(item)
    project = "GENERAL"
    if item.description.match(/Project: (.*?) \|/)
      project = "#{$1}"
    end
    campfire_room.speak "[#{project}] #{item.title} - #{item.dc_creator} (#{item.link})"
    guid_cache.add! item.title
  end
  
  def write_cache
    guid_cache.write_back_to_file
  end
  
end

Basecampfire.go!
