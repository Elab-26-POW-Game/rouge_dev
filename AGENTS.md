# AGENTS.md - 项目上下文文档

## 项目概述

**项目名称**: rouge_dev  
**项目类型**: Godot 4.4 肉鸽类游戏  
**开发团队**: 极创组26（寒假趣味项目）  
**项目状态**: 开发中（模板代码尚未完善）

**核心特性**:
- 角色控制系统（四方向移动 + 疾跑）
- 基础战斗系统（攻击动作、伤害判定）
- 敌人AI（史莱姆主动追踪和攻击）
- 视觉效果（屏幕震动、Y-Sorting植被遮挡）
- 游戏流程（死亡界面、对话系统）
- 主世界地图（碰撞检测、简单探索）

**游戏架构**:
- **地图形态**: 最多9x9方格
- **角色系统**: 基于Character抽象类的派生系统（Melee近战、Ranger远程）
- **角色选择**: UP主和宇航员（近战/远程）
- **复活机制**: 每个角色战斗中可复活一次，复活后死亡则彻底消失
- **物品系统**: 武器优先，道具暂缓
- **敌人系统**: 4种小怪 + 1个BOSS（风力发电机）
- **难度**: 默认一个难度

---

## 技术栈

- **引擎**: Godot 4.4
- **编程语言**: GDScript
- **架构模式**: 单例模式 + 事件总线
- **输入控制**: Godot输入映射系统
- **渲染**: Forward Plus

---

## 项目结构

```
E:\game_dev\godot\rouge_dev\
├── 场景/              # Godot场景文件 (*.tscn)
│   ├── 地图/          # 游戏地图场景
│   ├── 实体/          # 角色、敌人等实体场景
│   └── ui/            # 用户界面场景
├── 脚本/              # GDScript脚本
│   ├── 单例/          # 全局管理器单例
│   ├── 实体/          # 角色和敌人逻辑
│   └── 特效/          # 视觉特效脚本
├── 资产/              # Godot资源文件
│   ├── 图片/          # 精灵图、立绘、UI素材
│   ├── 字体/          # 游戏字体
│   ├── shader/        # 着色器代码
│   ├── sprite_frame/  # 精灵帧动画
│   ├── theme/         # UI主题
│   ├── tileset/       # 地图瓦片集
│   └── 对话/          # 对话数据
└── 数据/              # 游戏数据文件
```

---

## 核心系统架构

### 1. 单例系统

项目采用单例架构模式，将游戏各个系统抽象为 `XxxManager` 类：

| 系统 | 路径 | 职责 | 负责人 |
|------|------|------|--------|
| **GameManager** | `脚本/单例/GameManager.gd` | 游戏顶层系统，场景切换、全局状态机、特效控制 | 全员 |
| **EventBus** | `脚本/单例/EventBus.gd` | 事件总线，管理所有系统间通信的信号 | 全员 |
| **BattleManager** | `脚本/单例/BattleManager.gd` | 战斗系统，伤害计算、命中判定、Buff管理 | miku |
| **StorageManager** | `脚本/单例/StorageManager.gd` | 数据系统，配置、存档保存和加载 | 金元宝 |
| **DialogManager** | `脚本/单例/DialogManager.gd` | 对话系统，游戏对话管理和显示 | Essenpphire |
| **Debug** | `脚本/单例/Debug.gd` | 调试工具，日志输出和警告 | 全员 |

**待实现系统**:
- **MapManager** (灵梦子): 地图生成系统
- **AudioManager** (zhcommander): 音频系统
- **UIManager**: UI界面更新

### 2. 实体系统

所有游戏实体都继承自基础类：

```
Entity (CharacterBody2D) - 所有实体的基类
├── 主角.gd - 主角控制脚本
├── Chracter.gd - 角色基类
└── Enemy.gd - 敌人逻辑
```

