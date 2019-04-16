# Werewolf

## Development setup

### Environment configure

- Ruby

```
$ ruby -v
ruby 2.3.3p222
 ```

- Rails

```
$ rails -v
Rails 5.0.7
```

- Bundler

```
$ bundle -v
Bundler version 2.0.1
```

### Setup

- Provision

```
$ cd {project_dir}
$ bundle install --path=vendor/bundle
```

- Database

setup your database config in config/database.yml

default is `mysql -hlocalhost:3306 -uroot` (no pass)

* Database migration

```
$ cd {project_dir}
$ bundle exec rake db:create
$ bundle exec rake db:migrate
$ bundle exec rake db:seed
```

* Start development programe

```
$ cd {project_dir}
$ bundle exec rails server
(then access http://localhost:3000 using any browser)
```

### Audio

https://ai.baidu.com/tech/speech/tts

普通女生，语速4，语调4

### Roles

名称|含义|技能|描述
:--:|:--:|:--:|:--
augur|占卜师|Stargaze|夜晚指定一人，狼只能在被指定者及其左右两人中落刀
chief_wolf|白狼王|Destruct|自爆狼枪(必须自爆才可使用)
ghost_rider|恶灵骑士|(被动)反伤|每晚与狼人一起睁眼共同杀人，无法死在夜晚，不能自爆，反伤
god|神抽象基类|-|-
half|混血儿|Link|混血儿与混血对象阵营相同，全程无刀
hidden_wolf|隐狼|有狼队友返回队友数量，无队友则自杀|无狼刀，与狼队互不相认，狼队只剩隐狼时狼队失败，预言家，熊，狐狸，骑士等角色均不能认定其为狼
hunter|猎人|Shoot|-
idiot|白痴|-|公投出局时表明身份，从此无投票权但有发言机会，狼人无需刀翻牌的白痴即可胜利
knight|骑士|Battle|白天投票前翻牌单挑，对方是狼人，狼死，直接入夜，否则骑士死，投票继续
long_wolf|大灰狼|KillMore|与狼队互知身份但不能互通信息，每晚单独睁眼，可额外击杀，全场使用一次且第一夜不可使用，女巫看不见大灰狼刀法，可自爆
lord_wolf|狼王|Shoot|狼枪，毒死、自爆、殉情不开枪
magician|魔术师|Exchange|神，夜间先手行动，交换两人号码牌，整局每个号码牌只能被交换一次
normal_wolf|普狼|-|-
psychic|通灵师|PsychicCheck|查看具体身份
role|角色抽象基类|-|-
savior|守卫|Guard|同守同救死？
seer|预言家|Check|验阵营
villager|普通村民|-|-
witch|女巫|Prescribe|不可一夜双药
wolf|狼人基类|Kill|-

