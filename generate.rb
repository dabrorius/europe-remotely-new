require 'open-uri'
require 'digest/sha1'
require 'yaml'

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

cache_file = 'cache.yml'
cache = YAML.load_file(cache_file)

sources.each do |source|
  content = open(source[:url]).read
  web_content = content.match(%r{<\s*body[^>]*>(.*)<\s*\/body[^>]*>}m)[0]
  web_content_hash = Digest::SHA1.hexdigest(web_content)

  source_name = source[:title]
  cache[source_name] = {} unless cache.key?(source_name)
  if cache[source_name][:hash] == web_content_hash
    puts "No updates for #{source_name}"
  else
    puts "NEW! #{source_name}"
    cache[source_name][:hash] = web_content_hash
    cache[source_name][:updated_at] = Time.now
  end
end

File.open(cache_file, 'w') do |file|
  file.write(cache.to_yaml)
end
