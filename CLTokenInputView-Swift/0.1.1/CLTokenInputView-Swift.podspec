#
# Be sure to run `pod lib lint CLTokenInputView-Swift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CLTokenInputView-Swift'
  s.version          = '0.1.1'
  s.summary          = 'Input view like Mail.app.'

  s.description      = 'CLTokenInputView-Swift is an almost pixel perfect replica of the input portion iOS\'s native contacts picker, used in Mail.app and Messages.app when composing a new message. Originaly developed at Cluster Labs, Inc.. and then ported to swift by @rlaferla. Bugfixed, updated and added pod by @v.i.p.dimak'

  s.homepage         = 'https://github.com/dmitrykurochka/CLTokenInputView-Swift'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'v.i.p.dimak@gmail.com' => 'v.i.p.dimak@gmail.com' }
  s.source           = { :git => 'https://github.com/dmitrykurochka/CLTokenInputView-Swift.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'CLTokenInputView-Swift/Classes/**/*'
  
  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit'
end
