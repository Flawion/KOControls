Pod::Spec.new do |s|
  s.name = 'KOControls'
  s.version = '1.0'

  s.summary = 'Package of useful controls: pickers, presenting queue, textfield thats supports showing the errors etc.'
  s.homepage = 'https://github.com/Flawion/KOControls'

  s.license = 'MIT'
  s.author = 'Kuba Ostrowski'

  s.platform = :ios, '10.0'
  s.ios.deployment_target = '10.0'

  s.source = { :git => 'https://github.com/Flawion/KOControls.git', :tag => s.version }

  s.source_files = 'Sources/*.swift'
  s.resources = 'Sources/*.{png,jpeg,jpg,storyboard,xib,xcassets}'

  s.requires_arc = true
end
