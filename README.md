# \# 项目简介

# > \*\*注意！仓库内模板代码尚未完善，先别急着clone。\*\*

# 

# 极创组26寒假趣味项目，基于Godot4.4进行开发。目前我(Essenpphire)只实现了部分功能~~其实是以前练RPG的demo~~，具体特性如下：

# 1\. 角色控制系统

# &nbsp;	- \*\*移动与机动\*\*：支持角色在四个方向的流畅移动 + 集成疾跑功能

# &nbsp;	- \*\*基础战斗\*\*：实现了角色的基础攻击动作与判定

# 

# 2\. 敌人与战斗

# &nbsp;	- \*\*史莱姆\*\*：可主动追踪并攻击玩家角色

# 

# 3\. 视觉效果

# &nbsp;	- \*\*屏幕特效\*\*：实装了屏幕震动效果，增强战斗与受击的反馈

# &nbsp;	- \*\*Y-Sorting\*\*：实现了植被的动态遮挡功能

# 

# 4\. 游戏流程

# &nbsp;	- \*\*死亡界面\*\*：加入了角色死亡界面

# &nbsp;	- \*\*对话系统\*\*：开发了可显示角色立绘的对话系统

# &nbsp;   

# 5\. 游戏世界

# &nbsp;	- \*\*主世界地图\*\*：创建了首个可探索的简单地图，为添加了碰撞

# 

# 截图如下：

# !\[png](preview/1.png)

# 

# 战斗

# !\[png](preview/2.png)

# 

# 死亡及对话

# !\[png](preview/3.png)

# 

# \# 开发指南

# 将项目clone至本地，用godot导入即可。本项目采用单例架构开发，将游戏的各个系统抽象为`XxxManager`类，保证它们只被初始化一次，系统分工如下：

# 

# | 系统                  | 负责人 | 备注  |

# | ------------------- | --- | --- |

# | 场景管理系统 SceneManager | 暂定  |     |

# | 音频系统 AudioManager   | 暂定  |     |

# | 地图生成系统 MapManager   | 暂定  |     |

# | 数据系统 StorageManager | 暂定  |     |

# | 对话系统 DialogManager  | zsy |     |

# | …………                |     |     |

# 

# \*\*注意遵循开发规范，利好你我他~\*\*

# 

# \# 项目结构

# ```bash

# ├─场景 # 存放godot单个场景树(\*.tscn)

# │  ├─ui

# │  ├─地图

# │  ├─敌方

# │  └─角色

# ├─脚本 # 存放项目脚本

# │  ├─单例

# │  ├─敌方

# │  ├─特效

# │  └─角色

# │  │  └─Enemy.gd # 类定义

# │  │  └─主角.gd  # 主角控制脚本

# └─资产 # 存放godot专有资源的文件夹命名为英文

# &nbsp;   ├─shader

# &nbsp;   ├─sprite\_frame

# &nbsp;   ├─theme

# &nbsp;   ├─tileset

# &nbsp;   ├─图片

# &nbsp;   │  ├─tileset

# &nbsp;   │  │  └─Extra

# &nbsp;	│  ├─ui

# &nbsp;   │  ├─敌方

# &nbsp;   │  ├─立绘

# &nbsp;   │  └─角色

# &nbsp;   ├─字体

# &nbsp;   └─对话 # 自定义数据结构

# ```

# 

# \# 开发规范

# \## 命名

# \- 变量：小写下划线命名法 `snake\_case`

# \- 常量：大写下划线命名法`RUN\_SPEED`

# \- 函数：小驼峰命名法 `lowerCamelCase`，标出返回值，示例如下：

# ```gdscript

# func handleAttack() -> void:

# &nbsp;       if Input.is\_action\_just\_pressed("攻击") and !isDead:

# &nbsp;               if !isAttacking:

# &nbsp;                       GameManager.cameraShake(5.0)

# &nbsp;               isAttacking = true

# &nbsp;               if enemy and enemy.STATE.isHurting == false:

# &nbsp;                       enemy.STATE.isHurting = true

# &nbsp;                       enemy.received\_damage = self.ATK

# ```

# 

# \- 对象内置属性：需在前方加上`self.`，与自定义属性区分，示例如下：

# ```gdscript

# \# CharacterBody2D - 主角v1.gd

# &nbsp;	if direction and !isAttacking and !isDead:

# &nbsp;		isWalking = true

