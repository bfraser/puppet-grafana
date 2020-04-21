require 'spec_helper_acceptance'

describe 'grafana_user' do
  context 'setup grafana server' do
    it 'runs successfully' do
      pp = <<-EOS
      class { 'grafana':
        cfg => {
          security => {
            admin_user     => 'admin',
            admin_password => 'admin'
          }
        }
      }
      EOS
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
  end
  it 'runs successfully' do
    pp = <<-EOS

    grafana_user { 'user1':
      grafana_url       => 'http://localhost:3000',
      grafana_user      => 'admin',
      grafana_password  => 'admin',
      full_name         => 'John Doe',
      password          => 'Us3r5ecret',
      email             => 'john@example.com',
    }
    EOS
    apply_manifest(pp, catch_failures: true)
    apply_manifest(pp, catch_changes: true)
  end
end
