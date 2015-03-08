require 'spec_helper'

describe 'sabnzbd::default' do
  let(:sab_user) { 'nzbs' }
  let(:install_dir) { '/opt/nzbs' }
  let(:config_dir) { '/usr/local/etc/nzbs' }
  let(:data_dir) { '/tank/nzbs' }
  let(:run_dir) { '/usr/local/run/nzbs' }
  let(:log_dir) { '/usr/local/log/nzbs' }

  cached(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.set['sabnzbd']['user'] = sab_user
      %w( install config data run log ).each do |t|
        node.set['sabnzbd']["#{t}_dir"] = send("#{t}_dir".to_sym)
      end
      node.set['sabnzbd']['install_dir'] = install_dir
    end.converge(described_recipe)
  end

  it 'includes git' do
    expect(chef_run).to include_recipe('git')
  end

  %w( par2
      unrar
      unzip
      python-yenc
      python-cheetah
      python-openssl
      coreutils
      util-linux ).each do |pkg|
    it "installs package #{pkg}" do
      expect(chef_run).to install_package(pkg)
    end
  end

  it 'creates sabnzbd user' do
    expect(chef_run).to create_user(sab_user).with(
      :shell => '/bin/bash',
      :system => true
    )
  end

  %w( install config run log ).each do |d|
    it "creates the #{d} directory" do
      expect(chef_run).to create_directory(send("#{d}_dir".to_sym))
    end
  end

  %w( complete incomplete logs nzb_backup scripts templates watch ).each do |d|
    it "creates the #{d} data directory" do
      expect(chef_run).to create_directory(
        File.join(data_dir, d)
      )
    end
  end

  it 'syncs sabnzbd from git' do
    expect(chef_run).to sync_git(install_dir)
  end

  context 'with bluepill init_style' do
    before do
      chef_run.node.set['sabnzbd']['init_style'] = 'bluepill'
    end

    it 'includes the bluepill recipe' do
      expect(chef_run).to include_recipe('bluepill')
    end

    it 'creates sabnzbd bluepill configuration' do
      expect(chef_run).to create_template(
        '/etc/bluepill/sabnzbd.pill'
      )
    end

    it 'enables the bluepill service' do
      pending 'implementation of bluepill chefspec matchers'
    end
  end

end
