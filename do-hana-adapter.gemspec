# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "do-hana-adapter"
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["NA"]
  s.date = "2012-11-05"
  s.description = "A DataMapper DataObjects implementation that uses ODBC to work against SAP's HANA in-memory database offering."
  s.email = "support@anypresence.com"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "lib/do-hana-adapter.rb",
    "lib/do_hana_adapter/dm_do_hana_adapter.rb",
    "lib/do_hana_adapter/dm_do_hana_migrations.rb",
    "lib/do_hana_adapter/do_hana_command.rb",
    "lib/do_hana_adapter/do_hana_connection.rb",
    "lib/do_hana_adapter/do_hana_quoting.rb",
    "lib/do_hana_adapter/do_hana_reader.rb",
    "spec/do-hana-adapter_spec.rb",
    "spec/odbc.ini",
    "spec/odbcinst.ini",
    "spec/spec_helper.rb"
  ]
  s.homepage = "http://github.com/AnyPresence/do-hana-adapter"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "SAP HANA DataMapper DataObjects Adapter"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<dm-core>, ["~> 1.2.0"])
      s.add_runtime_dependency(%q<dm-types>, ["~> 1.2.0"])
      s.add_runtime_dependency(%q<dm-do-adapter>, ["~> 1.2.0"])
      s.add_runtime_dependency(%q<dm-migrations>, ["~> 1.2.0"])
      s.add_runtime_dependency(%q<data_objects>, ["~> 0.10.8"])
      s.add_runtime_dependency(%q<ruby-odbc>, ["~> 0.99994"])
      s.add_development_dependency(%q<rspec>, ["~> 2.10.0"])
      s.add_development_dependency(%q<shoulda>, [">= 0"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_development_dependency(%q<bundler>, ["~> 1.1.4"])
      s.add_development_dependency(%q<rcov>, ["~> 0.9.11"])
      s.add_development_dependency(%q<simplecov>, ["~> 0.4"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.8.4"])
    else
      s.add_dependency(%q<dm-core>, ["~> 1.2.0"])
      s.add_dependency(%q<dm-types>, ["~> 1.2.0"])
      s.add_dependency(%q<dm-do-adapter>, ["~> 1.2.0"])
      s.add_dependency(%q<dm-migrations>, ["~> 1.2.0"])
      s.add_dependency(%q<data_objects>, ["~> 0.10.8"])
      s.add_dependency(%q<ruby-odbc>, ["~> 0.99994"])
      s.add_dependency(%q<rspec>, ["~> 2.10.0"])
      s.add_dependency(%q<shoulda>, [">= 0"])
      s.add_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_dependency(%q<bundler>, ["~> 1.1.4"])
      s.add_dependency(%q<rcov>, ["~> 0.9.11"])
      s.add_dependency(%q<simplecov>, ["~> 0.4"])
      s.add_dependency(%q<jeweler>, ["~> 1.8.4"])
    end
  else
    s.add_dependency(%q<dm-core>, ["~> 1.2.0"])
    s.add_dependency(%q<dm-types>, ["~> 1.2.0"])
    s.add_dependency(%q<dm-do-adapter>, ["~> 1.2.0"])
    s.add_dependency(%q<dm-migrations>, ["~> 1.2.0"])
    s.add_dependency(%q<data_objects>, ["~> 0.10.8"])
    s.add_dependency(%q<ruby-odbc>, ["~> 0.99994"])
    s.add_dependency(%q<rspec>, ["~> 2.10.0"])
    s.add_dependency(%q<shoulda>, [">= 0"])
    s.add_dependency(%q<rdoc>, ["~> 3.12"])
    s.add_dependency(%q<bundler>, ["~> 1.1.4"])
    s.add_dependency(%q<rcov>, ["~> 0.9.11"])
    s.add_dependency(%q<simplecov>, ["~> 0.4"])
    s.add_dependency(%q<jeweler>, ["~> 1.8.4"])
  end
end
