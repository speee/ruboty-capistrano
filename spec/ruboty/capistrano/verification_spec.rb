require 'spec_helper'
require 'ruboty/capistrano/verification'
require 'ruboty/capistrano/deploy_source'

describe Ruboty::Capistrano::Verification do
  let(:deploy_source) { Ruboty::Capistrano::DeploySource.new(repo, branch) }
  let(:verification) do
    Ruboty::Capistrano::Verification.new(
      env: env,
      role: role,
      deploy_source: deploy_source
    )
  end
  let(:env) { 'staging' }
  let(:role) { 'admin' }
  let(:repo) { 'sample_repo' }
  let(:branch) { 'master' }

  describe '#execute' do
    subject { verification.execute }

    before do
      allow(deploy_source).to receive(:exist_github?).and_return(true)
    end

    context '正常系' do
      it { is_expected.to be_nil }
    end

    context 'production環境にmaster以外をデプロイしようとした時' do
      let(:env) { 'production' }
      let(:branch) { 'test' }

      it { expect { verification.execute }.to raise_error(Ruboty::Capistrano::Verification::InvalidDeploySettingError) }
    end

    context 'github上に指定したブランチが存在しない時' do
      before do
        allow(deploy_source).to receive(:exist_github?).and_return(false)
      end

      it { expect { verification.execute }.to raise_error(Ruboty::Capistrano::Verification::NoBranchError) }
    end
  end
end
