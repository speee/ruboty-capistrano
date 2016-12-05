# Ruboty::Capistrano

RubotyでCapistranoを使って、deployするためのgemです.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ruboty-capistrano'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ruboty-capistrano

## Usage

![usage](https://cloud.githubusercontent.com/assets/1563239/16789796/6aa5a088-48eb-11e6-9422-fc98904255a9.jpg)

### Deploy

```
@bot_name deploy environment branch_name
```

### Rollback

```
@bot_name rollback environment
```

## Env

```
RUBOTY_ENV              - deploy先の環境を指定する
DEFAULT_BRANCH          - deploy時において、branch指定されていなかった場合に、deployするdefaultのbranch
DEPLOY_REPOSITORY_PATH  - deploy対象のrepositoryのpath
(ex: "sample:/path/to/sample;admin:/path/to/admin")
DEPLOY_LOG_PATH         - deploy時のログを残すpath
GITHUB_ACCESS_TOKEN     - GitHubのアクセストークン(GitHubのAPIを用いるため)
DEPLOY_REPOSITORY_NAME  - deploy対象のGitHubのrepository名
(ex: "sample:hoge/sample-repo;admin:hoge/admin-repo")
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

