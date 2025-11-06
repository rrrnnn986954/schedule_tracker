require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'

# ------------- Migration チェック -------------
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

# ------------- RSpec 設定 -------------
RSpec.configure do |config|
  # fixtures（テスト用データ）を置くフォルダ
  config.fixture_paths = [Rails.root.join('spec/fixtures')]

  # 各テストをトランザクションで囲む（DBを綺麗に保つ）
  config.use_transactional_fixtures = true

  # spec/models/*.rb → modelテストとして扱う
  config.infer_spec_type_from_file_location!

  # Railsのノイズをバックトレースから除外
  config.filter_rails_from_backtrace!
end

