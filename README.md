# 项目简介
极创组26寒假趣味项目，基于Godot4.4进行开发，现有特性如下：
1. 角色控制系统
	- **移动与机动**：支持角色在四个方向的流畅移动 + 集成疾跑功能
	- **基础战斗**：实现了角色的基础攻击动作与判定
	- **互动系统**：新增互动功能，可通过E键与场景元素交互

2. 敌人与战斗
	- **史莱姆**：可主动追踪并攻击玩家角色
	- **刷怪笼**：可在战斗房间中生成敌人

3. 视觉效果
	- **屏幕特效**：实装了屏幕震动效果，增强战斗与受击的反馈
	- **Y-Sorting**：实现了植被的动态遮挡功能
	- **出生光束特效**：角色出生时的光束动画效果

4. 游戏流程
	- **死亡界面**：加入了角色死亡界面
	- **对话系统**：开发了可显示角色立绘的对话系统
    
5. 游戏世界
	- **主世界地图**：创建了首个可探索的简单地图，添加了碰撞
	- **地牢系统**：实现了可游玩的地牢第一层
		- 程序化生成：可自下而上连接房间生成地图
		- 房间类型：出生房、战斗房、结束房
		- 房间连接：通过门（正面/侧面）进行房间切换

6. 道具系统
	- **宝箱**：可放置于场景中的收集道具
	- **门**：支持正面和侧面两种形态，用于房间连接

截图如下：
主世界探索
![png](preview/1.png)

战斗
![png](preview/2.png)

死亡及对话
![png](preview/3.png)

地牢入口
![png](preview/4.png)

地牢出生房
![png](preview/5.png)

地牢战斗房
![png](preview/6.png)

地牢结束房
![png](preview/7.png)

# 更新日志

## v0.2.0 - 地牢系统上线

### feat: 新增可游玩的地牢（仅实现第一层）
- **地图场景**：新增主世界_地牢入口、地牢_第一层（1个出生房、2个战斗房、1个结束房）
- **程序化生成**：添加简单的程序化生成代码，可自下而上连接房间生成地图
- **实体系统**：
  - 新增宝箱道具
  - 新增刷怪笼，可在战斗房生成敌人
  - 新增门（正面/侧面），用于房间连接
- **特效系统**：新增出生光束特效
- **输入配置**：新增"互动"动作，对应键盘E键

### refactor: 重构项目架构，变量命名规范化
- **脚本目录重构**：创建BaseClass基类目录，集中管理Entity、Character、Enemy、Props、RoomBase等基类
- **场景文件重组**：将角色、敌人、道具等实体场景统一移至实体目录
- **资产目录整理**：将图片资源按用途分类整理（sprite、tileset、立绘等）

## v0.1.0 - 基础系统搭建
- 角色控制系统（移动、疾跑、战斗）
- 史莱姆敌人AI
- 屏幕震动特效
- 死亡界面与对话系统
- 主世界基础地图

# Roadmap
工期问题确实挺重要，还是先做减法，把游戏骨架搭出来为妙，项目一定要先走好才能再跑起来。房间以战斗优先；地图形态：最多9x9方格；基地不做，变成角色选择界面；角色先做UP主和宇航员，一个近战一个远程，写一个Character抽象类维护，派生出Melee和Ranger类；闪避功能可以先做着；理想空壳：**角色战斗中可以复活一次，复活后再死该角色就彻底没了，下一个角色出门就是打同一关，打过了自动把上一个角色空壳捡回来，捡回来之后有两个选择：第一个是给这个角色加强点（也可以有削弱）；第二个就是可以加一点从基地出来带的血包**；物品先做武器，道具不慌；敌人：小怪做4个，BOSS做1个（风力发电机），具体见*附表*；难度默认一个；美术和音乐：AIGC + 已有作品，随缘

附表：
|      |     |          |
| ---- | --- | -------- |
| 类型   | 名称  | 特点       |
| 普通敌人 | 压力  | 近战攻击     |
| 普通敌人 | 冷眼  | 远程攻击     |
| 精英敌人 | 忧愁  | 远程攻击、霰弹  |
| 精英敌人 | 愤怒  | 近战攻击，震荡波 |

# 开发指南
将项目clone至本地，用godot导入即可。本项目采用单例架构开发，将游戏的各个系统抽象为`XxxManager`类，保证它们只被初始化一次，系统说明以及分工如下：