**核心属性**:
- `hp`: 生命值
- `atk`: 攻击力
- `move_speed`: 移动速度
- `state`: 状态字典 (is_walking, is_attacking, is_hurting, is_dead)

**核心方法**:
- `changeAnimation()`: 切换动画
- `handleMove()`: 处理四方向移动
- `handleAttack()`: 处理攻击逻辑
- `handleHurt()`: 处理受伤逻辑
- `handleDeath()`: 处理死亡逻辑

### 3. 事件总线系统

**命名规范**: `小写下划线命名法`，格式为 `manager_主语_谓语`

**已定义的信号**:
```gdscript
# 效果信号
signal game_camera_shake(amount: float)  # 相机抖动

# 战斗信号
signal battle_entity_damaged(entity: Node, source: Node, damage: float, is_critical: bool)
signal battle_entity_died(entity: Node, killer: Node)
signal battle_buff_applied(entity: Node, buff_data: Dictionary)
signal battle_buff_removed(entity: Node, buff_type: String)
signal battle_enemy_entered_combat(enemy: Node)
signal battle_enemy_exited_combat(enemy: Node)

# 储存信号
signal storage_load_data(data: Dictionary)
signal storage_save_data(data: Dictionary)
signal storage_clear_data(data: Dictionary)
```

**使用方式**:
1. 在 `EventBus.gd` 中定义信号
2. 在Manager中通过 `EventBus.<信号名>.emit()` 激活信号
3. 在相应脚本中通过 `func _on_Eventbus_<信号名>()` 监听信号

### 4. 输入系统

**已配置的输入动作**:
- `向上移动`: W / 上箭头
- `向下移动`: S / 下箭头
- `向左移动`: A / 左箭头
- `向右移动`: D / 右箭头
- `奔跑`: Shift
- `攻击`: Z

---

## 开发规范

### 命名规范

- **变量**: 小写下划线命名法 `snake_case`
  ```gdscript
  var move_speed = 200.0
  var is_attacking = false
  ```

- **常量**: 大写下划线命名法 `UPPER_SNAKE_CASE`
  ```gdscript
  const RUN_SPEED = 400.0
  const WALK_SPEED = 200.0
  ```

- **函数**: 小驼峰命名法 `lowerCamelCase`，必须标出返回值
  ```gdscript
  func handleAttack() -> void:
      if Input.is_action_just_pressed("攻击") and !isDead:
          # 实现逻辑
  ```

- **对象内置属性**: 必须在前方加上 `self.`
  ```gdscript
  self.velocity = direction * speed
  ```

### 注释规范

遵循Godot官方文档注释规范，使用 `##` 进行文档注释：

```gdscript
## 简要描述类的功能
##
## 详细说明类的用途和功能
##
## @tutorial: https://example.com/tutorial
extends Node2D

## 信号的描述
signal my_signal

## 枚举的描述
enum Direction {
    ## 方向向上
    UP = 0,
    ## 方向向下
    DOWN = 1
}

## 常量的描述
const GRAVITY = 9.8

## 变量的描述
var player_hp: float = 100.0

## 方法的描述
## @param p1 参数1的描述
## @return 返回值的描述
func some_func(p1: int) -> int:
    return 0
```

### Git Commit Message 规范

