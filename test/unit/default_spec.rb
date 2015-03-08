require 'spec_helper'

describe 'sabnzbd::default' do
  let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }
  it 'runs no tests' do
    expect(chef_run)
  end
end
