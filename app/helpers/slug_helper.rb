module SlugHelper
  def slugify
    self.slug = "#{normalize}".parameterize(separator: '_')
    self.save
  end

  def check_slug
    "#{normalize}".parameterize(separator: '_') == self.slug
  end

  def normalize
    self.name.downcase.gsub(/[ț, ș, ă, î, â, ]/, 'ț' => 't', 'ș' => 's', 'ă' => 'a', 'î' => 'i', 'â' => 'a', ' ' => '_')
  end
end