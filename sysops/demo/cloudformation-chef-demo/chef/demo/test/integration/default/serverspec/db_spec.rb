require 'spec_helper'

describe service('mysql') do
  it { should be_enabled  }
  it { should be_running  }

  it 'is listening on port 3306' do
    expect(port(3306)).to be_listening
  end

  describe file('/var/run/mysqld/mysqld.sock') do
      it { should be_socket }
  end

  describe 'posso database' do
    describe command("echo \'SHOW DATABASES LIKE 'posso'\' | mysql --user=posso --password=posso") do
      its(:stdout) { should match /posso/ }
    end
  end
end
