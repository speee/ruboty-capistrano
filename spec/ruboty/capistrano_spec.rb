require 'spec_helper'

describe Ruboty::Capistrano do
  it 'has a version number' do
    expect(Ruboty::Capistrano::VERSION).not_to be nil
  end

  describe '.config' do
    let(:expected_repo_name) do
      {
        'sample' => 'hoge/sample-repo',
        'admin' => 'hoge/admin-repo'
      }
    end
    let(:expected_repo_path) do
      {
        'sample' => '/path/to/sample',
        'admin' => '/path/to/admin'
      }
    end

    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('DEPLOY_REPOSITORY_NAME').and_return('sample:hoge/sample-repo;admin:hoge/admin-repo')
      allow(ENV).to receive(:[]).with('DEPLOY_REPOSITORY_PATH').and_return('sample:/path/to/sample;admin:/path/to/admin')
    end

    it do
      expect(Ruboty::Capistrano.config.repository_name).to eq(expected_repo_name)
      expect(Ruboty::Capistrano.config.repository_path).to eq(expected_repo_path)
    end
  end
end
