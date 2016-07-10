require 'rails'
require 'erb'

class WbcaScribe
  def initialize(data_hash, title)
    @data = data_hash
    @title = title
  end

  def build_html
    ERB.new(F.read('views/final.html.erb')).result(self.get_binding)
  end

  def get_binding
    binding()
  end
end
