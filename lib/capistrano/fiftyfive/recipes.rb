Dir.glob("#{File.dirname(__FILE__)}/recipes/*.rb").sort.each do |recipe|
  load(recipe)
end
