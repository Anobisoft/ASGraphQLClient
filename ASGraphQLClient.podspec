
Pod::Spec.new do |s|

  s.name             = 'ASGraphQLClient'
  s.version          = '0.2.2'
  s.summary          = 'ASGraphQLClient - GraphQL Client'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
DESC

  s.homepage     = "https://github.com/Anobisoft/ASGraphQLClient"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Stanislav Pletnev" => "anobisoft@gmail.com" }
  s.social_media_url   = "https://twitter.com/Anobisoft"

  s.platform     = :ios, "8.3"
  s.source       = { :git => "https://github.com/Anobisoft/ASGraphQLClient.git", :tag => "v#{s.version}" }
  s.source_files  = "ASGraphQLClient/**/*.{h,m}"
  s.framework  = "Foundation"
  s.dependency 'AnobiKit', '~> 0.2.19'
  s.requires_arc = true


end
