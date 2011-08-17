require "rubygems"
require "rubygems/package_task"
require "rdoc/task"

require "rspec"
require "rspec/core/rake_task"
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = %w(--format documentation --colour)
end


task :default => ["spec"]

# This builds the actual gem. For details of what all these options
# mean, and other ones you can add, check the documentation here:
#
#   http://rubygems.org/read/chapter/20
#
spec = Gem::Specification.new do |s|

  # Change these as appropriate
  s.name              = "rspreedly"
  s.version           = "0.1.16"
  s.summary           = "Ruby library for the Spreedly API"
  s.author            = "Richard Livsey"
  s.email             = "richard@livsey.org"
  s.homepage          = "http://github.com/rlivsey/rspreedly"

  s.has_rdoc          = true
  s.extra_rdoc_files  = %w(README.rdoc)
  s.rdoc_options      = %w(--main README.rdoc)

  # Add any extra files to include in the gem
  s.files             = %w(LICENSE Rakefile README.rdoc rspreedly.gemspec) + Dir.glob("{spec,lib}/**/*")
  s.require_paths     = ["lib"]

  # If you want to depend on other gems, add them here, along with any
  # relevant versions
  s.add_dependency("httparty", ">= 0.5.0")

  # If your tests use any gems, include them here
  s.add_development_dependency("rspec")
  s.add_development_dependency("webmock")
end

# This task actually builds the gem. We also regenerate a static
# .gemspec file, which is useful if something (i.e. GitHub) will
# be automatically building a gem for this project. If you're not
# using GitHub, edit as appropriate.
#
# To publish your gem online, install the 'gemcutter' gem; Read more
# about that here: http://gemcutter.org/pages/gem_docs
Gem::PackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "Build the gemspec file #{spec.name}.gemspec"
task :gemspec do
  file = File.dirname(__FILE__) + "/#{spec.name}.gemspec"
  File.open(file, "w") {|f| f << spec.to_ruby }
end

# If you don't want to generate the .gemspec file, just remove this line. Reasons
# why you might want to generate a gemspec:
#  - using bundler with a git source
#  - building the gem without rake (i.e. gem build blah.gemspec)
#  - maybe others?
task :package => :gemspec

# Generate documentation
RDoc::Task.new do |rd|
  rd.main = "README.rdoc"
  rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
  rd.rdoc_dir = "rdoc"
end

desc 'Clear out RDoc and generated packages'
task :clean => [:clobber_rdoc, :clobber_package] do
  rm "#{spec.name}.gemspec"
end
