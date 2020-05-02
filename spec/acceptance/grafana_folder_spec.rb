require 'spec_helper_acceptance'

describe 'grafana_folder' do
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

  context 'create folder resource' do
    it 'creates the folders' do
      pp = <<-EOS
      include grafana::validator
      grafana_folder { 'example-folder':
        ensure           => present,
        uid              => 'example-folder',
        grafana_url      => 'http://localhost:3000',
        grafana_user     => 'admin',
        grafana_password => 'admin',
        permissions      => [
          {'permission' => 2, 'role' => 'Editor'},
          {'permission' => 1, 'role' => 'Viewer'},
        ],
      }
      grafana_folder { 'editor-folder':
        ensure           => present,
        uid              => 'editor-folder',
        grafana_url      => 'http://localhost:3000',
        grafana_user     => 'admin',
        grafana_password => 'admin',
        permissions      => [
          {'permission' => 1, 'role' => 'Editor'},
        ],
      }
      EOS
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has created the example folder' do
      shell('curl --user admin:admin http://localhost:3000/api/folders') do |f|
        expect(f.stdout).to match(%r{example-folder})
      end
    end
    it 'has created the editor folder' do
      shell('curl --user admin:admin http://localhost:3000/api/folders') do |f|
        expect(f.stdout).to match(%r{editor-folder})
      end
    end
    it 'has created the example folder permissions' do
      shell('curl --user admin:admin http://localhost:3000/api/folders/example-folder/permissions') do |f|
        data = JSON.parse(f.stdout)
        expect(data).to include(hash_including('permission' => 2, 'role' => 'Editor'), hash_including('permission' => 1, 'role' => 'Viewer'))
      end
    end
    it 'has created the editor folder permissions' do
      shell('curl --user admin:admin http://localhost:3000/api/folders/editor-folder/permissions') do |f|
        data = JSON.parse(f.stdout)
        expect(data).to include(hash_including('permission' => 1, 'role' => 'Editor'))
      end
    end
  end

  context 'updates folder resource' do
    it 'updates the folders' do
      pp = <<-EOS
      grafana_folder { 'example-folder':
        ensure           => present,
        uid              => 'example-folder',
        grafana_url      => 'http://localhost:3000',
        grafana_user     => 'admin',
        grafana_password => 'admin',
        permissions      => [
          {'permission' => 2, 'role' => 'Editor'},
        ],
      }
      grafana_folder { 'editor-folder':
        ensure           => present,
        uid              => 'editor-folder',
        grafana_url      => 'http://localhost:3000',
        grafana_user     => 'admin',
        grafana_password => 'admin',
        permissions      => [
          {'permission' => 1, 'role' => 'Viewer'},
        ],
      }
      EOS
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has updated the example folder permissions' do
      shell('curl --user admin:admin http://localhost:3000/api/folders/example-folder/permissions') do |f|
        data = JSON.parse(f.stdout)
        expect(data).to include(hash_including('permission' => 2, 'role' => 'Editor'))
        # expect(data.size).to eq(1)
        # expect(data[0]['permission']).to eq(2)
        # expect(data[0]['role']).to eq('Editor')
      end
    end
    it 'has updated the editor folder permissions' do
      shell('curl --user admin:admin http://localhost:3000/api/folders/editor-folder/permissions') do |f|
        data = JSON.parse(f.stdout)
        expect(data).to include(hash_including('permission' => 1, 'role' => 'Viewer'))
      end
    end
  end

  context 'create folder containing dashboard' do
    it 'creates an example dashboard in the example folder' do
      pp = <<-EOS
      include grafana::validator
      grafana_dashboard { 'example-dashboard':
        ensure           => present,
        grafana_url      => 'http://localhost:3000',
        grafana_user     => 'admin',
        grafana_password => 'admin',
        content          => '{"uid": "abc123xy"}',
        folder           => 'example-folder'
      }
      EOS
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'folder contains dashboard' do
      shell('curl --user admin:admin http://localhost:3000/api/dashboards/db/example-dashboard') do |f|
        expect(f.stdout).to match(%r{"folderId":1})
      end
    end
  end

  context 'destroy resources' do
    it 'destroys the folders and dashboard' do
      pp = <<-EOS
      include grafana::validator
      grafana_folder { 'example-folder':
        ensure           => absent,
        grafana_url      => 'http://localhost:3000',
        grafana_user     => 'admin',
        grafana_password => 'admin',
      }
      grafana_folder { 'editor-folder':
        ensure           => absent,
        grafana_url      => 'http://localhost:3000',
        grafana_user     => 'admin',
        grafana_password => 'admin',
      }
      grafana_folder { 'nomatch-folder':
        ensure           => absent,
        grafana_url      => 'http://localhost:3000',
        grafana_user     => 'admin',
        grafana_password => 'admin',
      }
      grafana_dashboard { 'example-dashboard':
        ensure           => absent,
        grafana_url      => 'http://localhost:3000',
        grafana_user     => 'admin',
        grafana_password => 'admin',
      }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has no example-folder' do
      shell('curl --user admin:admin http://localhost:3000/api/folders') do |f|
        expect(f.stdout).not_to match(%r{example-folder})
      end
    end

    it 'has no editor-folder' do
      shell('curl --user admin:admin http://localhost:3000/api/folders') do |f|
        expect(f.stdout).not_to match(%r{editor-folder})
      end
    end

    it 'has no nomatch-folder' do
      shell('curl --user admin:admin http://localhost:3000/api/folders') do |f|
        expect(f.stdout).not_to match(%r{nomatch-folder})
      end
    end
  end
end
