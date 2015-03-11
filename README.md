# 依赖
* resque
* elasticsearch
* mysql

## 启动resque

```sh
env RESQUE_TERM_TIMEOUT=1 TERM_CHILD=1 VVERBOSE=1 QUEUE=* bundle exec rake resque:work
```

## 安装elasticsearch(未使用)

http://stackoverflow.com/questions/23034863/install-elasticsearch-1-1-using-brew

```sh
brew install elasticsearch
brew info elasticsearch
```

## deploy
bundle exec mina deploy --verbose

