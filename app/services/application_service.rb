class ApplicationService
  def self.call(*args, **options)
    new(*args, **options).call
  end

  private_class_method :new
end
