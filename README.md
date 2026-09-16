# TarotAgentPet

帮我# ARCANA 黑客松 B｜桌宠整合版

这是一个 Vite + FastAPI 的 AI 塔罗网站。本版本在 Chrome 稳定版基础上整合了网页塔罗猫与独立 Windows 桌宠、站内对话、账号和个人占卜档案。

## 已包含功能

- 稳定的响应式首页与 88px 桌面导航，不再使用巨型滚动场景或 Canvas 星空。
- 更克制的黑色书册视觉，取消大面积金色渐变、胶囊按钮和产品宣传式表达。
- 中、英、日三语界面切换，并在浏览器中记住语言偏好。
- 所有页面都带有塔罗猫桌宠：单击会回应，闲置会休息，双击只打开站内对话框，不会跳转到外部智能体页面。
- 桌宠问答通过 FastAPI 的 `/api/pet/mind` 接口工作；每个问题只向一个 Minds Mind 发出一次无历史请求，同时返回回应、关键词和单牌简析。
- 22 张大阿卡那牌义图鉴，可搜索并查看正位、逆位三语释义；图鉴与抽牌结果共用同一套本地牌面图片。
- 首页卡面、中心眼睛和星轨会随鼠标产生带缓动的 3D 空间视差。
- 抽牌区使用扇形/百叶式展开，中央发光虚框是固定选牌位；鼠标、触屏、键盘和摄像头手势都会让牌组从虚框中滑过。
- 恢复摄像头手势选牌：左右移动食指让目标牌滑入发光虚框，张开手掌并保持约 0.9 秒确认；也保留点击操作。
- 抽牌页只负责提问与选择牌面；完成后跳转到独立的 `result.html`。
- 结果页改用类似演示文稿文字浮现的遮罩、模糊消散和轻微上移动画，并支持减少动态效果设置。
- 可注册、登录和退出，密码使用 PBKDF2 加盐哈希保存。
- 登录用户可以保存、查看和删除自己的占卜记录。
- SQLite 本地数据库，无需另外安装数据库服务。
- 未配置在线模型时自动使用本地基础解读。

## 一键运行（Windows）

1. 解压整个项目，目录结构不要打散。
2. 首次使用双击 `setup.bat`，等待依赖安装和前端构建完成。
3. 双击 `start.bat`，网站和独立 Windows 桌宠会一起启动。
4. 浏览器打开 <http://127.0.0.1:5174/>。

保持启动窗口开启，按 `Ctrl+C` 会停止前后端。


## 独立 Windows 桌宠

- 桌宠是独立窗口，不依赖浏览器标签页；也可以只双击 `desktop-pet.bat` 启动。
- 按住桌宠拖动可改变桌面位置；位置保存在本机，下次启动会自动恢复。
- 右键桌宠可切换“锁定位置”和“始终置顶”，也可让它回到右下角、打开网站或退出。
- 桌宠采用组员提供的 67 帧精细 GIF：休息时保持精细形象，进入好奇、对话或等待回复状态时播放动画；网页内桌宠同步使用该动画。
- 单击桌宠会展开一个小型、低干扰对话框。问她问题后，桌宠会提取关键词，小猫本体沿 Y 轴翻转成一张真实塔罗牌，并显示简短解读；约 8 秒后翻回小猫。
- 桌面对话框内可切换 `中 / EN / 日`，界面文案、请求语言、本地备用回复和在线回复都会跟随当前语言，并在下次启动时保留选择。
- 问答调用 `/api/pet/mind`，手动“抽一张”仍调用 `/api/pet/draw`；后端或 Minds 临时不可用时会自动使用三语本地回复和本地抽牌。
- 独立桌宠代码位于 `desktop_pet/arcana_desktop_pet.py`，位置设置保存在 `%LOCALAPPDATA%\ArcanaMuse\desktop-pet.json`。

## 网页内桌宠