## 系统架构
将项目clone至本地，用godot导入即可。本项目采用单例架构开发，将游戏的各个系统抽象为`XxxManager`类，保证它们只被初始化一次，系统说明以及分工如下：

## 系统架构
1. **游戏顶层系统 GameManager**
	- 预加载/管理游戏场景
	- 维护游戏全局状态机（运行、暂停、菜单、游戏结束）
	- 【暂定】特效控制，例如：镜头晃动、黑屏、闪屏等

2. **事件总线 EventBus**
	- 定义游戏所有信号，负责协调各个Manager之间的通信

3. **地图生成系统 MapManager**
	- 使用噪声算法在网格内生成地牢地图、敌人
	- 管理传送点、隐藏房间和特殊区域

4. **数据系统 StorageManager**
	- 处理游戏配置、存档等数据的保存和加载

5. 音频系统 AudioManager
	- 管理背景音乐、音效和音量设置

6. **战斗系统 BattleManager**
	- 处理伤害计算、命中判定和战斗反馈
	- 管理战斗时的buff

7. 对话系统 DialogManager
	- 管理游戏对话
	- 支持加载本地对话文件
  
8. UI系统 UIManager
	- 更新所有游戏界面：HUD（血条、蓝条）、暂停菜单、道具栏、升级选择界面

9. ~~场景管理系统 SceneManager~~
	*合并至GameManager里*
	- 管理游戏场景的加载、切换和卸载（如：标题、地牢、商店、战斗房间）
	- 处理场景间的过渡和通信

10. ~~道具系统 ItemManager~~
	- 管理玩家的属性和状态变化
	- 处理道具的获取、使用和效果
	- 管理物品栏和装备系统

| 系统                      | 负责人 | 备注  |
| ----------------------- | --- | --- |
| **游戏顶层系统 GameManager**  | 全员  |     |
| **事件总线 EventBus**       | 全员  |     |
| **地图生成系统 MapManager**   | 灵梦子  |     |
| **数据系统 StorageManager** | 金元宝  |     |
| 音频系统 AudioManager       | zhcommander  |     |
| **战斗系统 BattleManager**  | miku  |     |
| 对话系统 DialogManager      | Essenpphire  |     |

**注意遵循开发规范，利好你我他~**

# 项目结构
```bash
├─Scenes # 存放godot单个场景树(*.tscn)
│  ├─UI              # 界面场景
│  ├─地图            # 地图场景（主世界、地牢各层及房间）
│  ├─实体            # 实体场景（角色、敌人、道具等）
│  ├─Prop            # 道具场景（宝箱、门等）
│  ├─特效            # 特效场景（出生光束等）
│  └─Template        # 场景模板
├─Scripts # 存放项目脚本
│  ├─单例            # 单例Manager脚本
│  ├─BaseClass       # 基类脚本（Entity、Character、Enemy、Player、Props、RoomBase、Vfx等）
│  ├─实体            # 实体脚本
│  ├─房间            # 房间脚本（RoomBattle、RoomSpawn、RoomEnd等）
│  ├─Props           # 道具脚本（宝箱、门、刷怪笼等）
│  └─特效            # 特效脚本
└─Assets # 存放godot专有资源
    ├─shader          # 着色器
    ├─sprite_frame    # 精灵帧动画
    ├─theme           # UI主题
    ├─tileset         # 瓦片集
    ├─图片            # 图片资源
    │  ├─tileset      # 瓦片集图片
    │  ├─sprite       # 精灵图片
    │  ├─立绘         # 角色立绘
    │  └─幻想人形演舞AP立绘
    └─字体            # 字体文件
```

# 开发规范
## 命名
- 变量：小写下划线命名法 `snake_case`，标出变量类型，示例如下：
```gdscript
@export var WALK_SPEED : float = 200.0
@export var RUN_SPEED : float = 400.0
var facing : String = "down"	
var isWalking : bool = false
```
- 常量：大写下划线命名法`RUN_SPEED`
- 函数：小驼峰命名法 `lowerCamelCase`，标出返回值，示例如下：
```gdscript
func handleAttack() -> void:
        if Input.is_action_just_pressed("攻击") and !isDead:
                if !isAttacking:
                        GameManager.cameraShake(5.0)
                isAttacking = true
                if enemy and enemy.STATE.isHurting == false:
                        enemy.STATE.isHurting = true
                        enemy.received_damage = self.ATK
```