# &nbsp;		self.velocity = (RUN\_SPEED if Input.is\_action\_pressed("奔跑") else WALK\_SPEED) \* direction

# 

# ```

# 

# \## 注释（可选）

# 遵循Godot官方文档注释，参见：\[文档注释 | GDScript教程](https://godothub.com/oss/gdscript-tutorial/12.doc-comments.html)

# ```gdscript

# \## 简单的描述一下这个类的功能和作用

# \##

# \## 说明一下这个类可以做什么，以及它的任何其他细节

# \##

# \## @tutorial:        https://example.com/tutorial\_1

# \## @tutorial(教程 2): https://example.com/tutorial\_2

# \## @experimental

# extends Node2D

# \## 这个信号的描述

# signal my\_signal

# \## 这个枚举的描述

# enum Direction {

# &nbsp;       ## 方向 上

# &nbsp;       UP = 0,

# &nbsp;       ## 方向 下

# &nbsp;       DOWN = 1,

# &nbsp;       ## 方向 左

# &nbsp;       LEFT = 2,

# &nbsp;       ## 方向 右

# &nbsp;       RIGHT = 3,

# }

# \## 这个常量的描述

# const GRAVITY = 9.8

# \## 这个变量的描述

# var v1

# \## 这是一个多行描述，br是换行符 \[br]

# \## 这是第二行的描述

# var v2: int

# \## 文档注释应该位于注解之前

# \## 这里没有使用换行符，这将与上一行合并

# @export var v3 := some\_func()

# func some\_func() -> int:

# &nbsp;   return 0

# \## 虽然这个方法以下划线开头

# \## 但为其添加文档注释，这样就会让他显示在帮助窗口中

# func \_fn(p1: int, p2: String) -> int:

# &nbsp;   return 0

# \# 下面这个方法以下划线开头

# \# 并且没有为其添加文档注释，因此它不会显示在帮助窗口中

# func \_internal() -> void:

# &nbsp;   pass

# \## 内部类的文档，这会显示在一个独立的文档窗口中

# \##

# \## 类文档描述的规则也适用于这里，

# \## 文档必须位于类定义之前

# \##

# \## @tutorial: https://example.com/tutorial

# \## @experimental

# class Inner:

# &nbsp;   ## 内部类的变量

# &nbsp;   var v4

# &nbsp;   ## 内部类的方法

# &nbsp;   func fn(): pass

# ```

# 

# \## Git Commit Message（提交说明）

# 参见：\[Commit message 和 Change log 编写指南 - 阮一峰的网络日志](https://ruanyifeng.com/blog/2016/01/commit\_message\_change\_log.html)

# 

# 在使用Github进行项目管理时，一个清晰的提交说明能够迅速让组织成员知道你为项目做了什么改动。推荐的提交说明组成：Header，Body 和 Footer。

# 

# > ```Plain

# > <type>(<scope>): <subject>// 空一行

# > <body>// 空一行

# > <footer>

# > ```

# 

# \*\*其中，Header 是必需的，Body 和 Footer 可以省略。\*\*

# 

# 不管是哪一个部分，任何一行都不得超过72个字符（或100个字符）。这是为了避免自动换行影响美观。

# 

# Header部分只有一行，包括三个字段：`type`（必需）、`scope`（可选）和`subject`（必需）。

# 

# \*\*（1）type\*\*

# `type`用于说明 commit 的类别，只允许使用下面7个标识。

# 

# > - feat：新功能（feature）

# > - fix：修补bug

# > - docs：文档（documentation）

# > - style： 格式（不影响代码运行的变动）

# > - refactor：重构（即不是新增功能，也不是修改bug的代码变动）

# > - test：增加测试

# > - chore：构建过程或辅助工具的变动

# 

# 如果`type`为`feat`和`fix`，则该 commit 将肯定出现在 Change log 之中。其他情况（`docs`、`chore`、`style`、`refactor`、`test`）由你决定，要不要放入 Change log，建议是不要。

# 

# \*\*（2）scope\*\*

# `scope`用于说明 commit 影响的范围，比如数据层、控制层、视图层等等，视项目不同而不同。

# 

# \*\*（3）subject\*\*

# `subject`是 commit 目的的简短描述，不超过50个字符。

# 

# > - 以动词开头，使用第一人称现在时，比如`change`，而不是`changed`或`changes`

# > - 第一个字母小写

# > - 结尾不加句号（`.`）