- 单击桌宠：触发亲近回应与状态动画。
- 双击桌宠：打开当前网页内的对话框。
- 鼠标悬停：切换好奇状态；长时间无操作会进入休息状态。
- 对话会在当前浏览器标签页会话中保留，切换首页、牌义图鉴、结果页和个人档案时不会立即丢失。
- 中、英、日语言切换会同步更新桌宠名称、提示、快捷问题和输入区域。
- 四种状态素材位于 `frontend/public/assets/pet`，组件代码位于 `frontend/pet.js` 与 `frontend/pet.css`。

桌宠不会打开外部智能体页面。Minds 调用只发生在本机 FastAPI 后端，API Key 不会发送到网页或桌宠窗口。

独立 Windows 桌宠模仿的是轻量桌面助手的交互方式，不会接管或冒充 Codex；它只调用当前 ARCANA 的塔罗接口。

## Chrome 显示与摄像头

- 如果页面整体异常偏小，先按 `Ctrl+0` 把当前站点恢复到 100% 缩放。Chrome 会为每个站点单独记住缩放比例，之前调到 50% 时，导航和固定最大宽度都会一起缩小。
- 页面检测到疑似低缩放时会在底部显示提示，但网页本身不能替浏览器修改缩放设置。
- 点击“以手势选牌”后，在 Chrome 地址栏左侧的权限菜单中允许使用摄像头。
- 摄像头画面只在当前浏览器中交给本地 MediaPipe 模型识别，不会由本项目上传；停止手势或离开页面会关闭视频轨道。
- 手势模型运行文件已经包含在 `frontend/public/vendor/mediapipe`，牌面位于 `frontend/public/assets/cards`。

## 可选：接入 Minds Mind

最简单的方法是双击项目根目录的 `configure-mind.bat`，按提示粘贴 API Key 和 Mind Spark ID，然后关闭旧的启动窗口并重新双击 `start.bat`。

编辑 `agent/.env`：

```dotenv
MINDS_API_KEY=你的_minds_API_Key
MINDS_SPARK_ID=0582483e-f36b-1410-8466-00039ce7df11
MINDS_API_BASE=https://api.build.hellominds.ai
DEEPSEEK_API_KEY=你的_API_Key
ARCANA_DB_PATH=arcana.db
```

`MINDS_SPARK_ID` 已固定为你在 Hellominds 创建的 TARO Mind。每次提问都会创建一个独立 conversation，不发送之前的聊天记录。`DEEPSEEK_API_KEY` 只作为其他网站解读的可选在线模型。没有填写 `MINDS_API_KEY` 时仍可正常抽牌、使用桌宠、注册、登录和保存记录；桌宠会自动使用内置三语回复。请勿分享包含真实 Key 的 `.env`。

## 数据位置

本地用户与占卜记录默认保存在 `agent/arcana.db`。这个文件不包含在发布压缩包中，第一次启动后自动创建。

当前实现适合黑客松演示或个人本机使用。如果部署到无持久磁盘的云平台，应把 SQLite 替换为 PostgreSQL、Supabase 等持久数据库，并将允许跨域的来源改为实际域名。

## 手动启动

```powershell
cd agent
python -m venv .venv
& ".\.venv\Scripts\python.exe" -m pip install -r requirements.txt
& ".\.venv\Scripts\python.exe" -m uvicorn main:app --host 127.0.0.1 --port 8010
```

另开一个 PowerShell：

```powershell
cd frontend
npm install
npm run dev -- --host 127.0.0.1 --port 5174
```

再开一个 PowerShell 可单独启动桌宠：

```powershell
.\desktop-pet.ps1
```

## 验证

```powershell
cd agent
& ".\.venv\Scripts\python.exe" -m unittest discover -s tests -v

cd frontend
npm test
npm run build
npm run test:e2e
```

`test:e2e` 需要本机安装 Chrome，且前后端已分别运行在 `5174` 和 `8010` 端口。

## 牌面素材

本项目使用公共领域的 Rider–Waite–Smith 大阿卡那牌面。素材保存在项目内部，页面运行时不需要再向图片站点请求。
  
