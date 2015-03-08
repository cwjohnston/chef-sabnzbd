require 'serverspec'
set :backend, :exec

describe service('sabnzbd') do
  it { should be_running }
end
