require 'spec_helper_acceptance'

describe 'grafana_folder' do
  context 'create folder resource' do
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

      grafana_folder { 'example-folder': 
        ensure           => present,
        grafana_url      => 'http://localhost:3000',
        grafana_user     => 'admin',
        grafana_password => 'admin',
      }
      EOS
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has the folder' do
      shell('curl --user admin:admin http://localhost:3000/api/folders') do |f|
        expect(f.stdout).to match(%r{example-folder})
      end
    end
  end

  context 'destroy folder resource' do
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

      grafana_folder { 'example-folder': 
        ensure           => absent,
        grafana_url      => 'http://localhost:3000',
        grafana_user     => 'admin',
        grafana_password => 'admin',
      }
      EOS
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'does not have the folder' do
      shell('curl --user admin:admin http://localhost:3000/api/folders') do |f|
        expect(f.stdout).not_to match(%r{example-folder})
      end
    end
  end
end
