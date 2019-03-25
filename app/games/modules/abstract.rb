module Abstract
  def need_override(*methods)
    methods.each do |method|
      define_method(method) do |*_args|
        raise NotImplementedError.new("#{self.class}##{__method__} must be implemented")
      end
    end
  end

  def self_need_override(*methods)
    methods.each do |method|
      define_singleton_method(method) do |*_args|
        raise NotImplementedError.new("#{self}#self.#{__method__} must be implemented")
      end
    end
  end
end
