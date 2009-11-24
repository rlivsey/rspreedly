# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rspreedly}
  s.version = "0.1.8"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Richard Livsey"]
  s.date = %q{2009-11-25}
  s.email = %q{richard@livsey.org}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "lib/rspreedly.rb",
     "lib/rspreedly/base.rb",
     "lib/rspreedly/complimentary_subscription.rb",
     "lib/rspreedly/complimentary_time_extension.rb",
     "lib/rspreedly/config.rb",
     "lib/rspreedly/error.rb",
     "lib/rspreedly/invoice.rb",
     "lib/rspreedly/line_item.rb",
     "lib/rspreedly/payment_method.rb",
     "lib/rspreedly/subscriber.rb",
     "lib/rspreedly/subscription_plan.rb",
     "rspreedly.gemspec",
     "spec/base_spec.rb",
     "spec/config_spec.rb",
     "spec/fixtures/complimentary_failed_active.xml",
     "spec/fixtures/complimentary_failed_inactive.xml",
     "spec/fixtures/complimentary_not_valid.xml",
     "spec/fixtures/complimentary_success.xml",
     "spec/fixtures/create_subscriber.xml",
     "spec/fixtures/error.xml",
     "spec/fixtures/error_string.txt",
     "spec/fixtures/errors.xml",
     "spec/fixtures/existing_subscriber.xml",
     "spec/fixtures/free_plan_not_elligable.xml",
     "spec/fixtures/free_plan_not_free.xml",
     "spec/fixtures/free_plan_not_set.xml",
     "spec/fixtures/free_plan_success.xml",
     "spec/fixtures/invalid_subscriber.xml",
     "spec/fixtures/invalid_update.xml",
     "spec/fixtures/invoice_created.xml",
     "spec/fixtures/invoice_invalid.xml",
     "spec/fixtures/no_plans.xml",
     "spec/fixtures/no_subscribers.xml",
     "spec/fixtures/payment_already_paid.xml",
     "spec/fixtures/payment_invalid.xml",
     "spec/fixtures/payment_not_found.xml",
     "spec/fixtures/payment_success.xml",
     "spec/fixtures/plan_disabled.xml",
     "spec/fixtures/plan_not_found.xml",
     "spec/fixtures/subscriber.xml",
     "spec/fixtures/subscriber_not_found.xml",
     "spec/fixtures/subscribers.xml",
     "spec/fixtures/subscription_plan_list.xml",
     "spec/invoice_spec.rb",
     "spec/spec_helper.rb",
     "spec/subscriber_spec.rb",
     "spec/subscription_plan_spec.rb"
  ]
  s.homepage = %q{http://github.com/rlivsey/rspreedly}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Ruby library for the Spreedly API}
  s.test_files = [
    "spec/base_spec.rb",
     "spec/config_spec.rb",
     "spec/invoice_spec.rb",
     "spec/spec_helper.rb",
     "spec/subscriber_spec.rb",
     "spec/subscription_plan_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
