require 'open-uri'
require 'digest/sha1'

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

sources.each do |source|
  content = open(source[:url]).read
  web_content = content.match(%r{<\s*body[^>]*>(.*)<\s*\/body[^>]*>}m)[0]
  web_content_hash = Digest::SHA1.hexdigest(web_content)
  File.open("cache/#{source[:title]}", 'r') do |file|
    cached_content = file.read
    cached_content_hash = Digest::SHA1.hexdigest(cached_content)
    puts "IS EQUAL? #{cached_content_hash == web_content_hash}"
  end

  File.open("cache/#{source[:title]}", 'w') do |file|
    file.write(web_content)
  end
  #puts body
end
