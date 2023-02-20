class ConfigStruct < OpenStruct

  def configure(namespace = nil)
    if namespace.nil?
      yield self
    else
      self.send("#{namespace}=", OpenStruct.new)
      yield self.send(namespace)
    end
  end

end
