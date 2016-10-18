require 'spec_helper'

describe service('thin') do
  describe port(3000) do
    it { should be_listening }
  end
end

describe service('nginx') do
  it { should be_enabled  }
  it { should be_running  }

  describe port(80) do
    it { should be_listening }
  end
end

describe user('deploy') do
  it { should exist }
end