遵循 [Conventional Commits](https://www.conventionalcommits.org/) 规范：

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Type 类型**:
- `feat`: 新功能
- `fix`: 修复bug
- `docs`: 文档
- `style`: 格式调整
- `refactor`: 重构
- `test`: 测试
- `chore`: 构建工具或辅助工具变动

**示例**:
```
feat(battle): 添加暴击伤害计算系统

实现了暴击率和暴击倍率的计算逻辑，支持通过Buff系统动态调整暴击属性

Closes #123
```

---

## 构建和运行

### 环境要求

- **Godot Engine**: 4.4 或更高版本
- **操作系统**: Windows 10/11 (当前开发环境)

### 运行项目

1. 使用 Godot 4.4 打开项目目录 `E:\game_dev\godot\rouge_dev`
2. 点击编辑器右上角的"运行"按钮或按 `F5`
3. 主场景: `uid://bgnoenp68ijnh` (在 `project.godot` 中配置)

### 导入项目

```bash
git clone https://github.com/Elab-26-POW-Game/rouge_dev.git
```

然后使用 Godot 导入项目文件夹。

---

## 开发指南

### 添加新角色

1. 创建角色场景文件 (继承自 `CharacterBody2D`)
2. 创建角色脚本 (继承自 `Character` 或 `Entity`)
3. 实现必要的方法:
   - `handleMove()`: 移动逻辑
   - `handleAttack()`: 攻击逻辑
   - `handleHurt()`: 受伤逻辑
   - `handleDeath()`: 死亡逻辑
4. 配置动画和精灵
5. 将角色添加到相应的全局组 (`Player` 或 `Enemy`)

### 添加新敌人

1. 创建敌人场景文件
2. 创建敌人脚本 (继承自 `Entity`)
3. 实现AI逻辑:
   - 追踪玩家
   - 攻击判定
   - 状态管理
4. 配置属性和动画
5. 在 `BattleManager` 中注册敌人

### 实现新Buff

1. 在 `BattleManager.gd` 的 `_apply_damage_modifier()` 中添加Buff逻辑
2. 通过 `BattleManager.apply_buff()` 应用Buff
3. 通过 `BattleManager.remove_buff()` 移除Buff
4. 监听 `EventBus.battle_buff_applied` 和 `EventBus.battle_buff_removed` 信号

### 添加新对话

1. 在 `资产/对话/` 目录下创建对话数据文件
2. 使用 `DialogManager.showDialogs()` 显示对话
3. 配置角色立绘和文本内容

---

## 已知问题和待办事项

### 待实现功能

- [ ] **MapManager**: 地图生成系统（灵梦子）
- [ ] **AudioManager**: 音频系统（zhcommander）
- [ ] **UIManager**: UI界面更新系统
- [ ] 角色选择界面
- [ ] 物品/道具系统
- [ ] 更多敌人类型（压力、冷眼、忧愁、愤怒）
- [ ] BOSS系统（风力发电机）
- [ ] 存档系统完善

### 技术债务

- 存档系统需要确定保存和加载的时机
- 角色复活机制需要详细设计
- 部分单例系统功能尚未完善

---

## 游戏设计参考

### 敌人类型

| 类型 | 名称 | 特点 |
|------|------|------|
| 普通敌人 | 压力 | 近战攻击 |
| 普通敌人 | 冷眼 | 远程攻击 |
| 精英敌人 | 忧愁 | 远程攻击、霰弹 |
| 精英敌人 | 愤怒 | 近战攻击，震荡波 |
| BOSS | 风力发电机 | 待设计 |

### 开发理念

> "工期问题确实挺重要，还是先做减法，把游戏骨架搭出来为妙，项目一定要先走好才能再跑起来。"

**开发原则**:
1. 优先实现核心战斗系统
2. 地图形态简化为9x9方格
3. 基地改为角色选择界面
4. 物品系统先实现武器
5. 美术和音乐使用AIGC + 已有作品

---

## 联系方式

- **项目仓库**: https://github.com/Elab-26-POW-Game/rouge_dev.git
- **开发团队**: 极创组26

---

## 附录

### 参考资源

- [Godot官方文档](https://docs.godotengine.org/)
- [GDScript教程](https://godothub.com/oss/gdscript-tutorial/)
- [Commit message 编写指南](https://ruanyifeng.com/blog/2016/01/commit_message_change_log.html)

### 项目截图

游戏预览截图位于 `preview/` 目录:
- `1.png`: 游戏主界面
- `2.png`: 战斗场景
- `3.png`: 死亡及对话系统

---

*最后更新: 2026年2月15日*