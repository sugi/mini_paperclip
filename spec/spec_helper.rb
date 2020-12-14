require "bundler/setup"
require "active_record"
require "active_support/core_ext/numeric"
require "tapp"
require "rack/test"
require "webmock/rspec"
require 'pretty_backtrace'

if ENV['COVERAGE']
  require "coverage"
  # Minimum coverage
  Coverage.start
  at_exit do
    cov = Coverage.result.select { |d| d.match?(%r{/mini_paperclip/lib/}) }
    cov.transform_keys! { |key| key.dup.sub!(%r{^.*mini_paperclip/(lib/.*)$}, '\1') }
    cov.transform_values! do |ary|
      ary = ary.compact
      ary.count { |l| l > 0 }.fdiv(ary.length)
    end
    max_length = cov.keys.max_by(&:length).length

    puts "Coverage"
    cov.to_a.sort_by { |k, v| v }.each do |k, v|
      puts "| %-#{max_length}s | %6.2f %% |" % [k, v * 100]
    end
  end
end

require "mini_paperclip"
require "mini_paperclip/shoulda/matchers"

PrettyBacktrace.enable
PrettyBacktrace.multi_line = true

loglevel = ENV['LOGLEVEL']&.to_sym || :debug

MiniMagick.logger.level = loglevel
MiniPaperclip.config.tap do |config|
  config.storage = :filesystem
  config.filesystem_path = "spec/temp/:class/:attachment/:hash.:extension"
  config.hash_secret = "test"
  config.url_scheme = "http"
  config.url_host = "test.com"
  config.url_path = ":class/:attachment/:hash.:extension"
  config.logger.level = loglevel
end

ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: ":memory:"
)

ActiveRecord::Base.connection.create_table :not_extends, force: true do |table|
  table.column :image_file_name, :string
  table.column :image_file_size, :bigint
  table.column :image_content_type, :string
  table.column :image_updated_at, :timestamp
end

ActiveRecord::Base.connection.create_table :records, force: true do |table|
  table.column :image_file_name, :string
  table.column :image_file_size, :bigint
  table.column :image_content_type, :string
  table.column :image_updated_at, :timestamp
end

ActiveRecord::Base.connection.create_table :presence_records, force: true do |table|
  table.column :image_file_name, :string
  table.column :image_file_size, :bigint
  table.column :image_content_type, :string
  table.column :image_updated_at, :timestamp
end

ActiveRecord::Base.connection.create_table :zero_records, force: true do |table|
  table.column :image_file_name, :string
  table.column :image_file_size, :bigint
  table.column :image_content_type, :string
  table.column :image_updated_at, :timestamp
end

class NotExtend < ActiveRecord::Base
end

class Record < ActiveRecord::Base
  extend MiniPaperclip::ClassMethods
  has_attached_file :image, styles: { medium: '10x10' }
end

class PresenceRecord < ActiveRecord::Base
  extend MiniPaperclip::ClassMethods
  has_attached_file :image
  validates_attachment :image,
    presence: true,
    content_type: { content_type: ['image/png'] },
    size: { less_than: 1.megabytes },
    geometry: {
      width: { less_than_or_equal_to: 1000 },
      height: { less_than_or_equal_to: 1000 }
    }
end

class ZeroRecord < ActiveRecord::Base
  extend MiniPaperclip::ClassMethods
  has_attached_file :image
  validates_attachment :image,
    geometry: {
      width: { less_than_or_equal_to: 0 },
      height: { less_than_or_equal_to: 0 }
    }
end

def aws_stub_response(stub)
  orig_config = Aws.config
  Aws.config[:stub_responses] = stub
  yield
ensure
  Aws.config = orig_config
end

Tapp.configure do |config|
  config.report_caller = true
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.after(:all) do
    FileUtils.rm_rf("spec/temp")
  end
end
