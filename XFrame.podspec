Pod::Spec.new do |s|

  s.name         = "XFrame"
  s.version      = "0.3.8"
  s.summary      = "XFrame"
  s.homepage     = "http://www.xunshangwang.com"
  s.license      = "MIT"
  s.author       = { "ios" => "www.xunshangwang.com" }

s.source       = { :git => "http://192.168.2.8:880/r/XFrame-ios.git" }
  s.platform     = :ios
  s.source_files = 'XFrame/*.swift'
  s.resources    = 'XFrame/*.icon.js'

end
