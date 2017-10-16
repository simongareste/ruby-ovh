# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'ovh-api/version'
require 'date'


Gem::Specification.new do |s|
  s.name          = 'ovh-api'
  s.version       = OVHApi::VERSION
  s.date          = DateTime.now.strftime('%Y-%m-%d')
  s.summary       = "OVH API v6 wrapper"
  s.description   = "Library wrapping OVH API v6 (see: https://api.ovh.com)"
  s.authors       = ["Roland Laurès", "Benoit Vasseur", "Zyurs"]
  s.email         = 'roland.laures@semifir.com'
  s.files         = Dir.glob("{lib}/**/*") + %w(LICENSE readme.md)
  s.homepage      =
    'https://github.com/ShamoX/ruby-ovh'
  s.license       = 'MIT'
  s.require_path  = 'lib'

  s.has_rdoc      = 'yard'

  s.add_development_dependency 'cucumber', '~> 2.0', '>= 2.0.2'
  s.add_development_dependency 'webmock', '~> 1.21'
  s.add_development_dependency 'rspec', '~> 3.3'

end
