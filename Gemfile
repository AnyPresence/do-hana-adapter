source "http://rubygems.org"

DO_VERSION     = '~> 0.10.7'
DM_VERSION    = '~> 1.2.0'
RUBY_ODBC_VERSION = '~> 0.99995'

# Add dependencies required to use your gem here.
# Example:

gem "dm-core", DM_VERSION
gem "dm-types", DM_VERSION
gem "dm-do-adapter", DM_VERSION
gem "dm-migrations", DM_VERSION
gem "data_objects", DO_VERSION

# Add dependencies to develop your gem here.
# Include everything needed to run rake, tests, features, etc.
group :development, :test do
  gem "rspec", "~>  2.10.0"
  gem "shoulda", ">= 0"
  gem "rdoc", "~> 3.12"
  gem "bundler"
  gem "simplecov"
  gem "jeweler", "~> 1.8.4"
  gem "ruby-odbc", RUBY_ODBC_VERSION
end
