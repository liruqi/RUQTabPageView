Pod::Spec.new do |s|
  s.name     = 'RUQTabPageView'
  s.version  = '1.0'
  s.platform = :ios, '6.1'
  s.license  = 'MIT'
  s.summary  = 'RUQTabPageView is an iOS version of Android TabPageIndicator'
  s.homepage = 'https://github.com/liruqi/RUQTabPageView'
  s.authors   = { 'Ruqi Li' => 'liruqi@gmail.com' }
  s.source   = { :git => 'git@github.com:liruqi/RUQTabPageView.git' }
  s.description = 'RUQTabPageView is an iOS version of Android TabPageIndicator'
  s.source_files = 'RUQTabPageView/*.{h,m}'
  s.framework    = 'QuartzCore'
  s.requires_arc = true
end
