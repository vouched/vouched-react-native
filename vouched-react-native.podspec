require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "vouched-react-native"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = <<-DESC
                  Vouched React Native
                   DESC
  s.homepage     = "https://github.com/github_account/vouched-react-native"
  s.license      = "Apache-2.0"
  s.authors      = { "Vouched" => "support@vouched.id" }
  s.platforms    = { :ios => "12.0" }
  s.source       = { :git => "https://github.com/vouched/vouched-react-native.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,c,m,swift}"
  s.requires_arc = true

  s.dependency "React"
  s.dependency "Vouched", "1.6.4"
end
