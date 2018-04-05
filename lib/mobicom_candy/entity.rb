module MobicomCandy
  class Entity
    def initialize(**kwargs)
      @attributes = kwargs
    end

    def []=(key, value)
      name = self.class.attribute_names[key]

      @attributes[name] = value
    end

    def respond_to_missing?(name, include_private = false)
      @attributes.key?(name) || super
    end

    def method_missing(name, *args)
      return super unless @attributes.key?(name)

      @attributes[name]
    end

    def ==(other)
      other.class == self.class && other.attributes == @attributes
    end

    def to_h
      @attributes
    end

    def to_json(*a)
      @attributes.to_json(*a)
    end

    attr_reader :attributes

    protected :attributes

    def self.attribute_names
      @attribute_names ||= Hash.new do |hash, key|
        hash[key] = attribute_name(key)
      end
    end

    def self.attribute_name(key)
      return key if key.is_a?(Symbol)

      key.split(PATTERN).join(UNDERSCORE).downcase.to_sym
    end

    PATTERN = /[\-_]|(?<=\w)(?=[A-Z])/

    UNDERSCORE = '_'.freeze
  end
end