require 'open-uri'
require 'digest/sha1'
require 'yaml'
require 'erb'

sources = [
  {
    title: 'Digital Ocean',
    description: "We’re simplifying cloud infrastructure for developers.",
    url: 'https://www.digitalocean.com/company/careers/',
    icon: 'digital-ocean.png'
  },
  {
    title: 'Six to Start',
    description: "We're an indie game developer based in London.",
    url: 'http://www.sixtostart.com/workwithus/',
    icon: 'six-to-start.png'
  }
]

puts 'Loading cache data...'
cache_file = 'cache.yml'
cache = YAML.load_file(cache_file)

puts 'Checking for updates...'
sources.each do |source|
  source_name = source[:title]

  print "\t#{source_name}..."
  content = open(source[:url]).read
  web_content = content.match(%r{<\s*body[^>]*>(.*)<\s*\/body[^>]*>}m)[0]
  web_content_hash = Digest::SHA1.hexdigest(web_content)

  cache[source_name] = {} unless cache.key?(source_name)
  if cache[source_name][:hash] == web_content_hash
    puts 'no updates'
  else
    puts 'NEW!'
    cache[source_name][:hash] = web_content_hash
    cache[source_name][:updated_at] = Time.now
  end
  source[:updated_at] = cache[source_name][:updated_at]
end

puts 'Sorting sources...'
sources_by_update_time = sources.sort do |a, b|
  b[:updated_at] <=> a[:updated_at]
end
puts sources_by_update_time

puts 'Saving cache...'
File.open(cache_file, 'w') do |file|
  file.write(cache.to_yaml)
end

puts 'Generating HTML...'
@companies = sources_by_update_time
renderer = ERB.new(File.read('template.erb'))
generated_html = renderer.result(binding)
File.open('index.html', 'w') do |file|
  file.write(generated_html)
end

puts 'All done!'