- 对象内置属性：需在前方加上`self.`，与自定义属性区分，示例如下：
```gdscript
# CharacterBody2D - 主角v1.gd
	if direction and !isAttacking and !isDead:
		isWalking = true
		self.velocity = (RUN_SPEED if Input.is_action_pressed("奔跑") else WALK_SPEED) * direction

```

- 类的私有属性：考虑到godot没有private概念，统一用下划线开头，例如：`_id`

- *信号*：小写下划线命名法，由Manager调用，故需添加对应Manager的前缀，此后采用`主语_谓语`形式命名，示例：`battle_entity_damage`, `ui_update_hud`, `audio_sound_play`

## 注释（可选）
遵循Godot官方文档注释，参见：[文档注释 | GDScript教程](https://godothub.com/oss/gdscript-tutorial/12.doc-comments.html)
```gdscript
## 简单的描述一下这个类的功能和作用
##
## 说明一下这个类可以做什么，以及它的任何其他细节
##
## @tutorial:        https://example.com/tutorial_1
## @tutorial(教程 2): https://example.com/tutorial_2
## @experimental
extends Node2D
## 这个信号的描述
signal my_signal
## 这个枚举的描述
enum Direction {
        ## 方向 上
        UP = 0,
        ## 方向 下
        DOWN = 1,
        ## 方向 左
        LEFT = 2,
        ## 方向 右
        RIGHT = 3,
}
## 这个常量的描述
const GRAVITY = 9.8
## 这个变量的描述
var v1
## 这是一个多行描述，br是换行符 [br]
## 这是第二行的描述
var v2: int
## 文档注释应该位于注解之前
## 这里没有使用换行符，这将与上一行合并
@export var v3 := some_func()
func some_func() -> int:
    return 0
## 虽然这个方法以下划线开头
## 但为其添加文档注释，这样就会让他显示在帮助窗口中
func _fn(p1: int, p2: String) -> int:
    return 0
# 下面这个方法以下划线开头
# 并且没有为其添加文档注释，因此它不会显示在帮助窗口中
func _internal() -> void:
    pass
## 内部类的文档，这会显示在一个独立的文档窗口中
##
## 类文档描述的规则也适用于这里，
## 文档必须位于类定义之前
##
## @tutorial: https://example.com/tutorial
## @experimental
class Inner:
    ## 内部类的变量
    var v4
    ## 内部类的方法
    func fn(): pass
```

## Git Commit Message（提交说明）
参见：[Commit message 和 Change log 编写指南 - 阮一峰的网络日志](https://ruanyifeng.com/blog/2016/01/commit_message_change_log.html)

在使用Github进行项目管理时，一个清晰的提交说明能够迅速让组织成员知道你为项目做了什么改动。推荐的提交说明组成：Header，Body 和 Footer。

> ```Plain
> <type>(<scope>): <subject>// 空一行
> <body>// 空一行
> <footer>
> ```

**其中，Header 是必需的，Body 和 Footer 可以省略。**

不管是哪一个部分，任何一行都不得超过72个字符（或100个字符）。这是为了避免自动换行影响美观。

Header部分只有一行，包括三个字段：`type`（必需）、`scope`（可选）和`subject`（必需）。

**（1）type**
`type`用于说明 commit 的类别，只允许使用下面7个标识。

> - feat：新功能（feature）
> - fix：修补bug
> - docs：文档（documentation）
> - style： 格式（不影响代码运行的变动）
> - refactor：重构（即不是新增功能，也不是修改bug的代码变动）
> - test：增加测试
> - chore：构建过程或辅助工具的变动

如果`type`为`feat`和`fix`，则该 commit 将肯定出现在 Change log 之中。其他情况（`docs`、`chore`、`style`、`refactor`、`test`）由你决定，要不要放入 Change log，建议是不要。

**（2）scope**
`scope`用于说明 commit 影响的范围，比如数据层、控制层、视图层等等，视项目不同而不同。

**（3）subject**
`subject`是 commit 目的的简短描述，不超过50个字符。

> - 以动词开头，使用第一人称现在时，比如`change`，而不是`changed`或`changes`
> - 第一个字母小写
> - 结尾不加句号（`.`）
