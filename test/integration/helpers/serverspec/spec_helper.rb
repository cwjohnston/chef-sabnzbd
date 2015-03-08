require 'serverspec'
set :backend, :exec

shared_examples_for 'sabnzbd' do

  describe service('sabnzbd') do
    it { should be_running }
  end

end
