#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'qrcode_reader'
  s.version          = '0.0.1'
  s.summary          = 'A flutter plugin for reader qrcodes.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'https://github.com/johanhenselmans/flutter_qrcode_reader'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Netsense' => 'johan@netsense.nl' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  
  s.ios.deployment_target = '8.0'
end
