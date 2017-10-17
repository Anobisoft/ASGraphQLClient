
Pod::Spec.new do |s|

  s.name             = 'ASGraphQLClient'
  s.version          = '0.0.5'
  s.summary          = 'ASGraphQLClient - GraphQL Client'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
Description should be longer than summary.
more longer
much more longer
longer...
                       DESC

  s.homepage     = "https://github.com/Anobisoft/ASGraphQLClient"
# s.screenshots  = "www.example.com/screenshots_1.gif"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Stanislav Pletnev" => "anobisoft@gmail.com" }
  s.social_media_url   = "https://twitter.com/Anobisoft"

# s.platform     = :ios
  s.platform     = :ios, "8.3"
#  When using multiple platforms
# s.ios.deployment_target = "9.3"
# s.osx.deployment_target = "10.7"
# s.watchos.deployment_target = "2.0"
# s.tvos.deployment_target = "9.0"

  s.source       = { :git => "https://github.com/Anobisoft/ASGraphQLClient.git", :tag => "v#{s.version}" }
  s.source_files  = "ASGraphQLClient/Classes/**/*.{h,m}"
# s.public_header_files = "ASGraphQLClient/Classes/**/*.h"
# s.exclude_files = "Classes/Exclude"
# s.resource  = "icon.png"
  s.resources = "ASGraphQLClient/Resources/*.plist"
# s.preserve_paths = "FilesToSave", "MoreFilesToSave"

  s.framework  = "Foundation"
# s.frameworks = "SomeFramework", "AnotherFramework"
# s.library   = "iconv"
# s.libraries = "iconv", "xml2"
  s.dependency 'AFNetworking', '~> 3.1.0'
  s.dependency 'AnobiKit', '~> 0.1.11'

  s.requires_arc = true
# s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }

end
